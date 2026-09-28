# MCD - Modèle Conceptuel de Données PostgreSQL

## Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Entités Principales](#entités-principales)
3. [Relations](#relations)
4. [Diagramme MCD](#diagramme-mcd)
5. [Contraintes d'intégrité](#contraintes-dintégrité)

---

## Vue d'ensemble

Le Modèle Conceptuel de Données (MCD) de GestionBailleur représente la structure des données de la plateforme immobilière. Il est conçu pour supporter les relations entre bailleurs, clients, logements, visites, messages et autres entités du système.

### Principes de Conception

- **Normalisation** : Base de données normalisée (3NF) pour éviter les redondances
- **Intégrité référentielle** : Contraintes de clé étrangère pour garantir la cohérence
- **Scalabilité** : Structure optimisée pour des centaines de milliers d'utilisateurs
- **Performance** : Indexes appropriés pour les requêtes fréquentes
- **Flexibilité** : Structure évolutive pour les futures fonctionnalités

---

## Entités Principales

### 1. USER (Utilisateur)

**Description** : Entité représentant un utilisateur du système.

**Attributs** :
- `id` : Identifiant unique (UUID)
- `email` : Adresse email (unique)
- `phone` : Numéro de téléphone (unique, optionnel)
- `first_name` : Prénom
- `last_name` : Nom de famille
- `photo_url` : URL de la photo de profil (optionnel)
- `date_of_birth` : Date de naissance
- `gender` : Genre (masculin, féminin, autre)
- `nationality` : Nationalité (code pays ISO)
- `preferred_language` : Langue préférée (code langue ISO)
- `role` : Rôle (client, landlord, admin)
- `status` : Statut (active, inactive, suspended)
- `is_verified` : Vérifié (booléen)
- `is_active` : Actif (booléen)
- `created_at` : Date de création
- `updated_at` : Date de mise à jour
- `last_login_at` : Dernière connexion (optionnel)

**Identifiants** :
- Clé primaire : `id`
- Clé unique : `email`
- Clé unique : `phone`

---

### 2. PROFILE (Profil)

**Description** : Profil étendu d'un utilisateur.

**Attributs** :
- `id` : Identifiant unique (UUID)
- `user_id` : Référence vers USER (FK)
- `bio` : Biographie (optionnel)
- `website` : Site web (optionnel)
- `linkedin` : LinkedIn (optionnel)
- `facebook` : Facebook (optionnel)
- `twitter` : Twitter (optionnel)
- `instagram` : Instagram (optionnel)
- `preferences` : Préférences (JSON)
- `interests` : Centres d'intérêt (optionnel)
- `is_public_profile` : Profil public (booléen)
- `status` : Statut (active, inactive)
- `created_at` : Date de création
- `updated_at` : Date de mise à jour

**Identifiants** :
- Clé primaire : `id`
- Clé étrangère : `user_id` → USER(id)

**Relations** :
- 1:1 avec USER

---

### 3. CLIENT (Client)

**Description** : Informations spécifiques aux clients (locataires).

**Attributs** :
- `id` : Identifiant unique (UUID)
- `user_id` : Référence vers USER (FK)
- `id_number` : Numéro d'identité (optionnel)
- `id_type` : Type d'identité (CNI, passport, license)
- `profession` : Profession (optionnel)
- `monthly_income` : Revenu mensuel (optionnel)
- `employer` : Employeur (optionnel)
- `work_address` : Adresse professionnelle (optionnel)
- `work_phone` : Téléphone professionnel (optionnel)
- `guarantor_name` : Nom du garant (optionnel)
- `guarantor_phone` : Téléphone du garant (optionnel)
- `guarantor_address` : Adresse du garant (optionnel)
- `documents` : Documents (JSON array)
- `verification_status` : Statut de vérification (pending, approved, rejected)
- `status` : Statut (active, inactive)
- `created_at` : Date de création
- `updated_at` : Date de mise à jour

**Identifiants** :
- Clé primaire : `id`
- Clé étrangère : `user_id` → USER(id)

**Relations** :
- 1:1 avec USER

---

### 4. LANDLORD (Bailleur)

**Description** : Informations spécifiques aux bailleurs (propriétaires).

**Attributs** :
- `id` : Identifiant unique (UUID)
- `user_id` : Référence vers USER (FK)
- `company_name` : Nom de l'entreprise (optionnel)
- `registration_number` : Numéro d'enregistrement (optionnel)
- `tax_id` : Numéro fiscal (optionnel)
- `headquarters_address` : Adresse du siège (optionnel)
- `website` : Site web (optionnel)
- `description` : Description (optionnel)
- `business_phone` : Téléphone professionnel (optionnel)
- `business_email` : Email professionnel (optionnel)
- `properties` : Liste des propriétés (JSON array)
- `legal_documents` : Documents juridiques (JSON array)
- `is_professional` : Professionnel (booléen)
- `verification_status` : Statut de vérification (pending, approved, rejected)
- `status` : Statut (active, inactive)
- `created_at` : Date de création
- `updated_at` : Date de mise à jour

**Identifiants** :
- Clé primaire : `id`
- Clé étrangère : `user_id` → USER(id)

**Relations** :
- 1:1 avec USER
- 1:N avec PROPERTY

---

### 5. ADMIN (Administrateur)

**Description** : Administrateurs système.

**Attributs** :
- `id` : Identifiant unique (UUID)
- `user_id` : Référence vers USER (FK)
- `permissions` : Permissions (JSON array)
- `mandat_expiry_date` : Date d'expiration du mandat (optionnel)
- `superior_id` : Référence vers ADMIN (FK, optionnel)
- `is_super_admin` : Super administrateur (booléen)
- `department` : Département
- `position` : Poste (optionnel)
- `status` : Statut (active, inactive)
- `created_at` : Date de création
- `updated_at` : Date de mise à jour

**Identifiants** :
- Clé primaire : `id`
- Clé étrangère : `user_id` → USER(id)
- Clé étrangère : `superior_id` → ADMIN(id)

**Relations** :
- 1:1 avec USER
- N:1 avec ADMIN (hiérarchie)

---

### 6. PROPERTY (Logement)

**Description** : Logement avec toutes ses caractéristiques.

**Attributs** :
- `id` : Identifiant unique (UUID)
- `title` : Titre
- `description` : Description
- `price` : Prix
- `deposit` : Caution (optionnel)
- `advance` : Avance (optionnel)
- `currency` : Devise (code devise ISO)
- `surface` : Surface
- `bedrooms` : Nombre de chambres
- `living_rooms` : Nombre de salons
- `kitchens` : Nombre de cuisines
- `bathrooms` : Nombre de salles de bain
- `toilets` : Nombre de toilettes
- `has_parking` : Parking (booléen)
- `has_balcony` : Balcon (booléen)
- `has_terrace` : Terrasse (booléen)
- `has_internet` : Internet (booléen)
- `has_ac` : Climatisation (booléen)
- `has_generator` : Générateur (booléen)
- `has_well` : Puits (booléen)
- `pets_allowed` : Animaux autorisés (booléen)
- `location` : Localisation (PostGIS Point)
- `address_id` : Référence vers ADDRESS (FK)
- `landlord_id` : Référence vers LANDLORD (FK)
- `landlord_name` : Nom du bailleur (dénormalisé)
- `landlord_phone` : Téléphone du bailleur (dénormalisé)
- `category_id` : Référence vers CATEGORY (FK)
- `category_name` : Nom de la catégorie (dénormalisé)
- `type_id` : Référence vers TYPE (FK)
- `type_name` : Nom du type (dénormalisé)
- `equipment_ids` : Liste des équipements (JSON array)
- `photo_urls` : URLs des photos (JSON array)
- `video_urls` : URLs des vidéos (JSON array)
- `view_count` : Nombre de vues
- `favorite_count` : Nombre de favoris
- `share_count` : Nombre de partages
- `distance` : Distance (optionnel)
- `status` : Statut (draft, published, paused, archived)
- `published_at` : Date de publication
- `expiry_date` : Date d'expiration (optionnel)
- `created_at` : Date de création
- `updated_at` : Date de mise à jour

**Identifiants** :
- Clé primaire : `id`
- Clé étrangère : `address_id` → ADDRESS(id)
- Clé étrangère : `landlord_id` → LANDLORD(id)
- Clé étrangère : `category_id` → CATEGORY(id)
- Clé étrangère : `type_id` → TYPE(id)

**Relations** :
- N:1 avec LANDLORD
- N:1 with ADDRESS
- N:1 avec CATEGORY
- N:1 avec TYPE
- N:N avec EQUIPMENT (via equipment_ids)
- 1:N avec PROPERTY_PHOTO
- 1:N avec PROPERTY_VIDEO
- 1:N with REVIEW
- 1:N avec VISIT
- 1:N avec REPORT

---

### 7. PROPERTY_PHOTO (Photo de logement)

**Description** : Photo d'un logement.

**Attributs** :
- `id` : Identifiant unique (UUID)
- `property_id` : Référence vers PROPERTY (FK)
- `url` : URL de la photo
- `thumbnail_url` : URL de la miniature (optionnel)
- `description` : Description (optionnel)
- `order` : Ordre
- `is_primary` : Photo principale (booléen)
- `status` : Statut (active, inactive)
- `created_at` : Date de création
- `updated_at` : Date de mise à jour

**Identifiants** :
- Clé primaire : `id`
- Clé étrangère : `property_id` → PROPERTY(id)

**Relations** :
- N:1 avec PROPERTY

---

### 8. PROPERTY_VIDEO (Vidéo de logement)

**Description** : Vidéo d'un logement.

**Attributs** :
- `id` : Identifiant unique (UUID)
- `property_id` : Référence vers PROPERTY (FK)
- `url` : URL de la vidéo
- `thumbnail_url` : URL de la miniature (optionnel)
- `description` : Description (optionnel)
- `duration` : Durée (optionnel)
- `order` : Ordre
- `status` : Statut (active, inactive)
- `created_at` : Date de création
- `updated_at` : Date de mise à jour

**Identifiants** :
- Clé primaire : `id`
- Clé étrangère : `property_id` → PROPERTY(id)

**Relations** :
- N:1 avec PROPERTY

---

### 9. CATEGORY (Catégorie)

**Description** : Catégorie de logement.

**Attributs** :
- `id` : Identifiant unique (code court)
- `name` : Nom
- `description` : Description (optionnel)
- `icon` : Icône (optionnel)
- `order` : Ordre
- `status` : Statut (active, inactive)
- `created_at` : Date de création
- `updated_at` : Date de mise à jour

**Identifiants** :
- Clé primaire : `id`
- Clé unique : `name`

**Relations** :
- 1:N avec PROPERTY

---

### 10. TYPE (Type de logement)

**Description** : Type de logement (location, vente, etc.).

**Attributs** :
- `id` : Identifiant unique (code court)
- `name` : Nom
- `description` : Description (optionnel)
- `icon` : Icône (optionnel)
- `order` : Ordre
- `status` : Statut (active, inactive)
- `created_at` : Date de création
- `updated_at` : Date de mise à jour

**Identifiants** :
- Clé primaire : `id`
- Clé unique : `name`

**Relations** :
- 1:N avec PROPERTY

---

### 11. EQUIPMENT (Équipement)

**Description** : Équipement disponible dans les logements.

**Attributs** :
- `id` : Identifiant unique (code court)
- `name` : Nom
- `description` : Description (optionnel)
- `icon` : Icône (optionnel)
- `category` : Catégorie
- `order` : Ordre
- `status` : Statut (active, inactive)
- `created_at` : Date de création
- `updated_at` : Date de mise à jour

**Identifiants** :
- Clé primaire : `id`
- Clé unique : `name`

**Relations** :
- N:N avec PROPERTY (via equipment_ids)

---

### 12. CITY (Ville)

**Description** : Ville avec informations géographiques.

**Attributs** :
- `id` : Identifiant unique (code court)
- `name` : Nom
- `code` : Code (optionnel)
- `country` : Pays (code pays ISO)
- `region` : Région (optionnel)
- `province` : Province (optionnel)
- `location` : Localisation (PostGIS Point, optionnel)
- `population` : Population (optionnel)
- `status` : Statut (active, inactive)
- `created_at` : Date de création
- `updated_at` : Date de mise à jour

**Identifiants** :
- Clé primaire : `id`
- Clé unique : `name` + `country`

**Relations** :
- 1:N avec DISTRICT
- 1:N avec ADDRESS

---

### 13. DISTRICT (Quartier)

**Description** : Quartier rattaché à une ville.

**Attributs** :
- `id` : Identifiant unique (code court)
- `name` : Nom
- `city_id` : Référence vers CITY (FK)
- `city_name` : Nom de la ville (dénormalisé)
- `code` : Code (optionnel)
- `description` : Description (optionnel)
- `location` : Localisation (PostGIS Point, optionnel)
- `population` : Population (optionnel)
- `status` : Statut (active, inactive)
- `created_at` : Date de création
- `updated_at` : Date de mise à jour

**Identifiants** :
- Clé primaire : `id`
- Clé étrangère : `city_id` → CITY(id)
- Clé unique : `city_id` + `name`

**Relations** :
- N:1 avec CITY
- 1:N avec ADDRESS

---

### 14. ADDRESS (Adresse)

**Description** : Adresse physique avec coordonnées GPS.

**Attributs** :
- `id` : Identifiant unique (UUID)
- `street` : Rue
- `number` : Numéro (optionnel)
- `complement` : Complément (optionnel)
- `postal_code` : Code postal
- `city_id` : Référence vers CITY (FK)
- `city_name` : Nom de la ville (dénormalisé)
- `district_id` : Référence vers DISTRICT (FK, optionnel)
- `district_name` : Nom du quartier (dénormalisé, optionnel)
- `location` : Localisation (PostGIS Point)
- `status` : Statut (active, inactive)
- `created_at` : Date de création
- `updated_at` : Date de mise à jour

**Identifiants** :
- Clé primaire : `id`
- Clé étrangère : `city_id` → CITY(id)
- Clé étrangère : `district_id` → DISTRICT(id)

**Relations** :
- N:1 avec CITY
- N:1 avec DISTRICT
- 1:N avec PROPERTY

---

### 15. FAVORITE (Favori)

**Description** : Favori utilisateur pour un logement.

**Attributs** :
- `id` : Identifiant unique (UUID)
- `user_id` : Référence vers USER (FK)
- `property_id` : Référence vers PROPERTY (FK)
- `property_title` : Titre du logement (dénormalisé)
- `property_price` : Prix du logement (dénormalisé)
- `property_location` : Localisation du logement (dénormalisé)
- `notes` : Notes (optionnel)
- `status` : Statut (active, inactive)
- `created_at` : Date de création
- `updated_at` : Date de mise à jour

**Identifiants** :
- Clé primaire : `id`
- Clé étrangère : `user_id` → USER(id)
- Clé étrangère : `property_id` → PROPERTY(id)
- Clé unique : `user_id` + `property_id`

**Relations** :
- N:1 avec USER
- N:1 avec PROPERTY

---

### 16. REVIEW (Avis)

**Description** : Avis et évaluation d'un logement.

**Attributs** :
- `id` : Identifiant unique (UUID)
- `user_id` : Référence vers USER (FK)
- `user_name` : Nom de l'utilisateur (dénormalisé)
- `property_id` : Référence vers PROPERTY (FK)
- `property_title` : Titre du logement (dénormalisé)
- `rating` : Note (1-5)
- `comment` : Commentaire (optionnel)
- `landlord_response` : Réponse du bailleur (optionnel)
- `response_date` : Date de réponse (optionnel)
- `is_verified` : Vérifié (booléen)
- `status` : Statut (active, inactive)
- `created_at` : Date de création
- `updated_at` : Date de mise à jour

**Identifiants** :
- Clé primaire : `id`
- Clé étrangère : `user_id` → USER(id)
- Clé étrangère : `property_id` → PROPERTY(id)
- Clé unique : `user_id` + `property_id`

**Relations** :
- N:1 avec USER
- N:1 avec PROPERTY

---

### 17. CONVERSATION (Conversation)

**Description** : Conversation entre utilisateurs.

**Attributs** :
- `id` : Identifiant unique (UUID)
- `participant1_id` : Référence vers USER (FK)
- `participant1_name` : Nom du participant 1 (dénormalisé)
- `participant2_id` : Référence vers USER (FK)
- `participant2_name` : Nom du participant 2 (dénormalisé)
- `property_id` : Référence vers PROPERTY (FK, optionnel)
- `property_title` : Titre du logement (dénormalisé, optionnel)
- `last_message` : Dernier message (optionnel)
- `last_message_at` : Date du dernier message (optionnel)
- `message_count` : Nombre de messages
- `unread_count` : Nombre de messages non lus
- `status` : Statut (active, inactive, archived)
- `created_at` : Date de création
- `updated_at` : Date de mise à jour

**Identifiants** :
- Clé primaire : `id`
- Clé étrangère : `participant1_id` → USER(id)
- Clé étrangère : `participant2_id` → USER(id)
- Clé étrangère : `property_id` → PROPERTY(id)

**Relations** :
- N:1 avec USER (participant1)
- N:1 avec USER (participant2)
- N:1 avec PROPERTY
- 1:N avec MESSAGE

---

### 18. MESSAGE (Message)

**Description** : Message dans une conversation.

**Attributs** :
- `id` : Identifiant unique (UUID)
- `conversation_id` : Référence vers CONVERSATION (FK)
- `sender_id` : Référence vers USER (FK)
- `sender_name` : Nom de l'expéditeur (dénormalisé)
- `recipient_id` : Référence vers USER (FK)
- `content` : Contenu
- `attachment_url` : URL de la pièce jointe (optionnel)
- `type` : Type (text, image, document)
- `is_read` : Lu (booléen)
- `read_at` : Date de lecture (optionnel)
- `status` : Statut (active, deleted)
- `created_at` : Date de création
- `updated_at` : Date de mise à jour

**Identifiants** :
- Clé primaire : `id`
- Clé étrangère : `conversation_id` → CONVERSATION(id)
- Clé étrangère : `sender_id` → USER(id)
- Clé étrangère : `recipient_id` → USER(id)

**Relations** :
- N:1 avec CONVERSATION
- N:1 avec USER (sender)
- N:1 avec USER (recipient)

---

### 19. NOTIFICATION (Notification)

**Description** : Notification utilisateur.

**Attributs** :
- `id` : Identifiant unique (UUID)
- `user_id` : Référence vers USER (FK)
- `title` : Titre
- `message` : Message
- `link` : Lien (optionnel)
- `type` : Type
- `is_read` : Lu (booléen)
- `read_at` : Date de lecture (optionnel)
- `status` : Statut (active, archived)
- `created_at` : Date de création
- `updated_at` : Date de mise à jour

**Identifiants** :
- Clé primaire : `id`
- Clé étrangère : `user_id` → USER(id)

**Relations** :
- N:1 avec USER

---

### 20. VISIT (Visite)

**Description** : Visite programmée pour un logement.

**Attributs** :
- `id` : Identifiant unique (UUID)
- `property_id` : Référence vers PROPERTY (FK)
- `property_title` : Titre du logement (dénormalisé)
- `client_id` : Référence vers CLIENT (FK)
- `client_name` : Nom du client (dénormalisé)
- `landlord_id` : Référence vers LANDLORD (FK)
- `landlord_name` : Nom du bailleur (dénormalisé)
- `visit_date` : Date de visite
- `start_time` : Heure de début (optionnel)
- `end_time` : Heure de fin (optionnel)
- `status` : Statut (pending, confirmed, cancelled, completed)
- `notes` : Notes (optionnel)
- `feedback` : Feedback (optionnel)
- `created_at` : Date de création
- `updated_at` : Date de mise à jour

**Identifiants** :
- Clé primaire : `id`
- Clé étrangère : `property_id` → PROPERTY(id)
- Clé étrangère : `client_id` → CLIENT(id)
- Clé étrangère : `landlord_id` → LANDLORD(id)

**Relations** :
- N:1 avec PROPERTY
- N:1 avec CLIENT
- N:1 with LANDLORD

---

### 21. VISIT_SCHEDULE (Planning de visite)

**Description** : Planning des créneaux de visite des bailleurs.

**Attributs** :
- `id` : Identifiant unique (UUID)
- `landlord_id` : Référence vers LANDLORD (FK)
- `property_id` : Référence vers PROPERTY (FK)
- `slots` : Créneaux (JSON array)
- `instructions` : Instructions (optionnel)
- `visit_duration` : Durée de la visite (minutes)
- `booking_lead_time` : Délai de réservation (heures)
- `status` : Statut (active, inactive)
- `created_at` : Date de création
- `updated_at` : Date de mise à jour

**Identifiants** :
- Clé primaire : `id`
- Clé étrangère : `landlord_id` → LANDLORD(id)
- Clé étrangère : `property_id` → PROPERTY(id)

**Relations** :
- N:1 avec LANDLORD
- N:1 avec PROPERTY

---

### 22. REPORT (Signalement)

**Description** : Signalement de contenu inapproprié.

**Attributs** :
- `id` : Identifiant unique (UUID)
- `author_id` : Référence vers USER (FK)
- `entity_id` : ID de l'entité
- `entity_type` : Type de l'entité
- `reason` : Raison
- `description` : Description (optionnel)
- `status` : Statut (pending, in_progress, resolved, rejected)
- `admin_response` : Réponse de l'admin (optionnel)
- `processed_at` : Date de traitement (optionnel)
- `processed_by` : Référence vers ADMIN (FK, optionnel)
- `created_at` : Date de création
- `updated_at` : Date de mise à jour

**Identifiants** :
- Clé primaire : `id`
- Clé étrangère : `author_id` → USER(id)
- Clé étrangère : `processed_by` → ADMIN(id)

**Relations** :
- N:1 avec USER (author)
- N:1 avec ADMIN (processed_by)

---

### 23. VERIFICATION_DOCUMENT (Document de vérification)

**Description** : Document de vérification utilisateur.

**Attributs** :
- `id` : Identifiant unique (UUID)
- `user_id` : Référence vers USER (FK)
- `document_type` : Type de document
- `document_number` : Numéro de document
- `document_url` : URL du document (optionnel)
- `front_url` : URL du recto (optionnel)
- `back_url` : URL du verso (optionnel)
- `expiry_date` : Date d'expiration
- `verification_status` : Statut de vérification (pending, approved, rejected)
- `comment` : Commentaire (optionnel)
- `verified_at` : Date de vérification (optionnel)
- `verified_by` : Référence vers ADMIN (FK, optionnel)
- `status` : Statut (active, inactive, expired)
- `created_at` : Date de création
- `updated_at` : Date de mise à jour

**Identifiants** :
- Clé primaire : `id`
- Clé étrangère : `user_id` → USER(id)
- Clé étrangère : `verified_by` → ADMIN(id)

**Relations** :
- N:1 avec USER
- N:1 avec ADMIN

---

### 24. SEARCH (Recherche)

**Description** : Historique des recherches utilisateurs.

**Attributs** :
- `id` : Identifiant unique (UUID)
- `user_id` : Référence vers USER (FK)
- `query` : Requête (optionnel)
- `category_id` : Référence vers CATEGORY (FK, optionnel)
- `type_id` : Référence vers TYPE (FK, optionnel)
- `min_price` : Prix minimum (optionnel)
- `max_price` : Prix maximum (optionnel)
- `min_surface` : Surface minimum (optionnel)
- `max_surface` : Surface maximum (optionnel)
- `min_bedrooms` : Chambres minimum (optionnel)
- `max_bedrooms` : Chambres maximum (optionnel)
- `city_id` : Référence vers CITY (FK, optionnel)
- `district_id` : Référence vers DISTRICT (FK, optionnel)
- `location` : Localisation (PostGIS Point, optionnel)
- `radius` : Rayon (optionnel)
- `equipment_ids` : Liste des équipements (JSON array, optionnel)
- `result_count` : Nombre de résultats
- `status` : Statut (active, inactive)
- `created_at` : Date de création
- `updated_at` : Date de mise à jour

**Identifiants** :
- Clé primaire : `id`
- Clé étrangère : `user_id` → USER(id)
- Clé étrangère : `category_id` → CATEGORY(id)
- Clé étrangère : `type_id` → TYPE(id)
- Clé étrangère : `city_id` → CITY(id)
- Clé étrangère : `district_id` → DISTRICT(id)

**Relations** :
- N:1 avec USER
- N:1 avec CATEGORY
- N:1 avec TYPE
- N:1 avec CITY
- N:1 avec DISTRICT

---

### 25. SAVED_SEARCH (Recherche sauvegardée)

**Description** : Recherche sauvegardée par les utilisateurs.

**Attributs** :
- `id` : Identifiant unique (UUID)
- `user_id` : Référence vers USER (FK)
- `name` : Nom
- `query` : Requête (optionnel)
- `category_id` : Référence vers CATEGORY (FK, optionnel)
- `type_id` : Référence vers TYPE (FK, optionnel)
- `min_price` : Prix minimum (optionnel)
- `max_price` : Prix maximum (optionnel)
- `min_surface` : Surface minimum (optionnel)
- `max_surface` : Surface maximum (optionnel)
- `min_bedrooms` : Chambres minimum (optionnel)
- `max_bedrooms` : Chambres maximum (optionnel)
- `city_id` : Référence vers CITY (FK, optionnel)
- `district_id` : Référence vers DISTRICT (FK, optionnel)
- `location` : Localisation (PostGIS Point, optionnel)
- `radius` : Rayon (optionnel)
- `equipment_ids` : Liste des équipements (JSON array, optionnel)
- `alert_enabled` : Alertes activées (booléen)
- `alert_frequency` : Fréquence des alertes (immediate, daily, weekly)
- `status` : Statut (active, inactive)
- `created_at` : Date de création
- `updated_at` : Date de mise à jour

**Identifiants** :
- Clé primaire : `id`
- Clé étrangère : `user_id` → USER(id)
- Clé étrangère : `category_id` → CATEGORY(id)
- Clé étrangère : `type_id` → TYPE(id)
- Clé étrangère : `city_id` → CITY(id)
- Clé étrangère : `district_id` → DISTRICT(id)

**Relations** :
- N:1 avec USER
- N:1 avec CATEGORY
- N:1 avec TYPE
- N:1 avec CITY
- N:1 avec DISTRICT

---

### 26. CHATBOT_CONVERSATION (Conversation chatbot)

**Description** : Conversation avec le chatbot.

**Attributs** :
- `id` : Identifiant unique (UUID)
- `user_id` : Référence vers USER (FK)
- `title` : Titre (optionnel)
- `context` : Contexte (optionnel)
- `last_interaction_at` : Dernière interaction (optionnel)
- `message_count` : Nombre de messages
- `status` : Statut (active, inactive, archived)
- `created_at` : Date de création
- `updated_at` : Date de mise à jour

**Identifiants** :
- Clé primaire : `id`
- Clé étrangère : `user_id` → USER(id)

**Relations** :
- N:1 avec USER
- 1:N avec CHATBOT_MESSAGE

---

### 27. CHATBOT_MESSAGE (Message chatbot)

**Description** : Message du chatbot.

**Attributs** :
- `id` : Identifiant unique (UUID)
- `conversation_id` : Référence vers CHATBOT_CONVERSATION (FK)
- `content` : Contenu
- `role` : Rôle (user, assistant)
- `context` : Contexte (optionnel)
- `data` : Données (JSON, optionnel)
- `status` : Statut (active, inactive)
- `created_at` : Date de création
- `updated_at` : Date de mise à jour

**Identifiants** :
- Clé primaire : `id`
- Clé étrangère : `conversation_id` → CHATBOT_CONVERSATION(id)

**Relations** :
- N:1 avec CHATBOT_CONVERSATION

---

### 28. USER_SETTINGS (Paramètres utilisateur)

**Description** : Paramètres et préférences utilisateur.

**Attributs** :
- `id` : Identifiant unique (UUID)
- `user_id` : Référence vers USER (FK)
- `language` : Langue (code langue ISO)
- `timezone` : Fuseau horaire (IANA timezone)
- `email_notifications` : Notifications email (booléen)
- `push_notifications` : Notifications push (booléen)
- `sms_notifications` : Notifications SMS (booléen)
- `public_profile` : Profil public (booléen)
- `share_location` : Partager la localisation (booléen)
- `theme` : Thème (light, dark)
- `newsletter_frequency` : Fréquence newsletter (immediate, daily, weekly)
- `status` : Statut (active, inactive)
- `created_at` : Date de création
- `updated_at` : Date de mise à jour

**Identifiants** :
- Clé primaire : `id`
- Clé étrangère : `user_id` → USER(id)
- Clé unique : `user_id`

**Relations** :
- 1:1 avec USER

---

### 29. USER_SESSION (Session utilisateur)

**Description** : Session utilisateur avec tokens.

**Attributs** :
- `id` : Identifiant unique (UUID)
- `user_id` : Référence vers USER (FK)
- `access_token` : Token d'accès (JWT)
- `refresh_token` : Token de rafraîchissement (JWT)
- `start_date` : Date de début
- `end_date` : Date de fin (optionnel)
- `device_id` : ID du device (optionnel)
- `ip_address` : Adresse IP (optionnel)
- `user_agent` : User agent (optionnel)
- `location` : Localisation (optionnel)
- `is_active` : Active (booléen)
- `status` : Statut (active, expired, revoked)
- `created_at` : Date de création
- `updated_at` : Date de mise à jour

**Identifiants** :
- Clé primaire : `id`
- Clé étrangère : `user_id` → USER(id)

**Relations** :
- N:1 avec USER

---

### 30. AUDIT_LOG (Log d'audit)

**Description** : Log d'audit du système.

**Attributs** :
- `id` : Identifiant unique (UUID)
- `user_id` : Référence vers USER (FK, optionnel)
- `action_type` : Type d'action
- `description` : Description (optionnel)
- `entity_id` : ID de l'entité (optionnel)
- `entity_type` : Type de l'entité (optionnel)
- `data` : Données (JSON, optionnel)
- `ip_address` : Adresse IP (optionnel)
- `user_agent` : User agent (optionnel)
- `status` : Statut (active, inactive)
- `created_at` : Date de création
- `updated_at` : Date de mise à jour

**Identifiants** :
- Clé primaire : `id`
- Clé étrangère : `user_id` → USER(id)

**Relations** :
- N:1 avec USER

---

## Relations

### Relations Principales

| Entité Source | Relation | Entité Cible | Cardinalité |
|---------------|----------|--------------|-------------|
| USER | a | PROFILE | 1:1 |
| USER | a | CLIENT | 1:1 |
| USER | a | LANDLORD | 1:1 |
| USER | a | ADMIN | 1:1 |
| USER | a | USER_SETTINGS | 1:1 |
| USER | a | FAVORITE | 1:N |
| USER | a | REVIEW | 1:N |
| USER | a | CONVERSATION (participant1) | 1:N |
| USER | a | CONVERSATION (participant2) | 1:N |
| USER | a | MESSAGE (sender) | 1:N |
| USER | a | MESSAGE (recipient) | 1:N |
| USER | a | NOTIFICATION | 1:N |
| USER | a | SEARCH | 1:N |
| USER | a | SAVED_SEARCH | 1:N |
| USER | a | CHATBOT_CONVERSATION | 1:N |
| USER | a | USER_SESSION | 1:N |
| USER | a | AUDIT_LOG | 1:N |
| USER | a | VERIFICATION_DOCUMENT | 1:N |
| LANDLORD | a | PROPERTY | 1:N |
| LANDLORD | a | VISIT_SCHEDULE | 1:N |
| CLIENT | a | VISIT | 1:N |
| PROPERTY | a | PROPERTY_PHOTO | 1:N |
| PROPERTY | a | PROPERTY_VIDEO | 1:N |
| PROPERTY | a | REVIEW | 1:N |
| PROPERTY | a | VISIT | 1:N |
| PROPERTY | a | REPORT | 1:N |
| PROPERTY | a | FAVORITE | 1:N |
| PROPERTY | a | CONVERSATION | 1:N |
| CITY | a | DISTRICT | 1:N |
| CITY | a | ADDRESS | 1:N |
| DISTRICT | a | ADDRESS | 1:N |
| ADDRESS | a | PROPERTY | 1:N |
| CATEGORY | a | PROPERTY | 1:N |
| TYPE | a | PROPERTY | 1:N |
| CONVERSATION | a | MESSAGE | 1:N |
| CHATBOT_CONVERSATION | a | CHATBOT_MESSAGE | 1:N |
| ADMIN | a | ADMIN (hiérarchie) | 1:N |
| ADMIN | a | REPORT (processed_by) | 1:N |
| ADMIN | a | VERIFICATION_DOCUMENT (verified_by) | 1:N |

---

## Diagramme MCD

```
┌─────────────┐
│    USER     │
└──────┬──────┘
       │
       ├──────────────┬──────────────┬──────────────┐
       │              │              │              │
       ▼              ▼              ▼              ▼
┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│   PROFILE   │ │   CLIENT    │ │  LANDLORD   │ │    ADMIN    │
└─────────────┘ └──────┬──────┘ └──────┬──────┘ └──────┬──────┘
                       │              │              │
                       │              │              │
                       │              │              │
                       │              │              │
                       ▼              ▼              ▼
                ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
                │    VISIT    │ │  PROPERTY   │ │    ADMIN    │
                └─────────────┘ └──────┬──────┘ └─────────────┘
                                       │
                    ┌──────────────────┼──────────────────┐
                    │                  │                  │
                    ▼                  ▼                  ▼
           ┌─────────────┐   ┌─────────────┐   ┌─────────────┐
           │PROPERTY_PHOTO│   │PROPERTY_VIDEO│   │    REVIEW   │
           └─────────────┘   └─────────────┘   └─────────────┘

┌─────────────┐       ┌─────────────┐       ┌─────────────┐
│    CITY     │───────│  DISTRICT   │───────│  ADDRESS    │
└─────────────┘       └─────────────┘       └──────┬──────┘
                                                   │
                                                   ▼
                                            ┌─────────────┐
                                            │  PROPERTY   │
                                            └─────────────┘

┌─────────────┐       ┌─────────────┐
│ CONVERSATION│───────│   MESSAGE   │
└─────────────┘       └─────────────┘

┌─────────────┐       ┌─────────────┐
│CHATBOT_CONV │───────│CHATBOT_MSG  │
└─────────────┘       └─────────────┘
```

---

## Contraintes d'Intégrité

### Contraintes de Clé Primaire

- Toutes les tables ont une clé primaire `id`
- Les IDs sont des UUID v4 pour la plupart des tables
- Les tables de référence utilisent des codes courts (CATEGORY, TYPE, EQUIPMENT, CITY, DISTRICT)

### Contraintes de Clé Étrangère

- Toutes les clés étrangères sont indexées
- Les clés étrangères ont des contraintes ON DELETE CASCADE ou RESTRICT selon le cas
- Les clés étrangères nullable permettent les relations optionnelles

### Contraintes d'Unicité

- `USER.email` : Unique
- `USER.phone` : Unique
- `CATEGORY.name` : Unique
- `TYPE.name` : Unique
- `EQUIPMENT.name` : Unique
- `CITY.name` + `CITY.country` : Unique
- `DISTRICT.city_id` + `DISTRICT.name` : Unique
- `FAVORITE.user_id` + `FAVORITE.property_id` : Unique
- `REVIEW.user_id` + `REVIEW.property_id` : Unique
- `USER_SETTINGS.user_id` : Unique

### Contraintes de Non Nullité

- Les champs obligatoires ont une contrainte NOT NULL
- Les champs optionnels sont nullable
- Les timestamps (created_at, updated_at) sont obligatoires

### Contraintes de Domaine

- `USER.role` : ENUM (client, landlord, admin)
- `USER.status` : ENUM (active, inactive, suspended)
- `USER.gender` : ENUM (masculine, feminine, other)
- `PROPERTY.status` : ENUM (draft, published, paused, archived)
- `VISIT.status` : ENUM (pending, confirmed, cancelled, completed)
- `REVIEW.rating` : INT 1-5
- `MESSAGE.type` : ENUM (text, image, document)

### Contraintes de Vérification

- `PROPERTY.price` > 0
- `PROPERTY.surface` > 0
- `PROPERTY.bedrooms` >= 0
- `REVIEW.rating` BETWEEN 1 AND 5
- `VISIT.visit_date` >= CURRENT_DATE

### Contraintes de Trigger

- `USER.updated_at` : Automatique avant UPDATE
- `PROPERTY.updated_at` : Automatique avant UPDATE
- `PROPERTY.view_count` : Incrémenté automatiquement
- `PROPERTY.favorite_count` : Incrémenté automatiquement
- `CONVERSATION.updated_at` : Automatique avant UPDATE
- `CONVERSATION.message_count` : Incrémenté automatiquement
