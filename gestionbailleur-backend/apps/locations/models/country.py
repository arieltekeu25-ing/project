from django.db import models
from django.utils.translation import gettext_lazy as _

from .base import BaseModel


class Country(BaseModel):
    CONTINENT_CHOICES = [
        ('AF', _('Afrique')),
        ('AS', _('Asie')),
        ('EU', _('Europe')),
        ('NA', _('Amérique du Nord')),
        ('SA', _('Amérique du Sud')),
        ('OC', _('Océanie')),
        ('AN', _('Antarctique')),
    ]

    nom = models.CharField(max_length=100, unique=True, verbose_name='Nom')
    nom_officiel = models.CharField(max_length=200, blank=True, verbose_name='Nom officiel')
    code_iso2 = models.CharField(max_length=2, unique=True, verbose_name='Code ISO2')
    code_iso3 = models.CharField(max_length=3, unique=True, verbose_name='Code ISO3')
    indicatif_telephonique = models.CharField(max_length=10, blank=True, verbose_name='Indicatif téléphonique')
    devise = models.CharField(max_length=10, blank=True, verbose_name='Devise')
    langue_principale = models.CharField(max_length=10, blank=True, verbose_name='Langue principale')
    continent = models.CharField(max_length=2, choices=CONTINENT_CHOICES, verbose_name='Continent')
    actif = models.BooleanField(default=True, verbose_name='Actif')

    class Meta:
        verbose_name = _('Pays')
        verbose_name_plural = _('Pays')
        ordering = ['nom']
        indexes = [
            models.Index(fields=['nom']),
            models.Index(fields=['code_iso2']),
            models.Index(fields=['code_iso3']),
            models.Index(fields=['continent']),
            models.Index(fields=['actif']),
        ]
        constraints = [
            models.UniqueConstraint(
                fields=['nom'],
                condition=models.Q(is_deleted=False),
                name='unique_country_nom'
            ),
            models.UniqueConstraint(
                fields=['code_iso2'],
                condition=models.Q(is_deleted=False),
                name='unique_country_iso2'
            ),
            models.UniqueConstraint(
                fields=['code_iso3'],
                condition=models.Q(is_deleted=False),
                name='unique_country_iso3'
            ),
        ]

    def __str__(self):
        return f"{self.nom} ({self.code_iso2})"
