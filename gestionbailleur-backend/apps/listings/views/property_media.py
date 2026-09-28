import os
from django.db import transaction
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes, parser_classes
from rest_framework.parsers import MultiPartParser, FormParser, JSONParser
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema

from ..models import Property, PropertyMedia
from ..serializers import PropertyMediaSerializer
from ..services import upload_property_media, delete_cloudinary_media

ALLOWED_IMAGE_EXTS = {'.jpg', '.jpeg', '.png', '.webp'}
ALLOWED_VIDEO_EXTS = {'.mp4', '.mov'}
MAX_IMAGE_SIZE = 10 * 1024 * 1024  # 10 MB
MAX_VIDEO_SIZE = 100 * 1024 * 1024  # 100 MB


def check_landlord_permission(request, property_id):
    """
    Vérifie l'authentification, le compte actif et la propriété du logement.
    """
    try:
        prop = Property.objects.get(id=property_id, is_deleted=False)
    except Property.DoesNotExist:
        return None, Response({'error': 'Logement non trouvé'}, status=status.HTTP_404_NOT_FOUND)

    if prop.landlord != request.user:
        return None, Response(
            {'error': 'Vous n\'êtes pas autorisé à modifier les médias de ce logement'},
            status=status.HTTP_403_FORBIDDEN
        )

    if getattr(request.user, 'etat_compte', 'ACTIF') != 'ACTIF':
        return None, Response(
            {'error': 'Votre compte doit être approuvé par l\'administrateur'},
            status=status.HTTP_403_FORBIDDEN
        )

    return prop, None


@extend_schema(
    tags=['Médias Logement'],
    summary='Téléverser des médias pour un logement',
    description='Envoie un ou plusieurs fichiers images ou vidéos à Cloudinary et enregistre les métadonnées dans PostgreSQL.',
    responses={201: PropertyMediaSerializer(many=True)},
)
@api_view(['POST'])
@permission_classes([IsAuthenticated])
@parser_classes([MultiPartParser, FormParser])
def property_media_upload_view(request, property_id):
    prop, err_resp = check_landlord_permission(request, property_id)
    if err_resp:
        return err_resp

    files = request.FILES.getlist('files') or request.FILES.getlist('file')
    if not files and 'file' in request.FILES:
        files = [request.FILES['file']]

    if not files:
        return Response({'error': 'Aucun fichier fourni'}, status=status.HTTP_400_BAD_REQUEST)

    created_media_list = []
    
    # Obtenir l'ordre actuel maximum
    current_max_order = PropertyMedia.objects.filter(
        property=prop,
        is_deleted=False
    ).count()

    for idx, uploaded_file in enumerate(files):
        filename = uploaded_file.name.lower()
        ext = os.path.splitext(filename)[1]
        
        if ext in ALLOWED_IMAGE_EXTS:
            resource_type = 'image'
            max_size = MAX_IMAGE_SIZE
        elif ext in ALLOWED_VIDEO_EXTS:
            resource_type = 'video'
            max_size = MAX_VIDEO_SIZE
        else:
            return Response(
                {'error': f"Format de fichier non supporté pour {uploaded_file.name}. Extensions acceptées: JPG, PNG, WEBP, MP4, MOV"},
                status=status.HTTP_400_BAD_REQUEST
            )

        if uploaded_file.size > max_size:
            max_mb = max_size // (1024 * 1024)
            return Response(
                {'error': f"Le fichier {uploaded_file.name} dépasse la taille maximale autorisée de {max_mb}MB"},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Téléversement réel sur Cloudinary
        try:
            cloud_res = upload_property_media(
                file_obj=uploaded_file,
                property_id=prop.id,
                resource_type=resource_type
            )
        except Exception as e:
            return Response(
                {'error': f"Échec de l'envoi du fichier {uploaded_file.name} vers Cloudinary: {str(e)}"},
                status=status.HTTP_502_BAD_GATEWAY
            )

        # Enregistrement dans PostgreSQL avec stratégie de rollback en cas d'échec
        try:
            with transaction.atomic():
                has_existing_primary = PropertyMedia.objects.filter(
                    property=prop,
                    is_primary=True,
                    is_deleted=False
                ).exists()

                is_primary = False
                if resource_type == 'image' and not has_existing_primary and idx == 0:
                    is_primary = True

                media_obj = PropertyMedia.objects.create(
                    property=prop,
                    cloudinary_public_id=cloud_res['public_id'],
                    secure_url=cloud_res['secure_url'],
                    resource_type=resource_type,
                    format=cloud_res.get('format', ''),
                    width=cloud_res.get('width'),
                    height=cloud_res.get('height'),
                    duration=cloud_res.get('duration'),
                    file_size=cloud_res.get('bytes'),
                    order=current_max_order + idx + 1,
                    is_primary=is_primary
                )
                created_media_list.append(media_obj)
        except Exception as db_err:
            # Nettoyage Cloudinary d'urgence pour éviter les fichiers orphelins
            delete_cloudinary_media(cloud_res['public_id'], resource_type=resource_type)
            return Response(
                {'error': f"Erreur d'enregistrement PostgreSQL pour {uploaded_file.name}. Le fichier Cloudinary a été nettoyé: {str(db_err)}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    serializer = PropertyMediaSerializer(created_media_list, many=True)
    return Response(serializer.data, status=status.HTTP_201_CREATED)


@extend_schema(
    tags=['Médias Logement'],
    summary='Supprimer un média de logement',
    description='Supprime le fichier de Cloudinary et supprime la référence dans PostgreSQL.',
    responses={204: None},
)
@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def property_media_delete_view(request, property_id, media_id):
    prop, err_resp = check_landlord_permission(request, property_id)
    if err_resp:
        return err_resp

    try:
        media = PropertyMedia.objects.get(id=media_id, property=prop, is_deleted=False)
    except PropertyMedia.DoesNotExist:
        return Response({'error': 'Média non trouvé'}, status=status.HTTP_404_NOT_FOUND)

    was_primary = media.is_primary
    public_id = media.cloudinary_public_id
    resource_type = media.resource_type

    # Suppression Cloudinary en premier
    try:
        delete_cloudinary_media(public_id, resource_type=resource_type)
    except Exception as e:
        return Response(
            {'error': f"Impossible de supprimer le fichier Cloudinary: {str(e)}"},
            status=status.HTTP_502_BAD_GATEWAY
        )

    # Suppression DB
    media.delete()

    # Si c'était l'image principale, désigner la suivante si disponible
    if was_primary:
        next_image = PropertyMedia.objects.filter(
            property=prop,
            resource_type='image',
            is_deleted=False
        ).order_by('order', 'created_at').first()

        if next_image:
            next_image.is_primary = True
            next_image.save()
        else:
            prop.main_photo = None
            prop.save(update_fields=['main_photo'])

    return Response(status=status.HTTP_204_NO_CONTENT)


@extend_schema(
    tags=['Médias Logement'],
    summary='Définir l\'image principale',
    description='Définit le média sélectionné comme média/photo principal.',
    responses={200: PropertyMediaSerializer},
)
@api_view(['PATCH', 'POST'])
@permission_classes([IsAuthenticated])
def property_media_set_primary_view(request, property_id, media_id):
    prop, err_resp = check_landlord_permission(request, property_id)
    if err_resp:
        return err_resp

    try:
        media = PropertyMedia.objects.get(id=media_id, property=prop, is_deleted=False)
    except PropertyMedia.DoesNotExist:
        return Response({'error': 'Média non trouvé'}, status=status.HTTP_404_NOT_FOUND)

    media.is_primary = True
    media.save()

    return Response(PropertyMediaSerializer(media).data, status=status.HTTP_200_OK)


@extend_schema(
    tags=['Médias Logement'],
    summary='Réordonner les médias d\'un logement',
    description='Met à jour l\'ordre d\'affichage des médias à partir d\'une liste d\'objets [{id, order}].',
    responses={200: PropertyMediaSerializer(many=True)},
)
@api_view(['PATCH', 'POST'])
@permission_classes([IsAuthenticated])
@parser_classes([JSONParser])
def property_media_reorder_view(request, property_id):
    prop, err_resp = check_landlord_permission(request, property_id)
    if err_resp:
        return err_resp

    items = request.data.get('items') or request.data.get('orders')
    if not isinstance(items, list):
        return Response({'error': 'Le corps de la requête doit contenir un tableau "items"'}, status=status.HTTP_400_BAD_REQUEST)

    updated_ids = []
    with transaction.atomic():
        for item in items:
            media_id = item.get('id')
            order_val = item.get('order')
            if media_id and order_val is not None:
                PropertyMedia.objects.filter(id=media_id, property=prop).update(order=int(order_val))
                updated_ids.append(media_id)

    all_media = PropertyMedia.objects.filter(property=prop, is_deleted=False).order_by('order', 'created_at')
    return Response(PropertyMediaSerializer(all_media, many=True).data, status=status.HTTP_200_OK)
