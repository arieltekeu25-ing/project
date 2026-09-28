from rest_framework import serializers
from django.utils.translation import gettext_lazy as _
from ..models import CustomUser, Role, UserRole


class AdminUserSerializer(serializers.ModelSerializer):
    role = serializers.SerializerMethodField()
    role_code = serializers.SerializerMethodField()
    is_landlord = serializers.SerializerMethodField()
    is_client = serializers.SerializerMethodField()
    is_admin = serializers.SerializerMethodField()

    class Meta:
        model = CustomUser
        fields = [
            'id',
            'email',
            'telephone',
            'nom',
            'prenom',
            'photo',
            'date_naissance',
            'genre',
            'langue',
            'etat_compte',
            'email_verifie',
            'telephone_verifie',
            'is_active',
            'is_staff',
            'is_superuser',
            'derniere_connexion',
            'created_at',
            'updated_at',
            'role',
            'role_code',
            'is_landlord',
            'is_client',
            'is_admin',
        ]
        read_only_fields = [
            'id',
            'created_at',
            'updated_at',
            'derniere_connexion',
        ]

    def get_role(self, obj):
        user_role = UserRole.objects.filter(
            user=obj,
            actif=True,
            is_deleted=False
        ).first()
        return user_role.role.nom if user_role else None

    def get_role_code(self, obj):
        user_role = UserRole.objects.filter(
            user=obj,
            actif=True,
            is_deleted=False
        ).first()
        return user_role.role.code if user_role else None

    def get_is_landlord(self, obj):
        return UserRole.objects.filter(
            user=obj,
            role__code='BAILLEUR',
            actif=True,
            is_deleted=False
        ).exists()

    def get_is_client(self, obj):
        return UserRole.objects.filter(
            user=obj,
            role__code='CLIENT',
            actif=True,
            is_deleted=False
        ).exists()

    def get_is_admin(self, obj):
        return UserRole.objects.filter(
            user=obj,
            role__code__in=['ADMINISTRATEUR', 'SUPER_ADMINISTRATEUR'],
            actif=True,
            is_deleted=False
        ).exists()


class AdminUserUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomUser
        fields = [
            'nom',
            'prenom',
            'telephone',
            'photo',
            'date_naissance',
            'genre',
            'langue',
            'etat_compte',
            'is_active',
            'is_staff',
        ]


class AdminUserStatusUpdateSerializer(serializers.Serializer):
    etat_compte = serializers.ChoiceField(
        choices=['ACTIF', 'INACTIF', 'SUSPENDU', 'BLOQUE', 'EN_ATTENTE'],
        required=True
    )
    reason = serializers.CharField(required=False, allow_blank=True)


class AdminUserRoleUpdateSerializer(serializers.Serializer):
    role_code = serializers.ChoiceField(
        choices=['CLIENT', 'BAILLEUR', 'ADMINISTRATEUR', 'SUPER_ADMINISTRATEUR'],
        required=True
    )
