import os
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes, parser_classes
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema

from ..models import UserProfile
from apps.listings.services import upload_profile_photo, delete_cloudinary_media

ALLOWED_IMAGE_EXTS = {'.jpg', '.jpeg', '.png', '.webp'}
MAX_IMAGE_SIZE = 10 * 1024 * 1024  # 10 MB


def get_or_create_profile(user):
    profile, _ = UserProfile.objects.get_or_create(user=user)
    return profile


@extend_schema(
    tags=['Profil Utilisateur'],
    summary='Obtenir son profil utilisateur',
    description='Récupère les informations du profil utilisateur connecté.',
)
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def user_profile_me_view(request):
    profile = get_or_create_profile(request.user)
    
    # Récupérer le rôle de l'utilisateur
    user_role = request.user.roles.filter(actif=True, is_deleted=False).first()
    role_data = None
    if user_role:
        role_data = {
            'code': user_role.role.code,
            'nom': user_role.role.nom,
        }
    
    return Response({
        'user_id': str(request.user.id),
        'email': request.user.email,
        'nom': request.user.nom if hasattr(request.user, 'nom') else '',
        'prenom': request.user.prenom if hasattr(request.user, 'prenom') else '',
        'photo': profile.photo,
        'photo_cloudinary_public_id': profile.photo_cloudinary_public_id,
        'biographie': profile.biographie,
        'profession': profile.profession,
        'nationalite': profile.nationalite,
        'langue': profile.langue,
        'etat_profil': profile.etat_profil,
        'role': role_data,
        'etat_compte': request.user.etat_compte if hasattr(request.user, 'etat_compte') else 'EN_ATTENTE',
        'email_verifie': request.user.email_verifie if hasattr(request.user, 'email_verifie') else False,
        'telephone_verifie': request.user.telephone_verifie if hasattr(request.user, 'telephone_verifie') else False,
        'created_at': request.user.created_at.isoformat() if hasattr(request.user, 'created_at') else None,
        'derniere_connexion': request.user.derniere_connexion.isoformat() if hasattr(request.user, 'derniere_connexion') else None,
    }, status=status.HTTP_200_OK)


@extend_schema(
    tags=['Profil Utilisateur'],
    summary='Téléverser la photo de profil',
    description='Téléverse une photo de profil vers Cloudinary et enregistre son URL dans PostgreSQL.',
)
@api_view(['POST'])
@permission_classes([IsAuthenticated])
@parser_classes([MultiPartParser, FormParser])
def user_profile_photo_upload_view(request):
    file_obj = request.FILES.get('photo') or request.FILES.get('file')
    if not file_obj:
        return Response({'error': 'Aucun fichier photo fourni'}, status=status.HTTP_400_BAD_REQUEST)

    filename = file_obj.name.lower()
    ext = os.path.splitext(filename)[1]
    if ext not in ALLOWED_IMAGE_EXTS:
        return Response(
            {'error': 'Format de photo non supporté. Extensions acceptées: JPG, PNG, WEBP'},
            status=status.HTTP_400_BAD_REQUEST
        )

    if file_obj.size > MAX_IMAGE_SIZE:
        return Response(
            {'error': 'La photo dépasse la taille maximale autorisée (10MB)'},
            status=status.HTTP_400_BAD_REQUEST
        )

    profile = get_or_create_profile(request.user)

    # Supprimer l'ancienne photo Cloudinary si elle existe
    if profile.photo_cloudinary_public_id:
        try:
            delete_cloudinary_media(profile.photo_cloudinary_public_id, resource_type='image')
        except Exception:
            pass  # Poursuivre l'upload même si l'ancienne suppression échoue

    # Téléversement de la nouvelle photo
    try:
        cloud_res = upload_profile_photo(file_obj=file_obj, user_id=request.user.id)
    except Exception as e:
        return Response(
            {'error': f"Échec du téléversement de la photo de profil: {str(e)}"},
            status=status.HTTP_502_BAD_GATEWAY
        )

    profile.photo = cloud_res['secure_url']
    profile.photo_cloudinary_public_id = cloud_res['public_id']
    profile.save(update_fields=['photo', 'photo_cloudinary_public_id'])

    return Response({
        'photo': profile.photo,
        'photo_cloudinary_public_id': profile.photo_cloudinary_public_id,
        'message': 'Photo de profil mise à jour avec succès'
    }, status=status.HTTP_200_OK)


@extend_schema(
    tags=['Profil Utilisateur'],
    summary='Supprimer la photo de profil',
    description='Supprime la photo de profil de Cloudinary et remet le champ à null dans PostgreSQL.',
    responses={204: None},
)
@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def user_profile_photo_delete_view(request):
    profile = get_or_create_profile(request.user)

    if profile.photo_cloudinary_public_id:
        try:
            delete_cloudinary_media(profile.photo_cloudinary_public_id, resource_type='image')
        except Exception as e:
            return Response(
                {'error': f"Échec de la suppression Cloudinary: {str(e)}"},
                status=status.HTTP_502_BAD_GATEWAY
            )

    profile.photo = None
    profile.photo_cloudinary_public_id = None
    profile.save(update_fields=['photo', 'photo_cloudinary_public_id'])

    return Response(status=status.HTTP_204_NO_CONTENT)
