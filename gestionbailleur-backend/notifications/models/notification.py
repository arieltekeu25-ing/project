from django.db import models
from django.conf import settings
from django.utils.translation import gettext_lazy as _
from apps.listings.models.base import BaseModel


class Notification(BaseModel):
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='notifications',
        verbose_name=_('Utilisateur')
    )
    title = models.CharField(
        max_length=255,
        verbose_name=_('Titre')
    )
    message = models.TextField(
        verbose_name=_('Message')
    )
    notification_type = models.CharField(
        max_length=50,
        default='MESSAGE',
        verbose_name=_('Type de notification')
    )
    is_read = models.BooleanField(
        default=False,
        verbose_name=_('Lu')
    )
    related_id = models.CharField(
        max_length=255,
        null=True,
        blank=True,
        verbose_name=_('ID associé')
    )

    class Meta:
        verbose_name = _('Notification')
        verbose_name_plural = _('Notifications')
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user', 'is_read']),
        ]

    def __str__(self):
        return f"Notification ({self.title}) for {self.user}"
