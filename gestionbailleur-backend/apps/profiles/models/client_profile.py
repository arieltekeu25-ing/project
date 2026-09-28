from django.db import models
from django.utils.translation import gettext_lazy as _

from .base import BaseModel


class ClientProfile(BaseModel):
    user = models.OneToOneField(
        'accounts.CustomUser',
        on_delete=models.CASCADE,
        related_name='client_profile',
        verbose_name='Utilisateur'
    )
    profession = models.CharField(max_length=100, blank=True, verbose_name='Profession')
    revenu_estime = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        blank=True,
        null=True,
        verbose_name='Revenu estimé'
    )
    preferences_recherche = models.JSONField(blank=True, null=True, verbose_name='Préférences de recherche')
    historique_locations = models.JSONField(blank=True, null=True, verbose_name='Historique des locations')
    nombre_favoris = models.IntegerField(default=0, verbose_name='Nombre de favoris')
    nombre_visites = models.IntegerField(default=0, verbose_name='Nombre de visites')
    note_moyenne = models.DecimalField(
        max_digits=3,
        decimal_places=2,
        blank=True,
        null=True,
        verbose_name='Note moyenne'
    )

    class Meta:
        verbose_name = _('Profil client')
        verbose_name_plural = _('Profils clients')
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user']),
            models.Index(fields=['note_moyenne']),
            models.Index(fields=['nombre_favoris']),
            models.Index(fields=['nombre_visites']),
        ]
        constraints = [
            models.UniqueConstraint(
                fields=['user'],
                condition=models.Q(is_deleted=False),
                name='unique_client_profile'
            ),
        ]

    def __str__(self):
        return f"Profil client de {self.user.email}"
