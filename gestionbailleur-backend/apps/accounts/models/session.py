from django.db import models
from django.utils.translation import gettext_lazy as _

from .base import BaseModel


class UserSession(BaseModel):
    user = models.ForeignKey(
        'CustomUser',
        on_delete=models.CASCADE,
        related_name='sessions',
        verbose_name='Utilisateur'
    )
    token = models.CharField(max_length=500, unique=True, verbose_name='Token')
    refresh_token = models.CharField(max_length=500, unique=True, verbose_name='Refresh token')
    adresse_ip = models.GenericIPAddressField(verbose_name='Adresse IP')
    navigateur = models.CharField(max_length=255, blank=True, verbose_name='Navigateur')
    systeme = models.CharField(max_length=100, blank=True, verbose_name='Système')
    appareil = models.CharField(max_length=100, blank=True, verbose_name='Appareil')
    date_connexion = models.DateTimeField(auto_now_add=True, verbose_name='Date de connexion')
    date_expiration = models.DateTimeField(verbose_name='Date d\'expiration')
    est_active = models.BooleanField(default=True, verbose_name='Active')

    class Meta:
        verbose_name = _('Session utilisateur')
        verbose_name_plural = _('Sessions utilisateurs')
        ordering = ['-date_connexion']
        indexes = [
            models.Index(fields=['token']),
            models.Index(fields=['refresh_token']),
            models.Index(fields=['user']),
            models.Index(fields=['est_active']),
            models.Index(fields=['date_expiration']),
            models.Index(fields=['adresse_ip']),
        ]
        constraints = [
            models.UniqueConstraint(
                fields=['token'],
                condition=models.Q(is_deleted=False),
                name='unique_session_token'
            ),
            models.UniqueConstraint(
                fields=['refresh_token'],
                condition=models.Q(is_deleted=False),
                name='unique_session_refresh_token'
            ),
        ]

    def est_expiree(self):
        from django.utils import timezone
        return timezone.now() > self.date_expiration

    def desactiver(self):
        self.est_active = False
        self.save()

    def __str__(self):
        return f"{self.user.email} - {self.date_connexion}"
