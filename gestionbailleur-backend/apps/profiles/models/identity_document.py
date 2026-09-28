from django.db import models
from django.utils.translation import gettext_lazy as _

from .base import BaseModel


class IdentityDocument(BaseModel):
    TYPE_DOCUMENT_CHOICES = [
        ('CARTE_IDENTITE', _('Carte d\'identité')),
        ('PASSEPORT', _('Passeport')),
        ('PERMIS_CONDUIRE', _('Permis de conduire')),
        ('CARTE_SEJOUR', _('Carte de séjour')),
        ('AUTRE', _('Autre')),
    ]

    ETAT_VERIFICATION_CHOICES = [
        ('EN_ATTENTE', _('En attente')),
        ('EN_COURS', _('En cours')),
        ('VERIFIE', _('Vérifié')),
        ('REFUSE', _('Refusé')),
        ('EXPIRE', _('Expiré')),
    ]

    user = models.ForeignKey(
        'accounts.CustomUser',
        on_delete=models.CASCADE,
        related_name='identity_documents',
        verbose_name='Utilisateur'
    )
    type_document = models.CharField(
        max_length=20,
        choices=TYPE_DOCUMENT_CHOICES,
        verbose_name='Type de document'
    )
    numero = models.CharField(max_length=100, verbose_name='Numéro')
    date_expiration = models.DateField(blank=True, null=True, verbose_name='Date d\'expiration')
    document_recto = models.URLField(verbose_name='Document recto')
    document_verso = models.URLField(blank=True, null=True, verbose_name='Document verso')
    selfie_verification = models.URLField(blank=True, null=True, verbose_name='Selfie de vérification')
    etat_verification = models.CharField(
        max_length=20,
        choices=ETAT_VERIFICATION_CHOICES,
        default='EN_ATTENTE',
        verbose_name='État de vérification'
    )
    date_verification = models.DateTimeField(blank=True, null=True, verbose_name='Date de vérification')
    verifie_par = models.ForeignKey(
        'accounts.CustomUser',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='documents_verifies',
        verbose_name='Vérifié par'
    )

    class Meta:
        verbose_name = _('Document d\'identité')
        verbose_name_plural = _('Documents d\'identité')
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user']),
            models.Index(fields=['type_document']),
            models.Index(fields=['etat_verification']),
            models.Index(fields=['date_expiration']),
        ]

    def __str__(self):
        return f"{self.type_document} - {self.user.email}"
