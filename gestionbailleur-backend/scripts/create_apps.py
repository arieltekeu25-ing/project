#!/usr/bin/env python
"""
Script pour créer la structure des applications Django
"""

import os
import sys

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

APPS = [
    'profiles',
    'landlords',
    'clients',
    'properties',
    'categories',
    'locations',
    'favorites',
    'search',
    'messages',
    'chatbot',
    'notifications',
    'reviews',
    'visits',
    'verification',
    'reports',
    'statistics',
    'dashboard',
    'common',
    'core',
    'audit',
    'files',
    'settings',
]

SUBDIRS = [
    'models',
    'services',
    'repositories',
    'selectors',
    'validators',
    'permissions',
    'serializers',
    'views',
    'urls',
    'tasks',
    'signals',
    'tests',
    'exceptions',
    'constants',
]

def create_app_structure(app_name):
    """Crée la structure complète d'une application Django"""
    app_path = os.path.join(BASE_DIR, app_name)
    
    # Créer le dossier principal de l'app
    os.makedirs(app_path, exist_ok=True)
    
    # Créer tous les sous-dossiers
    for subdir in SUBDIRS:
        subdir_path = os.path.join(app_path, subdir)
        os.makedirs(subdir_path, exist_ok=True)
        
        # Créer __init__.py dans chaque sous-dossier
        init_file = os.path.join(subdir_path, '__init__.py')
        with open(init_file, 'w') as f:
            f.write(f'"""\nModule {app_name}.{subdir}\n"""\n')
    
    # Créer __init__.py principal de l'app
    init_file = os.path.join(app_path, '__init__.py')
    with open(init_file, 'w') as f:
        f.write(f'"""\nApplication Django {app_name}\n"""\n')
    
    # Créer apps.py
    apps_file = os.path.join(app_path, 'apps.py')
    with open(apps_file, 'w') as f:
        f.write(f'''"""
Configuration de l'application {app_name}
"""
from django.apps import AppConfig


class {app_name.capitalize()}Config(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apps.{app_name}'
    verbose_name = '{app_name.capitalize()}'
''')
    
    # Créer admin.py
    admin_file = os.path.join(app_path, 'admin.py')
    with open(admin_file, 'w') as f:
        f.write(f'''"""
Configuration de l'admin pour {app_name}
"""
from django.contrib import admin


# Register your models here.
''')
    
    print(f"✓ Application {app_name} créée avec succès")

def main():
    """Fonction principale"""
    print("Création de la structure des applications Django...")
    print(f"Répertoire de base: {BASE_DIR}")
    print()
    
    for app in APPS:
        try:
            create_app_structure(app)
        except Exception as e:
            print(f"✗ Erreur lors de la création de {app}: {e}")
    
    print()
    print("Création terminée!")

if __name__ == '__main__':
    main()
