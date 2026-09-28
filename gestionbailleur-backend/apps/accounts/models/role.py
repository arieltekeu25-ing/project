from django.db import models
from django.utils.translation import gettext_lazy as _

from .base import BaseModel


class RoleManager(models.Manager):
    def get_active_roles(self):
        return self.filter(actif=True, is_deleted=False)

    def get_by_code(self, code):
        return self.filter(code=code, is_deleted=False).first()


class Role(BaseModel):
    code = models.CharField(max_length=50, unique=True, verbose_name='Code')
    nom = models.CharField(max_length=100, verbose_name='Nom')
    description = models.TextField(blank=True, verbose_name='Description')
    niveau_priorite = models.IntegerField(default=0, verbose_name='Niveau de priorité')
    actif = models.BooleanField(default=True, verbose_name='Actif')
    permissions = models.ManyToManyField(
        'Permission',
        blank=True,
        related_name='roles',
        verbose_name='Permissions'
    )

    objects = RoleManager()

    class Meta:
        verbose_name = _('Rôle')
        verbose_name_plural = _('Rôles')
        ordering = ['-niveau_priorite', 'nom']
        indexes = [
            models.Index(fields=['code']),
            models.Index(fields=['actif']),
            models.Index(fields=['niveau_priorite']),
        ]
        constraints = [
            models.UniqueConstraint(
                fields=['code'],
                condition=models.Q(is_deleted=False),
                name='unique_role_code'
            ),
        ]

    def __str__(self):
        return f"{self.nom} ({self.code})"
