from django.db import models
from django.utils.translation import gettext_lazy as _

from .base import BaseModel


class City(BaseModel):
    nom = models.CharField(max_length=100, verbose_name='Nom')
    code = models.CharField(max_length=20, verbose_name='Code')
    region = models.ForeignKey(
        'Region',
        on_delete=models.CASCADE,
        related_name='cities',
        verbose_name='Région'
    )
    population = models.IntegerField(blank=True, null=True, verbose_name='Population')
    superficie = models.DecimalField(
        max_digits=15,
        decimal_places=2,
        blank=True,
        null=True,
        verbose_name='Superficie (km²)'
    )
    latitude = models.DecimalField(
        max_digits=9,
        decimal_places=6,
        blank=True,
        null=True,
        verbose_name='Latitude'
    )
    longitude = models.DecimalField(
        max_digits=9,
        decimal_places=6,
        blank=True,
        null=True,
        verbose_name='Longitude'
    )
    actif = models.BooleanField(default=True, verbose_name='Actif')

    class Meta:
        verbose_name = _('Ville')
        verbose_name_plural = _('Villes')
        ordering = ['region', 'nom']
        indexes = [
            models.Index(fields=['nom']),
            models.Index(fields=['code']),
            models.Index(fields=['region']),
            models.Index(fields=['latitude']),
            models.Index(fields=['longitude']),
            models.Index(fields=['actif']),
            models.Index(fields=['region', 'nom']),
        ]
        constraints = [
            models.UniqueConstraint(
                fields=['region', 'code'],
                condition=models.Q(is_deleted=False),
                name='unique_city_region_code'
            ),
        ]

    def __str__(self):
        return f"{self.nom}, {self.region.nom}"
