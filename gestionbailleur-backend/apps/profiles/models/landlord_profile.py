from django.db import models
from django.utils.translation import gettext_lazy as _

from .base import BaseModel


class LandlordProfile(BaseModel):
    TYPE_BAILLEUR_CHOICES = [
        ('PARTICULIER', _('Particulier')),
        ('PROFESSIONNEL', _('Professionnel')),
        ('AGENCE', _('Agence')),
        ('ENTREPRISE', _('Entreprise')),
    ]

    user = models.OneToOneField(
        'accounts.CustomUser',
        on_delete=models.CASCADE,
        related_name='landlord_profile',
        verbose_name='Utilisateur'
    )
    nom_affichage = models.CharField(max_length=100, blank=True, verbose_name='Nom d\'affichage')
    type_bailleur = models.CharField(
        max_length=20,
        choices=TYPE_BAILLEUR_CHOICES,
        blank=True,
        verbose_name='Type de bailleur'
    )
    description = models.TextField(blank=True, verbose_name='Description')
    annees_experience = models.IntegerField(blank=True, null=True, verbose_name='Années d\'expérience')
    nombre_logements = models.IntegerField(default=0, verbose_name='Nombre de logements')
    score_confiance = models.IntegerField(
        blank=True,
        null=True,
        verbose_name='Score de confiance'
    )
    note_moyenne = models.DecimalField(
        max_digits=3,
        decimal_places=2,
        blank=True,
        null=True,
        verbose_name='Note moyenne'
    )
    taux_reponse = models.DecimalField(
        max_digits=5,
        decimal_places=2,
        blank=True,
        null=True,
        verbose_name='Taux de réponse (%)'
    )
    temps_reponse_moyen = models.IntegerField(
        blank=True,
        null=True,
        verbose_name='Temps de réponse moyen (minutes)'
    )
    est_certifie = models.BooleanField(default=False, verbose_name='Certifié')
    date_certification = models.DateField(blank=True, null=True, verbose_name='Date de certification')

    class Meta:
        verbose_name = _('Profil bailleur')
        verbose_name_plural = _('Profils bailleurs')
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user']),
            models.Index(fields=['type_bailleur']),
            models.Index(fields=['est_certifie']),
            models.Index(fields=['note_moyenne']),
            models.Index(fields=['score_confiance']),
            models.Index(fields=['nombre_logements']),
        ]
        constraints = [
            models.UniqueConstraint(
                fields=['user'],
                condition=models.Q(is_deleted=False),
                name='unique_landlord_profile'
            ),
        ]

    def __str__(self):
        return f"Profil bailleur de {self.user.email}"
