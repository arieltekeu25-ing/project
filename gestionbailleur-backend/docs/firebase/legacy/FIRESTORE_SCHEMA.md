# Schéma Firestore - GestionBailleur

## Vue d'ensemble

Ce document décrit l'architecture complète de Cloud Firestore pour la plateforme GestionBailleur. Le schéma est conçu pour supporter plusieurs centaines de milliers d'utilisateurs avec des performances optimales.

## Principes de Conception

### 1. Structure Hiérarchique
- Collections racines pour les entités principales
- Sous-collections pour les entités dépendantes
- Documents imbriqués pour les données rarement modifiées

### 2. Dénormalisation Stratégique
- Données critiques dupliquées pour éviter les jointures
- Données de référence normalisées
- Mises à jour synchronisées via Cloud Functions

### 3. Partitionnement
- Sharding par région géographique
- Partitionnement temporel pour les données volumineuses
- Collections séparées pour les données d'archive

### 4. Scalabilité
- Structure plate pour les requêtes complexes
- Index composites optimisés
- Limitation de la taille des documents (max 1MB)

## Collections Racines

### Collections Principales

1. **users** - Utilisateurs du système
2. **profiles** - Profils utilisateurs
3. **clients** - Informations spécifiques aux clients
4. **landlords** - Informations spécifiques aux bailleurs
5. **admins** - Administrateurs système
6. **properties** - Logements
7. **categories** - Catégories de logements
8. **types** - Types de logements
9. **cities** - Villes
10. **districts** - Quartiers
11. **addresses** - Adresses
12. **equipment** - Équipements disponibles
13. **favorites** - Favoris utilisateurs
14. **searches** - Historique de recherches
15. **saved_searches** - Recherches sauvegardées
16. **conversations** - Conversations messagerie
17. **notifications** - Notifications utilisateurs
18. **reviews** - Avis et évaluations
19. **visits** - Visites programmées
20. **visit_schedules** - Planning des visites
21. **reports** - Signalements
22. **verification_documents** - Documents de vérification
23. **chatbot_conversations** - Conversations chatbot
24. **user_settings** - Paramètres utilisateurs
25. **user_sessions** - Sessions utilisateurs

### Collections de Support

26. **audit_logs** - Logs d'audit
27. **analytics** - Données analytiques
28. **counters** - Compteurs globaux
29. **config** - Configuration système
30. **maintenance** - Informations de maintenance

## Structure Hiérarchique

```
gestionbailleur/
├── users/                          # Utilisateurs
│   ├── {userId}/
│   │   ├── profile/               # Profil utilisateur
│   │   ├── settings/              # Paramètres
│   │   ├── sessions/              # Sessions actives
│   │   ├── favorites/             # Favoris
│   │   ├── searches/              # Historique recherche
│   │   ├── saved_searches/        # Recherches sauvegardées
│   │   ├── notifications/         # Notifications
│   │   ├── verification_docs/     # Documents vérification
│   │   └── chatbot_conversations/ # Conversations chatbot
│
├── properties/                     # Logements
│   ├── {propertyId}/
│   │   ├── photos/                # Photos
│   │   ├── videos/                # Vidéos
│   │   ├── reviews/               # Avis
│   │   ├── visits/                # Visites
│   │   └── reports/               # Signalements
│
├── conversations/                  # Conversations
│   ├── {conversationId}/
│   │   └── messages/              # Messages
│
├── cities/                         # Villes
│   ├── {cityId}/
│   │   └── districts/             # Quartiers
│
├── categories/                     # Catégories
├── types/                          # Types
├── equipment/                      # Équipements
├── audit_logs/                    # Logs audit
├── analytics/                      # Analytics
├── counters/                       # Compteurs
└── config/                         # Configuration
```

## Conventions de Nommage

### Collections
- Nom en minuscules
- Pluriel pour les collections d'entités
- Séparateur underscore pour les mots composés
- Exemples : `users`, `saved_searches`, `verification_documents`

### Documents
- ID auto-généré par Firestore (UUID v4)
- Pour les documents de référence : codes courts
- Exemples : `550e8400-e29b-41d4-a716-446655440000`, `cat_apartment`

### Champs
- camelCase pour les champs
- Préfixes pour les types spécifiques :
  - `is_` pour les booléens
  - `has_` pour les booléens
  - `date_` pour les dates
  - `count_` pour les compteurs
  - `list_` pour les tableaux
  - `map_` pour les objets

### Sous-collections
- Nom singulier
- Relation explicite dans le nom
- Exemples : `profile`, `photos`, `messages`

## Types de Données

### Types Primitifs
- **string** - Texte
- **number** - Nombre (entier ou décimal)
- **boolean** - Booléen
- **null** - Valeur nulle

### Types Complexes
- **array** - Tableau de valeurs
- **map** - Objet JSON
- **reference** - Référence vers un autre document
- **timestamp** - Date/heure Firestore
- **geopoint** - Coordonnées géographiques

### Types Personnalisés
- **enum** - Énumération (stockée comme string)
- **money** - Montant monétaire (map avec amount et currency)
- **url** - URL validée (string)
- **email** - Email validé (string)
- **phone** - Téléphone validé (string)

## Stratégies de Dénormalisation

### 1. Données de Profil
- Profil utilisateur dénormalisé dans les conversations
- Informations bailleur dénormalisées dans les logements
- Statistiques dénormalisées dans les logements

### 2. Données de Référence
- Catégories et types normalisés (référence)
- Villes et quartiers normalisés (référence)
- Équipements normalisés (référence)

### 3. Données Temporelles
- Historique des recherches partitionné par mois
- Logs d'audit partitionnés par jour
- Analytics partitionnés par semaine

## Stratégies de Partitionnement

### 1. Partitionnement Géographique
- Préfixe de région dans les IDs de documents
- Collections séparées par région pour les données volumineuses
- Exemple : `ci_abidjan_550e8400...`

### 2. Partitionnement Temporel
- Collections sharded par période pour les logs
- Sous-collections par année/mois pour l'historique
- Exemple : `searches_2024_01`

### 3. Partitionnement par Type
- Collections séparées pour les types de notifications
- Sous-collections par catégorie pour les logements
- Exemple : `notifications_messages`, `notifications_system`

## Gestion des Relations

### Références Simples
```javascript
{
  "landlord_id": "550e8400-e29b-41d4-a716-446655440000",
  "landlord_ref": db.collection('users').doc('550e8400...')
}
```

### Références Multiples
```javascript
{
  "equipment_ids": ["eq1", "eq2", "eq3"],
  "equipment_refs": [
    db.collection('equipment').doc('eq1'),
    db.collection('equipment').doc('eq2'),
    db.collection('equipment').doc('eq3')
  ]
}
```

### Relations Hiérarchiques
```javascript
// Parent document
{
  "id": "city_001",
  "name": "Abidjan"
}

// Child document in subcollection
{
  "id": "district_001",
  "name": "Cocody",
  "city_id": "city_001"
}
```

## Optimisations de Performance

### 1. Limitation des Tailles
- Documents max 1MB
- Tableaux max 500 éléments
- Profondeur d'imbrication max 5 niveaux

### 2. Pagination
- Cursor-based pagination pour les grandes listes
- Limit par défaut : 20 documents
- Maximum : 100 documents par requête

### 3. Cache
- Utilisation du cache Firestore client
- Cache des données de référence (catégories, types)
- Invalidation du cache sur modification

### 4. Requêtes Optimisées
- Index composites pour les filtres multiples
- Préchargement des données fréquemment accédées
- Projection de champs pour réduire la taille

## Stratégies de Mise à Jour

### 1. Mises à Jour Atomiques
- Utilisation de transactions pour les mises à jour complexes
- Batch writes pour les mises à jour multiples
- Optimistic locking pour éviter les conflits

### 2. Synchronisation des Données Dénormalisées
- Cloud Functions pour synchroniser les mises à jour
- Événements onCreate, onUpdate, onDelete
- File d'attente pour les mises à jour en masse

### 3. Gestion des Conflits
- Versioning des documents
- Timestamp de dernière modification
- Stratégie de résolution : last-write-wins

## Stratégies d'Archivage

### 1. Archivage Temporel
- Données de plus de 90 jours déplacées vers archive
- Collections séparées pour les données archivées
- Préfixe `archived_` pour les collections d'archive

### 2. Archivage par État
- Documents avec statut `deleted` ou `archived`
- Conservation pendant 30 jours avant suppression définitive
- Export vers Cloud Storage avant suppression

### 3. Archivage par Volume
- Collections sharded par volume
- Rotation automatique des shards
- Compression des données archivées

## Sécurité des Données

### 1. Chiffrement
- Chiffrement automatique par Firestore
- Chiffrement des champs sensibles au niveau application
- Clés de chiffrement gérées par Cloud KMS

### 2. Anonymisation
- Données personnelles pseudonymisées
- Logs anonymisés
- Données d'analyse agrégées

### 3. Conformité
- RGPD : Droit à l'oubli
- Conservation des données limitée
- Audit trail des accès aux données

## Monitoring et Maintenance

### 1. Monitoring
- Monitoring des performances des requêtes
- Alertes pour les requêtes lentes
- Suivi de l'utilisation des quotas

### 2. Maintenance
- Nettoyage régulier des données obsolètes
- Optimisation des index
- Vérification de l'intégrité des données

### 3. Sauvegarde
- Export quotidien vers Cloud Storage
- Sauvegardes multi-régionales
- Tests de restauration réguliers

## Scalabilité

### 1. Scalabilité Horizontale
- Distribution automatique par Firestore
- Sharding automatique des collections
- Load balancing des requêtes

### 2. Scalabilité Verticale
- Optimisation des requêtes
- Réduction de la taille des documents
- Cache intelligent

### 3. Limites Firestore
- 1 document = 1 Mo
- 1 document = 20 000 champs
- 1 tableau = 20 000 éléments
- 1 requête = 10 000 résultats max
- 1 transaction = 500 documents max

## Migration et Évolution

### 1. Version du Schéma
- Version du schéma dans la collection `config`
- Migration progressive des documents
- Compatibilité descendante maintenue

### 2. Migration des Données
- Scripts de migration Cloud Functions
- Validation des données migrées
- Rollback en cas d'erreur

### 3. Évolution du Schéma
- Champs optionnels pour les nouvelles fonctionnalités
- Dépréciation progressive des anciens champs
- Documentation des changements
