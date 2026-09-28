from django.db import models
from django.utils.translation import gettext_lazy as _

from .base import BaseModel


class EmergencyContact(BaseModel):
    LIEN_PARENTE_CHOICES = [
        ('CONJOINT', _('Conjoint')),
        ('PERE', _('Père')),
        ('MERE', _('Mère')),
        ('FRERE', _('Frère')),
        ('SOEUR', _('Sœur')),
        ('AMI', _('Ami')),
        ('COLLEGUE', _('Collègue')),
        ('AUTRE', _('Autre')),
    ]

    user = models.ForeignKey(
        'accounts.CustomUser',
        on_delete=models.CASCADE,
        related_name='emergency_contacts',
        verbose_name='Utilisateur'
    )
    nom = models.CharField(max_length=100, verbose_name='Nom')
    prenom = models.CharField(max_length=100, verbose_name='Prénom')
    telephone = models.CharField(max_length=20, verbose_name='Téléphone')
    email = models.EmailField(blank=True, verbose_name='Email')
    lien_parente = models.CharField(
        max_length=20,
        choices=LIEN_PARENTE_CHOICES,
        verbose_name='Lien de parenté'
    )

    class Meta:
        verbose_name = _('Contact d\'urgence')
        verbose_name_plural = _('Contacts d\'urgence')
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user']),
            models.Index(fields=['telephone']),
        ]

    def __str__(self):
        return f"{self.prenom} {self.nom} ({self.lien_parente})"
