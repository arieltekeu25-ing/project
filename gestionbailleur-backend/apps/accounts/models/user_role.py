from django.db import models
from django.utils.translation import gettext_lazy as _

from .base import BaseModel


class UserRole(BaseModel):
    user = models.ForeignKey(
        'CustomUser',
        on_delete=models.CASCADE,
        related_name='roles',
        verbose_name='Utilisateur'
    )
    role = models.ForeignKey(
        'Role',
        on_delete=models.PROTECT,
        related_name='users',
        verbose_name='Rôle'
    )
    date_attribution = models.DateTimeField(auto_now_add=True, verbose_name='Date d\'attribution')
    attribue_par = models.ForeignKey(
        'CustomUser',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='roles_attribues',
        verbose_name='Attribué par'
    )
    actif = models.BooleanField(default=True, verbose_name='Actif')

    class Meta:
        verbose_name = _('Rôle utilisateur')
        verbose_name_plural = _('Rôles utilisateurs')
        ordering = ['-date_attribution']
        unique_together = [['user', 'role']]
        indexes = [
            models.Index(fields=['user', 'role']),
            models.Index(fields=['role']),
            models.Index(fields=['actif']),
            models.Index(fields=['date_attribution']),
        ]

    def __str__(self):
        return f"{self.user.email} - {self.role.nom}"
