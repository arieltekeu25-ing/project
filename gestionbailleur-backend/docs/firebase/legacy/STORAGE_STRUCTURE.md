# Structure Firebase Storage - GestionBailleur

## Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Organisation des Buckets](#organisation-des-buckets)
3. [Structure des Dossiers](#structure-des-dossiers)
4. [Conventions de Nommage](#conventions-de-nommage)
5. [Types de Fichiers](#types-de-fichiers)
6. [Règles de Sécurité Storage](#règles-de-sécurité-storage)
7. [Configuration CDN](#configuration-cdn)
8. [Optimisations](#optimisations)
9. [Stratégies de Sauvegarde](#stratégies-de-sauvegarde)

---

## Vue d'ensemble

Firebase Storage est utilisé pour stocker tous les fichiers multimédias de la plateforme GestionBailleur : photos de logements, vidéos, documents de vérification, avatars utilisateurs, etc.

### Buckets Principaux

- **gestionbailleur.appspot.com** - Bucket principal (production)
- **gestionbailleur-test.appspot.com** - Bucket de test
- **gestionbailleur-dev.appspot.com** - Bucket de développement

---

## Organisation des Buckets

### Bucket Principal : gestionbailleur.appspot.com

```
gestionbailleur.appspot.com/
├── users/                    # Fichiers utilisateurs
│   ├── avatars/              # Photos de profil
│   ├── documents/            # Documents de vérification
│   └── uploads/              # Uploads temporaires
├── properties/               # Fichiers logements
│   ├── photos/               # Photos de logements
│   ├── videos/               # Vidéos de logements
│   └── thumbnails/           # Miniatures générées
├── messages/                  # Pièces jointes messages
├── system/                    # Fichiers système
│   ├── logos/                # Logos application
│   ├── icons/                # Icônes
│   └── banners/              # Bannières
├── temp/                     # Fichiers temporaires
└── archived/                 # Fichiers archivés
```

---

## Structure des Dossiers

### users/

**Description** : Fichiers liés aux utilisateurs

#### users/avatars/

**Structure** :
```
users/avatars/
├── {userId}/
│   ├── original/             # Photo originale
│   │   └── {avatarId}.jpg
│   ├── thumbnail/            # Miniature (150x150)
│   │   └── {avatarId}_thumb.jpg
│   └── medium/               # Moyenne (300x300)
│       └── {avatarId}_medium.jpg
```

**Conventions** :
- Format : JPG, PNG, WEBP
- Taille max : 5MB
- Dimensions : Max 2000x2000px
- Compression : 85%

#### users/documents/

**Structure** :
```
users/documents/
├── {userId}/
│   ├── identity/             # Pièces d'identité
│   │   ├── front/
│   │   │   └── {docId}_front.jpg
│   │   └── back/
│   │       └── {docId}_back.jpg
│   ├── proof/                # Justificatifs
│   │   └── {docId}.pdf
│   └── legal/                # Documents juridiques (bailleurs)
│       └── {docId}.pdf
```

**Conventions** :
- Format : PDF, JPG, PNG
- Taille max : 10MB
- Compression : Aucune (documents)

#### users/uploads/

**Structure** :
```
users/uploads/
├── {userId}/
│   └── {timestamp}_{random}/
│       └── {filename}
```

**Conventions** :
- Fichiers temporaires
- Suppression automatique après 24h
- Taille max : 20MB

---

### properties/

**Description** : Fichiers liés aux logements

#### properties/photos/

**Structure** :
```
properties/photos/
├── {propertyId}/
│   ├── original/             # Photos originales
│   │   ├── {photoId}_1.jpg
│   │   ├── {photoId}_2.jpg
│   │   └── ...
│   ├── thumbnail/            # Miniatures (300x300)
│   │   ├── {photoId}_1_thumb.jpg
│   │   ├── {photoId}_2_thumb.jpg
│   │   └── ...
│   ├── medium/               # Moyennes (800x600)
│   │   ├── {photoId}_1_medium.jpg
│   │   ├── {photoId}_2_medium.jpg
│   │   └── ...
│   └── large/                # Grandes (1920x1080)
│       ├── {photoId}_1_large.jpg
│       ├── {photoId}_2_large.jpg
│       └── ...
```

**Conventions** :
- Format : JPG, PNG, WEBP
- Taille max : 5MB par photo
- Max 20 photos par logement
- Compression : 85%
- Ordre : Numérotation 1-20

#### properties/videos/

**Structure** :
```
properties/videos/
├── {propertyId}/
│   ├── original/             # Vidéos originales
│   │   ├── {videoId}_1.mp4
│   │   └── ...
│   ├── thumbnail/            # Miniatures vidéo
│   │   ├── {videoId}_1_thumb.jpg
│   │   └── ...
│   └── compressed/           # Vidéos compressées
│       ├── {videoId}_1_comp.mp4
│       └── ...
```

**Conventions** :
- Format : MP4, WEBM
- Taille max : 100MB par vidéo
- Max 5 vidéos par logement
- Durée max : 5 minutes
- Compression : H.264, 720p

#### properties/thumbnails/

**Structure** :
```
properties/thumbnails/
├── {propertyId}/
│   ├── hero/                 # Image principale (1920x1080)
│   │   └── hero.jpg
│   ├── card/                 # Pour cartes (400x300)
│   │   └── card.jpg
│   └── list/                 # Pour listes (200x150)
│       └── list.jpg
```

**Conventions** :
- Généré automatiquement
- Format : WEBP
- Compression : 90%

---

### messages/

**Description** : Pièces jointes des messages

**Structure** :
```
messages/
├── {conversationId}/
│   ├── {messageId}/
│   │   ├── {filename}
│   │   └── {filename}_thumb.jpg (si image)
```

**Conventions** :
- Format : JPG, PNG, PDF, DOC, DOCX
- Taille max : 10MB
- Compression : Images 85%

---

### system/

**Description** : Fichiers système

#### system/logos/

**Structure** :
```
system/logos/
├── app_logo.png
├── app_logo_dark.png
└── favicon.ico
```

**Conventions** :
- Format : PNG, ICO
- Taille max : 1MB

#### system/icons/

**Structure** :
```
system/icons/
├── category_*.png
├── equipment_*.png
└── status_*.png
```

**Conventions** :
- Format : PNG, SVG
- Taille max : 500KB

#### system/banners/

**Structure** :
```
system/banners/
├── home_hero.jpg
├── category_*.jpg
└── promotional_*.jpg
```

**Conventions** :
- Format : JPG, WEBP
- Taille max : 2MB
- Dimensions : 1920x1080px

---

### temp/

**Description** : Fichiers temporaires

**Structure** :
```
temp/
├── {date}/
│   ├── {random}/
│   │   └── {filename}
```

**Conventions** :
- Suppression automatique après 24h
- Nettoyage quotidien via Cloud Functions

---

### archived/

**Description** : Fichiers archivés

**Structure** :
```
archived/
├── {year}/
│   ├── {month}/
│   │   ├── users/
│   │   ├── properties/
│   │   └── messages/
```

**Conventions** :
- Données de plus de 90 jours
- Compression GZIP
- Accès en lecture seule

---

## Conventions de Nommage

### Noms de Fichiers

**Format général** : `{prefix}_{id}_{variant}.{ext}`

**Préfixes** :
- `avatar_` - Photos de profil
- `doc_` - Documents
- `photo_` - Photos de logement
- `video_` - Vidéos de logement
- `msg_` - Pièces jointes messages
- `thumb_` - Miniatures

**Exemples** :
- `avatar_550e8400..._original.jpg`
- `photo_550e8400..._1_thumb.jpg`
- `video_550e8400..._1_comp.mp4`
- `doc_550e8400..._front.jpg`

### Noms de Dossiers

**Format** : `{entityType}/{entityId}/{subfolder}`

**Exemples** :
- `users/550e8400.../avatars/original`
- `properties/550e8400.../photos/thumbnail`
- `messages/550e8400.../550e8400...`

### IDs

- Utiliser UUID v4 pour les IDs
- Utiliser des codes courts pour les entités de référence
- Exemples : `550e8400-e29b-41d4-a716-446655440000`, `cat_apartment`

### Timestamps

- Utiliser ISO 8601 pour les dossiers temporels
- Format : `YYYY-MM-DD`
- Exemple : `2024-01-15`

---

## Types de Fichiers

### Images

| Type | Extensions | Taille Max | Compression |
|------|------------|------------|-------------|
| Avatar | JPG, PNG, WEBP | 5MB | 85% |
| Photo logement | JPG, PNG, WEBP | 5MB | 85% |
| Miniature | WEBP | 500KB | 90% |
| Bannière | JPG, WEBP | 2MB | 85% |
| Icône | PNG, SVG | 500KB | Aucune |

### Vidéos

| Type | Extensions | Taille Max | Durée Max | Résolution |
|------|------------|------------|-----------|------------|
| Visite logement | MP4, WEBM | 100MB | 5 min | 720p |
| Compressée | MP4 | 50MB | 5 min | 720p |

### Documents

| Type | Extensions | Taille Max | Compression |
|------|------------|------------|-------------|
| Pièce identité | JPG, PNG, PDF | 10MB | Aucune |
| Justificatif | PDF | 10MB | Aucune |
| Document juridique | PDF | 10MB | Aucune |
| Pièce jointe message | PDF, DOC, DOCX | 10MB | Aucune |

---

## Règles de Sécurité Storage

### Règles Générales

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Variables globales
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    function isAdmin() {
      return request.auth.token.admin == true;
    }
    
    function isImage() {
      return request.resource.contentType.matches('image/(jpeg|png|webp|gif)');
    }
    
    function isVideo() {
      return request.resource.contentType.matches('video/(mp4|webm|quicktime)');
    }
    
    function isDocument() {
      return request.resource.contentType.matches('application/(pdf|msword|vnd.openxmlformats-officedocument.wordprocessingml.document)');
    }
    
    function isValidSize(maxSize) {
      return request.resource.size <= maxSize;
    }
    
    // Bucket principal
    match /gestionbailleur.appspot.com/o {
      // Dossier users
      match /users/{userId}/{allPaths=**} {
        allow read: if isOwner(userId) || isAdmin();
        allow write: if isOwner(userId);
      }
      
      // Dossier properties
      match /properties/{propertyId}/{allPaths=**} {
        allow read: if true;
        allow write: if isAuthenticated();
      }
      
      // Dossier messages
      match /messages/{conversationId}/{allPaths=**} {
        allow read: if isAuthenticated();
        allow write: if isAuthenticated();
      }
      
      // Dossier system
      match /system/{allPaths=**} {
        allow read: if true;
        allow write: if isAdmin();
      }
      
      // Dossier temp
      match /temp/{allPaths=**} {
        allow read, write: if isAuthenticated();
      }
      
      // Dossier archived
      match /archived/{allPaths=**} {
        allow read: if isAdmin();
        allow write: if isAdmin();
      }
    }
  }
}
```

### Règles Spécifiques par Type

#### Avatars

```javascript
match /users/{userId}/avatars/{allPaths=**} {
  allow read: if true;
  allow create: if isOwner(userId) && 
                   isImage() && 
                   isValidSize(5 * 1024 * 1024);
  allow update, delete: if isOwner(userId) || isAdmin();
}
```

#### Documents de Vérification

```javascript
match /users/{userId}/documents/{allPaths=**} {
  allow read: if isOwner(userId) || isAdmin();
  allow create: if isOwner(userId) && 
                   (isImage() || isDocument()) && 
                   isValidSize(10 * 1024 * 1024);
  allow update: if isAdmin();
  allow delete: if isAdmin();
}
```

#### Photos de Logement

```javascript
match /properties/{propertyId}/photos/{allPaths=**} {
  allow read: if true;
  allow create: if isAuthenticated() && 
                   isImage() && 
                   isValidSize(5 * 1024 * 1024);
  allow update, delete: if isAuthenticated();
}
```

#### Vidéos de Logement

```javascript
match /properties/{propertyId}/videos/{allPaths=**} {
  allow read: if true;
  allow create: if isAuthenticated() && 
                   isVideo() && 
                   isValidSize(100 * 1024 * 1024);
  allow update, delete: if isAuthenticated();
}
```

---

## Configuration CDN

### Firebase CDN

Firebase Storage utilise automatiquement le CDN Firebase pour la distribution des fichiers.

### Configuration

```javascript
// Configuration CDN dans firebase.json
{
  "storage": {
    "rules": "storage.rules",
    "defaultBucket": "gestionbailleur.appspot.com"
  },
  "hosting": {
    "public": "build",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "headers": [
      {
        "source": "**/*.@(jpg|jpeg|png|webp)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "public, max-age=31536000, immutable"
          }
        ]
      },
      {
        "source": "**/*.@(mp4|webm)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "public, max-age=2592000"
          }
        ]
      }
    ]
  }
}
```

### Cache Headers

| Type de fichier | Cache-Control |
|----------------|---------------|
| Images statiques | public, max-age=31536000, immutable |
| Vidéos | public, max-age=2592000 |
| Documents utilisateurs | private, max-age=86400 |
| Fichiers système | public, max-age=31536000, immutable |

---

## Optimisations

### 1. Compression d'Images

Utiliser Firebase Extensions pour la compression automatique :

```javascript
// Configuration de compression
{
  "image": {
    "quality": 85,
    "resize": {
      "width": 1920,
      "height": 1080,
      "fit": "inside"
    }
  }
}
```

### 2. Génération de Miniatures

Générer automatiquement plusieurs tailles d'images :

```javascript
// Tailles générées
const sizes = [
  { name: 'thumbnail', width: 300, height: 300 },
  { name: 'medium', width: 800, height: 600 },
  { name: 'large', width: 1920, height: 1080 }
];
```

### 3. Compression de Vidéos

Utiliser Cloud Functions pour la compression vidéo :

```javascript
// Configuration vidéo
{
  "video": {
    "codec": "h264",
    "resolution": "720p",
    "bitrate": "2000k",
    "audio": "aac"
  }
}
```

### 4. Lazy Loading

Charger les images uniquement lorsque nécessaire :

```javascript
// URL avec paramètre de transformation
const thumbnailUrl = `https://firebasestorage.googleapis.com/v0/b/${bucket}/o/${path}?alt=media&token=${token}&width=300&height=300`;
```

### 5. Format WebP

Préférer le format WebP pour les images :

```javascript
// Conversion automatique vers WebP
if (request.resource.contentType == 'image/jpeg') {
  // Convertir vers WebP
}
```

### 6. CDN Multi-Régional

Configurer le CDN pour une distribution multi-régionale :

```javascript
{
  "cdn": {
    "regions": ["us-central1", "europe-west1", "asia-east1"]
  }
}
```

---

## Stratégies de Sauvegarde

### 1. Sauvegarde Automatique

Firebase Storage ne nécessite pas de sauvegarde traditionnelle car les données sont répliquées automatiquement.

### 2. Export vers Cloud Storage

Exporter régulièrement les données vers Cloud Storage pour une sauvegarde à long terme :

```javascript
// Script d'export Cloud Function
exports.backupStorage = functions.pubsub.schedule('0 2 * * *')
  .timeZone('Africa/Abidjan')
  .onRun(async (context) => {
    // Exporter les fichiers vers un bucket de sauvegarde
  });
```

### 3. Versioning

Activer le versioning pour les fichiers critiques :

```javascript
{
  "versioning": {
    "enabled": true,
    "maxVersions": 3
  }
}
```

### 4. Cycle de Vie

Configurer le cycle de vie des fichiers :

```javascript
{
  "lifecycle": {
    "rule": [
      {
        "action": "delete",
        "condition": {
          "age": 90
        }
      }
    ]
  }
}
```

### 5. Archive

Déplacer les anciens fichiers vers le dossier archived :

```javascript
// Cloud Function pour archivage
exports.archiveOldFiles = functions.pubsub.schedule('0 3 * * 0')
  .timeZone('Africa/Abidjan')
  .onRun(async (context) => {
    // Archiver les fichiers de plus de 90 jours
  });
```

---

## Monitoring

### 1. Surveillance de l'Utilisation

Surveiller l'utilisation du stockage via Firebase Console :

```javascript
// Cloud Function pour monitoring
exports.monitorStorage = functions.pubsub.schedule('0 * * * *')
  .onRun(async (context) => {
    const bucket = admin.storage().bucket();
    const [files] = await bucket.getFiles();
    const totalSize = files.reduce((sum, file) => sum + file.metadata.size, 0);
    
    // Envoyer alerte si > 80% du quota
    if (totalSize > 0.8 * QUOTA) {
      // Envoyer notification
    }
  });
```

### 2. Alertes

Configurer des alertes pour :
- Utilisation > 80%
- Erreurs d'upload
- Fichiers corrompus

### 3. Logs

Conserver les logs des opérations de stockage :

```javascript
// Logger les uploads
exports.logUpload = functions.storage.object().onFinalize(async (object) => {
  await admin.firestore().collection('storage_logs').add({
    action: 'upload',
    filePath: object.name,
    size: object.size,
    contentType: object.contentType,
    timestamp: admin.firestore.FieldValue.serverTimestamp()
  });
});
```

---

## Sécurité

### 1. Validation des Fichiers

Valider tous les fichiers uploadés côté serveur :

```javascript
// Validation avant upload
function validateFile(file) {
  const allowedTypes = ['image/jpeg', 'image/png', 'image/webp', 'video/mp4'];
  const maxSize = 10 * 1024 * 1024; // 10MB
  
  if (!allowedTypes.includes(file.type)) {
    throw new Error('Type de fichier non autorisé');
  }
  
  if (file.size > maxSize) {
    throw new Error('Fichier trop volumineux');
  }
}
```

### 2. Scan Antivirus

Scanner les fichiers uploadés pour détecter les virus :

```javascript
// Integration avec un service de scan antivirus
exports.scanFile = functions.storage.object().onFinalize(async (object) => {
  const file = bucket.file(object.name);
  const [buffer] = await file.download();
  
  // Scanner le fichier
  const isClean = await scanForVirus(buffer);
  
  if (!isClean) {
    await file.delete();
    throw new Error('Fichier infecté détecté');
  }
});
```

### 3. Watermarking

Ajouter un watermark aux images de logements :

```javascript
// Ajouter watermark automatique
exports.addWatermark = functions.storage.object().onFinalize(async (object) => {
  if (object.name.startsWith('properties/photos/')) {
    // Ajouter watermark
  }
});
```

---

## Bonnes Pratiques

### 1. Utiliser des Noms de Fichiers Descriptifs

Les noms de fichiers doivent être descriptifs mais courts.

### 2. Éviter les Espaces et Caractères Spéciaux

Utiliser uniquement des lettres, chiffres, tirets et underscores.

### 3. Utiliser des Extensions de Fichier Standard

Toujours inclure l'extension du fichier.

### 4. Organiser par Date

Utiliser des dossiers temporels pour les données volumineuses.

### 5. Nettoyer Régulièrement

Supprimer régulièrement les fichiers temporaires et obsolètes.

### 6. Compresser les Images

Toujours compresser les images avant upload.

### 7. Utiliser le Format Approprié

Choisir le format de fichier optimal pour chaque type de contenu.

### 8. Surveiller les Coûts

Surveiller régulièrement les coûts de stockage et d'opération.

### 9. Utiliser le Cache

Configurer le cache CDN pour réduire les coûts de téléchargement.

### 10. Documenter la Structure

Documenter la structure de stockage pour faciliter la maintenance.

---

## Migration

### Migration depuis un Autre Storage

Pour migrer depuis un autre service de stockage :

1. Exporter les fichiers
2. Télécharger vers Firebase Storage
3. Mettre à jour les URLs dans Firestore
4. Valider l'intégrité des fichiers

### Migration de Structure

Pour migrer vers une nouvelle structure de dossiers :

1. Créer la nouvelle structure
2. Déplacer les fichiers
3. Mettre à jour les références
4. Supprimer l'ancienne structure

---

## Dépannage

### Erreurs Courantes

**Erreur : Permission Denied**
- Vérifier les règles de sécurité Storage
- Vérifier que l'utilisateur est authentifié

**Erreur : File Too Large**
- Vérifier la taille maximale configurée
- Compresser le fichier avant upload

**Erreur : Invalid File Type**
- Vérifier les types de fichiers autorisés
- Convertir le fichier vers un format supporté

**Erreur : Quota Exceeded**
- Vérifier l'utilisation du stockage
- Nettoyer les fichiers obsolètes
- Augmenter le quota si nécessaire

---

## Coûts

### Estimation des Coûts

| Type | Coût mensuel estimé (100k utilisateurs) |
|------|----------------------------------------|
| Stockage (1TB) | $20 |
| Téléchargements (10TB) | $120 |
| Opérations (10M) | $10 |
| **Total** | **$150** |

### Optimisation des Coûts

- Compresser les images
- Utiliser le cache CDN
- Nettoyer régulièrement
- Archiver les anciens fichiers
- Utiliser des formats optimisés
