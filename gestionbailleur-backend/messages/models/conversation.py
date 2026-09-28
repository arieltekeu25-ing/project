from django.db import models
from django.conf import settings
from django.utils.translation import gettext_lazy as _
from apps.listings.models.base import BaseModel


class Conversation(BaseModel):
    client = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='client_conversations',
        verbose_name=_('Client')
    )
    landlord = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='landlord_conversations',
        verbose_name=_('Bailleur')
    )
    property = models.ForeignKey(
        'listings.Property',
        on_delete=models.CASCADE,
        related_name='conversations',
        verbose_name=_('Logement')
    )
    last_message_at = models.DateTimeField(
        auto_now_add=True,
        verbose_name=_('Date du dernier message')
    )

    class Meta:
        verbose_name = _('Conversation')
        verbose_name_plural = _('Conversations')
        ordering = ['-last_message_at']
        constraints = [
            models.UniqueConstraint(
                fields=['client', 'landlord', 'property'],
                name='unique_client_landlord_property_conversation'
            )
        ]

    def __str__(self):
        return f"Conversation: {self.client.nom_complet or self.client.email} <-> {self.landlord.nom_complet or self.landlord.email} ({self.property.title})"
