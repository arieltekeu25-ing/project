from django.db import models
from django.utils.translation import gettext_lazy as _

from .base import BaseModel


class GeoLocation(BaseModel):
    PROVIDER_CHOICES = [
        ('GPS', _('GPS')),
        ('IP', _('Adresse IP')),
        ('WIFI', _('WiFi')),
        ('MANUEL', _('Manuel')),
        ('API', _('API externe')),
    ]

    latitude = models.DecimalField(max_digits=9, decimal_places=6, verbose_name='Latitude')
    longitude = models.DecimalField(max_digits=9, decimal_places=6, verbose_name='Longitude')
    altitude = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        blank=True,
        null=True,
        verbose_name='Altitude (m)'
    )
    precision = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        blank=True,
        null=True,
        verbose_name='Précision (m)'
    )
    provider = models.CharField(
        max_length=20,
        choices=PROVIDER_CHOICES,
        default='GPS',
        verbose_name='Fournisseur'
    )
    date_mise_a_jour = models.DateTimeField(auto_now=True, verbose_name='Date de mise à jour')

    class Meta:
        verbose_name = _('Géolocalisation')
        verbose_name_plural = _('Géolocalisations')
        ordering = ['-date_mise_a_jour']
        indexes = [
            models.Index(fields=['latitude']),
            models.Index(fields=['longitude']),
            models.Index(fields=['provider']),
            models.Index(fields=['date_mise_a_jour']),
            models.Index(fields=['latitude', 'longitude']),
        ]

    def __str__(self):
        return f"({self.latitude}, {self.longitude})"
