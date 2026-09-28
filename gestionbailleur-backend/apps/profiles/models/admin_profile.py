from django.db import models
from django.utils.translation import gettext_lazy as _

from .base import BaseModel


class AdminProfile(BaseModel):
    NIVEAU_ACCES_CHOICES = [
        ('LECTURE', _('Lecture seule')),
        ('STANDARD', _('Standard')),
        ('AVANCE', _('Avancé')),
        ('SUPERVISEUR', _('Superviseur')),
        ('COMPLET', _('Accès complet')),
    ]

    user = models.OneToOneField(
        'accounts.CustomUser',
        on_delete=models.CASCADE,
        related_name='admin_profile',
        verbose_name='Utilisateur'
    )
    fonction = models.CharField(max_length=100, blank=True, verbose_name='Fonction')
    departement = models.CharField(max_length=100, blank=True, verbose_name='Département')
    niveau_acces = models.CharField(
        max_length=20,
        choices=NIVEAU_ACCES_CHOICES,
        default='STANDARD',
        verbose_name='Niveau d\'accès'
    )
    signature = models.CharField(max_length=255, blank=True, verbose_name='Signature')

    class Meta:
        verbose_name = _('Profil administrateur')
        verbose_name_plural = _('Profils administrateurs')
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user']),
            models.Index(fields=['departement']),
            models.Index(fields=['niveau_acces']),
        ]
        constraints = [
            models.UniqueConstraint(
                fields=['user'],
                condition=models.Q(is_deleted=False),
                name='unique_admin_profile'
            ),
        ]

    def __str__(self):
        return f"Profil admin de {self.user.email}"
