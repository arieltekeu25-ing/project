"""
Configuration de production
Configuration spécifique pour l'environnement de production
"""
from .base import *

DEBUG = False

# Détecter si on est sur Railway
IS_RAILWAY = os.environ.get('RAILWAY_ENVIRONMENT') or os.environ.get('RAILWAY')

ALLOWED_HOSTS = os.environ.get('ALLOWED_HOSTS', '').split(',')
# Filtrer les chaînes vides
ALLOWED_HOSTS = [host for host in ALLOWED_HOSTS if host]

# Sécurité renforcée pour la production
# SECURE_SSL_REDIRECT : désactivé sur Railway (activé si domaine personnalisé avec SSL)
if IS_RAILWAY:
    SECURE_SSL_REDIRECT = False
    SECURE_HSTS_SECONDS = 0
    SECURE_HSTS_INCLUDE_SUBDOMAINS = False
    SECURE_HSTS_PRELOAD = False
else:
    SECURE_SSL_REDIRECT = True
    SECURE_HSTS_SECONDS = 31536000
    SECURE_HSTS_INCLUDE_SUBDOMAINS = True
    SECURE_HSTS_PRELOAD = True

SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
SECURE_BROWSER_XSS_FILTER = True
SECURE_CONTENT_TYPE_NOSNIFF = True
X_FRAME_OPTIONS = 'DENY'

# Database PostgreSQL en production
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.environ.get('DB_NAME'),
        'USER': os.environ.get('DB_USER'),
        'PASSWORD': os.environ.get('DB_PASSWORD'),
        'HOST': os.environ.get('DB_HOST'),
        'PORT': os.environ.get('DB_PORT', '5432'),
        'OPTIONS': {
            'sslmode': 'require',
        },
    }
}

# Email backend SMTP réel
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = os.environ.get('EMAIL_HOST')
EMAIL_PORT = int(os.environ.get('EMAIL_PORT', 587))
EMAIL_USE_TLS = True
EMAIL_HOST_USER = os.environ.get('EMAIL_HOST_USER')
EMAIL_HOST_PASSWORD = os.environ.get('EMAIL_HOST_PASSWORD')
DEFAULT_FROM_EMAIL = os.environ.get('DEFAULT_FROM_EMAIL')

# Logging en production (console pour Railway, fichier pour Render/local)
# Détecter si on est sur Railway
IS_RAILWAY = os.environ.get('RAILWAY_ENVIRONMENT') or os.environ.get('RAILWAY')

# Construire la configuration de base
base_logging_config = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '{levelname} {asctime} {module} {process:d} {thread:d} {message}',
            'style': '{',
        },
    },
}

if IS_RAILWAY:
    # Configuration Railway : logs vers console uniquement
    base_logging_config['handlers'] = {
        'console': {
            'level': 'WARNING',
            'class': 'logging.StreamHandler',
            'formatter': 'verbose',
        },
    }
    base_logging_config['root'] = {
        'handlers': ['console'],
        'level': 'WARNING',
    }
    base_logging_config['loggers'] = {
        'django': {
            'handlers': ['console'],
            'level': 'WARNING',
            'propagate': False,
        },
        'django.security': {
            'handlers': ['console'],
            'level': 'ERROR',
            'propagate': False,
        },
    }
else:
    # Configuration Render/local : logs vers fichier (avec création du dossier logs)
    import os
    logs_dir = BASE_DIR / 'logs'
    logs_dir.mkdir(parents=True, exist_ok=True)
    
    base_logging_config['handlers'] = {
        'file': {
            'level': 'WARNING',
            'class': 'logging.handlers.RotatingFileHandler',
            'filename': logs_dir / 'django.log',
            'maxBytes': 1024 * 1024 * 100,  # 100MB
            'backupCount': 10,
            'formatter': 'verbose',
        },
    }
    base_logging_config['root'] = {
        'handlers': ['file'],
        'level': 'WARNING',
    }
    base_logging_config['loggers'] = {
        'django': {
            'handlers': ['file'],
            'level': 'WARNING',
            'propagate': False,
        },
        'django.security': {
            'handlers': ['file'],
            'level': 'ERROR',
            'propagate': False,
        },
    }

# Ajouter Sentry uniquement si SENTRY_DSN est configuré
if os.environ.get('SENTRY_DSN'):
    try:
        import sentry_sdk
        from sentry_sdk.integrations.django import DjangoIntegration
        
        # Initialiser Sentry
        sentry_sdk.init(
            dsn=os.environ.get('SENTRY_DSN'),
            integrations=[DjangoIntegration()],
            traces_sample_rate=0.1,
            send_default_pii=False,
        )
        
        # Ajouter le handler Sentry si disponible
        if hasattr(sentry_sdk.integrations.django, 'SentryHandler'):
            base_logging_config['handlers']['sentry'] = {
                'level': 'ERROR',
                'class': 'sentry_sdk.integrations.django.SentryHandler',
            }
            # Ajouter sentry aux handlers existants
            for logger_name in ['root', 'django', 'django.security']:
                if logger_name in base_logging_config['loggers']:
                    base_logging_config['loggers'][logger_name]['handlers'].append('sentry')
                elif logger_name == 'root':
                    base_logging_config['root']['handlers'].append('sentry')
    except ImportError:
        # Sentry non installé, ignorer silencieusement
        pass

LOGGING = base_logging_config

# CORS restreint en production (temporairement permissif pour le développement)
CORS_ALLOW_ALL_ORIGINS = True  # Temporairement True pour le développement Flutter Web
CORS_ALLOWED_ORIGINS = os.environ.get('CORS_ALLOWED_ORIGINS', '').split(',')
# Filtrer les chaînes vides
CORS_ALLOWED_ORIGINS = [origin for origin in CORS_ALLOWED_ORIGINS if origin]

# Rate limiting activé
RATELIMIT_ENABLE = True

# Cache Redis en production
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.redis.RedisCache',
        'LOCATION': os.environ.get('REDIS_URL'),
        'OPTIONS': {
            'CLIENT_CLASS': 'django_redis.client.DefaultClient',
            'CONNECTION_POOL_KWARGS': {'max_connections': 100}
        },
        'KEY_PREFIX': 'gestionbailleur_prod',
    }
}

# Static files servis par whitenoise en production
STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'

# Media files servis via CDN ou stockage S3
DEFAULT_FILE_STORAGE = 'storages.backends.s3boto3.S3Boto3Storage'
AWS_ACCESS_KEY_ID = os.environ.get('AWS_ACCESS_KEY_ID')
AWS_SECRET_ACCESS_KEY = os.environ.get('AWS_SECRET_ACCESS_KEY')
AWS_STORAGE_BUCKET_NAME = os.environ.get('AWS_STORAGE_BUCKET_NAME')
AWS_S3_REGION_NAME = os.environ.get('AWS_S3_REGION_NAME', 'us-east-1')
AWS_S3_CUSTOM_DOMAIN = os.environ.get('AWS_S3_CUSTOM_DOMAIN')
AWS_LOCATION = 'media'
AWS_DEFAULT_ACL = 'public-read'
