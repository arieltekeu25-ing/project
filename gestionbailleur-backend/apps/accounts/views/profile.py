from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema

from ..serializers import ProfileSerializer, ChangePasswordSerializer
from ..permissions import IsAccountOwner


@extend_schema(
    tags=['Authentication'],
    summary='Obtenir le profil utilisateur',
    description='Récupérer les informations du profil de l\'utilisateur connecté',
    responses={200: ProfileSerializer},
)
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def profile_view(request):
    serializer = ProfileSerializer(request.user)
    return Response(serializer.data, status=status.HTTP_200_OK)


@extend_schema(
    tags=['Authentication'],
    summary='Mettre à jour le profil',
    description='Mettre à jour les informations du profil utilisateur',
    request=ProfileSerializer,
    responses={200: ProfileSerializer},
)
@api_view(['PUT'])
@permission_classes([IsAuthenticated, IsAccountOwner])
def update_profile_view(request):
    serializer = ProfileSerializer(request.user, data=request.data, partial=True)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=status.HTTP_200_OK)
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@extend_schema(
    tags=['Authentication'],
    summary='Changer le mot de passe',
    description='Changer le mot de passe de l\'utilisateur connecté',
    request=ChangePasswordSerializer,
    responses={200: {'type': 'object', 'properties': {'message': {'type': 'string'}}}},
)
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def change_password_view(request):
    serializer = ChangePasswordSerializer(
        data=request.data,
        context={'request': request}
    )
    if serializer.is_valid():
        user = request.user
        user.set_password(serializer.validated_data['new_password'])
        user.save()
        
        return Response({
            'message': 'Mot de passe changé avec succès',
        }, status=status.HTTP_200_OK)
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
