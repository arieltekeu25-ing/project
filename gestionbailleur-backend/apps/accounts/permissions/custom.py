from rest_framework import permissions
from django.utils.translation import gettext_lazy as _


class IsAccountOwner(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        return obj == request.user


class IsActiveUser(permissions.BasePermission):
    message = _('Votre compte n\'est pas actif.')

    def has_permission(self, request, view):
        return request.user and request.user.is_authenticated and request.user.etat_compte == 'ACTIF'


class IsVerifiedUser(permissions.BasePermission):
    message = _('Votre compte n\'est pas vérifié.')

    def has_permission(self, request, view):
        return request.user and request.user.is_authenticated and request.user.email_verifie


class HasRole(permissions.BasePermission):
    message = _('Vous n\'avez pas les permissions requises.')

    def __init__(self, roles):
        self.roles = roles if isinstance(roles, list) else [roles]

    def has_permission(self, request, view):
        if not request.user or not request.user.is_authenticated:
            return False
        
        user_roles = request.user.roles.filter(
            actif=True,
            is_deleted=False
        ).values_list('role__code', flat=True)
        
        return any(role in user_roles for role in self.roles)
