"""
Configuration de test
Configuration spécifique pour l'environnement de test
"""
from .base import *

DEBUG = True

ALLOWED_HOSTS = ['*']

# Database SQLite pour les tests
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': ':memory:',
    }
}

# Email backend de test
EMAIL_BACKEND = 'django.core.mail.backends.locmem.EmailBackend'

# Désactiver les exigences de sécurité pour les tests
SECURE_SSL_REDIRECT = False
SESSION_COOKIE_SECURE = False
CSRF_COOKIE_SECURE = False

# Désactiver le rate limiting pour les tests
RATELIMIT_ENABLE = False

# Cache mémoire pour les tests
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
    }
}

# Logging minimal pour les tests
LOGGING = {
    'version': 1,
    'disable_existing_loggers': True,
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
        },
    },
    'root': {
        'handlers': ['console'],
        'level': 'WARNING',
    },
}

# Désactiver Celery pour les tests
CELERY_TASK_ALWAYS_EAGER = True

# CORS permissif pour les tests
CORS_ALLOW_ALL_ORIGINS = True

# Password validation simplifiée pour les tests
AUTH_PASSWORD_VALIDATORS = []

# Désactiver le debug toolbar pour les tests
if 'debug_toolbar' in INSTALLED_APPS:
    INSTALLED_APPS.remove('debug_toolbar')
if 'debug_toolbar.middleware.DebugToolbarMiddleware' in MIDDLEWARE:
    MIDDLEWARE.remove('debug_toolbar.middleware.DebugToolbarMiddleware')
