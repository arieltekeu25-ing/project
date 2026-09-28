from django.urls import path
from drf_spectacular.views import SpectacularAPIView, SpectacularRedocView, SpectacularSwaggerView

from ..views import (
    register_view,
    login_view,
    logout_view,
    TokenRefreshView,
    forgot_password_view,
    reset_password_view,
    profile_view,
    update_profile_view,
    change_password_view,
)
from ..views.admin import (
    admin_users_list_view,
    admin_user_detail_view,
    admin_user_update_view,
    admin_user_status_update_view,
    admin_user_role_update_view,
    admin_user_delete_view,
)

urlpatterns = [
    path('register/', register_view, name='register'),
    path('login/', login_view, name='login'),
    path('logout/', logout_view, name='logout'),
    path('refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('forgot-password/', forgot_password_view, name='forgot_password'),
    path('reset-password/', reset_password_view, name='reset_password'),
    path('me/', profile_view, name='profile'),
    path('profile/', update_profile_view, name='update_profile'),
    path('change-password/', change_password_view, name='change_password'),
    
    # Admin endpoints
    path('admin/users/', admin_users_list_view, name='admin_users_list'),
    path('admin/users/<uuid:user_id>/', admin_user_detail_view, name='admin_user_detail'),
    path('admin/users/<uuid:user_id>/update/', admin_user_update_view, name='admin_user_update'),
    path('admin/users/<uuid:user_id>/status/', admin_user_status_update_view, name='admin_user_status_update'),
    path('admin/users/<uuid:user_id>/role/', admin_user_role_update_view, name='admin_user_role_update'),
    path('admin/users/<uuid:user_id>/delete/', admin_user_delete_view, name='admin_user_delete'),
]
