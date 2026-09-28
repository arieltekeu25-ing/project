from django.db import models
from django.conf import settings
from django.utils.translation import gettext_lazy as _
from apps.listings.models.base import BaseModel


class Message(BaseModel):
    conversation = models.ForeignKey(
        'Conversation',
        on_delete=models.CASCADE,
        related_name='messages',
        verbose_name=_('Conversation')
    )
    sender = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='sent_messages',
        verbose_name=_('Expéditeur')
    )
    recipient = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='received_messages',
        verbose_name=_('Destinataire')
    )
    content = models.TextField(
        verbose_name=_('Contenu du message')
    )
    is_read = models.BooleanField(
        default=False,
        verbose_name=_('Lu')
    )
    read_at = models.DateTimeField(
        null=True,
        blank=True,
        verbose_name=_('Date de lecture')
    )

    class Meta:
        verbose_name = _('Message')
        verbose_name_plural = _('Messages')
        ordering = ['created_at']
        indexes = [
            models.Index(fields=['conversation', 'created_at']),
            models.Index(fields=['recipient', 'is_read']),
        ]

    def __str__(self):
        return f"Message from {self.sender} to {self.recipient} at {self.created_at}"
