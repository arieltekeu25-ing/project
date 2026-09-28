"""
Configuration de développement
Configuration spécifique pour l'environnement de développement
"""
from .base import *

DEBUG = True

ALLOWED_HOSTS = ['*']

# Database de développement (PostgreSQL)
# DATABASES = {
#     'default': {
#         'ENGINE': 'django.db.backends.sqlite3',
#         'NAME': BASE_DIR / 'db.sqlite3',
#     }
# }

# Email backend pour le développement (console)
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'

# Désactiver les exigences de sécurité pour le développement
SECURE_SSL_REDIRECT = False
SESSION_COOKIE_SECURE = False
CSRF_COOKIE_SECURE = False

# Activer le debug toolbar
# INSTALLED_APPS += ['debug_toolbar']
# MIDDLEWARE += ['debug_toolbar.middleware.DebugToolbarMiddleware']
# INTERNAL_IPS = ['127.0.0.1']


# CORS permissif pour le développement
CORS_ALLOW_ALL_ORIGINS = True
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",
    "http://localhost:8080",
    "http://localhost:8000",
    "http://127.0.0.1:3000",
    "http://127.0.0.1:8080",
    "http://127.0.0.1:8000",
]

# Désactiver le rate limiting en développement
RATELIMIT_ENABLE = False
