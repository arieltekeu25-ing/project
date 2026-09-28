# Architecture du Backend GestionBailleur

## Vue d'ensemble

Le backend GestionBailleur est construit avec Django REST Framework suivant une architecture modulaire et évolutive.

## Principes Architecturaux

### 1. Séparation des préoccupations
Chaque application Django a une responsabilité unique et bien définie.

### 2. Architecture en couches
- **Models** - Modèles de données Django
- **Repositories** - Accès aux données (pattern Repository)
- **Services** - Logique métier
- **Selectors** - Requêtes complexes et optimisées
- **Validators** - Validation des données
- **Serializers** - Sérialisation API
- **Views** - Contrôleurs API
- **Permissions** - Gestion des permissions

### 3. Pattern Repository
Les repositories encapsulent la logique d'accès aux données et fournissent une interface propre aux services.

### 4. Pattern Service
Les services contiennent la logique métier et coordonnent les opérations entre les repositories.

## Structure des Applications

Chaque application Django suit cette structure :

```
app_name/
├── __init__.py
├── apps.py              # Configuration de l'app
├── admin.py             # Configuration admin
├── models/              # Modèles Django
│   ├── __init__.py
│   └── ...
├── repositories/        # Repositories d'accès aux données
│   ├── __init__.py
│   └── ...
├── services/            # Services métier
│   ├── __init__.py
│   └── ...
├── selectors/           # Sélecteurs de requêtes
│   ├── __init__.py
│   └── ...
├── validators/          # Validateurs personnalisés
│   ├── __init__.py
│   └── ...
├── permissions/         # Permissions DRF
│   ├── __init__.py
│   └── ...
├── serializers/         # Serializers DRF
│   ├── __init__.py
│   └── ...
├── views/              # Vues API
│   ├── __init__.py
│   └── ...
├── urls/               # URLs de l'app
│   ├── __init__.py
│   └── ...
├── tasks/              # Tâches Celery
│   ├── __init__.py
│   └── ...
├── signals/            # Signals Django
│   ├── __init__.py
│   └── ...
├── tests/              # Tests
│   ├── __init__.py
│   └── ...
├── exceptions/         # Exceptions personnalisées
│   ├── __init__.py
│   └── ...
└── constants/          # Constantes
    ├── __init__.py
    └── ...
```

## Applications

### Accounts
Gestion des comptes utilisateurs et authentification JWT.

### Profiles
Profils utilisateurs avec informations personnelles.

### Landlords
Gestion spécifique des bailleurs (propriétaires).

### Clients
Gestion spécifique des clients (locataires).

### Properties
Gestion complète des logements avec caractéristiques.

### Categories
Catégories et types de logements.

### Locations
Géolocalisation (villes, quartiers, adresses).

### Favorites
Système de favoris des utilisateurs.

### Search
Moteur de recherche avancé avec filtres.

### Messages
Système de messagerie entre utilisateurs.

### Chatbot
Chatbot IA pour assistance.

### Notifications
Système de notifications multi-canaux.

### Reviews
Avis et évaluations des logements.

### Visits
Gestion des visites et planning.

### Verification
Vérification des documents utilisateurs.

### Reports
Système de signalements.

### Statistics
Statistiques et analytics.

### Dashboard
Tableau de bord administrateur.

### Common
Fonctionnalités communes partagées.

### Core
Cœur de l'application (utils, exceptions globales).

### Audit
Audit trail et logs système.

### Files
Gestion des fichiers uploadés.

### Settings
Paramètres utilisateurs.

## Flux de Requête

1. **Request** → Nginx
2. **Nginx** → Django ASGI
3. **Django** → Middleware
4. **Middleware** → View
5. **View** → Serializer
6. **Serializer** → Validator
7. **Validator** → Service
8. **Service** → Repository
9. **Repository** → Database
10. **Response** → Client

## Base de Données

### PostgreSQL (Base de données principale)
- **Toutes les données métier sont stockées dans PostgreSQL**
- Modèles relationnels Django ORM
- Indexes optimisés pour les requêtes fréquentes
- Transactions ACID pour l'intégrité des données
- Support des requêtes complexes avec joins
- Scalabilité horizontale via replication

**Données stockées dans PostgreSQL :**
- Utilisateurs (User, Profile)
- Clients (Client)
- Bailleurs (Landlord)
- Administrateurs (Admin)
- Logements (Property, PropertyPhoto, PropertyVideo)
- Catégories et types (Category, Type)
- Localisations (City, District, Address)
- Équipements (Equipment)
- Favoris (Favorite)
- Recherches (Search, SavedSearch)
- Messagerie (Conversation, Message)
- Notifications (Notification)
- Avis (Review)
- Visites (Visit, VisitSchedule)
- Signalements (Report)
- Documents de vérification (VerificationDocument)
- Sessions utilisateur (UserSession)
- Paramètres (UserSettings)
- Logs d'audit (AuditLog)

### Redis
- Cache des données fréquemment accédées
- Sessions utilisateur
- Queue Celery pour tâches asynchrones
- Rate limiting
- Locks distribués

### Firebase (Services auxiliaires uniquement)
**Note :** Firebase n'est PAS utilisé comme base de données.

**Firebase Storage (optionnel) :**
- Stockage des images de logements
- Stockage des avatars utilisateurs
- Stockage des documents de vérification
- Stockage des pièces jointes messages

**Firebase Cloud Messaging (optionnel) :**
- Notifications push mobile
- Notifications en temps réel

## Sécurité

- JWT Authentication
- Permissions granulaires
- Rate limiting
- CORS configuré
- HTTPS en production
- Validation des inputs

## Performance

- Cache Redis
- Selecteurs optimisés
- Pagination
- Lazy loading
- Indexes database

## Scalabilité

- Architecture modulaire
- Services découplés
- Celery pour tâches async
- Cache distribué
- Load balancing ready
