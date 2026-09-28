from django.db import models
from django.utils.translation import gettext_lazy as _

from .base import BaseModel


class BankAccount(BaseModel):
    user = models.ForeignKey(
        'accounts.CustomUser',
        on_delete=models.CASCADE,
        related_name='bank_accounts',
        verbose_name='Utilisateur'
    )
    nom_banque = models.CharField(max_length=100, verbose_name='Nom de la banque')
    titulaire = models.CharField(max_length=100, verbose_name='Titulaire du compte')
    iban = models.CharField(max_length=34, blank=True, verbose_name='IBAN')
    bic = models.CharField(max_length=11, blank=True, verbose_name='BIC/SWIFT')
    numero_compte = models.CharField(max_length=50, blank=True, verbose_name='Numéro de compte')
    mobile_money = models.CharField(max_length=20, blank=True, verbose_name='Mobile Money')
    numero_mobile_money = models.CharField(max_length=20, blank=True, verbose_name='Numéro Mobile Money')

    class Meta:
        verbose_name = _('Compte bancaire')
        verbose_name_plural = _('Comptes bancaires')
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user']),
            models.Index(fields=['iban']),
            models.Index(fields=['numero_compte']),
        ]
        constraints = [
            models.UniqueConstraint(
                fields=['iban'],
                condition=models.Q(is_deleted=False),
                name='unique_iban',
            ),
        ]

    def __str__(self):
        return f"{self.nom_banque} - {self.titulaire}"
