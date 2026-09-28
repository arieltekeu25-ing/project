# PostgreSQL Schema - GestionBailleur

## Table des matières

1. [Conventions PostgreSQL](#conventions-postgresql)
2. [Tables Utilisateurs](#tables-utilisateurs)
3. [Tables Logements](#tables-logements)
4. [Tables Localisation](#tables-localisation)
5. [Tables Communication](#tables-communication)
6. [Tables Gestion](#tables-gestion)
7. [Tables Support](#tables-support)

---

## Conventions PostgreSQL

### Conventions de Nommage

- **Tables** : snake_case (ex: users, property_photos)
- **Colonnes** : snake_case (ex: first_name, created_at)
- **Index** : idx_{table}_{column} (ex: idx_users_email)
- **Clés étrangères** : {table}_id (ex: user_id, property_id)
- **Timestamps** : created_at, updated_at (TIMESTAMP WITH TIME ZONE)

### Types de Données

| Type PostgreSQL | Django Field | Description |
|----------------|--------------|-------------|
| UUID | UUIDField | Identifiant unique |
| VARCHAR(n) | CharField/TextField | Chaîne de caractères |
| TEXT | TextField | Texte long |
| INTEGER | IntegerField | Entier |
| DECIMAL(m, n) | DecimalField | Nombre décimal |
| BOOLEAN | BooleanField | Booléen |
| DATE | DateField | Date |
| TIMESTAMP WITH TIME ZONE | DateTimeField | Date et heure |
| CHAR(n) | CharField | Chaîne fixe |
| JSONB | JSONField | JSON binaire |
| GEOGRAPHY(POINT, 4326) | PointField | Point géospatial |

### Conventions de Valeurs par Défaut

- `id` : uuid_generate_v4()
- `created_at` : CURRENT_TIMESTAMP
- `updated_at` : CURRENT_TIMESTAMP
- `status` : 'active'
- `is_active` : TRUE
- `is_verified` : FALSE
- `view_count` : 0
- `message_count` : 0

---

## Tables Utilisateurs

### users

| Nom | Type | Nullable | Valeur par défaut | Description |
|-----|------|----------|------------------|-------------|
| id | UUID | NO | uuid_generate_v4() | Identifiant unique |
| email | VARCHAR(255) | NO | - | Adresse email (unique) |
| phone | VARCHAR(20) | YES | - | Numéro de téléphone (unique) |
| first_name | VARCHAR(100) | NO | - | Prénom |
| last_name | VARCHAR(100) | NO | - | Nom de famille |
| photo_url | TEXT | YES | - | URL de la photo de profil |
| date_of_birth | DATE | NO | - | Date de naissance |
| gender | VARCHAR(20) | YES | - | Genre (masculine, feminine, other) |
| nationality | CHAR(2) | YES | - | Nationalité (code pays ISO) |
| preferred_language | CHAR(5) | YES | 'fr' | Langue préférée (code langue ISO) |
| role | VARCHAR(20) | NO | - | Rôle (client, landlord, admin) |
| status | VARCHAR(20) | NO | 'active' | Statut (active, inactive, suspended) |
| is_verified | BOOLEAN | YES | FALSE | Vérifié |
| is_active | BOOLEAN | YES | TRUE | Actif |
| created_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de mise à jour |
| last_login_at | TIMESTAMP WITH TIME ZONE | YES | - | Dernière connexion |

---

### profiles

| Nom | Type | Nullable | Valeur par défaut | Description |
|-----|------|----------|------------------|-------------|
| id | UUID | NO | uuid_generate_v4() | Identifiant unique |
| user_id | UUID | NO | - | Référence vers users (unique) |
| bio | TEXT | YES | - | Biographie |
| website | TEXT | YES | - | Site web |
| linkedin | TEXT | YES | - | LinkedIn |
| facebook | TEXT | YES | - | Facebook |
| twitter | TEXT | YES | - | Twitter |
| instagram | TEXT | YES | - | Instagram |
| preferences | JSONB | YES | - | Préférences |
| interests | TEXT | YES | - | Centres d'intérêt |
| is_public_profile | BOOLEAN | YES | FALSE | Profil public |
| status | VARCHAR(20) | NO | 'active' | Statut (active, inactive) |
| created_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de mise à jour |

---

### clients

| Nom | Type | Nullable | Valeur par défaut | Description |
|-----|------|----------|------------------|-------------|
| id | UUID | NO | uuid_generate_v4() | Identifiant unique |
| user_id | UUID | NO | - | Référence vers users (unique) |
| id_number | VARCHAR(50) | YES | - | Numéro d'identité |
| id_type | VARCHAR(20) | YES | - | Type d'identité (CNI, passport, license) |
| profession | VARCHAR(100) | YES | - | Profession |
| monthly_income | DECIMAL(15, 2) | YES | - | Revenu mensuel |
| employer | VARCHAR(100) | YES | - | Employeur |
| work_address | TEXT | YES | - | Adresse professionnelle |
| work_phone | VARCHAR(20) | YES | - | Téléphone professionnel |
| guarantor_name | VARCHAR(100) | YES | - | Nom du garant |
| guarantor_phone | VARCHAR(20) | YES | - | Téléphone du garant |
| guarantor_address | TEXT | YES | - | Adresse du garant |
| documents | JSONB | YES | - | Documents |
| verification_status | VARCHAR(20) | YES | 'pending' | Statut de vérification (pending, approved, rejected) |
| status | VARCHAR(20) | NO | 'active' | Statut (active, inactive) |
| created_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de mise à jour |

---

### landlords

| Nom | Type | Nullable | Valeur par défaut | Description |
|-----|------|----------|------------------|-------------|
| id | UUID | NO | uuid_generate_v4() | Identifiant unique |
| user_id | UUID | NO | - | Référence vers users (unique) |
| company_name | VARCHAR(255) | YES | - | Nom de l'entreprise |
| registration_number | VARCHAR(50) | YES | - | Numéro d'enregistrement |
| tax_id | VARCHAR(50) | YES | - | Numéro fiscal |
| headquarters_address | TEXT | YES | - | Adresse du siège |
| website | TEXT | YES | - | Site web |
| description | TEXT | YES | - | Description |
| business_phone | VARCHAR(20) | YES | - | Téléphone professionnel |
| business_email | VARCHAR(255) | YES | - | Email professionnel |
| properties | JSONB | YES | - | Liste des propriétés |
| legal_documents | JSONB | YES | - | Documents juridiques |
| is_professional | BOOLEAN | YES | FALSE | Professionnel |
| verification_status | VARCHAR(20) | YES | 'pending' | Statut de vérification (pending, approved, rejected) |
| status | VARCHAR(20) | NO | 'active' | Statut (active, inactive) |
| created_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de mise à jour |

---

### admins

| Nom | Type | Nullable | Valeur par défaut | Description |
|-----|------|----------|------------------|-------------|
| id | UUID | NO | uuid_generate_v4() | Identifiant unique |
| user_id | UUID | NO | - | Référence vers users (unique) |
| permissions | JSONB | NO | - | Permissions |
| mandat_expiry_date | TIMESTAMP WITH TIME ZONE | YES | - | Date d'expiration du mandat |
| superior_id | UUID | YES | - | Référence vers admins (hiérarchie) |
| is_super_admin | BOOLEAN | YES | FALSE | Super administrateur |
| department | VARCHAR(100) | NO | - | Département |
| position | VARCHAR(100) | YES | - | Poste |
| status | VARCHAR(20) | NO | 'active' | Statut (active, inactive) |
| created_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de mise à jour |

---

### user_settings

| Nom | Type | Nullable | Valeur par défaut | Description |
|-----|------|----------|------------------|-------------|
| id | UUID | NO | uuid_generate_v4() | Identifiant unique |
| user_id | UUID | NO | - | Référence vers users (unique) |
| language | CHAR(5) | YES | 'fr' | Langue (code langue ISO) |
| timezone | VARCHAR(50) | YES | 'Africa/Abidjan' | Fuseau horaire (IANA timezone) |
| email_notifications | BOOLEAN | YES | TRUE | Notifications email |
| push_notifications | BOOLEAN | YES | TRUE | Notifications push |
| sms_notifications | BOOLEAN | YES | FALSE | Notifications SMS |
| public_profile | BOOLEAN | YES | FALSE | Profil public |
| share_location | BOOLEAN | YES | FALSE | Partager la localisation |
| theme | VARCHAR(20) | YES | 'light' | Thème (light, dark) |
| newsletter_frequency | VARCHAR(20) | YES | 'immediate' | Fréquence newsletter (immediate, daily, weekly) |
| status | VARCHAR(20) | NO | 'active' | Statut (active, inactive) |
| created_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de mise à jour |

---

### user_sessions

| Nom | Type | Nullable | Valeur par défaut | Description |
|-----|------|----------|------------------|-------------|
| id | UUID | NO | uuid_generate_v4() | Identifiant unique |
| user_id | UUID | NO | - | Référence vers users |
| access_token | TEXT | NO | - | Token d'accès (JWT) |
| refresh_token | TEXT | NO | - | Token de rafraîchissement (JWT) |
| start_date | TIMESTAMP WITH TIME ZONE | NO | - | Date de début |
| end_date | TIMESTAMP WITH TIME ZONE | YES | - | Date de fin |
| device_id | VARCHAR(255) | YES | - | ID du device |
| ip_address | VARCHAR(45) | YES | - | Adresse IP |
| user_agent | TEXT | YES | - | User agent |
| location | VARCHAR(255) | YES | - | Localisation |
| is_active | BOOLEAN | YES | TRUE | Active |
| status | VARCHAR(20) | NO | 'active' | Statut (active, expired, revoked) |
| created_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de mise à jour |

---

## Tables Logements

### properties

| Nom | Type | Nullable | Valeur par défaut | Description |
|-----|------|----------|------------------|-------------|
| id | UUID | NO | uuid_generate_v4() | Identifiant unique |
| title | VARCHAR(255) | NO | - | Titre |
| description | TEXT | NO | - | Description |
| price | DECIMAL(15, 2) | NO | - | Prix |
| deposit | DECIMAL(15, 2) | YES | - | Caution |
| advance | DECIMAL(15, 2) | YES | - | Avance |
| currency | CHAR(3) | YES | 'XOF' | Devise (code devise ISO) |
| surface | DECIMAL(10, 2) | NO | - | Surface |
| bedrooms | INTEGER | NO | - | Nombre de chambres |
| living_rooms | INTEGER | NO | - | Nombre de salons |
| kitchens | INTEGER | NO | - | Nombre de cuisines |
| bathrooms | INTEGER | NO | - | Nombre de salles de bain |
| toilets | INTEGER | NO | - | Nombre de toilettes |
| has_parking | BOOLEAN | YES | FALSE | Parking |
| has_balcony | BOOLEAN | YES | FALSE | Balcon |
| has_terrace | BOOLEAN | YES | FALSE | Terrasse |
| has_internet | BOOLEAN | YES | FALSE | Internet |
| has_ac | BOOLEAN | YES | FALSE | Climatisation |
| has_generator | BOOLEAN | YES | FALSE | Générateur |
| has_well | BOOLEAN | YES | FALSE | Puits |
| pets_allowed | BOOLEAN | YES | FALSE | Animaux autorisés |
| location | GEOGRAPHY(POINT, 4326) | YES | - | Localisation (PostGIS Point) |
| address_id | UUID | YES | - | Référence vers addresses |
| landlord_id | UUID | NO | - | Référence vers landlords |
| landlord_name | VARCHAR(255) | NO | - | Nom du bailleur (dénormalisé) |
| landlord_phone | VARCHAR(20) | NO | - | Téléphone du bailleur (dénormalisé) |
| category_id | VARCHAR(50) | NO | - | Référence vers categories |
| category_name | VARCHAR(100) | NO | - | Nom de la catégorie (dénormalisé) |
| type_id | VARCHAR(50) | NO | - | Référence vers types |
| type_name | VARCHAR(100) | NO | - | Nom du type (dénormalisé) |
| equipment_ids | JSONB | YES | - | Liste des équipements |
| photo_urls | JSONB | YES | - | URLs des photos |
| video_urls | JSONB | YES | - | URLs des vidéos |
| view_count | INTEGER | YES | 0 | Nombre de vues |
| favorite_count | INTEGER | YES | 0 | Nombre de favoris |
| share_count | INTEGER | YES | 0 | Nombre de partages |
| distance | DECIMAL(10, 2) | YES | - | Distance |
| status | VARCHAR(20) | NO | 'draft' | Statut (draft, published, paused, archived) |
| published_at | TIMESTAMP WITH TIME ZONE | YES | - | Date de publication |
| expiry_date | TIMESTAMP WITH TIME ZONE | YES | - | Date d'expiration |
| created_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de mise à jour |

---

### property_photos

| Nom | Type | Nullable | Valeur par défaut | Description |
|-----|------|----------|------------------|-------------|
| id | UUID | NO | uuid_generate_v4() | Identifiant unique |
| property_id | UUID | NO | - | Référence vers properties |
| url | TEXT | NO | - | URL de la photo |
| thumbnail_url | TEXT | YES | - | URL de la miniature |
| description | VARCHAR(255) | YES | - | Description |
| order_num | INTEGER | YES | 0 | Ordre |
| is_primary | BOOLEAN | YES | FALSE | Photo principale |
| status | VARCHAR(20) | NO | 'active' | Statut (active, inactive) |
| created_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de mise à jour |

---

### property_videos

| Nom | Type | Nullable | Valeur par défaut | Description |
|-----|------|----------|------------------|-------------|
| id | UUID | NO | uuid_generate_v4() | Identifiant unique |
| property_id | UUID | NO | - | Référence vers properties |
| url | TEXT | NO | - | URL de la vidéo |
| thumbnail_url | TEXT | YES | - | URL de la miniature |
| description | VARCHAR(255) | YES | - | Description |
| duration | INTEGER | YES | 0 | Durée (secondes) |
| order_num | INTEGER | YES | 0 | Ordre |
| status | VARCHAR(20) | NO | 'active' | Statut (active, inactive) |
| created_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de mise à jour |

---

### categories

| Nom | Type | Nullable | Valeur par défaut | Description |
|-----|------|----------|------------------|-------------|
| id | VARCHAR(50) | NO | - | Identifiant unique (code court) |
| name | VARCHAR(100) | NO | - | Nom (unique) |
| description | TEXT | YES | - | Description |
| icon | VARCHAR(100) | YES | - | Icône |
| order_num | INTEGER | YES | 0 | Ordre |
| status | VARCHAR(20) | NO | 'active' | Statut (active, inactive) |
| created_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de mise à jour |

---

### types

| Nom | Type | Nullable | Valeur par défaut | Description |
|-----|------|----------|------------------|-------------|
| id | VARCHAR(50) | NO | - | Identifiant unique (code court) |
| name | VARCHAR(100) | NO | - | Nom (unique) |
| description | TEXT | YES | - | Description |
| icon | VARCHAR(100) | YES | - | Icône |
| order_num | INTEGER | YES | 0 | Ordre |
| status | VARCHAR(20) | NO | 'active' | Statut (active, inactive) |
| created_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de mise à jour |

---

### equipment

| Nom | Type | Nullable | Valeur par défaut | Description |
|-----|------|----------|------------------|-------------|
| id | VARCHAR(50) | NO | - | Identifiant unique (code court) |
| name | VARCHAR(100) | NO | - | Nom (unique) |
| description | TEXT | YES | - | Description |
| icon | VARCHAR(100) | YES | - | Icône |
| category | VARCHAR(50) | YES | - | Catégorie |
| order_num | INTEGER | YES | 0 | Ordre |
| status | VARCHAR(20) | NO | 'active' | Statut (active, inactive) |
| created_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de mise à jour |

---

### favorites

| Nom | Type | Nullable | Valeur par défaut | Description |
|-----|------|----------|------------------|-------------|
| id | UUID | NO | uuid_generate_v4() | Identifiant unique |
| user_id | UUID | NO | - | Référence vers users |
| property_id | UUID | NO | - | Référence vers properties |
| property_title | VARCHAR(255) | NO | - | Titre du logement (dénormalisé) |
| property_price | DECIMAL(15, 2) | NO | - | Prix du logement (dénormalisé) |
| property_location | GEOGRAPHY(POINT, 4326) | YES | - | Localisation du logement (dénormalisé) |
| notes | TEXT | YES | - | Notes |
| status | VARCHAR(20) | NO | 'active' | Statut (active, inactive) |
| created_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de mise à jour |

---

### reviews

| Nom | Type | Nullable | Valeur par défaut | Description |
|-----|------|----------|------------------|-------------|
| id | UUID | NO | uuid_generate_v4() | Identifiant unique |
| user_id | UUID | NO | - | Référence vers users |
| user_name | VARCHAR(255) | NO | - | Nom de l'utilisateur (dénormalisé) |
| property_id | UUID | NO | - | Référence vers properties |
| property_title | VARCHAR(255) | NO | - | Titre du logement (dénormalisé) |
| rating | INTEGER | NO | - | Note (1-5) |
| comment | TEXT | YES | - | Commentaire |
| landlord_response | TEXT | YES | - | Réponse du bailleur |
| response_date | TIMESTAMP WITH TIME ZONE | YES | - | Date de réponse |
| is_verified | BOOLEAN | YES | FALSE | Vérifié |
| status | VARCHAR(20) | NO | 'active' | Statut (active, inactive) |
| created_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de mise à jour |

---

## Tables Localisation

### cities

| Nom | Type | Nullable | Valeur par défaut | Description |
|-----|------|----------|------------------|-------------|
| id | VARCHAR(50) | NO | - | Identifiant unique (code court) |
| name | VARCHAR(100) | NO | - | Nom |
| code | VARCHAR(20) | YES | - | Code |
| country | CHAR(2) | NO | - | Pays (code pays ISO) |
| region | VARCHAR(100) | YES | - | Région |
| province | VARCHAR(100) | YES | - | Province |
| location | GEOGRAPHY(POINT, 4326) | YES | - | Localisation (PostGIS Point) |
| population | INTEGER | YES | 0 | Population |
| status | VARCHAR(20) | NO | 'active' | Statut (active, inactive) |
| created_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de mise à jour |

---

### districts

| Nom | Type | Nullable | Valeur par défaut | Description |
|-----|------|----------|------------------|-------------|
| id | VARCHAR(50) | NO | - | Identifiant unique (code court) |
| name | VARCHAR(100) | NO | - | Nom |
| city_id | VARCHAR(50) | NO | - | Référence vers cities |
| city_name | VARCHAR(100) | NO | - | Nom de la ville (dénormalisé) |
| code | VARCHAR(20) | YES | - | Code |
| description | TEXT | YES | - | Description |
| location | GEOGRAPHY(POINT, 4326) | YES | - | Localisation (PostGIS Point) |
| population | INTEGER | YES | 0 | Population |
| status | VARCHAR(20) | NO | 'active' | Statut (active, inactive) |
| created_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de mise à jour |

---

### addresses

| Nom | Type | Nullable | Valeur par défaut | Description |
|-----|------|----------|------------------|-------------|
| id | UUID | NO | uuid_generate_v4() | Identifiant unique |
| street | VARCHAR(255) | NO | - | Rue |
| number | VARCHAR(20) | YES | - | Numéro |
| complement | VARCHAR(255) | YES | - | Complément |
| postal_code | VARCHAR(20) | NO | - | Code postal |
| city_id | VARCHAR(50) | NO | - | Référence vers cities |
| city_name | VARCHAR(100) | NO | - | Nom de la ville (dénormalisé) |
| district_id | VARCHAR(50) | YES | - | Référence vers districts |
| district_name | VARCHAR(100) | YES | - | Nom du quartier (dénormalisé) |
| location | GEOGRAPHY(POINT, 4326) | NO | - | Localisation (PostGIS Point) |
| status | VARCHAR(20) | NO | 'active' | Statut (active, inactive) |
| created_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de mise à jour |

---

## Tables Communication

### conversations

| Nom | Type | Nullable | Valeur par défaut | Description |
|-----|------|----------|------------------|-------------|
| id | UUID | NO | uuid_generate_v4() | Identifiant unique |
| participant1_id | UUID | NO | - | Référence vers users (participant 1) |
| participant1_name | VARCHAR(255) | NO | - | Nom du participant 1 (dénormalisé) |
| participant2_id | UUID | NO | - | Référence vers users (participant 2) |
| participant2_name | VARCHAR(255) | NO | - | Nom du participant 2 (dénormalisé) |
| property_id | UUID | YES | - | Référence vers properties |
| property_title | VARCHAR(255) | YES | - | Titre du logement (dénormalisé) |
| last_message | TEXT | YES | - | Dernier message |
| last_message_at | TIMESTAMP WITH TIME ZONE | YES | - | Date du dernier message |
| message_count | INTEGER | YES | 0 | Nombre de messages |
| unread_count | INTEGER | YES | 0 | Nombre de messages non lus |
| status | VARCHAR(20) | NO | 'active' | Statut (active, inactive, archived) |
| created_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de mise à jour |

---

### messages

| Nom | Type | Nullable | Valeur par défaut | Description |
|-----|------|----------|------------------|-------------|
| id | UUID | NO | uuid_generate_v4() | Identifiant unique |
| conversation_id | UUID | NO | - | Référence vers conversations |
| sender_id | UUID | NO | - | Référence vers users (expéditeur) |
| sender_name | VARCHAR(255) | NO | - | Nom de l'expéditeur (dénormalisé) |
| recipient_id | UUID | NO | - | Référence vers users (destinataire) |
| content | TEXT | NO | - | Contenu |
| attachment_url | TEXT | YES | - | URL de la pièce jointe |
| type | VARCHAR(20) | NO | 'text' | Type (text, image, document) |
| is_read | BOOLEAN | YES | FALSE | Lu |
| read_at | TIMESTAMP WITH TIME ZONE | YES | - | Date de lecture |
| status | VARCHAR(20) | NO | 'active' | Statut (active, deleted) |
| created_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de mise à jour |

---

### notifications

| Nom | Type | Nullable | Valeur par défaut | Description |
|-----|------|----------|------------------|-------------|
| id | UUID | NO | uuid_generate_v4() | Identifiant unique |
| user_id | UUID | NO | - | Référence vers users |
| title | VARCHAR(255) | NO | - | Titre |
| message | TEXT | NO | - | Message |
| link | TEXT | YES | - | Lien |
| type | VARCHAR(50) | NO | - | Type |
| is_read | BOOLEAN | YES | FALSE | Lu |
| read_at | TIMESTAMP WITH TIME ZONE | YES | - | Date de lecture |
| status | VARCHAR(20) | NO | 'active' | Statut (active, archived) |
| created_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de mise à jour |

---

### chatbot_conversations

| Nom | Type | Nullable | Valeur par défaut | Description |
|-----|------|----------|------------------|-------------|
| id | UUID | NO | uuid_generate_v4() | Identifiant unique |
| user_id | UUID | NO | - | Référence vers users |
| title | VARCHAR(255) | YES | - | Titre |
| context | TEXT | YES | - | Contexte |
| last_interaction_at | TIMESTAMP WITH TIME ZONE | YES | - | Dernière interaction |
| message_count | INTEGER | YES | 0 | Nombre de messages |
| status | VARCHAR(20) | NO | 'active' | Statut (active, inactive, archived) |
| created_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de mise à jour |

---

### chatbot_messages

| Nom | Type | Nullable | Valeur par défaut | Description |
|-----|------|----------|------------------|-------------|
| id | UUID | NO | uuid_generate_v4() | Identifiant unique |
| conversation_id | UUID | NO | - | Référence vers chatbot_conversations |
| content | TEXT | NO | - | Contenu |
| role | VARCHAR(20) | NO | - | Rôle (user, assistant) |
| context | TEXT | YES | - | Contexte |
| data | JSONB | YES | - | Données |
| status | VARCHAR(20) | NO | 'active' | Statut (active, inactive) |
| created_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de mise à jour |

---

## Tables Gestion

### visits

| Nom | Type | Nullable | Valeur par défaut | Description |
|-----|------|----------|------------------|-------------|
| id | UUID | NO | uuid_generate_v4() | Identifiant unique |
| property_id | UUID | NO | - | Référence vers properties |
| property_title | VARCHAR(255) | NO | - | Titre du logement (dénormalisé) |
| client_id | UUID | NO | - | Référence vers clients |
| client_name | VARCHAR(255) | NO | - | Nom du client (dénormalisé) |
| landlord_id | UUID | NO | - | Référence vers landlords |
| landlord_name | VARCHAR(255) | NO | - | Nom du bailleur (dénormalisé) |
| visit_date | DATE | NO | - | Date de visite |
| start_time | TIME | YES | - | Heure de début |
| end_time | TIME | YES | - | Heure de fin |
| status | VARCHAR(20) | NO | 'pending' | Statut (pending, confirmed, cancelled, completed) |
| notes | TEXT | YES | - | Notes |
| feedback | TEXT | YES | - | Feedback |
| created_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de mise à jour |

---

### visit_schedules

| Nom | Type | Nullable | Valeur par défaut | Description |
|-----|------|----------|------------------|-------------|
| id | UUID | NO | uuid_generate_v4() | Identifiant unique |
| landlord_id | UUID | NO | - | Référence vers landlords |
| property_id | UUID | NO | - | Référence vers properties |
| slots | JSONB | NO | - | Créneaux |
| instructions | TEXT | YES | - | Instructions |
| visit_duration | INTEGER | YES | 30 | Durée de la visite (minutes) |
| booking_lead_time | INTEGER | YES | 24 | Délai de réservation (heures) |
| status | VARCHAR(20) | NO | 'active' | Statut (active, inactive) |
| created_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de mise à jour |

---

### reports

| Nom | Type | Nullable | Valeur par défaut | Description |
|-----|------|----------|------------------|-------------|
| id | UUID | NO | uuid_generate_v4() | Identifiant unique |
| author_id | UUID | NO | - | Référence vers users |
| entity_id | UUID | NO | - | ID de l'entité |
| entity_type | VARCHAR(50) | NO | - | Type de l'entité |
| reason | VARCHAR(255) | NO | - | Raison |
| description | TEXT | YES | - | Description |
| status | VARCHAR(20) | NO | 'pending' | Statut (pending, in_progress, resolved, rejected) |
| admin_response | TEXT | YES | - | Réponse de l'admin |
| processed_at | TIMESTAMP WITH TIME ZONE | YES | - | Date de traitement |
| processed_by | UUID | YES | - | Référence vers admins |
| created_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de mise à jour |

---

### verification_documents

| Nom | Type | Nullable | Valeur par défaut | Description |
|-----|------|----------|------------------|-------------|
| id | UUID | NO | uuid_generate_v4() | Identifiant unique |
| user_id | UUID | NO | - | Référence vers users |
| document_type | VARCHAR(50) | NO | - | Type de document |
| document_number | VARCHAR(100) | NO | - | Numéro de document |
| document_url | TEXT | YES | - | URL du document |
| front_url | TEXT | YES | - | URL du recto |
| back_url | TEXT | YES | - | URL du verso |
| expiry_date | DATE | NO | - | Date d'expiration |
| verification_status | VARCHAR(20) | YES | 'pending' | Statut de vérification (pending, approved, rejected) |
| comment | TEXT | YES | - | Commentaire |
| verified_at | TIMESTAMP WITH TIME ZONE | YES | - | Date de vérification |
| verified_by | UUID | YES | - | Référence vers admins |
| status | VARCHAR(20) | NO | 'active' | Statut (active, inactive, expired) |
| created_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de mise à jour |

---

### searches

| Nom | Type | Nullable | Valeur par défaut | Description |
|-----|------|----------|------------------|-------------|
| id | UUID | NO | uuid_generate_v4() | Identifiant unique |
| user_id | UUID | NO | - | Référence vers users |
| query | TEXT | YES | - | Requête |
| category_id | VARCHAR(50) | YES | - | Référence vers categories |
| type_id | VARCHAR(50) | YES | - | Référence vers types |
| min_price | DECIMAL(15, 2) | YES | - | Prix minimum |
| max_price | DECIMAL(15, 2) | YES | - | Prix maximum |
| min_surface | DECIMAL(10, 2) | YES | - | Surface minimum |
| max_surface | DECIMAL(10, 2) | YES | - | Surface maximum |
| min_bedrooms | INTEGER | YES | - | Chambres minimum |
| max_bedrooms | INTEGER | YES | - | Chambres maximum |
| city_id | VARCHAR(50) | YES | - | Référence vers cities |
| district_id | VARCHAR(50) | YES | - | Référence vers districts |
| location | GEOGRAPHY(POINT, 4326) | YES | - | Localisation (PostGIS Point) |
| radius | DECIMAL(10, 2) | YES | - | Rayon |
| equipment_ids | JSONB | YES | - | Liste des équipements |
| result_count | INTEGER | YES | 0 | Nombre de résultats |
| status | VARCHAR(20) | NO | 'active' | Statut (active, inactive) |
| created_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de mise à jour |

---

### saved_searches

| Nom | Type | Nullable | Valeur par défaut | Description |
|-----|------|----------|------------------|-------------|
| id | UUID | NO | uuid_generate_v4() | Identifiant unique |
| user_id | UUID | NO | - | Référence vers users |
| name | VARCHAR(255) | NO | - | Nom |
| query | TEXT | YES | - | Requête |
| category_id | VARCHAR(50) | YES | - | Référence vers categories |
| type_id | VARCHAR(50) | YES | - | Référence vers types |
| min_price | DECIMAL(15, 2) | YES | - | Prix minimum |
| max_price | DECIMAL(15, 2) | YES | - | Prix maximum |
| min_surface | DECIMAL(10, 2) | YES | - | Surface minimum |
| max_surface | DECIMAL(10, 2) | YES | - | Surface maximum |
| min_bedrooms | INTEGER | YES | - | Chambres minimum |
| max_bedrooms | INTEGER | YES | - | Chambres maximum |
| city_id | VARCHAR(50) | YES | - | Référence vers cities |
| district_id | VARCHAR(50) | YES | - | Référence vers districts |
| location | GEOGRAPHY(POINT, 4326) | YES | - | Localisation (PostGIS Point) |
| radius | DECIMAL(10, 2) | YES | - | Rayon |
| equipment_ids | JSONB | YES | - | Liste des équipements |
| alert_enabled | BOOLEAN | YES | FALSE | Alertes activées |
| alert_frequency | VARCHAR(20) | YES | 'immediate' | Fréquence des alertes (immediate, daily, weekly) |
| status | VARCHAR(20) | NO | 'active' | Statut (active, inactive) |
| created_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de mise à jour |

---

## Tables Support

### audit_logs

| Nom | Type | Nullable | Valeur par défaut | Description |
|-----|------|----------|------------------|-------------|
| id | UUID | NO | uuid_generate_v4() | Identifiant unique |
| user_id | UUID | YES | - | Référence vers users |
| action_type | VARCHAR(50) | NO | - | Type d'action |
| description | TEXT | YES | - | Description |
| entity_id | UUID | YES | - | ID de l'entité |
| entity_type | VARCHAR(50) | YES | - | Type de l'entité |
| data | JSONB | YES | - | Données |
| ip_address | VARCHAR(45) | YES | - | Adresse IP |
| user_agent | TEXT | YES | - | User agent |
| status | VARCHAR(20) | NO | 'active' | Statut (active, inactive) |
| created_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP WITH TIME ZONE | NO | CURRENT_TIMESTAMP | Date de mise à jour |

---

## Extensions PostgreSQL Requises

### uuid-ossp

```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

Génération d'UUID pour les clés primaires.

### postgis

```sql
CREATE EXTENSION IF NOT EXISTS postgis;
```

Support des données géospatiales (GEOGRAPHY).

### pg_trgm

```sql
CREATE EXTENSION IF NOT EXISTS pg_trgm;
```

Support de la recherche textuelle avec trigrammes.

---

## Fonctions PostgreSQL

### Fonction update_updated_at_column

Cette fonction met à jour automatiquement le champ `updated_at` avant chaque modification.

```sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';
```

---

## Mapping Django ORM

### Correspondance Types PostgreSQL ↔ Django

| PostgreSQL | Django Field | Exemple |
|------------|-------------|---------|
| UUID | UUIDField | id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False) |
| VARCHAR(255) | CharField | models.CharField(max_length=255) |
| TEXT | TextField | models.TextField() |
| INTEGER | IntegerField | models.IntegerField() |
| DECIMAL(15, 2) | DecimalField | models.DecimalField(max_digits=15, decimal_places=2) |
| BOOLEAN | BooleanField | models.BooleanField(default=False) |
| DATE | DateField | models.DateField() |
| TIMESTAMP WITH TIME ZONE | DateTimeField | models.DateTimeField(auto_now_add=True) |
| CHAR(2) | CharField | models.CharField(max_length=2) |
| CHAR(3) | CharField | models.CharField(max_length=3) |
| CHAR(5) | CharField | models.CharField(max_length=5) |
| JSONB | JSONField | models.JSONField() |
| GEOGRAPHY(POINT, 4326) | PointField | models.PointField(srid=4326) |

### Correspondance Contraintes PostgreSQL ↔ Django

| PostgreSQL | Django | Exemple |
|------------|--------|---------|
| PRIMARY KEY | primary_key=True | models.UUIDField(primary_key=True) |
| UNIQUE | unique=True | models.CharField(unique=True) |
| NOT NULL | blank=False, null=False | models.CharField(blank=False, null=False) |
| FOREIGN KEY | ForeignKey | models.ForeignKey('User', on_delete=models.CASCADE) |
| CHECK | validators | models.IntegerField(validators=[MinValueValidator(0)]) |
| DEFAULT | default= | models.IntegerField(default=0) |

---

## Notes de Conception

### Dénormalisation

Certains champs sont dénormalisés pour optimiser les performances :
- `landlord_name`, `landlord_phone` dans properties
- `category_name`, `type_name` dans properties
- `user_name` dans reviews, messages
- `property_title`, `property_price` dans favorites

Ces champs doivent être synchronisés via des triggers ou des signaux Django.

### Données Géospatiales

Les champs de localisation utilisent le type GEOGRAPHY(POINT, 4326) avec SRID 4326 (WGS84) pour la compatibilité avec les standards GPS.

### Données JSONB

Les champs JSONB sont utilisés pour :
- `preferences` : Préférences utilisateur flexibles
- `equipment_ids` : Liste des équipements d'un logement
- `photo_urls`, `video_urls` : Listes d'URLs
- `slots` : Créneaux de visite
- `documents` : Documents utilisateur

Ces champs permettent une flexibilité tout en maintenant la possibilité d'indexer et de requêter.

### Timestamps

Toutes les tables utilisent `TIMESTAMP WITH TIME ZONE` pour les champs de date/heure afin de gérer correctement les fuseaux horaires.

### UUID vs Serial

Les clés primaires utilisent UUID plutôt que SERIAL pour :
- Éviter les collisions dans les systèmes distribués
- Permettre la génération d'IDs côté client
- Améliorer la sécurité (IDs non prévisibles)
