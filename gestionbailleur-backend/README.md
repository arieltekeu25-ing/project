# GestionBailleur Backend

Backend Django REST API pour la plateforme immobilière GestionBailleur.

## Description

Ce projet est le backend Django de la plateforme immobilière GestionBailleur, qui met en relation les bailleurs et les clients pour la location de biens immobiliers.

**Architecture de la base de données :**
- **PostgreSQL** : Base de données principale pour toutes les données métier (utilisateurs, logements, messages, etc.)
- **Firebase Storage** : Stockage des images et documents (optionnel)
- **Firebase Cloud Messaging** : Notifications push (optionnel)

**Note :** Firebase n'est PAS utilisé comme base de données. Toutes les données métier sont stockées dans PostgreSQL.

## Architecture

Le projet suit une architecture modulaire avec 21 applications Django :

- **accounts** - Gestion des comptes utilisateurs et authentification
- **profiles** - Profils utilisateurs
- **landlords** - Gestion des bailleurs
- **clients** - Gestion des clients
- **properties** - Gestion des logements
- **categories** - Catégories de logements
- **locations** - Localisations (villes, quartiers)
- **favorites** - Favoris des utilisateurs
- **search** - Recherche et filtres
- **messages** - Messagerie entre utilisateurs
- **chatbot** - Chatbot IA
- **notifications** - Système de notifications
- **reviews** - Avis et évaluations
- **visits** - Gestion des visites
- **verification** - Vérification des documents
- **reports** - Signalements
- **statistics** - Statistiques et analytics
- **dashboard** - Tableau de bord
- **common** - Fonctionnalités communes
- **core** - Cœur de l'application
- **audit** - Audit et logs
- **files** - Gestion des fichiers
- **settings** - Paramètres utilisateurs

## Technologies

- Python 3.10+
- Django 4.2+
- Django REST Framework
- PostgreSQL (Base de données principale)
- Redis (Cache et message broker)
- Celery (Tâches asynchrones)
- JWT Authentication
- Firebase Storage (Stockage images/documents)
- Firebase Cloud Messaging (Notifications push)
- Docker

## Installation

### Prérequis

- Python 3.10 ou supérieur
- PostgreSQL 13+
- Redis 6+
- pip

### Configuration

1. Cloner le repository
```bash
git clone <repository-url>
cd gestionbailleur-backend
```

2. Créer l'environnement virtuel
```bash
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
```

3. Installer les dépendances
```bash
pip install -r requirements/development.txt
```

4. Configurer les variables d'environnement
```bash
cp .env.example .env
# Éditer .env avec vos configurations
```

5. Exécuter les migrations
```bash
python manage.py migrate
```

6. Créer un superutilisateur
```bash
python manage.py createsuperuser
```

7. Démarrer le serveur
```bash
python manage.py runserver
```

## Structure du projet

```
gestionbailleur-backend/
├── apps/                    # Applications Django
├── config/                  # Configuration Django
│   ├── settings/           # Settings par environnement
│   ├── urls.py             # URLs principales
│   ├── wsgi.py             # WSGI
│   └── asgi.py             # ASGI
├── docs/                    # Documentation
├── scripts/                 # Scripts utilitaires
├── media/                   # Fichiers media
├── static/                  # Fichiers statiques
├── logs/                    # Logs
├── requirements/            # Dépendances Python
├── manage.py               # Script de gestion Django
└── .env                    # Variables d'environnement
```

## Documentation

- [Architecture](docs/ARCHITECTURE.md) - Architecture détaillée du projet
- [API Guide](docs/API_GUIDE.md) - Guide de l'API REST
- [Business Domain](docs/business/) - Documentation du domaine métier
- [Database](docs/database/) - Documentation PostgreSQL (MCD, MLD)
- [Firebase Legacy](docs/firebase/legacy/) - Documentation Firebase (Storage/FCM uniquement)
- [Contributing](docs/CONTRIBUTING.md) - Guide de contribution

## Développement

### Lancer les tests
```bash
python manage.py test
```

### Lancer le linter
```bash
flake8
black .
isort .
```

### Lancer Celery
```bash
celery -A config worker -l info
celery -A config beat -l info
```

## Déploiement

Le projet est configuré pour être déployé sur :

- Docker / Docker Compose
- Heroku
- AWS (Elastic Beanstalk, EC2)
- DigitalOcean

## Licence

Ce projet est privé et confidentiel.

## Contact

Pour toute question, contactez l'équipe de développement.