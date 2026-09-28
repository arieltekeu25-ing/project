from rest_framework import serializers
from django.contrib.auth import get_user_model
from django.db import models
from django.utils.translation import gettext_lazy as _

from ..models import CustomUser, Role, UserRole

User = get_user_model()


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(
        write_only=True,
        required=True,
        style={'input_type': 'password'},
        min_length=8
    )
    password_confirm = serializers.CharField(
        write_only=True,
        required=True,
        style={'input_type': 'password'}
    )
    user_type = serializers.ChoiceField(
        choices=['client', 'landlord'],
        write_only=True,
        required=True
    )
    nom = serializers.CharField(required=False, allow_blank=True, default='')
    prenom = serializers.CharField(required=False, allow_blank=True, default='')

    class Meta:
        model = CustomUser
        fields = [
            'id',
            'email',
            'telephone',
            'password',
            'password_confirm',
            'user_type',
            'nom',
            'prenom',
            'etat_compte',
            'created_at',
        ]
        read_only_fields = ['id', 'etat_compte', 'created_at']
        extra_kwargs = {
            'email': {'required': True},
            'telephone': {'required': True},
        }

    def to_representation(self, instance):
        data = super().to_representation(instance)
        # Ensure string fields are never null
        data['id'] = str(instance.id)
        data['nom'] = data.get('nom') or ''
        data['prenom'] = data.get('prenom') or ''
        user_role = instance.roles.filter(actif=True, is_deleted=False).first()
        if user_role:
            data['role'] = {
                'code': user_role.role.code,
                'nom': user_role.role.nom,
            }
        else:
            data['role'] = None
        return data

    def validate(self, attrs):
        if attrs['password'] != attrs['password_confirm']:
            raise serializers.ValidationError({
                'password': _('Les mots de passe ne correspondent pas.')
            })
        return attrs

    def validate_email(self, value):
        if CustomUser.objects.filter(email=value, is_deleted=False).exists():
            raise serializers.ValidationError(
                _('Cet email est déjà utilisé.')
            )
        return value

    def validate_telephone(self, value):
        if CustomUser.objects.filter(telephone=value, is_deleted=False).exists():
            raise serializers.ValidationError(
                _('Ce numéro de téléphone est déjà utilisé.')
            )
        return value

    def create(self, validated_data):
        validated_data.pop('password_confirm')
        user_type = validated_data.pop('user_type')

        user = CustomUser.objects.create_user(
            email=validated_data['email'],
            telephone=validated_data['telephone'],
            password=validated_data['password'],
            nom=validated_data.get('nom', ''),
            prenom=validated_data.get('prenom', ''),
        )

        if user_type == 'client':
            role = Role.objects.get_or_create(
                code='CLIENT',
                defaults={
                    'nom': 'Client',
                    'description': 'Utilisateur client',
                    'niveau_priorite': 10,
                    'actif': True
                }
            )[0]
            UserRole.objects.create(
                user=user,
                role=role,
                actif=True
            )
            user.etat_compte = 'ACTIF'

        elif user_type == 'landlord':
            role = Role.objects.get_or_create(
                code='BAILLEUR',
                defaults={
                    'nom': 'Bailleur',
                    'description': 'Propriétaire de logements',
                    'niveau_priorite': 20,
                    'actif': True
                }
            )[0]
            UserRole.objects.create(
                user=user,
                role=role,
                actif=True
            )
            user.etat_compte = 'EN_ATTENTE'

        user.save()
        return user


class LoginSerializer(serializers.Serializer):
    identifier = serializers.CharField(required=True)
    password = serializers.CharField(
        required=True,
        style={'input_type': 'password'}
    )

    def validate(self, attrs):
        identifier = attrs.get('identifier')
        password = attrs.get('password')

        user = CustomUser.objects.filter(
            models.Q(email=identifier) | models.Q(telephone=identifier),
            is_deleted=False
        ).first()

        if not user:
            raise serializers.ValidationError(
                {'identifier': _('Aucun compte trouvé avec cet identifiant.')}
            )

        if not user.check_password(password):
            raise serializers.ValidationError(
                {'password': _('Mot de passe incorrect.')}
            )

        if user.etat_compte == 'BLOQUE':
            raise serializers.ValidationError(
                {'identifier': _('Votre compte a été bloqué par l\'administrateur. Veuillez le contacter pour plus d\'informations.')}
            )

        if user.etat_compte == 'SUSPENDU':
            raise serializers.ValidationError(
                {'identifier': _('Votre compte est suspendu temporairement. Veuillez contacter l\'administrateur.')}
            )

        if user.etat_compte == 'EN_ATTENTE':
            # Permettre aux bailleurs en attente de se connecter
            # Ils seront redirigés vers leur dashboard avec un statut d'attente
            user_role = UserRole.objects.filter(
                user=user,
                role__code='BAILLEUR',
                actif=True,
                is_deleted=False
            ).first()
            
            # Si ce n'est pas un bailleur, bloquer la connexion
            if not user_role:
                raise serializers.ValidationError(
                    {'identifier': _('Votre compte est en attente de validation.')}
                )

        attrs['user'] = user
        return attrs


class LogoutSerializer(serializers.Serializer):
    refresh_token = serializers.CharField(required=True)


class RefreshTokenSerializer(serializers.Serializer):
    refresh_token = serializers.CharField(required=True)


class ForgotPasswordSerializer(serializers.Serializer):
    email = serializers.EmailField(required=True)

    def validate_email(self, value):
        if not CustomUser.objects.filter(email=value, is_deleted=False).exists():
            raise serializers.ValidationError(
                _('Aucun compte trouvé avec cet email.')
            )
        return value


class ResetPasswordSerializer(serializers.Serializer):
    token = serializers.CharField(required=True)
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
