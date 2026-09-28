import re
from django.core.exceptions import ValidationError
from django.utils.translation import gettext_lazy as _


def validate_email(value):
    email_regex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    if not re.match(email_regex, value):
        raise ValidationError(_('Format d\'email invalide.'))
    return value


def validate_telephone(value):
    telephone_regex = r'^\+?[0-9]{10,15}$'
    if not re.match(telephone_regex, value):
        raise ValidationError(_('Format de numéro de téléphone invalide.'))
    return value


def validate_password(value):
    if len(value) < 8:
        raise ValidationError(_('Le mot de passe doit contenir au moins 8 caractères.'))
    
    if not any(char.isdigit() for char in value):
        raise ValidationError(_('Le mot de passe doit contenir au moins un chiffre.'))
    
    if not any(char.isupper() for char in value):
        raise ValidationError(_('Le mot de passe doit contenir au moins une majuscule.'))
    
    if not any(char.islower() for char in value):
        raise ValidationError(_('Le mot de passe doit contenir au moins une minuscule.'))
    
    return value
