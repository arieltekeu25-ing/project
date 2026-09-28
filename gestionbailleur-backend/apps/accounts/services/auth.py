from rest_framework_simplejwt.tokens import RefreshToken
from django.utils import timezone
from django.contrib.auth import get_user_model

from ..models import UserSession, RefreshToken as RefreshTokenModel, LoginHistory

User = get_user_model()


class TokenService:
    @staticmethod
    def generate_tokens(user):
        refresh = RefreshToken.for_user(user)
        return {
            'access_token': str(refresh.access_token),
            'refresh_token': str(refresh),
        }

    @staticmethod
    def refresh_token(refresh_token):
        try:
            refresh = RefreshToken(refresh_token)
            access_token = str(refresh.access_token)
            return {
                'access_token': access_token,
                'refresh_token': str(refresh),
            }
        except Exception:
            return None

    @staticmethod
    def blacklist_token(refresh_token):
        try:
            token = RefreshToken(refresh_token)
            token.blacklist()
            return True
        except Exception:
            return False


class AuthService:
    @staticmethod
    def create_user_session(user, request):
        from django.utils import timezone
        from datetime import timedelta
        
        ip_address = AuthService.get_client_ip(request)
        tokens = TokenService.generate_tokens(user)
        
        # Set expiration to 7 days from now
        date_expiration = timezone.now() + timedelta(days=7)

        session = UserSession.objects.create(
            user=user,
            token=tokens['access_token'],
            refresh_token=tokens['refresh_token'],
            adresse_ip=ip_address,
            date_expiration=date_expiration,
            est_active=True
        )
        return session

    @staticmethod
    def create_login_history(user, request, success=True):
        ip_address = AuthService.get_client_ip(request)

        LoginHistory.objects.create(
            user=user,
            email=user.email,
            adresse_ip=ip_address,
            resultat='SUCCES' if success else 'ECHEC'
        )

    @staticmethod
    def get_client_ip(request):
        x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
        if x_forwarded_for:
            ip = x_forwarded_for.split(',')[0]
        else:
            ip = request.META.get('REMOTE_ADDR')
        return ip

    @staticmethod
    def update_last_login(user):
        user.derniere_connexion = timezone.now()
        user.save()

    @staticmethod
    def logout_user(user, refresh_token):
        try:
            RefreshTokenModel.objects.filter(
                user=user,
                token=refresh_token,
                revoque=False
            ).update(revoque=True)
            
            UserSession.objects.filter(
                user=user,
                refresh_token=refresh_token
            ).update(est_active=False)
            
            return True
        except Exception:
            return False
