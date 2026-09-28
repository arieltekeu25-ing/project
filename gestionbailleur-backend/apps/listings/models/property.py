from django.db import models
from django.utils.translation import gettext_lazy as _
from ..models.base import BaseModel


class Property(BaseModel):
    TYPE_CHOICES = [
        ('APARTMENT', _('Appartement')),
        ('HOUSE', _('Maison')),
        ('STUDIO', _('Studio')),
        ('LOFT', _('Loft')),
        ('VILLA', _('Villa')),
        ('TERRACE', _('Terasse')),
        ('OTHER', _('Autre')),
    ]

    STATUS_CHOICES = [
        ('DRAFT', _('Brouillon')),
        ('PUBLISHED', _('Publié')),
        ('RENTED', _('Loué')),
        ('SUSPENDED', _('Suspendu')),
        ('ARCHIVED', _('Archivé')),
    ]

    title = models.CharField(max_length=200, verbose_name='Titre')
    description = models.TextField(verbose_name='Description')
    property_type = models.CharField(
        max_length=20,
        choices=TYPE_CHOICES,
        verbose_name='Type de logement'
    )
    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default='DRAFT',
        verbose_name='Statut'
    )
    
    # Prix
    rent_price = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        verbose_name='Prix du loyer'
    )
    charges = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        null=True,
        blank=True,
        verbose_name='Charges'
    )
    deposit = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        null=True,
        blank=True,
        verbose_name='Caution'
    )
    
    # Caractéristiques
    surface = models.DecimalField(
        max_digits=6,
        decimal_places=2,
        verbose_name='Surface (m²)'
    )
    rooms = models.IntegerField(verbose_name='Nombre de pièces')
    bedrooms = models.IntegerField(default=0, verbose_name='Nombre de chambres')
    bathrooms = models.IntegerField(default=0, verbose_name='Nombre de salles de bain')
    floor = models.IntegerField(null=True, blank=True, verbose_name='Étage')
    
    # Équipements
    furnished = models.BooleanField(default=False, verbose_name='Meublé')
    parking = models.BooleanField(default=False, verbose_name='Parking')
    balcony = models.BooleanField(default=False, verbose_name='Balcon')
    terrace = models.BooleanField(default=False, verbose_name='Terasse')
    elevator = models.BooleanField(default=False, verbose_name='Ascenseur')
    garden = models.BooleanField(default=False, verbose_name='Jardin')
    pool = models.BooleanField(default=False, verbose_name='Piscine')
    air_conditioning = models.BooleanField(default=False, verbose_name='Climatisation')
    heating = models.BooleanField(default=False, verbose_name='Chauffage')
    
    # Adresse (relation avec locations app)
    address = models.ForeignKey(
        'locations.Address',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='properties',
        verbose_name='Adresse'
    )
    
    # Propriétaire
    landlord = models.ForeignKey(
        'accounts.CustomUser',
        on_delete=models.CASCADE,
        related_name='properties',
        verbose_name='Propriétaire'
    )
    
    # Disponibilité
    available_from = models.DateField(
        null=True,
        blank=True,
        verbose_name='Disponible à partir du'
    )
    minimum_rent_duration = models.IntegerField(
        null=True,
        blank=True,
        verbose_name='Durée minimale de location (mois)'
    )
    
    # Photos
    main_photo = models.URLField(
        null=True,
        blank=True,
        verbose_name='Photo principale'
    )
    
    # Statistiques
    views_count = models.IntegerField(default=0, verbose_name='Nombre de vues')
    inquiries_count = models.IntegerField(default=0, verbose_name='Nombre de demandes')
    
    class Meta:
        verbose_name = _('Logement')
        verbose_name_plural = _('Logements')
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['landlord']),
            models.Index(fields=['status']),
            models.Index(fields=['property_type']),
            models.Index(fields=['rent_price']),
            models.Index(fields=['available_from']),
            models.Index(fields=['-created_at']),
        ]
        constraints = [
            models.UniqueConstraint(
                fields=['landlord', 'title'],
                condition=models.Q(is_deleted=False),
                name='unique_landlord_property_title'
            ),
        ]

    def __str__(self):
        return f"{self.title} - {self.rent_price}€"
