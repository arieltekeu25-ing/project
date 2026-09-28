# Guide de l'API REST GestionBailleur

## Architecture de la Base de Données

**Note importante :** L'API GestionBailleur utilise PostgreSQL comme base de données principale pour toutes les données métier. Firebase n'est PAS utilisé comme base de données.

**PostgreSQL :**
- Toutes les données métier (utilisateurs, logements, messages, etc.)
- Modèles relationnels Django ORM
- Transactions ACID
- Requêtes complexes avec joins

**Firebase (services auxiliaires uniquement) :**
- Firebase Storage : Stockage des images/documents (optionnel)
- Firebase Cloud Messaging : Notifications push (optionnel)

## Base URL

- **Development**: `http://localhost:8000/api/v1/`
- **Production**: `https://api.gestionbailleur.com/api/v1/`

## Authentication

L'API utilise l'authentification JWT (JSON Web Tokens).

### Login

```http
POST /api/v1/auth/login/
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "role": "client"
  }
}
```

### Utilisation du Token

Ajoutez le header `Authorization` à chaque requête protégée :

```http
Authorization: Bearer <access_token>
```

### Refresh Token

```http
POST /api/v1/auth/refresh/
Content-Type: application/json

{
  "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

## Endpoints Principaux

### Utilisateurs

#### Liste des utilisateurs
```http
GET /api/v1/users/
```

#### Détail utilisateur
```http
GET /api/v1/users/{id}/
```

#### Créer utilisateur
```http
POST /api/v1/users/
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123",
  "nom": "Doe",
  "prenom": "John"
}
```

#### Mettre à jour utilisateur
```http
PUT /api/v1/users/{id}/
Authorization: Bearer <token>
Content-Type: application/json

{
  "nom": "Doe",
  "prenom": "John"
}
```

### Logements

#### Liste des logements
```http
GET /api/v1/properties/
```

**Filtres:**
- `?category=apartment`
- `?min_price=50000&max_price=200000`
- `?city=Abidjan`
- `?bedrooms=2`
- `?search=terrace`

#### Détail logement
```http
GET /api/v1/properties/{id}/
```

#### Créer logement (Bailleur uniquement)
```http
POST /api/v1/properties/
Authorization: Bearer <token>
Content-Type: application/json

{
  "titre": "Appartement moderne",
  "description": "Bel appartement...",
  "prix": 150000,
  "surface": 120,
  "categorie": "apartment",
  "adresse": "123 Rue Principale"
}
```

### Favoris

#### Ajouter aux favoris
```http
POST /api/v1/favorites/
Authorization: Bearer <token>
Content-Type: application/json

{
  "property_id": "uuid"
}
```

#### Liste des favoris
```http
GET /api/v1/favorites/
Authorization: Bearer <token>
```

### Recherche

#### Recherche avancée
```http
POST /api/v1/search/
Authorization: Bearer <token>
Content-Type: application/json

{
  "query": "appartement",
  "filters": {
    "min_price": 50000,
    "max_price": 200000,
    "city": "Abidjan",
    "bedrooms": 2
  }
}
```

### Messages

#### Envoyer un message
```http
POST /api/v1/messages/
Authorization: Bearer <token>
Content-Type: application/json

{
  "conversation_id": "uuid",
  "contenu": "Bonjour, je suis intéressé..."
}
```

#### Liste des conversations
```http
GET /api/v1/messages/conversations/
Authorization: Bearer <token>
```

### Visites

#### Demander une visite
```http
POST /api/v1/visits/
Authorization: Bearer <token>
Content-Type: application/json

{
  "property_id": "uuid",
  "date_visite": "2024-01-15",
  "heure_debut": "10:00"
}
```

## Pagination

Tous les endpoints de liste supportent la pagination :

```http
GET /api/v1/properties/?page=1&page_size=20
```

**Response:**
```json
{
  "count": 150,
  "next": "http://localhost:8000/api/v1/properties/?page=2",
  "previous": null,
  "results": [...]
}
```

## Erreurs

L'API utilise les codes HTTP standards :

- `200 OK` - Succès
- `201 Created` - Ressource créée
- `400 Bad Request` - Requête invalide
- `401 Unauthorized` - Non authentifié
- `403 Forbidden` - Permission refusée
- `404 Not Found` - Ressource non trouvée
- `429 Too Many Requests` - Trop de requêtes
- `500 Internal Server Error` - Erreur serveur

**Format d'erreur:**
```json
{
  "error": "message d'erreur",
  "code": "ERROR_CODE",
  "details": {}
}
```

## Rate Limiting

- 1000 requêtes par heure par IP
- 100 requêtes par minute par utilisateur authentifié

## Documentation Interactive

La documentation interactive est disponible via Swagger UI :

`http://localhost:8000/api/docs/`
