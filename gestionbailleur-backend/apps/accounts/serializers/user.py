from rest_framework import serializers
from django.contrib.auth import get_user_model
from django.utils.translation import gettext_lazy as _

from ..models import CustomUser

User = get_user_model()


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomUser
        fields = [
            'id',
            'email',
            'telephone',
            'nom',
            'prenom',
            'photo',
            'etat_compte',
        ]
        read_only_fields = ['id', 'email', 'telephone', 'etat_compte']


class UserDetailSerializer(serializers.ModelSerializer):
    role = serializers.SerializerMethodField()

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
            'etat_compte',
            'email_verifie',
            'telephone_verifie',
            'derniere_connexion',
            'role',
            'created_at',
            'updated_at',
        ]
        read_only_fields = [
            'id',
            'email',
            'telephone',
            'etat_compte',
            'email_verifie',
            'telephone_verifie',
            'derniere_connexion',
            'created_at',
            'updated_at',
        ]

    def get_role(self, obj):
        user_role = obj.user_roles.filter(actif=True, is_deleted=False).first()
        if user_role:
            return {
                'code': user_role.role.code,
                'nom': user_role.role.nom,
            }
        return None
