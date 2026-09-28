from django.db import models
from django.conf import settings
from django.utils.translation import gettext_lazy as _
from apps.listings.models.base import BaseModel


class Visit(BaseModel):
    STATUS_CHOICES = [
        ('PENDING', _('En attente')),
        ('ACCEPTED', _('Acceptée')),
        ('REJECTED', _('Refusée')),
        ('RESCHEDULED', _('Reprogrammée')),
        ('CANCELLED', _('Annulée')),
        ('COMPLETED', _('Terminée')),
    ]

    property = models.ForeignKey(
        'listings.Property',
        on_delete=models.CASCADE,
        related_name='visits',
        verbose_name=_('Logement')
    )
    client = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='visit_requests',
        verbose_name=_('Client')
    )
    landlord = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='received_visits',
        verbose_name=_('Bailleur')
    )
    requested_date = models.DateField(
        verbose_name=_('Date demandée')
    )
    requested_time = models.TimeField(
        verbose_name=_('Heure demandée')
    )
    message = models.TextField(
        null=True,
        blank=True,
        verbose_name=_('Message du client')
    )
    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default='PENDING',
        verbose_name=_('Statut')
    )
    landlord_response = models.TextField(
        null=True,
        blank=True,
        verbose_name=_('Réponse du bailleur')
    )
    rescheduled_date = models.DateField(
        null=True,
        blank=True,
        verbose_name=_('Date reprogrammée')
    )
    rescheduled_time = models.TimeField(
        null=True,
        blank=True,
        verbose_name=_('Heure reprogrammée')
    )
    rescheduled_message = models.TextField(
        null=True,
        blank=True,
        verbose_name=_('Message de reprogrammation')
    )

    class Meta:
        verbose_name = _('Visite')
        verbose_name_plural = _('Visites')
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['property']),
            models.Index(fields=['client']),
            models.Index(fields=['landlord']),
            models.Index(fields=['status']),
            models.Index(fields=['requested_date']),
            models.Index(fields=['-created_at']),
        ]
        constraints = [
            models.UniqueConstraint(
                fields=['property', 'client', 'requested_date', 'requested_time'],
                condition=models.Q(status='PENDING'),
                name='unique_pending_visit_request'
            ),
        ]

    def __str__(self):
        return f"Visite {self.property.title} - {self.requested_date} {self.requested_time}"
