from django.db import models
from django.utils.translation import gettext_lazy as _

from .base import BaseModel


class PermissionManager(models.Manager):
    def get_active_permissions(self):
        return self.filter(active=True, is_deleted=False)

    def get_by_module(self, module):
        return self.filter(module=module, is_deleted=False)

    def get_by_code(self, code):
        return self.filter(code=code, is_deleted=False).first()


class Permission(BaseModel):
    code = models.CharField(max_length=100, unique=True, verbose_name='Code')
    nom = models.CharField(max_length=200, verbose_name='Nom')
    description = models.TextField(blank=True, verbose_name='Description')
    module = models.CharField(max_length=50, verbose_name='Module')
    active = models.BooleanField(default=True, verbose_name='Active')

    objects = PermissionManager()

    class Meta:
        verbose_name = _('Permission')
        verbose_name_plural = _('Permissions')
        ordering = ['module', 'code']
        indexes = [
            models.Index(fields=['code']),
            models.Index(fields=['module']),
            models.Index(fields=['active']),
            models.Index(fields=['module', 'code']),
        ]
        constraints = [
            models.UniqueConstraint(
                fields=['code'],
                condition=models.Q(is_deleted=False),
                name='unique_permission_code'
            ),
        ]

    def __str__(self):
        return f"{self.module}.{self.code}"
