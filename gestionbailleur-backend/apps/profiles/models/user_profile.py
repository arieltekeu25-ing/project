from django.db import models
from django.utils.translation import gettext_lazy as _

from .base import BaseModel


class UserProfile(BaseModel):
    ETAT_PROFIL_CHOICES = [
        ('INCOMPLET', _('Incomplet')),
        ('COMPLET', _('Complet')),
        ('EN_REVISION', _('En révision')),
        ('VERIFIE', _('Vérifié')),
        ('SUSPENDU', _('Suspendu')),
    ]

    GENRE_CHOICES = [
        ('M', _('Masculin')),
        ('F', _('Féminin')),
        ('A', _('Autre')),
    ]

    LANGUE_CHOICES = [
        ('fr', _('Français')),
        ('en', _('Anglais')),
        ('es', _('Espagnol')),
        ('de', _('Allemand')),
        ('pt', _('Portugais')),
    ]

    user = models.OneToOneField(
        'accounts.CustomUser',
        on_delete=models.CASCADE,
        related_name='profile',
        verbose_name='Utilisateur'
    )
    photo = models.URLField(blank=True, null=True, verbose_name='Photo')
    photo_cloudinary_public_id = models.CharField(max_length=255, blank=True, null=True, verbose_name='Cloudinary Public ID Photo')
    date_naissance = models.DateField(blank=True, null=True, verbose_name='Date de naissance')
    genre = models.CharField(max_length=1, choices=GENRE_CHOICES, blank=True, verbose_name='Genre')
    langue = models.CharField(max_length=5, choices=LANGUE_CHOICES, default='fr', verbose_name='Langue')
    biographie = models.TextField(blank=True, verbose_name='Biographie')
    profession = models.CharField(max_length=100, blank=True, verbose_name='Profession')
    nationalite = models.CharField(max_length=100, blank=True, verbose_name='Nationalité')
    photo_couverture = models.URLField(blank=True, null=True, verbose_name='Photo de couverture')
    site_web = models.URLField(blank=True, verbose_name='Site web')
    etat_profil = models.CharField(
        max_length=20,
        choices=ETAT_PROFIL_CHOICES,
        default='INCOMPLET',
        verbose_name='État du profil'
    )
    est_verifie = models.BooleanField(default=False, verbose_name='Vérifié')
    derniere_activite = models.DateTimeField(blank=True, null=True, verbose_name='Dernière activité')

    class Meta:
        verbose_name = _('Profil utilisateur')
        verbose_name_plural = _('Profils utilisateurs')
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user']),
            models.Index(fields=['etat_profil']),
            models.Index(fields=['est_verifie']),
            models.Index(fields=['derniere_activite']),
        ]
        constraints = [
            models.UniqueConstraint(
                fields=['user'],
                condition=models.Q(is_deleted=False),
                name='unique_user_profile'
            ),
        ]

    def __str__(self):
        return f"Profil de {self.user.email}"
