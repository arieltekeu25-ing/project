from django.urls import path
from ..views import (
    conversations_list_create_view,
    conversation_detail_view,
    messages_list_create_view,
    mark_conversation_read_view,
    unread_messages_count_view,
)

urlpatterns = [
    path('conversations/', conversations_list_create_view, name='conversations_list_create'),
    path('conversations/<uuid:conversation_id>/', conversation_detail_view, name='conversation_detail'),
    path('conversations/<uuid:conversation_id>/messages/', messages_list_create_view, name='messages_list_create'),
    path('conversations/<uuid:conversation_id>/read/', mark_conversation_read_view, name='mark_conversation_read'),
    path('unread-count/', unread_messages_count_view, name='unread_messages_count'),
]
