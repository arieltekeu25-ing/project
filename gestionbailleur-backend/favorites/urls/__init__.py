from django.urls import path
from ..views import favorites_list_create_view, favorite_delete_view

urlpatterns = [
    path('', favorites_list_create_view, name='favorites_list_create'),
    path('<uuid:property_id>/', favorite_delete_view, name='favorite_delete'),
]
