from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework_simplejwt.views import TokenRefreshView as BaseTokenRefreshView
from drf_spectacular.utils import extend_schema, OpenApiParameter, OpenApiExample

from ..serializers import (
    RegisterSerializer,
    LoginSerializer,
    LogoutSerializer,
    RefreshTokenSerializer,
    ForgotPasswordSerializer,
    ResetPasswordSerializer,
)
from ..services import AuthService, TokenService


@extend_schema(
    tags=['Authentication'],
    summary='Inscription utilisateur',
    description='Créer un nouveau compte utilisateur (Client ou Bailleur)',
    request=RegisterSerializer,
    responses={201: RegisterSerializer},
)
@api_view(['POST'])
@permission_classes([AllowAny])
def register_view(request):
    serializer = RegisterSerializer(data=request.data)
    if serializer.is_valid():
        try:
            import logging
            logger = logging.getLogger(__name__)
            
            user = serializer.save()
            logger.info(f"User created: {user.email}")
            
            tokens = TokenService.generate_tokens(user)
            logger.info(f"Tokens generated for {user.email}")
            
            AuthService.create_user_session(user, request)
            logger.info(f"Session created for {user.email}")
            
            AuthService.update_last_login(user)
            logger.info(f"Last login updated for {user.email}")
            
            return Response({
                'message': 'Compte créé avec succès',
                'user': RegisterSerializer(user).data,
                'tokens': tokens,
            }, status=status.HTTP_201_CREATED)
        except Exception as e:
            import logging
            import traceback
            logger = logging.getLogger(__name__)
            logger.error(f"Error in registration: {str(e)}")
            logger.error(traceback.format_exc())
            return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@extend_schema(
    tags=['Authentication'],
    summary='Connexion utilisateur',
    description='Connexion avec email ou téléphone et mot de passe',
    request=LoginSerializer,
    responses={200: {'type': 'object', 'properties': {
        'access_token': {'type': 'string'},
        'refresh_token': {'type': 'string'},
        'user': {'type': 'object'},
    }}},
)
@api_view(['POST'])
@permission_classes([AllowAny])
def login_view(request):
    serializer = LoginSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.validated_data['user']
        tokens = TokenService.generate_tokens(user)
        AuthService.create_user_session(user, request)
        AuthService.create_login_history(user, request, success=True)
        AuthService.update_last_login(user)
        
        # Récupérer le rôle de l'utilisateur
        user_role = user.roles.filter(actif=True, is_deleted=False).first()
        role_data = None
        if user_role:
            role_data = {
                'code': user_role.role.code,
                'nom': user_role.role.nom,
            }
        
        return Response({
            'message': 'Connexion réussie',
            'tokens': tokens,
            'user': {
                'id': str(user.id),
                'email': user.email,
                'telephone': user.telephone,
                'nom': user.nom,
                'prenom': user.prenom,
                'etat_compte': user.etat_compte,
                'role': role_data,
            },
        }, status=status.HTTP_200_OK)
    
    return Response(serializer.errors, status=status.HTTP_401_UNAUTHORIZED)


@extend_schema(
    tags=['Authentication'],
    summary='Déconnexion utilisateur',
    description='Révoquer le refresh token et déconnecter l\'utilisateur',
    request=LogoutSerializer,
    responses={200: {'type': 'object', 'properties': {'message': {'type': 'string'}}}},
)
@api_view(['POST'])
def logout_view(request):
    serializer = LogoutSerializer(data=request.data)
    if serializer.is_valid():
        refresh_token = serializer.validated_data['refresh_token']
        AuthService.logout_user(request.user, refresh_token)
        TokenService.blacklist_token(refresh_token)
        
        return Response({
            'message': 'Déconnexion réussie',
        }, status=status.HTTP_200_OK)
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class TokenRefreshView(BaseTokenRefreshView):
    @extend_schema(
        tags=['Authentication'],
        summary='Rafraîchir le token d\'accès',
        description='Obtenir un nouveau access token à partir du refresh token',
        request=RefreshTokenSerializer,
        responses={200: {'type': 'object', 'properties': {
            'access': {'type': 'string'},
            'refresh': {'type': 'string'},
        }}},
    )
    def post(self, request, *args, **kwargs):
        return super().post(request, *args, **kwargs)


@extend_schema(
    tags=['Authentication'],
    summary='Mot de passe oublié',
    description='Demander une réinitialisation du mot de passe par email',
    request=ForgotPasswordSerializer,
    responses={200: {'type': 'object', 'properties': {'message': {'type': 'string'}}}},
)
@api_view(['POST'])
@permission_classes([AllowAny])
def forgot_password_view(request):
    serializer = ForgotPasswordSerializer(data=request.data)
    if serializer.is_valid():
        email = serializer.validated_data['email']
        # TODO: Implement email sending with reset token
        # For now, return success to not leak email existence
        return Response({
            'message': 'Si un compte existe avec cet email, vous recevrez un lien de réinitialisation.',
        }, status=status.HTTP_200_OK)
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@extend_schema(
    tags=['Authentication'],
    summary='Réinitialiser le mot de passe',
    description='Réinitialiser le mot de passe avec un token',
    request=ResetPasswordSerializer,
    responses={200: {'type': 'object', 'properties': {'message': {'type': 'string'}}}},
)
@api_view(['POST'])
@permission_classes([AllowAny])
def reset_password_view(request):
    serializer = ResetPasswordSerializer(data=request.data)
    if serializer.is_valid():
        token = serializer.validated_data['token']
        new_password = serializer.validated_data['new_password']
        
        # TODO: Validate token and reset password
        # For now, this is a placeholder
        return Response({
            'message': 'Mot de passe réinitialisé avec succès',
        }, status=status.HTTP_200_OK)
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
