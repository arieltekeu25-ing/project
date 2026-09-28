# Indexes Firestore - GestionBailleur

## Table des matières

1. [Indexes Single Field](#indexes-single-field)
2. [Indexes Composite](#indexes-composite)
3. [Indexes Geospatial](#indexes-geospatial)
4. [Configuration des Indexes](#configuration-des-indexes)
5. [Optimisations](#optimisations)

---

## Indexes Single Field

### users

| Champ | Ordre | Description |
|-------|-------|-------------|
| email | ASC | Recherche par email (unique) |
| phone | ASC | Recherche par téléphone (unique) |
| role | ASC | Filtrage par rôle |
| status | ASC | Filtrage par statut |
| createdAt | DESC | Tri par date de création |
| lastLoginAt | DESC | Tri par dernière connexion |

### clients

| Champ | Ordre | Description |
|-------|-------|-------------|
| userId | ASC | Recherche par utilisateur (unique) |
| verificationStatus | ASC | Filtrage par statut de vérification |
| status | ASC | Filtrage par statut |
| createdAt | DESC | Tri par date de création |

### landlords

| Champ | Ordre | Description |
|-------|-------|-------------|
| userId | ASC | Recherche par utilisateur (unique) |
| verificationStatus | ASC | Filtrage par statut de vérification |
| status | ASC | Filtrage par statut |
| createdAt | DESC | Tri par date de création |

### admins

| Champ | Ordre | Description |
|-------|-------|-------------|
| userId | ASC | Recherche par utilisateur (unique) |
| department | ASC | Filtrage par département |
| status | ASC | Filtrage par statut |
| superiorId | ASC | Recherche par supérieur |

### properties

| Champ | Ordre | Description |
|-------|-------|-------------|
| landlordId | ASC | Filtrage par bailleur |
| categoryId | ASC | Filtrage par catégorie |
| typeId | ASC | Filtrage par type |
| status | ASC | Filtrage par statut |
| price | ASC | Tri par prix croissant |
| price | DESC | Tri par prix décroissant |
| surface | ASC | Tri par surface croissante |
| surface | DESC | Tri par surface décroissante |
| bedrooms | ASC | Filtrage par nombre de chambres |
| viewCount | DESC | Tri par nombre de vues |
| favoriteCount | DESC | Tri par nombre de favoris |
| publishedAt | DESC | Tri par date de publication |
| createdAt | DESC | Tri par date de création |

### categories

| Champ | Ordre | Description |
|-------|-------|-------------|
| name | ASC | Recherche par nom (unique) |
| order | ASC | Tri par ordre |
| status | ASC | Filtrage par statut |

### types

| Champ | Ordre | Description |
|-------|-------|-------------|
| name | ASC | Recherche par nom (unique) |
| order | ASC | Tri par ordre |
| status | ASC | Filtrage par statut |

### equipment

| Champ | Ordre | Description |
|-------|-------|-------------|
| name | ASC | Recherche par nom (unique) |
| category | ASC | Filtrage par catégorie |
| order | ASC | Tri par ordre |
| status | ASC | Filtrage par statut |

### favorites

| Champ | Ordre | Description |
|-------|-------|-------------|
| userId | ASC | Filtrage par utilisateur |
| propertyId | ASC | Filtrage par logement |
| createdAt | DESC | Tri par date de création |

### reviews

| Champ | Ordre | Description |
|-------|-------|-------------|
| userId | ASC | Filtrage par utilisateur |
| propertyId | ASC | Filtrage par logement |
| rating | DESC | Tri par note |
| createdAt | DESC | Tri par date de création |

### conversations

| Champ | Ordre | Description |
|-------|-------|-------------|
| participant1Id | ASC | Filtrage par participant 1 |
| participant2Id | ASC | Filtrage par participant 2 |
| propertyId | ASC | Filtrage par logement |
| lastMessageAt | DESC | Tri par dernier message |
| messageCount | DESC | Tri par nombre de messages |
| status | ASC | Filtrage par statut |

### messages

| Champ | Ordre | Description |
|-------|-------|-------------|
| conversationId | ASC | Filtrage par conversation |
| senderId | ASC | Filtrage par expéditeur |
| recipientId | ASC | Filtrage par destinataire |
| isRead | ASC | Filtrage par statut de lecture |
| createdAt | DESC | Tri par date de création |

### notifications

| Champ | Ordre | Description |
|-------|-------|-------------|
| userId | ASC | Filtrage par utilisateur |
| type | ASC | Filtrage par type |
| isRead | ASC | Filtrage par statut de lecture |
| createdAt | DESC | Tri par date de création |

### visits

| Champ | Ordre | Description |
|-------|-------|-------------|
| propertyId | ASC | Filtrage par logement |
| clientId | ASC | Filtrage par client |
| landlordId | ASC | Filtrage par bailleur |
| visitDate | ASC | Tri par date de visite |
| status | ASC | Filtrage par statut |

### visit_schedules

| Champ | Ordre | Description |
|-------|-------|-------------|
| landlordId | ASC | Filtrage par bailleur |
| propertyId | ASC | Filtrage par logement |
| status | ASC | Filtrage par statut |

### reports

| Champ | Ordre | Description |
|-------|-------|-------------|
| authorId | ASC | Filtrage par auteur |
| entityId | ASC | Filtrage par entité |
| entityType | ASC | Filtrage par type d'entité |
| status | ASC | Filtrage par statut |
| createdAt | DESC | Tri par date de création |

### verification_documents

| Champ | Ordre | Description |
|-------|-------|-------------|
| userId | ASC | Filtrage par utilisateur |
| verificationStatus | ASC | Filtrage par statut de vérification |
| expiryDate | ASC | Tri par date d'expiration |
| status | ASC | Filtrage par statut |

### searches

| Champ | Ordre | Description |
|-------|-------|-------------|
| userId | ASC | Filtrage par utilisateur |
| categoryId | ASC | Filtrage par catégorie |
| typeId | ASC | Filtrage par type |
| cityId | ASC | Filtrage par ville |
| createdAt | DESC | Tri par date de création |

### saved_searches

| Champ | Ordre | Description |
|-------|-------|-------------|
| userId | ASC | Filtrage par utilisateur |
| alertEnabled | ASC | Filtrage par alerte activée |
| status | ASC | Filtrage par statut |
| createdAt | DESC | Tri par date de création |

### chatbot_conversations

| Champ | Ordre | Description |
|-------|-------|-------------|
| userId | ASC | Filtrage par utilisateur |
| lastInteractionAt | DESC | Tri par dernière interaction |
| messageCount | DESC | Tri par nombre de messages |
| status | ASC | Filtrage par statut |

### cities

| Champ | Ordre | Description |
|-------|-------|-------------|
| name | ASC | Recherche par nom |
| country | ASC | Filtrage par pays |
| population | DESC | Tri par population |
| status | ASC | Filtrage par statut |

### districts

| Champ | Ordre | Description |
|-------|-------|-------------|
| cityId | ASC | Filtrage par ville |
| name | ASC | Recherche par nom |
| population | DESC | Tri par population |
| status | ASC | Filtrage par statut |

### addresses

| Champ | Ordre | Description |
|-------|-------|-------------|
| cityId | ASC | Filtrage par ville |
| districtId | ASC | Filtrage par quartier |
| status | ASC | Filtrage par statut |

### audit_logs

| Champ | Ordre | Description |
|-------|-------|-------------|
| userId | ASC | Filtrage par utilisateur |
| actionType | ASC | Filtrage par type d'action |
| entityType | ASC | Filtrage par type d'entité |
| createdAt | DESC | Tri par date de création |

### analytics

| Champ | Ordre | Description |
|-------|-------|-------------|
| metric | ASC | Filtrage par métrique |
| period | ASC | Filtrage par période |
| date | ASC | Tri par date |

---

## Indexes Composite

### users

| Champs | Ordre | Description |
|--------|-------|-------------|
| role, status | ASC, ASC | Filtrage par rôle et statut |
| status, createdAt | ASC, DESC | Filtrage par statut, tri par date |

### properties

| Champs | Ordre | Description |
|--------|-------|-------------|
| landlordId, status | ASC, ASC | Logements d'un bailleur par statut |
| categoryId, status | ASC, ASC | Logements d'une catégorie par statut |
| typeId, status | ASC, ASC | Logements d'un type par statut |
| status, publishedAt | ASC, DESC | Logements publiés triés par date |
| status, price | ASC, ASC | Logements par statut et prix |
| status, surface | ASC, DESC | Logements par statut et surface |
| status, bedrooms | ASC, ASC | Logements par statut et chambres |
| categoryId, price | ASC, ASC | Logements d'une catégorie par prix |
| cityId, status | ASC, ASC | Logements d'une ville par statut |
| districtId, status | ASC, ASC | Logements d'un quartier par statut |
| price, surface | ASC, DESC | Logements par prix et surface |
| bedrooms, price | ASC, ASC | Logements par chambres et prix |

### favorites

| Champs | Ordre | Description |
|--------|-------|-------------|
| userId, createdAt | ASC, DESC | Favoris d'un utilisateur triés par date |
| propertyId, createdAt | ASC, DESC | Favoris d'un logement triés par date |

### reviews

| Champs | Ordre | Description |
|--------|-------|-------------|
| propertyId, rating | ASC, DESC | Avis d'un logement triés par note |
| userId, propertyId | ASC, ASC | Avis d'un utilisateur pour un logement (unique) |
| propertyId, createdAt | ASC, DESC | Avis d'un logement triés par date |

### conversations

| Champs | Ordre | Description |
|--------|-------|-------------|
| participant1Id, status | ASC, ASC | Conversations du participant 1 par statut |
| participant2Id, status | ASC, ASC | Conversations du participant 2 par statut |
| propertyId, status | ASC, ASC | Conversations d'un logement par statut |
| lastMessageAt, status | DESC, ASC | Conversations triées par dernier message |
| participant1Id, lastMessageAt | ASC, DESC | Conversations du participant 1 triées par activité |
| participant2Id, lastMessageAt | ASC, DESC | Conversations du participant 2 triées par activité |

### messages

| Champs | Ordre | Description |
|--------|-------|-------------|
| conversationId, createdAt | ASC, DESC | Messages d'une conversation triés par date |
| senderId, createdAt | ASC, DESC | Messages envoyés par un utilisateur triés par date |
| recipientId, isRead | ASC, ASC | Messages non lus d'un utilisateur |
| recipientId, createdAt | ASC, DESC | Messages reçus par un utilisateur triés par date |

### notifications

| Champs | Ordre | Description |
|--------|-------|-------------|
| userId, isRead | ASC, ASC | Notifications d'un utilisateur par statut de lecture |
| userId, createdAt | ASC, DESC | Notifications d'un utilisateur triées par date |
| type, createdAt | ASC, DESC | Notifications par type triées par date |

### visits

| Champs | Ordre | Description |
|--------|-------|-------------|
| clientId, visitDate | ASC, ASC | Visites d'un client triées par date |
| landlordId, visitDate | ASC, ASC | Visites d'un bailleur triées par date |
| propertyId, visitDate | ASC, ASC | Visites d'un logement triées par date |
| status, visitDate | ASC, ASC | Visites par statut et date |
| clientId, status | ASC, ASC | Visites d'un client par statut |
| landlordId, status | ASC, ASC | Visites d'un bailleur par statut |

### reports

| Champs | Ordre | Description |
|--------|-------|-------------|
| authorId, status | ASC, ASC | Signalements d'un utilisateur par statut |
| entityId, entityType, status | ASC, ASC, ASC | Signalements d'une entité par statut |
| status, createdAt | ASC, DESC | Signalements par statut triés par date |

### verification_documents

| Champs | Ordre | Description |
|--------|-------|-------------|
| userId, verificationStatus | ASC, ASC | Documents d'un utilisateur par statut |
| verificationStatus, status | ASC, ASC | Documents par statut de vérification |
| expiryDate, status | ASC, ASC | Documents par date d'expiration et statut |

### searches

| Champs | Ordre | Description |
|--------|-------|-------------|
| userId, createdAt | ASC, DESC | Recherches d'un utilisateur triées par date |
| cityId, createdAt | ASC, DESC | Recherches dans une ville triées par date |
| categoryId, createdAt | ASC, DESC | Recherches d'une catégorie triées par date |

### saved_searches

| Champs | Ordre | Description |
|--------|-------|-------------|
| userId, alertEnabled | ASC, ASC | Recherches sauvegardées avec alertes |
| userId, status | ASC, ASC | Recherches sauvegardées par statut |

### chatbot_conversations

| Champs | Ordre | Description |
|--------|-------|-------------|
| userId, status | ASC, ASC | Conversations chatbot d'un utilisateur par statut |
| userId, lastInteractionAt | ASC, DESC | Conversations chatbot triées par activité |

### cities

| Champs | Ordre | Description |
|--------|-------|-------------|
| country, name | ASC, ASC | Villes d'un pays triées par nom |
| country, status | ASC, ASC | Villes d'un pays par statut |

### districts

| Champs | Ordre | Description |
|--------|-------|-------------|
| cityId, name | ASC, ASC | Quartiers d'une ville triés par nom |
| cityId, status | ASC, ASC | Quartiers d'une ville par statut |

### audit_logs

| Champs | Ordre | Description |
|--------|-------|-------------|
| userId, createdAt | ASC, DESC | Logs d'un utilisateur triés par date |
| actionType, createdAt | ASC, DESC | Logs par type d'action triés par date |
| entityId, entityType, createdAt | ASC, ASC, DESC | Logs d'une entité triés par date |

### analytics

| Champs | Ordre | Description |
|--------|-------|-------------|
| metric, period, date | ASC, ASC, ASC | Analytics par métrique, période et date |
| date, metric | ASC, ASC | Analytics par date et métrique |

---

## Indexes Geospatial

### properties

| Champ | Description |
|-------|-------------|
| location | Recherche géospatiale des logements |

### cities

| Champ | Description |
|-------|-------------|
| location | Recherche géospatiale des villes |

### districts

| Champ | Description |
|-------|-------------|
| location | Recherche géospatiale des quartiers |

### addresses

| Champ | Description |
|-------|-------------|
| location | Recherche géospatiale des adresses |

### searches

| Champ | Description |
|-------|-------------|
| location | Recherche géospatiale dans les recherches |

### saved_searches

| Champ | Description |
|-------|-------------|
| location | Recherche géospatiale dans les recherches sauvegardées |

---

## Configuration des Indexes

### Fichier firestore.indexes.json

```json
{
  "indexes": [
    {
      "collectionGroup": "users",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "email",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "role",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "status",
          "order": "ASCENDING"
        }
      ]
    },
    {
      "collectionGroup": "properties",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "landlordId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "status",
          "order": "ASCENDING"
        }
      ]
    },
    {
      "collectionGroup": "properties",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "categoryId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "status",
          "order": "ASCENDING"
        }
      ]
    },
    {
      "collectionGroup": "properties",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "status",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "price",
          "order": "ASCENDING"
        }
      ]
    },
    {
      "collectionGroup": "properties",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "location",
          "order": "ASCENDING"
        }
      ],
      "geoPointRadiusIndex": {
        "field": "location",
        "radiusInKm": 50.0
      }
    },
    {
      "collectionGroup": "conversations",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "participant1Id",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "lastMessageAt",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "messages",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "conversationId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "createdAt",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "notifications",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "userId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "isRead",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "createdAt",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "visits",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "clientId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "visitDate",
          "order": "ASCENDING"
        }
      ]
    },
    {
      "collectionGroup": "visits",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "landlordId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "visitDate",
          "order": "ASCENDING"
        }
      ]
    },
    {
      "collectionGroup": "reviews",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "propertyId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "rating",
          "order": "DESCENDING"
        }
      ]
    }
  ],
  "fieldOverrides": []
}
```

---

## Optimisations

### 1. Indexes Uniques

Les indexes uniques sont gérés au niveau application via des contraintes :

```javascript
// Vérifier l'unicité avant création
async function checkEmailUnique(email) {
  const snapshot = await db.collection('users')
    .where('email', '==', email)
    .limit(1)
    .get();
  
  if (!snapshot.empty) {
    throw new Error('Email already exists');
  }
}
```

### 2. Indexes de Collection Group

Pour les sous-collections qui doivent être interrogées globalement :

```json
{
  "collectionGroup": "messages",
  "queryScope": "COLLECTION_GROUP",
  "fields": [
    {
      "fieldPath": "senderId",
      "order": "ASCENDING"
    },
    {
      "fieldPath": "createdAt",
      "order": "DESCENDING"
    }
  ]
}
```

### 3. Indexes de Recherche Texte

Pour la recherche textuelle, utiliser des indexes composites avec des champs de recherche normalisés :

```javascript
// Ajouter un champ de recherche normalisé
{
  "searchName": "appartement moderne cocody".toLowerCase(),
  "searchKeywords": ["appartement", "moderne", "cocody"]
}
```

### 4. Indexes de Pagination

Pour la pagination cursor-based :

```javascript
// Index pour pagination
{
  "fields": [
    { "fieldPath": "createdAt", "order": "DESCENDING" },
    { "fieldPath": "id", "order": "ASCENDING" }
  ]
}
```

### 5. Indexes de Filtres Multiples

Pour les requêtes avec plusieurs filtres :

```javascript
// Index pour recherche avancée
{
  "fields": [
    { "fieldPath": "categoryId", "order": "ASCENDING" },
    { "fieldPath": "minPrice", "order": "ASCENDING" },
    { "fieldPath": "maxPrice", "order": "ASCENDING" },
    { "fieldPath": "bedrooms", "order": "ASCENDING" }
  ]
}
```

### 6. Indexes de Tri

Pour les tris personnalisés :

```javascript
// Index pour tri par pertinence
{
  "fields": [
    { "fieldPath": "relevanceScore", "order": "DESCENDING" },
    { "fieldPath": "createdAt", "order": "DESCENDING" }
  ]
}
```

### 7. Indexes de Date Range

Pour les requêtes sur des plages de dates :

```javascript
// Index pour requêtes temporelles
{
  "fields": [
    { "fieldPath": "visitDate", "order": "ASCENDING" },
    { "fieldPath": "status", "order": "ASCENDING" }
  ]
}
```

### 8. Indexes de Comptage

Pour les requêtes de comptage :

```javascript
// Index pour comptage optimisé
{
  "fields": [
    { "fieldPath": "propertyId", "order": "ASCENDING" },
    { "fieldPath": "status", "order": "ASCENDING" }
  ]
}
```

---

## Bonnes Pratiques

### 1. Créer les Indexes Avant le Déploiement

Les indexes doivent être créés avant le déploiement pour éviter des erreurs de requête.

### 2. Limiter le Nombre d'Indexes

Trop d'indexes peuvent ralentir les écritures. Créer uniquement les indexes nécessaires.

### 3. Utiliser des Indexes Composites pour les Filtres Multiples

Les indexes composites sont plus efficaces que plusieurs indexes single field.

### 4. Utiliser des Indexes Geospatiaux pour la Localisation

Les indexes géospatiaux sont optimisés pour les requêtes de proximité.

### 5. Surveiller l'Utilisation des Indexes

Utiliser Firebase Console pour surveiller l'utilisation des indexes et supprimer ceux non utilisés.

### 6. Tester les Indexes en Environnement de Test

Toujours tester les indexes en environnement de test avant déploiement en production.

### 7. Documenter les Indexes

Documenter la raison de chaque index pour faciliter la maintenance.

### 8. Utiliser des Indexes de Collection Group pour les Sous-collections

Les indexes de collection group permettent d'interroger toutes les sous-collections d'un type.

### 9. Optimiser la Taille des Indexes

Les indexes sur des champs de grande taille (texte long) peuvent être inefficaces.

### 10. Utiliser des Indexes Exemptés pour les Données d'Archive

Les données d'archive n'ont pas besoin d'indexes complexes.

---

## Maintenance des Indexes

### Suppression d'Indexes

Les indexes non utilisés doivent être supprimés pour réduire les coûts et améliorer les performances.

### Recréation d'Indexes

En cas de modification de la structure des données, certains indexes doivent être recréés.

### Monitoring

Surveiller régulièrement les performances des indexes et ajuster si nécessaire.

### Migration

Planifier la migration des indexes lors des mises à jour majeures du schéma.
