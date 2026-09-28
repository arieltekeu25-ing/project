from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from django.utils.translation import gettext_lazy as _

from .models import (
    CustomUser,
    Role,
    Permission,
    UserRole,
    UserSession,
    RefreshToken,
    LoginHistory,
)


@admin.register(CustomUser)
class CustomUserAdmin(BaseUserAdmin):
    list_display = [
        'email',
        'telephone',
        'nom_complet',
        'etat_compte',
        'email_verifie',
        'telephone_verifie',
        'is_active',
        'is_staff',
        'derniere_connexion',
        'created_at',
    ]
    list_filter = [
        'etat_compte',
        'email_verifie',
        'telephone_verifie',
        'is_active',
        'is_staff',
        'genre',
        'langue',
        'created_at',
    ]
    search_fields = ['email', 'telephone', 'nom', 'prenom']
    ordering = ['-created_at']
    readonly_fields = ['id', 'created_at', 'updated_at', 'derniere_connexion']

    fieldsets = (
        (None, {'fields': ('id', 'email', 'telephone', 'password')}),
        (_('Informations personnelles'), {
            'fields': ('nom', 'prenom', 'photo', 'date_naissance', 'genre')
        }),
        (_('Préférences'), {
            'fields': ('langue',)
        }),
        (_('État du compte'), {
            'fields': (
                'etat_compte',
                'email_verifie',
                'telephone_verifie',
                'is_active',
                'is_staff',
                'is_superuser',
            )
        }),
        (_('Dates'), {
            'fields': ('derniere_connexion', 'created_at', 'updated_at')
        }),
        (_('Permissions'), {
            'fields': ('groups', 'user_permissions'),
        }),
    )

    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('email', 'telephone', 'password1', 'password2'),
        }),
    )

    def nom_complet(self, obj):
        return obj.nom_complet()
    nom_complet.short_description = _('Nom complet')


@admin.register(Role)
class RoleAdmin(admin.ModelAdmin):
    list_display = ['code', 'nom', 'niveau_priorite', 'actif', 'created_at']
    list_filter = ['actif', 'niveau_priorite', 'created_at']
    search_fields = ['code', 'nom', 'description']
    ordering = ['-niveau_priorite', 'nom']
    readonly_fields = ['id', 'created_at', 'updated_at']
    filter_horizontal = ['permissions']


@admin.register(Permission)
class PermissionAdmin(admin.ModelAdmin):
    list_display = ['code', 'nom', 'module', 'active', 'created_at']
    list_filter = ['module', 'active', 'created_at']
    search_fields = ['code', 'nom', 'description', 'module']
    ordering = ['module', 'code']
    readonly_fields = ['id', 'created_at', 'updated_at']


@admin.register(UserRole)
class UserRoleAdmin(admin.ModelAdmin):
    list_display = ['user', 'role', 'actif', 'date_attribution', 'attribue_par']
    list_filter = ['actif', 'role', 'date_attribution']
    search_fields = ['user__email', 'role__nom', 'role__code']
    ordering = ['-date_attribution']
    readonly_fields = ['id', 'date_attribution', 'created_at', 'updated_at']


@admin.register(UserSession)
class UserSessionAdmin(admin.ModelAdmin):
    list_display = [
        'user',
        'adresse_ip',
        'appareil',
        'est_active',
        'date_connexion',
        'date_expiration',
    ]
    list_filter = ['est_active', 'date_connexion', 'date_expiration']
    search_fields = ['user__email', 'adresse_ip', 'appareil', 'navigateur']
    ordering = ['-date_connexion']
    readonly_fields = [
        'id',
        'token',
        'refresh_token',
        'date_connexion',
        'created_at',
        'updated_at',
    ]


@admin.register(RefreshToken)
class RefreshTokenAdmin(admin.ModelAdmin):
    list_display = ['user', 'est_valide', 'expiration', 'revoque', 'created_at']
    list_filter = ['revoque', 'expiration', 'created_at']
    search_fields = ['user__email', 'token']
    ordering = ['-created_at']
    readonly_fields = [
        'id',
        'token',
        'expiration',
        'created_at',
        'updated_at',
        'date_revoquation',
    ]

    def est_valide(self, obj):
        return obj.est_valide()
    est_valide.boolean = True
    est_valide.short_description = _('Valide')


@admin.register(LoginHistory)
class LoginHistoryAdmin(admin.ModelAdmin):
    list_display = [
        'user_info',
        'resultat',
        'raison_echec',
        'adresse_ip',
        'appareil',
        'date',
    ]
    list_filter = ['resultat', 'raison_echec', 'date']
    search_fields = ['user__email', 'email', 'adresse_ip', 'appareil']
    ordering = ['-date']
    readonly_fields = ['id', 'date', 'created_at', 'updated_at']

    def user_info(self, obj):
        return obj.user.email if obj.user else obj.email
    user_info.short_description = _('Utilisateur')
