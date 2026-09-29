#!/bin/bash
set -e

# Définir DJANGO_SETTINGS_MODULE pour utiliser production
export DJANGO_SETTINGS_MODULE=config.settings.production

# Appliquer les migrations Django
python manage.py migrate --noinput

# Collecter les fichiers statiques
python manage.py collectstatic --noinput --clear

# Démarrer Gunicorn sur 0.0.0.0:${PORT:-8000}
gunicorn config.wsgi:application --bind 0.0.0.0:${PORT:-8000} --workers 4 --threads 2 --timeout 120 --access-logfile - --error-logfile - --log-level info