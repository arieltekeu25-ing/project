from rest_framework import serializers
from django.contrib.auth import get_user_model
from django.utils.translation import gettext_lazy as _

from ..models import CustomUser

User = get_user_model()


class ProfileSerializer(serializers.ModelSerializer):
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
        ]

    def get_role(self, obj):
        user_role = obj.roles.filter(actif=True, is_deleted=False).first()
        if user_role:
            return {
                'code': user_role.role.code,
                'nom': user_role.role.nom,
            }
        return None

    def update(self, instance, validated_data):
        instance.nom = validated_data.get('nom', instance.nom)
        instance.prenom = validated_data.get('prenom', instance.prenom)
        instance.photo = validated_data.get('photo', instance.photo)
        instance.date_naissance = validated_data.get('date_naissance', instance.date_naissance)
        instance.genre = validated_data.get('genre', instance.genre)
        instance.save()
        return instance


class ChangePasswordSerializer(serializers.Serializer):
    old_password = serializers.CharField(
        required=True,
        style={'input_type': 'password'}
    )
    new_password = serializers.CharField(
        required=True,
        style={'input_type': 'password'},
        min_length=8
    )
    new_password_confirm = serializers.CharField(
        required=True,
        style={'input_type': 'password'}
    )

    def validate(self, attrs):
        if attrs['new_password'] != attrs['new_password_confirm']:
            raise serializers.ValidationError({
                'new_password': _('Les mots de passe ne correspondent pas.')
            })
        return attrs

    def validate_old_password(self, value):
        user = self.context['request'].user
        if not user.check_password(value):
            raise serializers.ValidationError(
                _('L\'ancien mot de passe est incorrect.')
            )
        return value
