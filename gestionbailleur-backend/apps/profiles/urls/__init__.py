from django.urls import path
from ..views import (
    user_profile_me_view,
    user_profile_photo_upload_view,
    user_profile_photo_delete_view,
)

urlpatterns = [
    path('me/', user_profile_me_view, name='user_profile_me'),
    path('me/photo/', user_profile_photo_upload_view, name='user_profile_photo_upload'),
    path('me/photo/delete/', user_profile_photo_delete_view, name='user_profile_photo_delete'),
]
