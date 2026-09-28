from django.db import models
from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin, BaseUserManager
from django.utils import timezone
from django.utils.translation import gettext_lazy as _

from .base import BaseModel


class CustomUserManager(BaseUserManager):
    def create_user(self, email, telephone, password=None, **extra_fields):
        if not email:
            raise ValueError(_('L\'email est obligatoire'))
        if not telephone:
            raise ValueError(_('Le téléphone est obligatoire'))
        
        email = self.normalize_email(email)
        user = self.model(email=email, telephone=telephone, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, telephone, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('is_active', True)
        extra_fields.setdefault('email_verifie', True)
        extra_fields.setdefault('telephone_verifie', True)

        if extra_fields.get('is_staff') is not True:
            raise ValueError(_('Le superuser doit avoir is_staff=True'))
        if extra_fields.get('is_superuser') is not True:
            raise ValueError(_('Le superuser doit avoir is_superuser=True'))

        return self.create_user(email, telephone, password, **extra_fields)


class CustomUser(AbstractBaseUser, PermissionsMixin, BaseModel):
    GENRE_CHOICES = [
        ('M', _('Masculin')),
        ('F', _('Féminin')),
        ('A', _('Autre')),
    ]

    ETAT_COMPTE_CHOICES = [
        ('ACTIF', _('Actif')),
        ('INACTIF', _('Inactif')),
        ('SUSPENDU', _('Suspendu')),
        ('BLOQUE', _('Bloqué')),
        ('EN_ATTENTE', _('En attente')),
    ]

    LANGUE_CHOICES = [
        ('fr', _('Français')),
        ('en', _('Anglais')),
        ('es', _('Espagnol')),
        ('de', _('Allemand')),
        ('pt', _('Portugais')),
    ]

    email = models.EmailField(unique=True, verbose_name='Email')
    telephone = models.CharField(max_length=20, unique=True, verbose_name='Téléphone')
    nom = models.CharField(max_length=100, blank=True, verbose_name='Nom')
    prenom = models.CharField(max_length=100, blank=True, verbose_name='Prénom')
    photo = models.URLField(blank=True, null=True, verbose_name='Photo')
    date_naissance = models.DateField(blank=True, null=True, verbose_name='Date de naissance')
    genre = models.CharField(max_length=1, choices=GENRE_CHOICES, blank=True, verbose_name='Genre')
    langue = models.CharField(max_length=5, choices=LANGUE_CHOICES, default='fr', verbose_name='Langue')
    etat_compte = models.CharField(
        max_length=20, 
        choices=ETAT_COMPTE_CHOICES, 
        default='EN_ATTENTE',
        verbose_name='État du compte'
    )
    email_verifie = models.BooleanField(default=False, verbose_name='Email vérifié')
    telephone_verifie = models.BooleanField(default=False, verbose_name='Téléphone vérifié')
    is_active = models.BooleanField(default=True, verbose_name='Actif')
    is_staff = models.BooleanField(default=False, verbose_name='Staff')
    is_superuser = models.BooleanField(default=False, verbose_name='Super utilisateur')
    derniere_connexion = models.DateTimeField(blank=True, null=True, verbose_name='Dernière connexion')

    objects = CustomUserManager()

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['telephone']

    class Meta:
        verbose_name = _('Utilisateur')
        verbose_name_plural = _('Utilisateurs')
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['email']),
            models.Index(fields=['telephone']),
            models.Index(fields=['etat_compte']),
            models.Index(fields=['email_verifie', 'telephone_verifie']),
            models.Index(fields=['derniere_connexion']),
        ]
        constraints = [
            models.UniqueConstraint(
                fields=['email'],
                condition=models.Q(is_deleted=False),
                name='unique_email_active'
            ),
            models.UniqueConstraint(
                fields=['telephone'],
                condition=models.Q(is_deleted=False),
                name='unique_telephone_active'
            ),
        ]

    def nom_complet(self):
        return f"{self.prenom} {self.nom}".strip() or self.email

    def est_bailleur(self):
        return self.roles.filter(code='BAILLEUR', actif=True).exists()

    def est_client(self):
        return self.roles.filter(code='CLIENT', actif=True).exists()

    def est_administrateur(self):
        return self.roles.filter(code__in=['ADMINISTRATEUR', 'SUPER_ADMINISTRATEUR'], actif=True).exists()

    def possede_role(self, role_code):
        return self.roles.filter(code=role_code, actif=True).exists()

    def possede_permission(self, permission_code):
        return self.roles.filter(
            permissions__code=permission_code,
            actif=True,
            permissions__active=True
        ).exists()

    def attribuer_role(self, role_code, attribue_par=None):
        from .role import Role
        from .user_role import UserRole
        
        role = Role.objects.filter(code=role_code).first()
        if role:
            UserRole.objects.get_or_create(
                user=self,
                role=role,
                defaults={'attribue_par': attribue_par}
            )

    def retirer_role(self, role_code):
        from .role import Role
        from .user_role import UserRole
        
        role = Role.objects.filter(code=role_code).first()
        if role:
            UserRole.objects.filter(user=self, role=role).delete()

    def __str__(self):
        return self.nom_complet()
