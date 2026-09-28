# Collections Firestore - GestionBailleur

## Table des matières

1. [Collections Utilisateurs](#collections-utilisateurs)
2. [Collections Logements](#collections-logements)
3. [Collections Localisation](#collections-localisation)
4. [Collections Communication](#collections-communication)
5. [Collections Gestion](#collections-gestion)
6. [Collections Support](#collections-support)

---

## Collections Utilisateurs

### users

**Description** : Utilisateurs du système avec informations d'authentification

**Structure** :
```javascript
{
  "id": "string (UUID)",
  "email": "string",
  "phone": "string?",
  "firstName": "string",
  "lastName": "string",
  "photoUrl": "string?",
  "dateOfBirth": "timestamp",
  "gender": "string (enum: masculine, feminine, other)",
  "nationality": "string (ISO country code)",
  "preferredLanguage": "string (ISO language code)",
  "role": "string (enum: client, landlord, admin)",
  "status": "string (enum: active, inactive, suspended)",
  "isVerified": "boolean",
  "isActive": "boolean",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "lastLoginAt": "timestamp?"
}
```

**Sous-collections** :
- `profile` - Profil étendu
- `settings` - Paramètres utilisateur
- `sessions` - Sessions actives
- `favorites` - Favoris
- `searches` - Historique recherche
- `saved_searches` - Recherches sauvegardées
- `notifications` - Notifications
- `verification_docs` - Documents vérification
- `chatbot_conversations` - Conversations chatbot

**Relations** :
- 1:1 avec `clients` (si role = client)
- 1:1 avec `landlords` (si role = landlord)
- 1:1 avec `admins` (si role = admin)

---

### clients

**Description** : Informations spécifiques aux clients (locataires)

**Structure** :
```javascript
{
  "id": "string (UUID)",
  "userId": "string (reference to users)",
  "idNumber": "string?",
  "idType": "string (enum: CNI, passport, license)",
  "profession": "string?",
  "monthlyIncome": "number?",
  "employer": "string?",
  "workAddress": "string?",
  "workPhone": "string?",
  "guarantorName": "string?",
  "guarantorPhone": "string?",
  "guarantorAddress": "string?",
  "documents": "array of strings (URLs)",
  "verificationStatus": "string (enum: pending, approved, rejected)",
  "status": "string (enum: active, inactive)",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Sous-collections** : Aucune

**Relations** :
- N:1 avec `users`

---

### landlords

**Description** : Informations spécifiques aux bailleurs (propriétaires)

**Structure** :
```javascript
{
  "id": "string (UUID)",
  "userId": "string (reference to users)",
  "companyName": "string?",
  "registrationNumber": "string?",
  "taxId": "string?",
  "headquartersAddress": "string?",
  "website": "string?",
  "description": "string?",
  "businessPhone": "string?",
  "businessEmail": "string?",
  "properties": "array of strings (property IDs)",
  "legalDocuments": "array of strings (URLs)",
  "isProfessional": "boolean",
  "verificationStatus": "string (enum: pending, approved, rejected)",
  "status": "string (enum: active, inactive)",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Sous-collections** : Aucune

**Relations** :
- N:1 avec `users`
- 1:N avec `properties`

---

### admins

**Description** : Administrateurs système

**Structure** :
```javascript
{
  "id": "string (UUID)",
  "userId": "string (reference to users)",
  "permissions": "array of strings",
  "mandatExpiryDate": "timestamp?",
  "superiorId": "string (reference to admins)?",
  "isSuperAdmin": "boolean",
  "department": "string",
  "position": "string?",
  "status": "string (enum: active, inactive)",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Sous-collections** : Aucune

**Relations** :
- N:1 avec `users`
- N:1 avec `admins` (superieur)

---

### user_settings

**Description** : Paramètres et préférences utilisateur

**Structure** :
```javascript
{
  "id": "string (UUID)",
  "userId": "string (reference to users)",
  "language": "string (ISO language code)",
  "timezone": "string (IANA timezone)",
  "emailNotifications": "boolean",
  "pushNotifications": "boolean",
  "smsNotifications": "boolean",
  "publicProfile": "boolean",
  "shareLocation": "boolean",
  "theme": "string (enum: light, dark)",
  "newsletterFrequency": "string (enum: immediate, daily, weekly)",
  "status": "string (enum: active, inactive)",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Sous-collections** : Aucune

**Relations** :
- N:1 avec `users`

---

### user_sessions

**Description** : Sessions utilisateur avec tokens

**Structure** :
```javascript
{
  "id": "string (UUID)",
  "userId": "string (reference to users)",
  "accessToken": "string (JWT token)",
  "refreshToken": "string (JWT token)",
  "startDate": "timestamp",
  "endDate": "timestamp?",
  "deviceId": "string?",
  "ipAddress": "string?",
  "userAgent": "string?",
  "location": "string?",
  "isActive": "boolean",
  "status": "string (enum: active, expired, revoked)",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Sous-collections** : Aucune

**Relations** :
- N:1 avec `users`

---

## Collections Logements

### properties

**Description** : Logements avec toutes leurs caractéristiques

**Structure** :
```javascript
{
  "id": "string (UUID)",
  "title": "string",
  "description": "string",
  "price": "number",
  "deposit": "number?",
  "advance": "number?",
  "currency": "string (ISO currency code)",
  "surface": "number",
  "bedrooms": "number",
  "livingRooms": "number",
  "kitchens": "number",
  "bathrooms": "number",
  "toilets": "number",
  "hasParking": "boolean",
  "hasBalcony": "boolean",
  "hasTerrace": "boolean",
  "hasInternet": "boolean",
  "hasAC": "boolean",
  "hasGenerator": "boolean",
  "hasWell": "boolean",
  "petsAllowed": "boolean",
  "location": "geopoint",
  "addressId": "string (reference to addresses)",
  "landlordId": "string (reference to landlords)",
  "landlordName": "string (denormalized)",
  "landlordPhone": "string (denormalized)",
  "categoryId": "string (reference to categories)",
  "categoryName": "string (denormalized)",
  "typeId": "string (reference to types)",
  "typeName": "string (denormalized)",
  "equipmentIds": "array of strings",
  "photoUrls": "array of strings",
  "videoUrls": "array of strings",
  "viewCount": "number",
  "favoriteCount": "number",
  "shareCount": "number",
  "distance": "number?",
  "status": "string (enum: draft, published, paused, archived)",
  "publishedAt": "timestamp",
  "expiryDate": "timestamp?",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Sous-collections** :
- `photos` - Photos du logement
- `videos` - Vidéos du logement
- `reviews` - Avis
- `visits` - Visites
- `reports` - Signalements

**Relations** :
- N:1 avec `landlords`
- N:1 avec `addresses`
- N:1 avec `categories`
- N:1 avec `types`
- N:N avec `equipment`

---

### categories

**Description** : Catégories de logements

**Structure** :
```javascript
{
  "id": "string (short code)",
  "name": "string",
  "description": "string?",
  "icon": "string?",
  "order": "number",
  "status": "string (enum: active, inactive)",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Sous-collections** : Aucune

**Relations** :
- 1:N avec `properties`

---

### types

**Description** : Types de logements (location, vente, etc.)

**Structure** :
```javascript
{
  "id": "string (short code)",
  "name": "string",
  "description": "string?",
  "icon": "string?",
  "order": "number",
  "status": "string (enum: active, inactive)",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Sous-collections** : Aucune

**Relations** :
- 1:N avec `properties`

---

### equipment

**Description** : Équipements disponibles dans les logements

**Structure** :
```javascript
{
  "id": "string (short code)",
  "name": "string",
  "description": "string?",
  "icon": "string?",
  "category": "string",
  "order": "number",
  "status": "string (enum: active, inactive)",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Sous-collections** : Aucune

**Relations** :
- N:N avec `properties` (via equipmentIds)

---

### favorites

**Description** : Favoris utilisateurs pour les logements

**Structure** :
```javascript
{
  "id": "string (UUID)",
  "userId": "string (reference to users)",
  "propertyId": "string (reference to properties)",
  "propertyTitle": "string (denormalized)",
  "propertyPrice": "number (denormalized)",
  "propertyLocation": "geopoint (denormalized)",
  "notes": "string?",
  "status": "string (enum: active, inactive)",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Sous-collections** : Aucune

**Relations** :
- N:1 avec `users`
- N:1 avec `properties`

---

### reviews

**Description** : Avis et évaluations des logements

**Structure** :
```javascript
{
  "id": "string (UUID)",
  "userId": "string (reference to users)",
  "userName": "string (denormalized)",
  "propertyId": "string (reference to properties)",
  "propertyTitle": "string (denormalized)",
  "rating": "number (1-5)",
  "comment": "string?",
  "landlordResponse": "string?",
  "responseDate": "timestamp?",
  "isVerified": "boolean",
  "status": "string (enum: active, inactive)",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Sous-collections** : Aucune

**Relations** :
- N:1 avec `users`
- N:1 avec `properties`

---

## Collections Localisation

### cities

**Description** : Villes avec informations géographiques

**Structure** :
```javascript
{
  "id": "string (short code)",
  "name": "string",
  "code": "string?",
  "country": "string (ISO country code)",
  "region": "string?",
  "province": "string?",
  "location": "geopoint",
  "population": "number",
  "status": "string (enum: active, inactive)",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Sous-collections** :
- `districts` - Quartiers de la ville

**Relations** :
- 1:N avec `districts`
- 1:N avec `addresses`

---

### districts

**Description** : Quartiers rattachés aux villes

**Structure** :
```javascript
{
  "id": "string (short code)",
  "name": "string",
  "cityId": "string (reference to cities)",
  "cityName": "string (denormalized)",
  "code": "string?",
  "description": "string?",
  "location": "geopoint",
  "population": "number",
  "status": "string (enum: active, inactive)",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Sous-collections** : Aucune

**Relations** :
- N:1 avec `cities`
- 1:N avec `addresses`

---

### addresses

**Description** : Adresses physiques avec coordonnées GPS

**Structure** :
```javascript
{
  "id": "string (UUID)",
  "street": "string",
  "number": "string?",
  "complement": "string?",
  "postalCode": "string?",
  "cityId": "string (reference to cities)",
  "cityName": "string (denormalized)",
  "districtId": "string (reference to districts)?",
  "districtName": "string (denormalized)?",
  "location": "geopoint",
  "status": "string (enum: active, inactive)",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Sous-collections** : Aucune

**Relations** :
- N:1 avec `cities`
- N:1 avec `districts`
- 1:N avec `properties`

---

## Collections Communication

### conversations

**Description** : Conversations entre utilisateurs

**Structure** :
```javascript
{
  "id": "string (UUID)",
  "participant1Id": "string (reference to users)",
  "participant1Name": "string (denormalized)",
  "participant2Id": "string (reference to users)",
  "participant2Name": "string (denormalized)",
  "propertyId": "string (reference to properties)",
  "propertyTitle": "string (denormalized)",
  "lastMessage": "string?",
  "lastMessageAt": "timestamp?",
  "messageCount": "number",
  "unreadCount": "number",
  "status": "string (enum: active, inactive, archived)",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Sous-collections** :
- `messages` - Messages de la conversation

**Relations** :
- N:1 avec `users` (participant1)
- N:1 avec `users` (participant2)
- N:1 avec `properties`

---

### messages

**Description** : Messages dans une conversation

**Structure** :
```javascript
{
  "id": "string (UUID)",
  "conversationId": "string (reference to conversations)",
  "senderId": "string (reference to users)",
  "senderName": "string (denormalized)",
  "recipientId": "string (reference to users)",
  "content": "string",
  "attachmentUrl": "string?",
  "type": "string (enum: text, image, document)",
  "isRead": "boolean",
  "readAt": "timestamp?",
  "status": "string (enum: active, deleted)",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Sous-collections** : Aucune

**Relations** :
- N:1 avec `conversations`
- N:1 avec `users` (sender)
- N:1 avec `users` (recipient)

---

### notifications

**Description** : Notifications utilisateurs

**Structure** :
```javascript
{
  "id": "string (UUID)",
  "userId": "string (reference to users)",
  "title": "string",
  "message": "string",
  "link": "string?",
  "type": "string",
  "isRead": "boolean",
  "readAt": "timestamp?",
  "status": "string (enum: active, archived)",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Sous-collections** : Aucune

**Relations** :
- N:1 avec `users`

---

## Collections Gestion

### visits

**Description** : Visites programmées pour les logements

**Structure** :
```javascript
{
  "id": "string (UUID)",
  "propertyId": "string (reference to properties)",
  "propertyTitle": "string (denormalized)",
  "clientId": "string (reference to clients)",
  "clientName": "string (denormalized)",
  "landlordId": "string (reference to landlords)",
  "landlordName": "string (denormalized)",
  "visitDate": "timestamp",
  "startTime": "string?",
  "endTime": "string?",
  "status": "string (enum: pending, confirmed, cancelled, completed)",
  "notes": "string?",
  "feedback": "string?",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Sous-collections** : Aucune

**Relations** :
- N:1 avec `properties`
- N:1 avec `clients`
- N:1 avec `landlords`

---

### visit_schedules

**Description** : Planning des créneaux de visite des bailleurs

**Structure** :
```javascript
{
  "id": "string (UUID)",
  "landlordId": "string (reference to landlords)",
  "propertyId": "string (reference to properties)",
  "slots": "array of strings",
  "instructions": "string?",
  "visitDuration": "number (minutes)",
  "bookingLeadTime": "number (hours)",
  "status": "string (enum: active, inactive)",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Sous-collections** : Aucune

**Relations** :
- N:1 avec `landlords`
- N:1 avec `properties`

---

### reports

**Description** : Signalements de contenu inapproprié

**Structure** :
```javascript
{
  "id": "string (UUID)",
  "authorId": "string (reference to users)",
  "entityId": "string",
  "entityType": "string",
  "reason": "string",
  "description": "string?",
  "status": "string (enum: pending, in_progress, resolved, rejected)",
  "adminResponse": "string?",
  "processedAt": "timestamp?",
  "processedBy": "string (reference to admins)?",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Sous-collections** : Aucune

**Relations** :
- N:1 avec `users` (author)
- N:1 avec `admins` (processedBy)

---

### verification_documents

**Description** : Documents de vérification utilisateur

**Structure** :
```javascript
{
  "id": "string (UUID)",
  "userId": "string (reference to users)",
  "documentType": "string",
  "documentNumber": "string",
  "documentUrl": "string?",
  "frontUrl": "string?",
  "backUrl": "string?",
  "expiryDate": "timestamp",
  "verificationStatus": "string (enum: pending, approved, rejected)",
  "comment": "string?",
  "verifiedAt": "timestamp?",
  "verifiedBy": "string (reference to admins)?",
  "status": "string (enum: active, inactive, expired)",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Sous-collections** : Aucune

**Relations** :
- N:1 avec `users`
- N:1 avec `admins` (verifiedBy)

---

### searches

**Description** : Historique des recherches utilisateurs

**Structure** :
```javascript
{
  "id": "string (UUID)",
  "userId": "string (reference to users)",
  "query": "string?",
  "categoryId": "string (reference to categories)?",
  "typeId": "string (reference to types)?",
  "minPrice": "number?",
  "maxPrice": "number?",
  "minSurface": "number?",
  "maxSurface": "number?",
  "minBedrooms": "number?",
  "maxBedrooms": "number?",
  "cityId": "string (reference to cities)?",
  "districtId": "string (reference to districts)?",
  "location": "geopoint?",
  "radius": "number?",
  "equipmentIds": "array of strings?",
  "resultCount": "number",
  "status": "string (enum: active, inactive)",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Sous-collections** : Aucune

**Relations** :
- N:1 avec `users`

---

### saved_searches

**Description** : Recherches sauvegardées par les utilisateurs

**Structure** :
```javascript
{
  "id": "string (UUID)",
  "userId": "string (reference to users)",
  "name": "string",
  "query": "string?",
  "categoryId": "string (reference to categories)?",
  "typeId": "string (reference to types)?",
  "minPrice": "number?",
  "maxPrice": "number?",
  "minSurface": "number?",
  "maxSurface": "number?",
  "minBedrooms": "number?",
  "maxBedrooms": "number?",
  "cityId": "string (reference to cities)?",
  "districtId": "string (reference to districts)?",
  "location": "geopoint?",
  "radius": "number?",
  "equipmentIds": "array of strings?",
  "alertEnabled": "boolean",
  "alertFrequency": "string (enum: immediate, daily, weekly)",
  "status": "string (enum: active, inactive)",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Sous-collections** : Aucune

**Relations** :
- N:1 avec `users`

---

### chatbot_conversations

**Description** : Conversations avec le chatbot

**Structure** :
```javascript
{
  "id": "string (UUID)",
  "userId": "string (reference to users)",
  "title": "string?",
  "context": "string?",
  "lastInteractionAt": "timestamp?",
  "messageCount": "number",
  "status": "string (enum: active, inactive, archived)",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Sous-collections** :
- `messages` - Messages du chatbot

**Relations** :
- N:1 avec `users`

---

## Collections Support

### audit_logs

**Description** : Logs d'audit du système

**Structure** :
```javascript
{
  "id": "string (UUID)",
  "userId": "string (reference to users)?",
  "actionType": "string",
  "description": "string?",
  "entityId": "string?",
  "entityType": "string?",
  "data": "map?",
  "ipAddress": "string?",
  "userAgent": "string?",
  "status": "string (enum: active, inactive)",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Sous-collections** : Aucune

**Relations** :
- N:1 avec `users`

---

### analytics

**Description** : Données analytiques agrégées

**Structure** :
```javascript
{
  "id": "string (UUID)",
  "metric": "string",
  "value": "number",
  "dimensions": "map?",
  "period": "string (enum: daily, weekly, monthly)",
  "date": "timestamp",
  "status": "string (enum: active, inactive)",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Sous-collections** : Aucune

**Relations** : Aucune

---

### counters

**Description** : Compteurs globaux du système

**Structure** :
```javascript
{
  "id": "string",
  "count": "number",
  "lastUpdated": "timestamp"
}
```

**Sous-collections** : Aucune

**Relations** : Aucune

---

### config

**Description** : Configuration système

**Structure** :
```javascript
{
  "id": "string",
  "key": "string",
  "value": "any",
  "description": "string?",
  "updatedAt": "timestamp"
}
```

**Sous-collections** : Aucune

**Relations** : Aucune

---

### maintenance

**Description** : Informations de maintenance

**Structure** :
```javascript
{
  "id": "string (UUID)",
  "title": "string",
  "message": "string",
  "startTime": "timestamp",
  "endTime": "timestamp?",
  "isPlanned": "boolean",
  "status": "string (enum: scheduled, in_progress, completed)",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Sous-collections** : Aucune

**Relations** : Aucune
