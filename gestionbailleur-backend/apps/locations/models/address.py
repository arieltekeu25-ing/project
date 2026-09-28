from django.db import models
from django.utils.translation import gettext_lazy as _

from .base import BaseModel


class Address(BaseModel):
    PRECISION_GPS_CHOICES = [
        ('EXACTE', _('Exacte')),
        ('APPROXIMATIVE', _('Approximative')),
        ('VILLE', _('Ville')),
        ('REGION', _('Région')),
    ]

    ligne_1 = models.CharField(max_length=255, verbose_name='Ligne 1')
    ligne_2 = models.CharField(max_length=255, blank=True, verbose_name='Ligne 2')
    point_repere = models.CharField(max_length=255, blank=True, verbose_name='Point de repère')
    code_postal = models.CharField(max_length=20, blank=True, verbose_name='Code postal')
    country = models.ForeignKey(
        'Country',
        on_delete=models.PROTECT,
        related_name='addresses',
        verbose_name='Pays'
    )
    region = models.ForeignKey(
        'Region',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='addresses',
        verbose_name='Région'
    )
    city = models.ForeignKey(
        'City',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='addresses',
        verbose_name='Ville'
    )
    district = models.ForeignKey(
        'District',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='addresses',
        verbose_name='Arrondissement'
    )
    neighborhood = models.ForeignKey(
        'Neighborhood',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='addresses',
        verbose_name='Quartier'
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
    precision_gps = models.CharField(
        max_length=20,
        choices=PRECISION_GPS_CHOICES,
        blank=True,
        verbose_name='Précision GPS'
    )

    class Meta:
        verbose_name = _('Adresse')
        verbose_name_plural = _('Adresses')
        ordering = ['country', 'region', 'city', 'district', 'neighborhood']
        indexes = [
            models.Index(fields=['country']),
            models.Index(fields=['region']),
            models.Index(fields=['city']),
            models.Index(fields=['district']),
            models.Index(fields=['neighborhood']),
            models.Index(fields=['latitude']),
            models.Index(fields=['longitude']),
            models.Index(fields=['code_postal']),
            models.Index(fields=['city', 'district']),
            models.Index(fields=['neighborhood', 'code_postal']),
        ]

    def adresse_complete(self):
        parties = [self.ligne_1]
        if self.ligne_2:
            parties.append(self.ligne_2)
        if self.city:
            parties.append(self.city.nom)
        if self.region:
            parties.append(self.region.nom)
        if self.country:
            parties.append(self.country.nom)
        return ', '.join(parties)

    def __str__(self):
        return self.adresse_complete()
