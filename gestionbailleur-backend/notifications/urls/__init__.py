from django.urls import path
from ..views import (
    notifications_list_view,
    unread_notifications_count_view,
    mark_notifications_read_view,
)

urlpatterns = [
    path('', notifications_list_view, name='notifications_list'),
    path('unread-count/', unread_notifications_count_view, name='unread_notifications_count'),
    path('mark-read/', mark_notifications_read_view, name='mark_notifications_read'),
]
