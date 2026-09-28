from django.urls import path
from ..views import (
    property_list_view,
    property_create_view,
    property_detail_view,
    property_update_view,
    property_delete_view,
    property_publish_view,
    property_search_view,
    property_filter_options_view,
    property_media_upload_view,
    property_media_delete_view,
    property_media_set_primary_view,
    property_media_reorder_view,
)

urlpatterns = [
    path('', property_list_view, name='property_list'),
    path('search/', property_search_view, name='property_search'),
    path('options/', property_filter_options_view, name='property_filter_options'),
    path('create/', property_create_view, name='property_create'),
    path('<uuid:property_id>/', property_detail_view, name='property_detail'),
    path('<uuid:property_id>/update/', property_update_view, name='property_update'),
    path('<uuid:property_id>/delete/', property_delete_view, name='property_delete'),
    path('<uuid:property_id>/publish/', property_publish_view, name='property_publish'),

    # Médias
    path('<uuid:property_id>/media/', property_media_upload_view, name='property_media_upload'),
    path('<uuid:property_id>/media/<uuid:media_id>/', property_media_delete_view, name='property_media_delete'),
    path('<uuid:property_id>/media/<uuid:media_id>/set-primary/', property_media_set_primary_view, name='property_media_set_primary'),
    path('<uuid:property_id>/media/reorder/', property_media_reorder_view, name='property_media_reorder'),
]

