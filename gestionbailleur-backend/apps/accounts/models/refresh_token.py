from django.db import models
from django.utils.translation import gettext_lazy as _

from .base import BaseModel


class RefreshToken(BaseModel):
    user = models.ForeignKey(
        'CustomUser',
        on_delete=models.CASCADE,
        related_name='refresh_tokens',
        verbose_name='Utilisateur'
    )
    token = models.CharField(max_length=255, unique=True, verbose_name='Token')
    session = models.ForeignKey(
        'UserSession',
        on_delete=models.CASCADE,
        related_name='refresh_tokens',
        null=True,
        blank=True,
        verbose_name='Session'
    )
    expiration = models.DateTimeField(verbose_name='Date d\'expiration')
    revoque = models.BooleanField(default=False, verbose_name='Révoqué')
    date_revoquation = models.DateTimeField(null=True, blank=True, verbose_name='Date de révocation')

    class Meta:
        verbose_name = _('Refresh token')
        verbose_name_plural = _('Refresh tokens')
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['token']),
            models.Index(fields=['user']),
            models.Index(fields=['session']),
            models.Index(fields=['expiration']),
            models.Index(fields=['revoque']),
        ]
        constraints = [
            models.UniqueConstraint(
                fields=['token'],
                condition=models.Q(is_deleted=False),
                name='unique_refresh_token'
            ),
        ]

    def est_expire(self):
        from django.utils import timezone
        return timezone.now() > self.expiration

    def est_valide(self):
        return not self.revoque and not self.est_expire()

    def revoquer(self):
        from django.utils import timezone
        self.revoque = True
        self.date_revoquation = timezone.now()
        self.save()

    def __str__(self):
        return f"{self.user.email} - {'Valide' if self.est_valide() else 'Invalide'}"
