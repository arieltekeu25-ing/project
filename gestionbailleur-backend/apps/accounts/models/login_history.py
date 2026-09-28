from django.db import models
from django.utils.translation import gettext_lazy as _

from .base import BaseModel


class LoginHistory(BaseModel):
    RESULTAT_CHOICES = [
        ('SUCCES', _('Succès')),
        ('ECHEC', _('Échec')),
    ]

    RAISON_ECHEC_CHOICES = [
        ('MAUVAIS_EMAIL', _('Email incorrect')),
        ('MAUVAIS_MOT_DE_PASSE', _('Mot de passe incorrect')),
        ('COMPTE_INACTIF', _('Compte inactif')),
        ('COMPTE_BLOQUE', _('Compte bloqué')),
        ('COMPTE_SUSPENDU', _('Compte suspendu')),
        ('EMAIL_NON_VERIFIE', _('Email non vérifié')),
        ('TELEPHONE_NON_VERIFIE', _('Téléphone non vérifié')),
        ('TENTATIVES_EXCESSIVES', _('Tentatives excessives')),
        ('TOKEN_EXPIRE', _('Token expiré')),
        ('TOKEN_INVALIDE', _('Token invalide')),
        ('AUTRE', _('Autre')),
    ]

    user = models.ForeignKey(
        'CustomUser',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='login_history',
        verbose_name='Utilisateur'
    )
    email = models.EmailField(blank=True, verbose_name='Email tenté')
    adresse_ip = models.GenericIPAddressField(verbose_name='Adresse IP')
    navigateur = models.CharField(max_length=255, blank=True, verbose_name='Navigateur')
    os = models.CharField(max_length=100, blank=True, verbose_name='OS')
    appareil = models.CharField(max_length=100, blank=True, verbose_name='Appareil')
    resultat = models.CharField(max_length=20, choices=RESULTAT_CHOICES, verbose_name='Résultat')
    raison_echec = models.CharField(
        max_length=50,
        choices=RAISON_ECHEC_CHOICES,
        blank=True,
        verbose_name='Raison de l\'échec'
    )
    date = models.DateTimeField(auto_now_add=True, verbose_name='Date')

    class Meta:
        verbose_name = _('Historique de connexion')
        verbose_name_plural = _('Historiques de connexions')
        ordering = ['-date']
        indexes = [
            models.Index(fields=['user']),
            models.Index(fields=['email']),
            models.Index(fields=['adresse_ip']),
            models.Index(fields=['resultat']),
            models.Index(fields=['date']),
            models.Index(fields=['user', 'date']),
            models.Index(fields=['adresse_ip', 'date']),
        ]

    def __str__(self):
        user_info = self.user.email if self.user else self.email
        return f"{user_info} - {self.resultat} - {self.date}"
