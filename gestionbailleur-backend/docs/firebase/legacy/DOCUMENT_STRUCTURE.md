# Structure des Documents Firestore - GestionBailleur

## Table des matières

1. [Documents Utilisateurs](#documents-utilisateurs)
2. [Documents Logements](#documents-logements)
3. [Documents Localisation](#documents-localisation)
4. [Documents Communication](#documents-communication)
5. [Documents Gestion](#documents-gestion)
6. [Documents Support](#documents-support)

---

## Documents Utilisateurs

### users/{userId}

**Document ID** : UUID v4 auto-généré

**Champs** :
```javascript
{
  "email": "string (required, unique)",
  "phone": "string (optional, unique)",
  "firstName": "string (required, min 2 chars)",
  "lastName": "string (required, min 2 chars)",
  "photoUrl": "string (optional, URL)",
  "dateOfBirth": "timestamp (required, >= 13 years ago)",
  "gender": "string (optional, enum: masculine, feminine, other)",
  "nationality": "string (optional, ISO country code)",
  "preferredLanguage": "string (optional, ISO language code, default: fr)",
  "role": "string (required, enum: client, landlord, admin)",
  "status": "string (required, enum: active, inactive, suspended, default: active)",
  "isVerified": "boolean (optional, default: false)",
  "isActive": "boolean (optional, default: true)",
  "createdAt": "timestamp (required, auto)",
  "updatedAt": "timestamp (required, auto)",
  "lastLoginAt": "timestamp (optional)"
}
```

**Indexes** :
- `email` (unique)
- `phone` (unique)
- `role` + `status`
- `status` + `createdAt`

---

### users/{userId}/profile/{profileId}

**Document ID** : UUID v4 auto-généré

**Champs** :
```javascript
{
  "userId": "string (required, reference to users)",
  "bio": "string (optional, max 500 chars)",
  "website": "string (optional, URL)",
  "linkedin": "string (optional, URL)",
  "facebook": "string (optional, URL)",
  "twitter": "string (optional, URL)",
  "instagram": "string (optional, URL)",
  "preferences": "map (optional)",
  "interests": "string (optional, max 300 chars)",
  "isPublicProfile": "boolean (optional, default: false)",
  "status": "string (required, enum: active, inactive, default: active)",
  "createdAt": "timestamp (required, auto)",
  "updatedAt": "timestamp (required, auto)"
}
```

**Indexes** :
- `userId` (unique)

---

### clients/{clientId}

**Document ID** : UUID v4 auto-généré

**Champs** :
```javascript
{
  "userId": "string (required, reference to users)",
  "idNumber": "string (optional)",
  "idType": "string (optional, enum: CNI, passport, license)",
  "profession": "string (optional)",
  "monthlyIncome": "number (optional, >= 0)",
  "employer": "string (optional)",
  "workAddress": "string (optional)",
  "workPhone": "string (optional)",
  "guarantorName": "string (optional)",
  "guarantorPhone": "string (optional)",
  "guarantorAddress": "string (optional)",
  "documents": "array (optional, max 10 URLs)",
  "verificationStatus": "string (optional, enum: pending, approved, rejected, default: pending)",
  "status": "string (required, enum: active, inactive, default: active)",
  "createdAt": "timestamp (required, auto)",
  "updatedAt": "timestamp (required, auto)"
}
```

**Indexes** :
- `userId` (unique)
- `verificationStatus` + `status`

---

### landlords/{landlordId}

**Document ID** : UUID v4 auto-généré

**Champs** :
```javascript
{
  "userId": "string (required, reference to users)",
  "companyName": "string (optional)",
  "registrationNumber": "string (optional)",
  "taxId": "string (optional)",
  "headquartersAddress": "string (optional)",
  "website": "string (optional, URL)",
  "description": "string (optional, max 1000 chars)",
  "businessPhone": "string (optional)",
  "businessEmail": "string (optional, email format)",
  "properties": "array (optional, max 100 property IDs)",
  "legalDocuments": "array (optional, max 10 URLs)",
  "isProfessional": "boolean (optional, default: false)",
  "verificationStatus": "string (optional, enum: pending, approved, rejected, default: pending)",
  "status": "string (required, enum: active, inactive, default: active)",
  "createdAt": "timestamp (required, auto)",
  "updatedAt": "timestamp (required, auto)"
}
```

**Indexes** :
- `userId` (unique)
- `verificationStatus` + `status`

---

### admins/{adminId}

**Document ID** : UUID v4 auto-généré

**Champs** :
```javascript
{
  "userId": "string (required, reference to users)",
  "permissions": "array (required, min 1 permission)",
  "mandatExpiryDate": "timestamp (optional)",
  "superiorId": "string (optional, reference to admins)",
  "isSuperAdmin": "boolean (optional, default: false)",
  "department": "string (required)",
  "position": "string (optional)",
  "status": "string (required, enum: active, inactive, default: active)",
  "createdAt": "timestamp (required, auto)",
  "updatedAt": "timestamp (required, auto)"
}
```

**Indexes** :
- `userId` (unique)
- `department` + `status`
- `superiorId`

---

## Documents Logements

### properties/{propertyId}

**Document ID** : UUID v4 auto-généré

**Champs** :
```javascript
{
  "title": "string (required, min 5, max 200 chars)",
  "description": "string (required, min 50 chars)",
  "price": "number (required, > 0)",
  "deposit": "number (optional, >= 0)",
  "advance": "number (optional, >= 0)",
  "currency": "string (required, ISO currency code, default: XOF)",
  "surface": "number (required, > 0)",
  "bedrooms": "number (required, >= 0)",
  "livingRooms": "number (required, >= 0)",
  "kitchens": "number (required, >= 0)",
  "bathrooms": "number (required, >= 0)",
  "toilets": "number (required, >= 0)",
  "hasParking": "boolean (optional, default: false)",
  "hasBalcony": "boolean (optional, default: false)",
  "hasTerrace": "boolean (optional, default: false)",
  "hasInternet": "boolean (optional, default: false)",
  "hasAC": "boolean (optional, default: false)",
  "hasGenerator": "boolean (optional, default: false)",
  "hasWell": "boolean (optional, default: false)",
  "petsAllowed": "boolean (optional, default: false)",
  "location": "geopoint (required)",
  "addressId": "string (required, reference to addresses)",
  "landlordId": "string (required, reference to landlords)",
  "landlordName": "string (denormalized)",
  "landlordPhone": "string (denormalized)",
  "categoryId": "string (required, reference to categories)",
  "categoryName": "string (denormalized)",
  "typeId": "string (required, reference to types)",
  "typeName": "string (denormalized)",
  "equipmentIds": "array (optional, max 20 equipment IDs)",
  "photoUrls": "array (optional, max 20 URLs)",
  "videoUrls": "array (optional, max 5 URLs)",
  "viewCount": "number (optional, default: 0, >= 0)",
  "favoriteCount": "number (optional, default: 0, >= 0)",
  "shareCount": "number (optional, default: 0, >= 0)",
  "distance": "number (optional, >= 0, in km)",
  "status": "string (required, enum: draft, published, paused, archived, default: draft)",
  "publishedAt": "timestamp (required, auto)",
  "expiryDate": "timestamp (optional)",
  "createdAt": "timestamp (required, auto)",
  "updatedAt": "timestamp (required, auto)"
}
```

**Indexes** :
- `landlordId` + `status`
- `categoryId` + `status`
- `typeId` + `status`
- `status` + `publishedAt`
- `location` (geopoint)
- `price` + `status`
- `surface` + `status`
- `bedrooms` + `status`

---

### properties/{propertyId}/photos/{photoId}

**Document ID** : UUID v4 auto-généré

**Champs** :
```javascript
{
  "propertyId": "string (required, reference to properties)",
  "url": "string (required, URL)",
  "thumbnailUrl": "string (optional, URL)",
  "description": "string (optional, max 255 chars)",
  "order": "number (optional, default: 0, >= 0)",
  "isPrimary": "boolean (optional, default: false)",
  "status": "string (required, enum: active, inactive, default: active)",
  "createdAt": "timestamp (required, auto)",
  "updatedAt": "timestamp (required, auto)"
}
```

**Indexes** :
- `propertyId` + `order`
- `propertyId` + `isPrimary`

---

### properties/{propertyId}/videos/{videoId}

**Document ID** : UUID v4 auto-généré

**Champs** :
```javascript
{
  "propertyId": "string (required, reference to properties)",
  "url": "string (required, URL)",
  "thumbnailUrl": "string (optional, URL)",
  "description": "string (optional, max 255 chars)",
  "duration": "number (optional, default: 0, >= 0, in seconds)",
  "order": "number (optional, default: 0, >= 0)",
  "status": "string (required, enum: active, inactive, default: active)",
  "createdAt": "timestamp (required, auto)",
  "updatedAt": "timestamp (required, auto)"
}
```

**Indexes** :
- `propertyId` + `order`

---

### properties/{propertyId}/reviews/{reviewId}

**Document ID** : UUID v4 auto-généré

**Champs** :
```javascript
{
  "userId": "string (required, reference to users)",
  "userName": "string (denormalized)",
  "propertyId": "string (required, reference to properties)",
  "propertyTitle": "string (denormalized)",
  "rating": "number (required, 1-5)",
  "comment": "string (optional, max 1000 chars)",
  "landlordResponse": "string (optional, max 1000 chars)",
  "responseDate": "timestamp (optional)",
  "isVerified": "boolean (optional, default: false)",
  "status": "string (required, enum: active, inactive, default: active)",
  "createdAt": "timestamp (required, auto)",
  "updatedAt": "timestamp (required, auto)"
}
```

**Indexes** :
- `propertyId` + `rating`
- `userId` + `propertyId` (unique)

---

### properties/{propertyId}/visits/{visitId}

**Document ID** : UUID v4 auto-généré

**Champs** :
```javascript
{
  "propertyId": "string (required, reference to properties)",
  "propertyTitle": "string (denormalized)",
  "clientId": "string (required, reference to clients)",
  "clientName": "string (denormalized)",
  "landlordId": "string (required, reference to landlords)",
  "landlordName": "string (denormalized)",
  "visitDate": "timestamp (required)",
  "startTime": "string (optional, format HH:MM)",
  "endTime": "string (optional, format HH:MM)",
  "status": "string (required, enum: pending, confirmed, cancelled, completed, default: pending)",
  "notes": "string (optional, max 500 chars)",
  "feedback": "string (optional, max 1000 chars)",
  "createdAt": "timestamp (required, auto)",
  "updatedAt": "timestamp (required, auto)"
}
```

**Indexes** :
- `propertyId` + `visitDate`
- `clientId` + `visitDate`
- `landlordId` + `visitDate`
- `status` + `visitDate`

---

### categories/{categoryId}

**Document ID** : Code court (ex: cat_apartment)

**Champs** :
```javascript
{
  "name": "string (required, unique)",
  "description": "string (optional, max 500 chars)",
  "icon": "string (optional)",
  "order": "number (optional, default: 0, >= 0)",
  "status": "string (required, enum: active, inactive, default: active)",
  "createdAt": "timestamp (required, auto)",
  "updatedAt": "timestamp (required, auto)"
}
```

**Indexes** :
- `name` (unique)
- `order` + `status`

---

### types/{typeId}

**Document ID** : Code court (ex: type_rent)

**Champs** :
```javascript
{
  "name": "string (required, unique)",
  "description": "string (optional, max 500 chars)",
  "icon": "string (optional)",
  "order": "number (optional, default: 0, >= 0)",
  "status": "string (required, enum: active, inactive, default: active)",
  "createdAt": "timestamp (required, auto)",
  "updatedAt": "timestamp (required, auto)"
}
```

**Indexes** :
- `name` (unique)
- `order` + `status`

---

### equipment/{equipmentId}

**Document ID** : Code court (ex: eq_ac)

**Champs** :
```javascript
{
  "name": "string (required, unique)",
  "description": "string (optional, max 500 chars)",
  "icon": "string (optional)",
  "category": "string (required)",
  "order": "number (optional, default: 0, >= 0)",
  "status": "string (required, enum: active, inactive, default: active)",
  "createdAt": "timestamp (required, auto)",
  "updatedAt": "timestamp (required, auto)"
}
```

**Indexes** :
- `name` (unique)
- `category` + `order`

---

## Documents Localisation

### cities/{cityId}

**Document ID** : Code court (ex: ci_abj)

**Champs** :
```javascript
{
  "name": "string (required, unique per country)",
  "code": "string (optional)",
  "country": "string (optional, ISO country code)",
  "region": "string (optional)",
  "province": "string (optional)",
  "location": "geopoint (optional)",
  "population": "number (optional, default: 0, >= 0)",
  "status": "string (required, enum: active, inactive, default: active)",
  "createdAt": "timestamp (required, auto)",
  "updatedAt": "timestamp (required, auto)"
}
```

**Indexes** :
- `name` + `country` (unique)
- `country` + `status`
- `location` (geopoint)

---

### cities/{cityId}/districts/{districtId}

**Document ID** : Code court (ex: ci_abj_coc)

**Champs** :
```javascript
{
  "name": "string (required)",
  "cityId": "string (required, reference to cities)",
  "cityName": "string (denormalized)",
  "code": "string (optional)",
  "description": "string (optional, max 500 chars)",
  "location": "geopoint (optional)",
  "population": "number (optional, default: 0, >= 0)",
  "status": "string (required, enum: active, inactive, default: active)",
  "createdAt": "timestamp (required, auto)",
  "updatedAt": "timestamp (required, auto)"
}
```

**Indexes** :
- `cityId` + `name` (unique)
- `cityId` + `status`

---

### addresses/{addressId}

**Document ID** : UUID v4 auto-généré

**Champs** :
```javascript
{
  "street": "string (required, min 5 chars)",
  "number": "string (optional)",
  "complement": "string (optional)",
  "postalCode": "string (required)",
  "cityId": "string (required, reference to cities)",
  "cityName": "string (denormalized)",
  "districtId": "string (optional, reference to districts)",
  "districtName": "string (denormalized)",
  "location": "geopoint (required)",
  "status": "string (required, enum: active, inactive, default: active)",
  "createdAt": "timestamp (required, auto)",
  "updatedAt": "timestamp (required, auto)"
}
```

**Indexes** :
- `cityId` + `status`
- `districtId` + `status`
- `location` (geopoint)

---

## Documents Communication

### conversations/{conversationId}

**Document ID** : UUID v4 auto-généré

**Champs** :
```javascript
{
  "participant1Id": "string (required, reference to users)",
  "participant1Name": "string (denormalized)",
  "participant2Id": "string (required, reference to users)",
  "participant2Name": "string (denormalized)",
  "propertyId": "string (required, reference to properties)",
  "propertyTitle": "string (denormalized)",
  "lastMessage": "string (optional, max 500 chars)",
  "lastMessageAt": "timestamp (optional)",
  "messageCount": "number (optional, default: 0, >= 0)",
  "unreadCount": "number (optional, default: 0, >= 0)",
  "status": "string (required, enum: active, inactive, archived, default: active)",
  "createdAt": "timestamp (required, auto)",
  "updatedAt": "timestamp (required, auto)"
}
```

**Indexes** :
- `participant1Id` + `status`
- `participant2Id` + `status`
- `propertyId` + `status`
- `lastMessageAt` + `status`

---

### conversations/{conversationId}/messages/{messageId}

**Document ID** : UUID v4 auto-généré

**Champs** :
```javascript
{
  "conversationId": "string (required, reference to conversations)",
  "senderId": "string (required, reference to users)",
  "senderName": "string (denormalized)",
  "recipientId": "string (required, reference to users)",
  "content": "string (required, max 5000 chars)",
  "attachmentUrl": "string (optional, URL)",
  "type": "string (required, enum: text, image, document, default: text)",
  "isRead": "boolean (optional, default: false)",
  "readAt": "timestamp (optional)",
  "status": "string (required, enum: active, deleted, default: active)",
  "createdAt": "timestamp (required, auto)",
  "updatedAt": "timestamp (required, auto)"
}
```

**Indexes** :
- `conversationId` + `createdAt`
- `senderId` + `createdAt`
- `recipientId` + `isRead`

---

### notifications/{notificationId}

**Document ID** : UUID v4 auto-généré

**Champs** :
```javascript
{
  "userId": "string (required, reference to users)",
  "title": "string (required, min 5 chars)",
  "message": "string (required, max 1000 chars)",
  "link": "string (optional, URL)",
  "type": "string (required)",
  "isRead": "boolean (optional, default: false)",
  "readAt": "timestamp (optional)",
  "status": "string (required, enum: active, archived, default: active)",
  "createdAt": "timestamp (required, auto)",
  "updatedAt": "timestamp (required, auto)"
}
```

**Indexes** :
- `userId` + `isRead` + `createdAt`
- `userId` + `status`
- `type` + `createdAt`

---

## Documents Gestion

### visits/{visitId}

**Document ID** : UUID v4 auto-généré

**Champs** :
```javascript
{
  "propertyId": "string (required, reference to properties)",
  "propertyTitle": "string (denormalized)",
  "clientId": "string (required, reference to clients)",
  "clientName": "string (denormalized)",
  "landlordId": "string (required, reference to landlords)",
  "landlordName": "string (denormalized)",
  "visitDate": "timestamp (required)",
  "startTime": "string (optional, format HH:MM)",
  "endTime": "string (optional, format HH:MM)",
  "status": "string (required, enum: pending, confirmed, cancelled, completed, default: pending)",
  "notes": "string (optional, max 500 chars)",
  "feedback": "string (optional, max 1000 chars)",
  "createdAt": "timestamp (required, auto)",
  "updatedAt": "timestamp (required, auto)"
}
```

**Indexes** :
- `clientId` + `visitDate` + `status`
- `landlordId` + `visitDate` + `status`
- `propertyId` + `visitDate` + `status`
- `status` + `visitDate`

---

### visit_schedules/{scheduleId}

**Document ID** : UUID v4 auto-généré

**Champs** :
```javascript
{
  "landlordId": "string (required, reference to landlords)",
  "propertyId": "string (required, reference to properties)",
  "slots": "array (required, max 20 time slots)",
  "instructions": "string (optional, max 500 chars)",
  "visitDuration": "number (optional, default: 30, >= 0, in minutes)",
  "bookingLeadTime": "number (optional, default: 24, >= 0, in hours)",
  "status": "string (required, enum: active, inactive, default: active)",
  "createdAt": "timestamp (required, auto)",
  "updatedAt": "timestamp (required, auto)"
}
```

**Indexes** :
- `landlordId` + `status`
- `propertyId` + `status`

---

### reports/{reportId}

**Document ID** : UUID v4 auto-généré

**Champs** :
```javascript
{
  "authorId": "string (required, reference to users)",
  "entityId": "string (required)",
  "entityType": "string (required)",
  "reason": "string (required)",
  "description": "string (optional, max 1000 chars)",
  "status": "string (required, enum: pending, in_progress, resolved, rejected, default: pending)",
  "adminResponse": "string (optional, max 1000 chars)",
  "processedAt": "timestamp (optional)",
  "processedBy": "string (optional, reference to admins)",
  "createdAt": "timestamp (required, auto)",
  "updatedAt": "timestamp (required, auto)"
}
```

**Indexes** :
- `authorId` + `status`
- `entityId` + `entityType` + `status`
- `status` + `createdAt`

---

### verification_documents/{docId}

**Document ID** : UUID v4 auto-généré

**Champs** :
```javascript
{
  "userId": "string (required, reference to users)",
  "documentType": "string (required)",
  "documentNumber": "string (required)",
  "documentUrl": "string (optional, URL)",
  "frontUrl": "string (optional, URL)",
  "backUrl": "string (optional, URL)",
  "expiryDate": "timestamp (required)",
  "verificationStatus": "string (optional, enum: pending, approved, rejected, default: pending)",
  "comment": "string (optional, max 500 chars)",
  "verifiedAt": "timestamp (optional)",
  "verifiedBy": "string (optional, reference to admins)",
  "status": "string (required, enum: active, inactive, expired, default: active)",
  "createdAt": "timestamp (required, auto)",
  "updatedAt": "timestamp (required, auto)"
}
```

**Indexes** :
- `userId` + `verificationStatus`
- `verificationStatus` + `status`
- `expiryDate` + `status`

---

### searches/{searchId}

**Document ID** : UUID v4 auto-généré

**Champs** :
```javascript
{
  "userId": "string (required, reference to users)",
  "query": "string (optional)",
  "categoryId": "string (optional, reference to categories)",
  "typeId": "string (optional, reference to types)",
  "minPrice": "number (optional, >= 0)",
  "maxPrice": "number (optional, >= 0)",
  "minSurface": "number (optional, >= 0)",
  "maxSurface": "number (optional, >= 0)",
  "minBedrooms": "number (optional, >= 0)",
  "maxBedrooms": "number (optional, >= 0)",
  "cityId": "string (optional, reference to cities)",
  "districtId": "string (optional, reference to districts)",
  "location": "geopoint (optional)",
  "radius": "number (optional, >= 0, in km)",
  "equipmentIds": "array (optional, max 20 equipment IDs)",
  "resultCount": "number (optional, default: 0, >= 0)",
  "status": "string (required, enum: active, inactive, default: active)",
  "createdAt": "timestamp (required, auto)",
  "updatedAt": "timestamp (required, auto)"
}
```

**Indexes** :
- `userId` + `createdAt`
- `cityId` + `createdAt`
- `categoryId` + `createdAt`

---

### saved_searches/{savedSearchId}

**Document ID** : UUID v4 auto-généré

**Champs** :
```javascript
{
  "userId": "string (required, reference to users)",
  "name": "string (required)",
  "query": "string (optional)",
  "categoryId": "string (optional, reference to categories)",
  "typeId": "string (optional, reference to types)",
  "minPrice": "number (optional, >= 0)",
  "maxPrice": "number (optional, >= 0)",
  "minSurface": "number (optional, >= 0)",
  "maxSurface": "number (optional, >= 0)",
  "minBedrooms": "number (optional, >= 0)",
  "maxBedrooms": "number (optional, >= 0)",
  "cityId": "string (optional, reference to cities)",
  "districtId": "string (optional, reference to districts)",
  "location": "geopoint (optional)",
  "radius": "number (optional, >= 0, in km)",
  "equipmentIds": "array (optional, max 20 equipment IDs)",
  "alertEnabled": "boolean (optional, default: false)",
  "alertFrequency": "string (optional, enum: immediate, daily, weekly, default: immediate)",
  "status": "string (required, enum: active, inactive, default: active)",
  "createdAt": "timestamp (required, auto)",
  "updatedAt": "timestamp (required, auto)"
}
```

**Indexes** :
- `userId` + `alertEnabled`
- `userId` + `status`

---

### chatbot_conversations/{chatbotConversationId}

**Document ID** : UUID v4 auto-généré

**Champs** :
```javascript
{
  "userId": "string (required, reference to users)",
  "title": "string (optional)",
  "context": "string (optional, max 1000 chars)",
  "lastInteractionAt": "timestamp (optional)",
  "messageCount": "number (optional, default: 0, >= 0)",
  "status": "string (required, enum: active, inactive, archived, default: active)",
  "createdAt": "timestamp (required, auto)",
  "updatedAt": "timestamp (required, auto)"
}
```

**Indexes** :
- `userId` + `status`
- `lastInteractionAt` + `status`

---

### chatbot_conversations/{chatbotConversationId}/messages/{messageId}

**Document ID** : UUID v4 auto-généré

**Champs** :
```javascript
{
  "conversationId": "string (required, reference to chatbot_conversations)",
  "content": "string (required, max 5000 chars)",
  "role": "string (required, enum: user, assistant)",
  "context": "string (optional, max 1000 chars)",
  "data": "map (optional)",
  "status": "string (required, enum: active, inactive, default: active)",
  "createdAt": "timestamp (required, auto)",
  "updatedAt": "timestamp (required, auto)"
}
```

**Indexes** :
- `conversationId` + `createdAt`
- `role` + `createdAt`

---

## Documents Support

### audit_logs/{logId}

**Document ID** : UUID v4 auto-généré

**Champs** :
```javascript
{
  "userId": "string (optional, reference to users)",
  "actionType": "string (required)",
  "description": "string (optional, max 500 chars)",
  "entityId": "string (optional)",
  "entityType": "string (optional)",
  "data": "map (optional)",
  "ipAddress": "string (optional)",
  "userAgent": "string (optional)",
  "status": "string (required, enum: active, inactive, default: active)",
  "createdAt": "timestamp (required, auto)",
  "updatedAt": "timestamp (required, auto)"
}
```

**Indexes** :
- `userId` + `createdAt`
- `actionType` + `createdAt`
- `entityId` + `entityType` + `createdAt`

---

### analytics/{analyticsId}

**Document ID** : UUID v4 auto-généré

**Champs** :
```javascript
{
  "metric": "string (required)",
  "value": "number (required)",
  "dimensions": "map (optional)",
  "period": "string (required, enum: daily, weekly, monthly)",
  "date": "timestamp (required)",
  "status": "string (required, enum: active, inactive, default: active)",
  "createdAt": "timestamp (required, auto)",
  "updatedAt": "timestamp (required, auto)"
}
```

**Indexes** :
- `metric` + `period` + `date`
- `date` + `metric`

---

### counters/{counterId}

**Document ID** : Nom du compteur (ex: total_users, total_properties)

**Champs** :
```javascript
{
  "count": "number (required, >= 0)",
  "lastUpdated": "timestamp (required, auto)"
}
```

**Indexes** : Aucun (document unique par compteur)

---

### config/{configId}

**Document ID** : Clé de configuration (ex: app_version, maintenance_mode)

**Champs** :
```javascript
{
  "key": "string (required, unique)",
  "value": "any (required)",
  "description": "string (optional)",
  "updatedAt": "timestamp (required, auto)"
}
```

**Indexes** :
- `key` (unique)

---

### maintenance/{maintenanceId}

**Document ID** : UUID v4 auto-généré

**Champs** :
```javascript
{
  "title": "string (required)",
  "message": "string (required, max 1000 chars)",
  "startTime": "timestamp (required)",
  "endTime": "timestamp (optional)",
  "isPlanned": "boolean (required, default: false)",
  "status": "string (required, enum: scheduled, in_progress, completed, default: scheduled)",
  "createdAt": "timestamp (required, auto)",
  "updatedAt": "timestamp (required, auto)"
}
```

**Indexes** :
- `status` + `startTime`
- `startTime` + `endTime`
