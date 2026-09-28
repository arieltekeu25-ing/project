from django.contrib import admin
from django.utils.translation import gettext_lazy as _

from .models import (
    UserProfile,
    ClientProfile,
    LandlordProfile,
    AdminProfile,
    IdentityDocument,
    EmergencyContact,
    BankAccount,
    SocialLink,
)


@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = [
        'user',
        'genre',
        'langue',
        'etat_profil',
        'est_verifie',
        'derniere_activite',
        'created_at',
    ]
    list_filter = [
        'genre',
        'langue',
        'etat_profil',
        'est_verifie',
        'created_at',
    ]
    search_fields = ['user__email', 'user__nom', 'user__prenom', 'profession']
    ordering = ['-created_at']
    readonly_fields = ['id', 'created_at', 'updated_at', 'derniere_activite']


@admin.register(ClientProfile)
class ClientProfileAdmin(admin.ModelAdmin):
    list_display = [
        'user',
        'profession',
        'revenu_estime',
        'nombre_favoris',
        'nombre_visites',
        'note_moyenne',
        'created_at',
    ]
    list_filter = ['created_at']
    search_fields = ['user__email', 'profession']
    ordering = ['-created_at']
    readonly_fields = ['id', 'created_at', 'updated_at']


@admin.register(LandlordProfile)
class LandlordProfileAdmin(admin.ModelAdmin):
    list_display = [
        'user',
        'nom_affichage',
        'type_bailleur',
        'annees_experience',
        'nombre_logements',
        'score_confiance',
        'note_moyenne',
        'est_certifie',
        'created_at',
    ]
    list_filter = [
        'type_bailleur',
        'est_certifie',
        'created_at',
    ]
    search_fields = ['user__email', 'nom_affichage', 'description']
    ordering = ['-created_at']
    readonly_fields = ['id', 'created_at', 'updated_at', 'date_certification']


@admin.register(AdminProfile)
class AdminProfileAdmin(admin.ModelAdmin):
    list_display = [
        'user',
        'fonction',
        'departement',
        'niveau_acces',
        'created_at',
    ]
    list_filter = ['departement', 'niveau_acces', 'created_at']
    search_fields = ['user__email', 'fonction', 'departement']
    ordering = ['-created_at']
    readonly_fields = ['id', 'created_at', 'updated_at']


@admin.register(IdentityDocument)
class IdentityDocumentAdmin(admin.ModelAdmin):
    list_display = [
        'user',
        'type_document',
        'numero',
        'date_expiration',
        'etat_verification',
        'date_verification',
        'created_at',
    ]
    list_filter = [
        'type_document',
        'etat_verification',
        'date_expiration',
        'created_at',
    ]
    search_fields = ['user__email', 'numero']
    ordering = ['-created_at']
    readonly_fields = ['id', 'created_at', 'updated_at', 'date_verification']


@admin.register(EmergencyContact)
class EmergencyContactAdmin(admin.ModelAdmin):
    list_display = [
        'user',
        'nom',
        'prenom',
        'telephone',
        'lien_parente',
        'created_at',
    ]
    list_filter = ['lien_parente', 'created_at']
    search_fields = ['user__email', 'nom', 'prenom', 'telephone']
    ordering = ['-created_at']
    readonly_fields = ['id', 'created_at', 'updated_at']


@admin.register(BankAccount)
class BankAccountAdmin(admin.ModelAdmin):
    list_display = [
        'user',
        'nom_banque',
        'titulaire',
        'iban',
        'mobile_money',
        'created_at',
    ]
    list_filter = ['nom_banque', 'created_at']
    search_fields = ['user__email', 'nom_banque', 'titulaire', 'iban']
    ordering = ['-created_at']
    readonly_fields = ['id', 'created_at', 'updated_at']


@admin.register(SocialLink)
class SocialLinkAdmin(admin.ModelAdmin):
    list_display = [
        'user',
        'facebook',
        'instagram',
        'linkedin',
        'twitter',
        'created_at',
    ]
    list_filter = ['created_at']
    search_fields = ['user__email']
    ordering = ['-created_at']
    readonly_fields = ['id', 'created_at', 'updated_at']
