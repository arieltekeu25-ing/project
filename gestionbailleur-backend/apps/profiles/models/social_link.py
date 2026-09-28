from django.db import models
from django.utils.translation import gettext_lazy as _

from .base import BaseModel


class SocialLink(BaseModel):
    user = models.OneToOneField(
        'accounts.CustomUser',
        on_delete=models.CASCADE,
        related_name='social_links',
        verbose_name='Utilisateur'
    )
    facebook = models.URLField(blank=True, verbose_name='Facebook')
    instagram = models.URLField(blank=True, verbose_name='Instagram')
    linkedin = models.URLField(blank=True, verbose_name='LinkedIn')
    twitter = models.URLField(blank=True, verbose_name='Twitter')
    tiktok = models.URLField(blank=True, verbose_name='TikTok')
    youtube = models.URLField(blank=True, verbose_name='YouTube')
    site_web = models.URLField(blank=True, verbose_name='Site web')

    class Meta:
        verbose_name = _('Lien social')
        verbose_name_plural = _('Liens sociaux')
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user']),
        ]
        constraints = [
            models.UniqueConstraint(
                fields=['user'],
                condition=models.Q(is_deleted=False),
                name='unique_social_link'
            ),
        ]

    def __str__(self):
        return f"Liens sociaux de {self.user.email}"
