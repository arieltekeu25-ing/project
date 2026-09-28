from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema, OpenApiParameter
from django.db import models

from ..serializers.admin import (
    AdminUserSerializer,
    AdminUserUpdateSerializer,
    AdminUserStatusUpdateSerializer,
    AdminUserRoleUpdateSerializer,
)
from ..models import CustomUser, Role, UserRole


@extend_schema(
    tags=['Admin'],
    summary='Lister tous les utilisateurs',
    description='Récupérer la liste de tous les utilisateurs (réservé aux administrateurs)',
    responses={200: AdminUserSerializer(many=True)},
)
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def admin_users_list_view(request):
    # Vérifier que l'utilisateur est admin
    if not request.user.is_staff and not request.user.is_superuser:
        return Response(
            {'error': 'Accès non autorisé'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    queryset = CustomUser.objects.filter(is_deleted=False)
    
    # Filtres
    role_filter = request.query_params.get('role')
    if role_filter:
        queryset = queryset.filter(
            user_roles__role__code=role_filter,
            user_roles__actif=True,
            user_roles__is_deleted=False
        )
    
    status_filter = request.query_params.get('status')
    if status_filter:
        queryset = queryset.filter(etat_compte=status_filter)
    
    search = request.query_params.get('search')
    if search:
        queryset = queryset.filter(
            models.Q(email__icontains=search) |
            models.Q(telephone__icontains=search) |
            models.Q(nom__icontains=search) |
            models.Q(prenom__icontains=search)
        )
    
    serializer = AdminUserSerializer(queryset, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)


@extend_schema(
    tags=['Admin'],
    summary='Détails d\'un utilisateur',
    description='Récupérer les détails d\'un utilisateur spécifique (réservé aux administrateurs)',
    responses={200: AdminUserSerializer},
)
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def admin_user_detail_view(request, user_id):
    # Vérifier que l'utilisateur est admin
    if not request.user.is_staff and not request.user.is_superuser:
        return Response(
            {'error': 'Accès non autorisé'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    try:
        user = CustomUser.objects.get(id=user_id, is_deleted=False)
        serializer = AdminUserSerializer(user)
        return Response(serializer.data, status=status.HTTP_200_OK)
    except CustomUser.DoesNotExist:
        return Response(
            {'error': 'Utilisateur non trouvé'},
            status=status.HTTP_404_NOT_FOUND
        )


@extend_schema(
    tags=['Admin'],
    summary='Mettre à jour un utilisateur',
    description='Mettre à jour les informations d\'un utilisateur (réservé aux administrateurs)',
    request=AdminUserUpdateSerializer,
    responses={200: AdminUserSerializer},
)
@api_view(['PUT', 'PATCH'])
@permission_classes([IsAuthenticated])
def admin_user_update_view(request, user_id):
    # Vérifier que l'utilisateur est admin
    if not request.user.is_staff and not request.user.is_superuser:
        return Response(
            {'error': 'Accès non autorisé'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    try:
        user = CustomUser.objects.get(id=user_id, is_deleted=False)
        serializer = AdminUserUpdateSerializer(
            user,
            data=request.data,
            partial=request.method == 'PATCH'
        )
        if serializer.is_valid():
            user = serializer.save()
            return Response(
                AdminUserSerializer(user).data,
                status=status.HTTP_200_OK
            )
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    except CustomUser.DoesNotExist:
        return Response(
            {'error': 'Utilisateur non trouvé'},
            status=status.HTTP_404_NOT_FOUND
        )


@extend_schema(
    tags=['Admin'],
    summary='Mettre à jour le statut d\'un utilisateur',
    description='Changer le statut du compte d\'un utilisateur (réservé aux administrateurs)',
    request=AdminUserStatusUpdateSerializer,
    responses={200: AdminUserSerializer},
)
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def admin_user_status_update_view(request, user_id):
    # Vérifier que l'utilisateur est admin
    if not request.user.is_staff and not request.user.is_superuser:
        return Response(
            {'error': 'Accès non autorisé'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    try:
        user = CustomUser.objects.get(id=user_id, is_deleted=False)
        serializer = AdminUserStatusUpdateSerializer(data=request.data)
        if serializer.is_valid():
            user.etat_compte = serializer.validated_data['etat_compte']
            if serializer.validated_data['etat_compte'] == 'INACTIF':
                user.is_active = False
            else:
                user.is_active = True
            user.save()
            return Response(
                AdminUserSerializer(user).data,
                status=status.HTTP_200_OK
            )
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    except CustomUser.DoesNotExist:
        return Response(
            {'error': 'Utilisateur non trouvé'},
            status=status.HTTP_404_NOT_FOUND
        )


@extend_schema(
    tags=['Admin'],
    summary='Mettre à jour le rôle d\'un utilisateur',
    description='Changer le rôle d\'un utilisateur (réservé aux administrateurs)',
    request=AdminUserRoleUpdateSerializer,
    responses={200: AdminUserSerializer},
)
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def admin_user_role_update_view(request, user_id):
    # Vérifier que l'utilisateur est admin
    if not request.user.is_staff and not request.user.is_superuser:
        return Response(
            {'error': 'Accès non autorisé'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    try:
        user = CustomUser.objects.get(id=user_id, is_deleted=False)
        serializer = AdminUserRoleUpdateSerializer(data=request.data)
        if serializer.is_valid():
            role_code = serializer.validated_data['role_code']
            
            # Désactiver les rôles existants
            UserRole.objects.filter(user=user).update(actif=False)
            
            # Créer ou activer le nouveau rôle
            role = Role.objects.get(code=role_code)
            UserRole.objects.create(
                user=user,
                role=role,
                actif=True
            )
            
            # Mettre à jour le statut du compte selon le rôle
            if role_code == 'BAILLEUR':
                user.etat_compte = 'EN_ATTENTE'
            elif role_code == 'CLIENT':
                user.etat_compte = 'ACTIF'
            
            user.save()
            
            return Response(
                AdminUserSerializer(user).data,
                status=status.HTTP_200_OK
            )
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    except CustomUser.DoesNotExist:
        return Response(
            {'error': 'Utilisateur non trouvé'},
            status=status.HTTP_404_NOT_FOUND
        )
    except Role.DoesNotExist:
        return Response(
            {'error': 'Rôle non trouvé'},
            status=status.HTTP_404_NOT_FOUND
        )


@extend_schema(
    tags=['Admin'],
    summary='Supprimer un utilisateur',
    description='Supprimer un utilisateur (réservé aux administrateurs)',
    responses={204: None},
)
@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def admin_user_delete_view(request, user_id):
    # Vérifier que l'utilisateur est admin
    if not request.user.is_staff and not request.user.is_superuser:
        return Response(
            {'error': 'Accès non autorisé'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    try:
        user = CustomUser.objects.get(id=user_id, is_deleted=False)
        
        # Empêcher la suppression de soi-même
        if user.id == request.user.id:
            return Response(
                {'error': 'Vous ne pouvez pas supprimer votre propre compte'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        user.soft_delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
    except CustomUser.DoesNotExist:
        return Response(
            {'error': 'Utilisateur non trouvé'},
            status=status.HTTP_404_NOT_FOUND
        )
