from django.db import models
from django.utils.translation import gettext_lazy as _

from .base import BaseModel


class Neighborhood(BaseModel):
    NIVEAU_SECURITE_CHOICES = [
        ('TRES_HAUT', _('Très haut')),
        ('HAUT', _('Haut')),
        ('MOYEN', _('Moyen')),
        ('BAS', _('Bas')),
        ('TRES_BAS', _('Très bas')),
    ]

    nom = models.CharField(max_length=100, verbose_name='Nom')
    district = models.ForeignKey(
        'District',
        on_delete=models.CASCADE,
        related_name='neighborhoods',
        verbose_name='Arrondissement'
    )
    code_postal = models.CharField(max_length=20, blank=True, verbose_name='Code postal')
    description = models.TextField(blank=True, verbose_name='Description')
    niveau_securite = models.CharField(
        max_length=20,
        choices=NIVEAU_SECURITE_CHOICES,
        blank=True,
        verbose_name='Niveau de sécurité'
    )

    class Meta:
        verbose_name = _('Quartier')
        verbose_name_plural = _('Quartiers')
        ordering = ['district', 'nom']
        indexes = [
            models.Index(fields=['nom']),
            models.Index(fields=['district']),
            models.Index(fields=['code_postal']),
            models.Index(fields=['niveau_securite']),
            models.Index(fields=['district', 'nom']),
        ]

    def __str__(self):
        return f"{self.nom}, {self.district.nom}"
