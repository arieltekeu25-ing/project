from django.db import models
from django.utils.translation import gettext_lazy as _

from .base import BaseModel


class Region(BaseModel):
    nom = models.CharField(max_length=100, verbose_name='Nom')
    code = models.CharField(max_length=20, verbose_name='Code')
    description = models.TextField(blank=True, verbose_name='Description')
    country = models.ForeignKey(
        'Country',
        on_delete=models.CASCADE,
        related_name='regions',
        verbose_name='Pays'
    )

    class Meta:
        verbose_name = _('Région')
        verbose_name_plural = _('Régions')
        ordering = ['country', 'nom']
        indexes = [
            models.Index(fields=['nom']),
            models.Index(fields=['code']),
            models.Index(fields=['country']),
            models.Index(fields=['country', 'nom']),
        ]
        constraints = [
            models.UniqueConstraint(
                fields=['country', 'code'],
                condition=models.Q(is_deleted=False),
                name='unique_region_country_code'
            ),
        ]

    def __str__(self):
        return f"{self.nom}, {self.country.nom}"
