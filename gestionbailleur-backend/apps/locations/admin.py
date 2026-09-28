from django.contrib import admin
from django.utils.translation import gettext_lazy as _

from .models import (
    Country,
    Region,
    City,
    District,
    Neighborhood,
    Address,
    GeoLocation,
)


@admin.register(Country)
class CountryAdmin(admin.ModelAdmin):
    list_display = [
        'nom',
        'nom_officiel',
        'code_iso2',
        'code_iso3',
        'indicatif_telephonique',
        'devise',
        'continent',
        'actif',
        'created_at',
    ]
    list_filter = ['continent', 'actif', 'created_at']
    search_fields = ['nom', 'nom_officiel', 'code_iso2', 'code_iso3']
    ordering = ['nom']
    readonly_fields = ['id', 'created_at', 'updated_at']


@admin.register(Region)
class RegionAdmin(admin.ModelAdmin):
    list_display = ['nom', 'code', 'country', 'created_at']
    list_filter = ['country', 'created_at']
    search_fields = ['nom', 'code', 'country__nom']
    ordering = ['country', 'nom']
    readonly_fields = ['id', 'created_at', 'updated_at']


@admin.register(City)
class CityAdmin(admin.ModelAdmin):
    list_display = [
        'nom',
        'code',
        'region',
        'population',
        'superficie',
        'latitude',
        'longitude',
        'actif',
        'created_at',
    ]
    list_filter = ['region', 'actif', 'created_at']
    search_fields = ['nom', 'code', 'region__nom']
    ordering = ['region', 'nom']
    readonly_fields = ['id', 'created_at', 'updated_at']


@admin.register(District)
class DistrictAdmin(admin.ModelAdmin):
    list_display = ['nom', 'ville', 'created_at']
    list_filter = ['ville', 'created_at']
    search_fields = ['nom', 'ville__nom']
    ordering = ['ville', 'nom']
    readonly_fields = ['id', 'created_at', 'updated_at']


@admin.register(Neighborhood)
class NeighborhoodAdmin(admin.ModelAdmin):
    list_display = [
        'nom',
        'district',
        'code_postal',
        'niveau_securite',
        'created_at',
    ]
    list_filter = ['district', 'niveau_securite', 'created_at']
    search_fields = ['nom', 'code_postal', 'district__nom']
    ordering = ['district', 'nom']
    readonly_fields = ['id', 'created_at', 'updated_at']


@admin.register(Address)
class AddressAdmin(admin.ModelAdmin):
    list_display = [
        'ligne_1',
        'city',
        'district',
        'neighborhood',
        'country',
        'code_postal',
        'created_at',
    ]
    list_filter = [
        'country',
        'region',
        'city',
        'district',
        'neighborhood',
        'precision_gps',
        'created_at',
    ]
    search_fields = [
        'ligne_1',
        'ligne_2',
        'code_postal',
        'city__nom',
        'district__nom',
        'neighborhood__nom',
    ]
    ordering = ['country', 'region', 'city', 'district', 'neighborhood']
    readonly_fields = ['id', 'created_at', 'updated_at']


@admin.register(GeoLocation)
class GeoLocationAdmin(admin.ModelAdmin):
    list_display = [
        'latitude',
        'longitude',
        'altitude',
        'precision',
        'provider',
        'date_mise_a_jour',
    ]
    list_filter = ['provider', 'date_mise_a_jour']
    search_fields = ['latitude', 'longitude']
    ordering = ['-date_mise_a_jour']
    readonly_fields = ['id', 'created_at', 'updated_at', 'date_mise_a_jour']

