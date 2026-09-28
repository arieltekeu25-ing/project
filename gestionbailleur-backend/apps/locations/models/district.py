from django.db import models
from django.utils.translation import gettext_lazy as _

from .base import BaseModel


class District(BaseModel):
    nom = models.CharField(max_length=100, verbose_name='Nom')
    ville = models.ForeignKey(
        'City',
        on_delete=models.CASCADE,
        related_name='districts',
        verbose_name='Ville'
    )
    description = models.TextField(blank=True, verbose_name='Description')

    class Meta:
        verbose_name = _('Arrondissement')
        verbose_name_plural = _('Arrondissements')
        ordering = ['ville', 'nom']
        indexes = [
            models.Index(fields=['nom']),
            models.Index(fields=['ville']),
            models.Index(fields=['ville', 'nom']),
        ]

    def __str__(self):
        return f"{self.nom}, {self.ville.nom}"
