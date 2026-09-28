from django.db import models
from django.conf import settings
from django.utils.translation import gettext_lazy as _
from apps.listings.models.base import BaseModel


class ChatbotConversation(BaseModel):
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='chatbot_conversations',
        verbose_name=_('Utilisateur')
    )
    title = models.CharField(
        max_length=255,
        default='Nouvelle conversation',
        verbose_name=_('Titre')
    )
    context = models.TextField(
        blank=True,
        null=True,
        verbose_name=_('Contexte')
    )
    last_interaction = models.DateTimeField(
        auto_now=True,
        verbose_name=_('Dernière interaction')
    )

    class Meta:
        verbose_name = _('Conversation Chatbot')
        verbose_name_plural = _('Conversations Chatbot')
        ordering = ['-updated_at']
        indexes = [
            models.Index(fields=['user', '-updated_at']),
        ]

    def __str__(self):
        return f"Chatbot {self.user} - {self.title} ({self.created_at.strftime('%Y-%m-%d %H:%M')})"


class ChatbotMessage(BaseModel):
    ROLE_CHOICES = [
        ('user', _('Utilisateur')),
        ('assistant', _('Assistant IA')),
        ('system', _('Système')),
    ]

    conversation = models.ForeignKey(
        ChatbotConversation,
        on_delete=models.CASCADE,
        related_name='messages',
        verbose_name=_('Conversation')
    )
    sender = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        null=True,
        blank=True,
        related_name='chatbot_sent_messages',
        verbose_name=_('Expéditeur')
    )
    role = models.CharField(
        max_length=20,
        choices=ROLE_CHOICES,
        default='user',
        verbose_name=_('Rôle')
    )
    content = models.TextField(
        verbose_name=_('Contenu')
    )
    metadata = models.JSONField(
        default=dict,
        blank=True,
        verbose_name=_('Métadonnées (données de recherche, logement, etc.)')
    )

    class Meta:
        verbose_name = _('Message Chatbot')
        verbose_name_plural = _('Messages Chatbot')
        ordering = ['created_at']
        indexes = [
            models.Index(fields=['conversation', 'created_at']),
        ]

    def __str__(self):
        return f"[{self.role}] {self.content[:30]}..."
