from django.db import models
from django.conf import settings
from django.utils.translation import gettext_lazy as _
from apps.listings.models.base import BaseModel


class Favorite(BaseModel):
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='favorites',
        verbose_name=_('Utilisateur')
    )
    property = models.ForeignKey(
        'listings.Property',
        on_delete=models.CASCADE,
        related_name='favorited_by',
        verbose_name=_('Logement')
    )

    class Meta:
        verbose_name = _('Favori')
        verbose_name_plural = _('Favoris')
        ordering = ['-created_at']
        constraints = [
            models.UniqueConstraint(
                fields=['user', 'property'],
                name='unique_user_favorite_property'
            )
        ]

    def __str__(self):
        return f"{self.user} - {self.property.title}"
