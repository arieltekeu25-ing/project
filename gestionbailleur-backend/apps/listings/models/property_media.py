from django.db import models
from django.utils.translation import gettext_lazy as _
from .base import BaseModel


class PropertyMedia(BaseModel):
    RESOURCE_TYPE_CHOICES = [
        ('image', _('Image')),
        ('video', _('Vidéo')),
    ]

    property = models.ForeignKey(
        'listings.Property',
        on_delete=models.CASCADE,
        related_name='media',
        verbose_name=_('Logement')
    )
    cloudinary_public_id = models.CharField(
        max_length=255,
        verbose_name=_('Public ID Cloudinary')
    )
    secure_url = models.URLField(
        max_length=500,
        verbose_name=_('URL sécurisée Cloudinary')
    )
    resource_type = models.CharField(
        max_length=10,
        choices=RESOURCE_TYPE_CHOICES,
        default='image',
        verbose_name=_('Type de ressource')
    )
    format = models.CharField(
        max_length=20,
        blank=True,
        verbose_name=_('Format')
    )
    width = models.IntegerField(
        null=True,
        blank=True,
        verbose_name=_('Largeur (px)')
    )
    height = models.IntegerField(
        null=True,
        blank=True,
        verbose_name=_('Hauteur (px)')
    )
    duration = models.FloatField(
        null=True,
        blank=True,
        verbose_name=_('Durée (secondes)')
    )
    file_size = models.BigIntegerField(
        null=True,
        blank=True,
        verbose_name=_('Taille du fichier (octets)')
    )
    order = models.IntegerField(
        default=0,
        verbose_name=_('Ordre d\'affichage')
    )
    is_primary = models.BooleanField(
        default=False,
        verbose_name=_('Média principal')
    )

    class Meta:
        verbose_name = _('Média du logement')
        verbose_name_plural = _('Médias des logements')
        ordering = ['order', 'created_at']
        indexes = [
            models.Index(fields=['property']),
            models.Index(fields=['resource_type']),
            models.Index(fields=['is_primary']),
            models.Index(fields=['order']),
        ]

    def save(self, *args, **kwargs):
        # Si cet élément devient principal, désactiver le principal précédent pour ce logement
        if self.is_primary:
            PropertyMedia.objects.filter(
                property=self.property,
                is_primary=True,
                is_deleted=False
            ).exclude(pk=self.pk).update(is_primary=False)
            
            # Mettre à jour l'image principale du logement si c'est une image
            if self.resource_type == 'image':
                self.property.main_photo = self.secure_url
                self.property.save(update_fields=['main_photo'])

        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.resource_type.upper()} ({self.order}) pour {self.property.title}"
