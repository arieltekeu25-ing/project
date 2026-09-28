# Règles de Sécurité Firestore - GestionBailleur

## Table des matières

1. [Principes de Sécurité](#principes-de-sécurité)
2. [Règles d'Authentification](#règles-dauthentification)
3. [Règles par Collection](#règles-par-collection)
4. [Règles de Validation](#règles-de-validation)
5. [Règles de Rate Limiting](#règles-de-rate-limiting)
6. [Règles d'Audit](#règles-daudit)

---

## Principes de Sécurité

### 1. Principe de Moindre Privilège
- Les utilisateurs ne peuvent accéder qu'aux données nécessaires
- Les administrateurs ont un accès contrôlé
- Les données sensibles sont protégées

### 2. Validation Côté Serveur
- Toutes les données sont validées avant écriture
- Les types sont vérifiés
- Les contraintes sont appliquées

### 3. Authentification Requise
- La plupart des opérations nécessitent une authentification
- Les visiteurs ont un accès limité en lecture seule
- Les tokens sont validés

### 4. Propriété des Données
- Les utilisateurs ne peuvent modifier que leurs propres données
- Les bailleurs ne peuvent modifier que leurs logements
- Les administrateurs peuvent modifier toutes les données

---

## Règles d'Authentification

### Variables Globales

```javascript
// Helper functions
function isAuthenticated() {
  return request.auth != null;
}

function isVisitor() {
  return request.auth == null;
}

function getUserId() {
  return request.auth.uid;
}

function hasRole(role) {
  return get(/databases/$(database)/documents/users/$(request.auth.uid)/data).role == role;
}

function isClient() {
  return hasRole('client');
}

function isLandlord() {
  return hasRole('landlord');
}

function isAdmin() {
  return hasRole('admin');
}

function isSuperAdmin() {
  return hasRole('admin') && 
         get(/databases/$(database)/documents/users/$(request.auth.uid)/data).isSuperAdmin == true;
}

function isActiveUser() {
  return get(/databases/$(database)/documents/users/$(request.auth.uid)/data).status == 'active';
}

function isVerifiedLandlord() {
  return isLandlord() && 
         get(/databases/$(database)/documents/landlords/$(request.auth.uid)/data).verificationStatus == 'approved';
}

function isVerifiedClient() {
  return isClient() && 
         get(/databases/$(database)/documents/clients/$(request.auth.uid)/data).verificationStatus == 'approved';
}
```

---

## Règles par Collection

### users

```javascript
match /users/{userId} {
  // Lecture : Public pour les profils, privé pour les données sensibles
  allow read: if isVisitor() || 
                isAuthenticated() && 
                (request.auth.uid == userId || isAdmin());
  
  // Création : Public (inscription)
  allow create: if isVisitor() &&
                   request.resource.data.email.matches('^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$') &&
                   request.resource.data.firstName.size() >= 2 &&
                   request.resource.data.lastName.size() >= 2 &&
                   request.resource.data.role in ['client', 'landlord'];
  
  // Modification : Propriétaire ou admin
  allow update: if (request.auth.uid == userId && isActiveUser()) ||
                  isAdmin();
  
  // Suppression : Propriétaire ou admin
  allow delete: if (request.auth.uid == userId && isActiveUser()) ||
                  isAdmin();
  
  // Sous-collections
  match /profile/{profileId} {
    allow read, write: if request.auth.uid == userId || isAdmin();
  }
  
  match /settings/{settingsId} {
    allow read, write: if request.auth.uid == userId || isAdmin();
  }
  
  match /sessions/{sessionId} {
    allow read, write: if request.auth.uid == userId || isAdmin();
  }
  
  match /favorites/{favoriteId} {
    allow read: if request.auth.uid == userId || isAdmin();
    allow create: if request.auth.uid == userId;
    allow update, delete: if request.auth.uid == userId;
  }
  
  match /searches/{searchId} {
    allow read, write: if request.auth.uid == userId;
  }
  
  match /saved_searches/{savedSearchId} {
    allow read, write: if request.auth.uid == userId;
  }
  
  match /notifications/{notificationId} {
    allow read, if request.auth.uid == userId;
    allow update: if request.auth.uid == userId && 
                    request.resource.data.isRead == true;
    allow delete: if request.auth.uid == userId;
  }
  
  match /verification_docs/{docId} {
    allow read: if request.auth.uid == userId || isAdmin();
    allow create: if request.auth.uid == userId;
    allow update: if isAdmin();
    allow delete: if isAdmin();
  }
  
  match /chatbot_conversations/{chatbotId} {
    allow read, write: if request.auth.uid == userId;
  }
}
```

---

### clients

```javascript
match /clients/{clientId} {
  allow read: if request.auth.uid == resource.data.userId || isAdmin();
  allow create: if request.auth.uid == request.resource.data.userId && isClient();
  allow update: if (request.auth.uid == resource.data.userId && isActiveUser()) ||
                  isAdmin();
  allow delete: if isAdmin();
}
```

---

### landlords

```javascript
match /landlords/{landlordId} {
  allow read: if request.auth.uid == resource.data.userId || isAdmin();
  allow create: if request.auth.uid == request.resource.data.userId && isLandlord();
  allow update: if (request.auth.uid == resource.data.userId && isActiveUser()) ||
                  isAdmin();
  allow delete: if isAdmin();
}
```

---

### admins

```javascript
match /admins/{adminId} {
  allow read: if isAdmin();
  allow create: if isSuperAdmin();
  allow update: if isSuperAdmin() || request.auth.uid == adminId;
  allow delete: if isSuperAdmin();
}
```

---

### properties

```javascript
match /properties/{propertyId} {
  // Lecture : Public pour les logements publiés
  allow read: if resource.data.status == 'published' ||
                request.auth.uid == resource.data.landlordId ||
                isAdmin();
  
  // Création : Bailleur vérifié uniquement
  allow create: if isVerifiedLandlord() &&
                   request.resource.data.landlordId == request.auth.uid &&
                   request.resource.data.status == 'draft' &&
                   request.resource.data.photoUrls.size() >= 1;
  
  // Modification : Propriétaire ou admin
  allow update: if (request.auth.uid == resource.data.landlordId && 
                    isActiveUser() &&
                    resource.data.status != 'deleted') ||
                   isAdmin();
  
  // Suppression : Propriétaire (sans visites actives) ou admin
  allow delete: if isAdmin() ||
                  (request.auth.uid == resource.data.landlordId && 
                   isActiveUser() &&
                   !exists(/databases/$(database)/documents/properties/$(propertyId)/visits));
  
  // Sous-collections
  match /photos/{photoId} {
    allow read: if true;
    allow create, update, delete: if request.auth.uid == resource.data.landlordId || isAdmin();
  }
  
  match /videos/{videoId} {
    allow read: if true;
    allow create, update, delete: if request.auth.uid == resource.data.landlordId || isAdmin();
  }
  
  match /reviews/{reviewId} {
    allow read: if true;
    allow create: if isVerifiedClient() &&
                    request.resource.data.userId == request.auth.uid &&
                    request.resource.data.rating >= 1 &&
                    request.resource.data.rating <= 5;
    allow update: if request.auth.uid == resource.data.userId ||
                    (request.auth.uid == resource.data.landlordId && 
                     request.resource.data.landlordResponse != null);
    allow delete: if isAdmin();
  }
  
  match /visits/{visitId} {
    allow read: if request.auth.uid == resource.data.clientId ||
                  request.auth.uid == resource.data.landlordId ||
                  isAdmin();
    allow create: if isVerifiedClient() &&
                    request.resource.data.clientId == request.auth.uid;
    allow update: if request.auth.uid == resource.data.landlordId ||
                    isAdmin();
    allow delete: if isAdmin();
  }
  
  match /reports/{reportId} {
    allow read: if request.auth.uid == resource.data.authorId || isAdmin();
    allow create: if isAuthenticated() &&
                    request.resource.data.authorId == request.auth.uid;
    allow update: if isAdmin();
    allow delete: if isAdmin();
  }
}
```

---

### categories

```javascript
match /categories/{categoryId} {
  allow read: if true;
  allow create, update, delete: if isAdmin();
}
```

---

### types

```javascript
match /types/{typeId} {
  allow read: if true;
  allow create, update, delete: if isAdmin();
}
```

---

### equipment

```javascript
match /equipment/{equipmentId} {
  allow read: if true;
  allow create, update, delete: if isAdmin();
}
```

---

### favorites

```javascript
match /favorites/{favoriteId} {
  allow read: if request.auth.uid == resource.data.userId || isAdmin();
  allow create: if request.auth.uid == request.resource.data.userId;
  allow update, delete: if request.auth.uid == resource.data.userId;
}
```

---

### conversations

```javascript
match /conversations/{conversationId} {
  allow read: if request.auth.uid == resource.data.participant1Id ||
                request.auth.uid == resource.data.participant2Id ||
                isAdmin();
  allow create: if isVerifiedClient() &&
                  (request.resource.data.participant1Id == request.auth.uid ||
                   request.resource.data.participant2Id == request.auth.uid);
  allow update: if request.auth.uid == resource.data.participant1Id ||
                  request.auth.uid == resource.data.participant2Id ||
                  isAdmin();
  allow delete: if request.auth.uid == resource.data.participant1Id ||
                  request.auth.uid == resource.data.participant2Id ||
                  isAdmin();
  
  match /messages/{messageId} {
    allow read: if request.auth.uid == resource.data.senderId ||
                  request.auth.uid == resource.data.recipientId ||
                  isAdmin();
    allow create: if request.auth.uid == request.resource.data.senderId;
    allow update: if isAdmin();
    allow delete: if isAdmin();
  }
}
```

---

### notifications

```javascript
match /notifications/{notificationId} {
  allow read: if request.auth.uid == resource.data.userId;
  allow create: if isAdmin() || request.auth.uid == resource.data.userId;
  allow update: if request.auth.uid == resource.data.userId &&
                  request.resource.data.isRead == true;
  allow delete: if request.auth.uid == resource.data.userId;
}
```

---

### visits

```javascript
match /visits/{visitId} {
  allow read: if request.auth.uid == resource.data.clientId ||
                request.auth.uid == resource.data.landlordId ||
                isAdmin();
  allow create: if isVerifiedClient() &&
                  request.resource.data.clientId == request.auth.uid;
  allow update: if request.auth.uid == resource.data.landlordId ||
                  isAdmin();
  allow delete: if isAdmin();
}
```

---

### visit_schedules

```javascript
match /visit_schedules/{scheduleId} {
  allow read: if request.auth.uid == resource.data.landlordId || isAdmin();
  allow create: if isVerifiedLandlord() &&
                  request.resource.data.landlordId == request.auth.uid;
  allow update: if request.auth.uid == resource.data.landlordId || isAdmin();
  allow delete: if request.auth.uid == resource.data.landlordId || isAdmin();
}
```

---

### reports

```javascript
match /reports/{reportId} {
  allow read: if request.auth.uid == resource.data.authorId || isAdmin();
  allow create: if isAuthenticated() &&
                  request.resource.data.authorId == request.auth.uid;
  allow update: if isAdmin();
  allow delete: if isAdmin();
}
```

---

### verification_documents

```javascript
match /verification_documents/{docId} {
  allow read: if request.auth.uid == resource.data.userId || isAdmin();
  allow create: if request.auth.uid == request.resource.data.userId;
  allow update: if isAdmin();
  allow delete: if isAdmin();
}
```

---

### searches

```javascript
match /searches/{searchId} {
  allow read, write: if request.auth.uid == resource.data.userId;
}
```

---

### saved_searches

```javascript
match /saved_searches/{savedSearchId} {
  allow read, write: if request.auth.uid == resource.data.userId;
}
```

---

### chatbot_conversations

```javascript
match /chatbot_conversations/{chatbotId} {
  allow read, write: if request.auth.uid == resource.data.userId;
  
  match /messages/{messageId} {
    allow read, write: if request.auth.uid == resource.data.userId;
  }
}
```

---

### cities

```javascript
match /cities/{cityId} {
  allow read: if true;
  allow create, update, delete: if isAdmin();
  
  match /districts/{districtId} {
    allow read: if true;
    allow create, update, delete: if isAdmin();
  }
}
```

---

### districts

```javascript
match /districts/{districtId} {
  allow read: if true;
  allow create, update, delete: if isAdmin();
}
```

---

### addresses

```javascript
match /addresses/{addressId} {
  allow read: if true;
  allow create: if isAuthenticated();
  allow update: if isAdmin();
  allow delete: if isAdmin();
}
```

---

### audit_logs

```javascript
match /audit_logs/{logId} {
  allow read, create: if isAdmin();
  allow update, delete: if isSuperAdmin();
}
```

---

### analytics

```javascript
match /analytics/{analyticsId} {
  allow read: if isAdmin();
  allow create, update, delete: if isAdmin();
}
```

---

### counters

```javascript
match /counters/{counterId} {
  allow read: if true;
  allow create, update, delete: if isAdmin();
}
```

---

### config

```javascript
match /config/{configId} {
  allow read: if true;
  allow create, update, delete: if isSuperAdmin();
}
```

---

### maintenance

```javascript
match /maintenance/{maintenanceId} {
  allow read: if true;
  allow create, update, delete: if isSuperAdmin();
}
```

---

## Règles de Validation

### Validation des Emails

```javascript
function isValidEmail(email) {
  return email.matches('^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$');
}
```

### Validation des Téléphones

```javascript
function isValidPhone(phone) {
  return phone.matches('^\\+?[0-9]{10,15}$');
}
```

### Validation des URLs

```javascript
function isValidUrl(url) {
  return url.matches('^https?://[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}(/.*)?$');
}
```

### Validation des Prix

```javascript
function isValidPrice(price) {
  return price > 0 && price <= 1000000000;
}
```

### Validation des Surfaces

```javascript
function isValidSurface(surface) {
  return surface > 0 && surface <= 10000;
}
```

### Validation des Notes

```javascript
function isValidRating(rating) {
  return rating >= 1 && rating <= 5;
}
```

### Validation des Dates

```javascript
function isValidDate(date) {
  return date != null && date.toDate() > new Date();
}
```

---

## Règles de Rate Limiting

### Limitation des Écritures

```javascript
// Maximum 10 écritures par minute par utilisateur
function isWriteRateLimited() {
  return request.time < resource.data.lastWriteTime + duration.value(1, 'm');
}
```

### Limitation des Créations

```javascript
// Maximum 5 créations par heure par utilisateur
function isCreateRateLimited() {
  const lastHour = request.time - duration.value(1, 'h');
  const count = get(/databases/$(database)/documents/audit_logs)
    .where('userId', '==', request.auth.uid)
    .where('actionType', '==', 'create')
    .where('createdAt', '>', lastHour)
    .count();
  return count >= 5;
}
```

---

## Règles d'Audit

### Logging des Actions

```javascript
// Toutes les écritures doivent être loggées
function logAction(actionType, entityType, entityId) {
  return create(/databases/$(database)/documents/audit_logs/$(request.auth.uid), {
    userId: request.auth.uid,
    actionType: actionType,
    entityType: entityType,
    entityId: entityId,
    ipAddress: request.ip,
    userAgent: request.userAgent,
    createdAt: request.time
  });
}
```

---

## Règles Spéciales

### Protection contre la Suppression en Cascade

```javascript
// Empêcher la suppression d'un utilisateur avec des logements actifs
function hasActiveProperties(userId) {
  return exists(/databases/$(database)/documents/properties)
    .where('landlordId', '==', userId)
    .where('status', '==', 'published');
}
```

### Protection contre la Modification de Statut

```javascript
// Seuls les admins peuvent modifier le statut
function canModifyStatus() {
  return isAdmin();
}
```

### Protection des Données Sensibles

```javascript
// Les données sensibles ne peuvent être lues que par le propriétaire ou admin
function isSensitiveData(field) {
  return field in ['email', 'phone', 'idNumber', 'monthlyIncome'];
}
```

---

## Règles de Maintenance

### Mode Maintenance

```javascript
// En mode maintenance, seule la lecture est autorisée
function isMaintenanceMode() {
  return get(/databases/$(database)/documents/config/maintenance_mode).value == true;
}

// Appliquer à toutes les collections
allow read: if !isMaintenanceMode();
allow write: if !isMaintenanceMode() && isAdmin();
```

---

## Règles de Test

### Environnement de Test

```javascript
// En environnement de test, règles plus permissives
function isTestEnvironment() {
  return projectId == 'gestionbailleur-test';
}

if (isTestEnvironment()) {
  match /{path=**} {
    allow read, write: if true;
  }
}
```

---

## Règles de Production

### Environnement de Production

```javascript
// En production, règles strictes
function isProductionEnvironment() {
  return projectId == 'gestionbailleur-prod';
}

if (isProductionEnvironment()) {
  // Logging obligatoire
  function requireAuditLog() {
    return exists(/databases/$(database)/documents/audit_logs/$(request.auth.uid));
  }
  
  // Validation stricte
  function requireStrictValidation() {
    return request.resource.data.size() < 1000000; // 1MB max
  }
}
```

---

## Règles par Défaut

### Règle de Fallback

```javascript
// Par défaut, refuser tout accès non explicitement autorisé
match /{path=**} {
  allow read, write: if false;
}
```

---

## Bonnes Pratiques

### 1. Toujours Valider l'Authentification
```javascript
allow read, write: if request.auth != null;
```

### 2. Toujours Valider la Propriété
```javascript
allow write: if request.auth.uid == resource.data.userId;
```

### 3. Toujours Valider les Données
```javascript
allow create: if request.resource.data.email.matches('^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$');
```

### 4. Utiliser des Fonctions Helper
```javascript
function isOwner(userId) {
  return request.auth.uid == userId;
}
```

### 5. Logger les Actions Sensibles
```javascript
allow delete: if isAdmin() && logAction('delete', 'user', userId);
```

### 6. Limiter la Taille des Documents
```javascript
allow create: if request.resource.data.size() < 1000000;
```

### 7. Limiter les Tableaux
```javascript
allow create: if request.resource.data.photos.size() <= 20;
```

### 8. Valider les Types
```javascript
allow create: if request.resource.data.price is number;
```

### 9. Utiliser des Index pour les Requêtes
```javascript
// Les index doivent être créés pour les requêtes complexes
allow read: if request.query.orderBy == 'createdAt';
```

### 10. Tester les Règles
```javascript
// Toujours tester les règles en environnement de test avant déploiement
```
