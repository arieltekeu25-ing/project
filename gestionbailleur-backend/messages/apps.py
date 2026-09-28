"""
Configuration de l'application messages
"""
from django.apps import AppConfig


class MessagesConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'messages'
    label = 'user_messages'
    verbose_name = 'Messages'
