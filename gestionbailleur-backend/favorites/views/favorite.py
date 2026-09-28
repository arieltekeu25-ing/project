from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema

from ..models import Favorite
from apps.listings.models import Property
from apps.listings.serializers import PropertySerializer


@extend_schema(
    tags=['Favoris'],
    summary='Lister ou ajouter des favoris',
    description='Récupérer ou ajouter des logements mis en favori par l\'utilisateur connecté',
    responses={200: PropertySerializer(many=True)},
)
@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def favorites_list_create_view(request):
    if request.method == 'GET':
        favorites = Favorite.objects.filter(user=request.user, is_deleted=False).select_related('property')
        properties = [fav.property for fav in favorites if fav.property and not fav.property.is_deleted]
        
        serializer = PropertySerializer(properties, many=True)
        data = serializer.data
        for item in data:
            item['is_favorite'] = True
            
        return Response(data, status=status.HTTP_200_OK)

    elif request.method == 'POST':
        property_id = request.data.get('property_id') or request.data.get('id')
        if not property_id:
            return Response({'error': 'L\'identifiant du logement (property_id) est requis'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            target_property = Property.objects.get(id=property_id, is_deleted=False)
        except Property.DoesNotExist:
            return Response({'error': 'Logement non trouvé'}, status=status.HTTP_404_NOT_FOUND)

        favorite, created = Favorite.objects.get_or_create(
            user=request.user,
            property=target_property
        )
        if not created and favorite.is_deleted:
            favorite.is_deleted = False
            favorite.save()

        return Response({
            'message': 'Logement ajouté aux favoris',
            'is_favorite': True,
            'property_id': str(target_property.id)
        }, status=status.HTTP_201_CREATED)


@extend_schema(
    tags=['Favoris'],
    summary='Supprimer un favori',
    description='Retirer un logement des favoris de l\'utilisateur connecté',
    responses={204: None},
)
@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def favorite_delete_view(request, property_id):
    try:
        favorite = Favorite.objects.get(user=request.user, property_id=property_id, is_deleted=False)
        favorite.soft_delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
    except Favorite.DoesNotExist:
        return Response({'message': 'Favori déjà retiré ou inexistant'}, status=status.HTTP_204_NO_CONTENT)
