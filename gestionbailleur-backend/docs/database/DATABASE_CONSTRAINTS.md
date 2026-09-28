# Database Constraints - GestionBailleur PostgreSQL

## Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Contraintes de Clé Primaire](#contraintes-de-clé-primaire)
3. [Contraintes de Clé Étrangère](#contraintes-de-clé-étrangère)
4. [Contraintes d'Unicité](#contraintes-dunicité)
5. [Contraintes CHECK](#contraintes-check)
6. [Contraintes NOT NULL](#contraintes-not-null)
7. [Contraintes DEFAULT](#contraintes-default)
8. [Actions ON DELETE](#actions-on-delete)
9. [Validation des Données](#validation-des-données)
10. [Mapping Django ORM](#mapping-django-orm)

---

## Vue d'ensemble

Les contraintes garantissent l'intégrité, la cohérence et la validité des données dans PostgreSQL. Ce document définit toutes les contraintes de la base de données GestionBailleur.

### Types de Contraintes

- **PRIMARY KEY** : Identifiant unique de chaque ligne
- **FOREIGN KEY** : Relation avec une autre table
- **UNIQUE** : Valeur unique dans une colonne
- **CHECK** : Validation des valeurs autorisées
- **NOT NULL** : Valeur obligatoire
- **DEFAULT** : Valeur par défaut

---

## Contraintes de Clé Primaire

### Convention

Toutes les tables utilisent une clé primaire `id` de type UUID pour garantir l'unicité et éviter les collisions dans les systèmes distribués.

### Tables avec UUID comme Clé Primaire

```sql
-- Utilisateurs
ALTER TABLE users ADD CONSTRAINT users_pkey PRIMARY KEY (id);
ALTER TABLE profiles ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);
ALTER TABLE clients ADD CONSTRAINT clients_pkey PRIMARY KEY (id);
ALTER TABLE landlords ADD CONSTRAINT landlords_pkey PRIMARY KEY (id);
ALTER TABLE admins ADD CONSTRAINT admins_pkey PRIMARY KEY (id);
ALTER TABLE user_settings ADD CONSTRAINT user_settings_pkey PRIMARY KEY (id);
ALTER TABLE user_sessions ADD CONSTRAINT user_sessions_pkey PRIMARY KEY (id);

-- Logements
ALTER TABLE properties ADD CONSTRAINT properties_pkey PRIMARY KEY (id);
ALTER TABLE property_photos ADD CONSTRAINT property_photos_pkey PRIMARY KEY (id);
ALTER TABLE property_videos ADD CONSTRAINT property_videos_pkey PRIMARY KEY (id);

-- Communication
ALTER TABLE conversations ADD CONSTRAINT conversations_pkey PRIMARY KEY (id);
ALTER TABLE messages ADD CONSTRAINT messages_pkey PRIMARY KEY (id);
ALTER TABLE notifications ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);
ALTER TABLE chatbot_conversations ADD CONSTRAINT chatbot_conversations_pkey PRIMARY KEY (id);
ALTER TABLE chatbot_messages ADD CONSTRAINT chatbot_messages_pkey PRIMARY KEY (id);

-- Gestion
ALTER TABLE visits ADD CONSTRAINT visits_pkey PRIMARY KEY (id);
ALTER TABLE visit_schedules ADD CONSTRAINT visit_schedules_pkey PRIMARY KEY (id);
ALTER TABLE reports ADD CONSTRAINT reports_pkey PRIMARY KEY (id);
ALTER TABLE verification_documents ADD CONSTRAINT verification_documents_pkey PRIMARY KEY (id);
ALTER TABLE searches ADD CONSTRAINT searches_pkey PRIMARY KEY (id);
ALTER TABLE saved_searches ADD CONSTRAINT saved_searches_pkey PRIMARY KEY (id);

-- Support
ALTER TABLE favorites ADD CONSTRAINT favorites_pkey PRIMARY KEY (id);
ALTER TABLE reviews ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);
ALTER TABLE addresses ADD CONSTRAINT addresses_pkey PRIMARY KEY (id);
ALTER TABLE audit_logs ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);
```

### Tables avec Code Court comme Clé Primaire

Les tables de référence utilisent des codes courts comme clés primaires pour une meilleure lisibilité.

```sql
-- Référence
ALTER TABLE categories ADD CONSTRAINT categories_pkey PRIMARY KEY (id);
ALTER TABLE types ADD CONSTRAINT types_pkey PRIMARY KEY (id);
ALTER TABLE equipment ADD CONSTRAINT equipment_pkey PRIMARY KEY (id);
ALTER TABLE cities ADD CONSTRAINT cities_pkey PRIMARY KEY (id);
ALTER TABLE districts ADD CONSTRAINT districts_pkey PRIMARY KEY (id);
```

---

## Contraintes de Clé Étrangère

### Relations Utilisateurs

```sql
-- Profile vers User
ALTER TABLE profiles 
ADD CONSTRAINT profiles_user_id_fkey 
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- Client vers User
ALTER TABLE clients 
ADD CONSTRAINT clients_user_id_fkey 
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- Landlord vers User
ALTER TABLE landlords 
ADD CONSTRAINT landlords_user_id_fkey 
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- Admin vers User
ALTER TABLE admins 
ADD CONSTRAINT admins_user_id_fkey 
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- Admin hiérarchie
ALTER TABLE admins 
ADD CONSTRAINT admins_superior_id_fkey 
FOREIGN KEY (superior_id) REFERENCES admins(id) ON DELETE SET NULL;

-- User Settings vers User
ALTER TABLE user_settings 
ADD CONSTRAINT user_settings_user_id_fkey 
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- User Sessions vers User
ALTER TABLE user_sessions 
ADD CONSTRAINT user_sessions_user_id_fkey 
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
```

### Relations Logements

```sql
-- Property vers Landlord
ALTER TABLE properties 
ADD CONSTRAINT properties_landlord_id_fkey 
FOREIGN KEY (landlord_id) REFERENCES landlords(id) ON DELETE RESTRICT;

-- Property vers Address
ALTER TABLE properties 
ADD CONSTRAINT properties_address_id_fkey 
FOREIGN KEY (address_id) REFERENCES addresses(id) ON DELETE RESTRICT;

-- Property vers Category
ALTER TABLE properties 
ADD CONSTRAINT properties_category_id_fkey 
FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT;

-- Property vers Type
ALTER TABLE properties 
ADD CONSTRAINT properties_type_id_fkey 
FOREIGN KEY (type_id) REFERENCES types(id) ON DELETE RESTRICT;

-- Property Photos vers Property
ALTER TABLE property_photos 
ADD CONSTRAINT property_photos_property_id_fkey 
FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE;

-- Property Videos vers Property
ALTER TABLE property_videos 
ADD CONSTRAINT property_videos_property_id_fkey 
FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE;
```

### Relations Localisation

```sql
-- District vers City
ALTER TABLE districts 
ADD CONSTRAINT districts_city_id_fkey 
FOREIGN KEY (city_id) REFERENCES cities(id) ON DELETE CASCADE;

-- Address vers City
ALTER TABLE addresses 
ADD CONSTRAINT addresses_city_id_fkey 
FOREIGN KEY (city_id) REFERENCES cities(id) ON DELETE RESTRICT;

-- Address vers District
ALTER TABLE addresses 
ADD CONSTRAINT addresses_district_id_fkey 
FOREIGN KEY (district_id) REFERENCES districts(id) ON DELETE SET NULL;
```

### Relations Communication

```sql
-- Conversation vers User (participant1)
ALTER TABLE conversations 
ADD CONSTRAINT conversations_participant1_id_fkey 
FOREIGN KEY (participant1_id) REFERENCES users(id) ON DELETE CASCADE;

-- Conversation vers User (participant2)
ALTER TABLE conversations 
ADD CONSTRAINT conversations_participant2_id_fkey 
FOREIGN KEY (participant2_id) REFERENCES users(id) ON DELETE CASCADE;

-- Conversation vers Property
ALTER TABLE conversations 
ADD CONSTRAINT conversations_property_id_fkey 
FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE SET NULL;

-- Message vers Conversation
ALTER TABLE messages 
ADD CONSTRAINT messages_conversation_id_fkey 
FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE;

-- Message vers User (sender)
ALTER TABLE messages 
ADD CONSTRAINT messages_sender_id_fkey 
FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE;

-- Message vers User (recipient)
ALTER TABLE messages 
ADD CONSTRAINT messages_recipient_id_fkey 
FOREIGN KEY (recipient_id) REFERENCES users(id) ON DELETE CASCADE;

-- Notification vers User
ALTER TABLE notifications 
ADD CONSTRAINT notifications_user_id_fkey 
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- Chatbot Conversation vers User
ALTER TABLE chatbot_conversations 
ADD CONSTRAINT chatbot_conversations_user_id_fkey 
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- Chatbot Message vers Chatbot Conversation
ALTER TABLE chatbot_messages 
ADD CONSTRAINT chatbot_messages_conversation_id_fkey 
FOREIGN KEY (conversation_id) REFERENCES chatbot_conversations(id) ON DELETE CASCADE;
```

### Relations Gestion

```sql
-- Visit vers Property
ALTER TABLE visits 
ADD CONSTRAINT visits_property_id_fkey 
FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE;

-- Visit vers Client
ALTER TABLE visits 
ADD CONSTRAINT visits_client_id_fkey 
FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE;

-- Visit vers Landlord
ALTER TABLE visits 
ADD CONSTRAINT visits_landlord_id_fkey 
FOREIGN KEY (landlord_id) REFERENCES landlords(id) ON DELETE CASCADE;

-- Visit Schedule vers Landlord
ALTER TABLE visit_schedules 
ADD CONSTRAINT visit_schedules_landlord_id_fkey 
FOREIGN KEY (landlord_id) REFERENCES landlords(id) ON DELETE CASCADE;

-- Visit Schedule vers Property
ALTER TABLE visit_schedules 
ADD CONSTRAINT visit_schedules_property_id_fkey 
FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE;

-- Report vers User (author)
ALTER TABLE reports 
ADD CONSTRAINT reports_author_id_fkey 
FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE;

-- Report vers Admin (processed_by)
ALTER TABLE reports 
ADD CONSTRAINT reports_processed_by_fkey 
FOREIGN KEY (processed_by) REFERENCES admins(id) ON DELETE SET NULL;

-- Verification Document vers User
ALTER TABLE verification_documents 
ADD CONSTRAINT verification_documents_user_id_fkey 
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- Verification Document vers Admin (verified_by)
ALTER TABLE verification_documents 
ADD CONSTRAINT verification_documents_verified_by_fkey 
FOREIGN KEY (verified_by) REFERENCES admins(id) ON DELETE SET NULL;
```

### Relations Support

```sql
-- Favorite vers User
ALTER TABLE favorites 
ADD CONSTRAINT favorites_user_id_fkey 
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- Favorite vers Property
ALTER TABLE favorites 
ADD CONSTRAINT favorites_property_id_fkey 
FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE;

-- Review vers User
ALTER TABLE reviews 
ADD CONSTRAINT reviews_user_id_fkey 
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- Review vers Property
ALTER TABLE reviews 
ADD CONSTRAINT reviews_property_id_fkey 
FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE;

-- Search vers User
ALTER TABLE searches 
ADD CONSTRAINT searches_user_id_fkey 
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- Search vers Category
ALTER TABLE searches 
ADD CONSTRAINT searches_category_id_fkey 
FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL;

-- Search vers Type
ALTER TABLE searches 
ADD CONSTRAINT searches_type_id_fkey 
FOREIGN KEY (type_id) REFERENCES types(id) ON DELETE SET NULL;

-- Search vers City
ALTER TABLE searches 
ADD CONSTRAINT searches_city_id_fkey 
FOREIGN KEY (city_id) REFERENCES cities(id) ON DELETE SET NULL;

-- Search vers District
ALTER TABLE searches 
ADD CONSTRAINT searches_district_id_fkey 
FOREIGN KEY (district_id) REFERENCES districts(id) ON DELETE SET NULL;

-- Saved Search vers User
ALTER TABLE saved_searches 
ADD CONSTRAINT saved_searches_user_id_fkey 
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- Saved Search vers Category
ALTER TABLE saved_searches 
ADD CONSTRAINT saved_searches_category_id_fkey 
FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL;

-- Saved Search vers Type
ALTER TABLE saved_searches 
ADD CONSTRAINT saved_searches_type_id_fkey 
FOREIGN KEY (type_id) REFERENCES types(id) ON DELETE SET NULL;

-- Saved Search vers City
ALTER TABLE saved_searches 
ADD CONSTRAINT saved_searches_city_id_fkey 
FOREIGN KEY (city_id) REFERENCES cities(id) ON DELETE SET NULL;

-- Saved Search vers District
ALTER TABLE saved_searches 
ADD CONSTRAINT saved_searches_district_id_fkey 
FOREIGN KEY (district_id) REFERENCES districts(id) ON DELETE SET NULL;

-- Audit Log vers User
ALTER TABLE audit_logs 
ADD CONSTRAINT audit_logs_user_id_fkey 
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL;
```

---

## Contraintes d'Unicité

### Contraintes d'Unicité Simples

```sql
-- Email utilisateur unique
ALTER TABLE users 
ADD CONSTRAINT users_email_key UNIQUE (email);

-- Téléphone utilisateur unique
ALTER TABLE users 
ADD CONSTRAINT users_phone_key UNIQUE (phone);

-- Nom de catégorie unique
ALTER TABLE categories 
ADD CONSTRAINT categories_name_key UNIQUE (name);

-- Nom de type unique
ALTER TABLE types 
ADD CONSTRAINT types_name_key UNIQUE (name);

-- Nom d'équipement unique
ALTER TABLE equipment 
ADD CONSTRAINT equipment_name_key UNIQUE (name);
```

### Contraintes d'Unicité Composites

```sql
-- Nom de ville unique par pays
ALTER TABLE cities 
ADD CONSTRAINT cities_name_country_key UNIQUE (name, country);

-- Nom de quartier unique par ville
ALTER TABLE districts 
ADD CONSTRAINT districts_city_name_key UNIQUE (city_id, name);

-- Favori unique par utilisateur et logement
ALTER TABLE favorites 
ADD CONSTRAINT favorites_user_property_key UNIQUE (user_id, property_id);

-- Avis unique par utilisateur et logement
ALTER TABLE reviews 
ADD CONSTRAINT reviews_user_property_key UNIQUE (user_id, property_id);

-- Profil unique par utilisateur
ALTER TABLE profiles 
ADD CONSTRAINT profiles_user_id_key UNIQUE (user_id);

-- Client unique par utilisateur
ALTER TABLE clients 
ADD CONSTRAINT clients_user_id_key UNIQUE (user_id);

-- Landlord unique par utilisateur
ALTER TABLE landlords 
ADD CONSTRAINT landlords_user_id_key UNIQUE (user_id);

-- Admin unique par utilisateur
ALTER TABLE admins 
ADD CONSTRAINT admins_user_id_key UNIQUE (user_id);

-- Paramètres utilisateur uniques
ALTER TABLE user_settings 
ADD CONSTRAINT user_settings_user_id_key UNIQUE (user_id);
```

---

## Contraintes CHECK

### Contraintes CHECK sur les Énumérations

```sql
-- Rôle utilisateur
ALTER TABLE users 
ADD CONSTRAINT users_role_check 
CHECK (role IN ('client', 'landlord', 'admin'));

-- Statut utilisateur
ALTER TABLE users 
ADD CONSTRAINT users_status_check 
CHECK (status IN ('active', 'inactive', 'suspended'));

-- Genre utilisateur
ALTER TABLE users 
ADD CONSTRAINT users_gender_check 
CHECK (gender IN ('masculine', 'feminine', 'other'));

-- Type d'identité
ALTER TABLE clients 
ADD CONSTRAINT clients_id_type_check 
CHECK (id_type IN ('CNI', 'passport', 'license'));

-- Statut de vérification
ALTER TABLE clients 
ADD CONSTRAINT clients_verification_status_check 
CHECK (verification_status IN ('pending', 'approved', 'rejected'));

-- Statut bailleur
ALTER TABLE landlords 
ADD CONSTRAINT landlords_verification_status_check 
CHECK (verification_status IN ('pending', 'approved', 'rejected'));

-- Statut admin
ALTER TABLE admins 
ADD CONSTRAINT admins_status_check 
CHECK (status IN ('active', 'inactive'));

-- Statut logement
ALTER TABLE properties 
ADD CONSTRAINT properties_status_check 
CHECK (status IN ('draft', 'published', 'paused', 'archived'));

-- Note logement (1-5)
ALTER TABLE reviews 
ADD CONSTRAINT reviews_rating_check 
CHECK (rating >= 1 AND rating <= 5);

-- Type de message
ALTER TABLE messages 
ADD CONSTRAINT messages_type_check 
CHECK (type IN ('text', 'image', 'document'));

-- Statut conversation
ALTER TABLE conversations 
ADD CONSTRAINT conversations_status_check 
CHECK (status IN ('active', 'inactive', 'archived'));

-- Statut message
ALTER TABLE messages 
ADD CONSTRAINT messages_status_check 
CHECK (status IN ('active', 'deleted'));

-- Statut notification
ALTER TABLE notifications 
ADD CONSTRAINT notifications_status_check 
CHECK (status IN ('active', 'archived'));

-- Statut visite
ALTER TABLE visits 
ADD CONSTRAINT visits_status_check 
CHECK (status IN ('pending', 'confirmed', 'cancelled', 'completed'));

-- Statut signalement
ALTER TABLE reports 
ADD CONSTRAINT reports_status_check 
CHECK (status IN ('pending', 'in_progress', 'resolved', 'rejected'));

-- Statut document de vérification
ALTER TABLE verification_documents 
ADD CONSTRAINT verification_documents_verification_status_check 
CHECK (verification_status IN ('pending', 'approved', 'rejected'));

-- Statut document
ALTER TABLE verification_documents 
ADD CONSTRAINT verification_documents_status_check 
CHECK (status IN ('active', 'inactive', 'expired'));

-- Fréquence d'alerte
ALTER TABLE saved_searches 
ADD CONSTRAINT saved_searches_alert_frequency_check 
CHECK (alert_frequency IN ('immediate', 'daily', 'weekly'));

-- Thème utilisateur
ALTER TABLE user_settings 
ADD CONSTRAINT user_settings_theme_check 
CHECK (theme IN ('light', 'dark'));

-- Fréquence newsletter
ALTER TABLE user_settings 
ADD CONSTRAINT user_settings_newsletter_frequency_check 
CHECK (newsletter_frequency IN ('immediate', 'daily', 'weekly'));

-- Statut session
ALTER TABLE user_sessions 
ADD CONSTRAINT user_sessions_status_check 
CHECK (status IN ('active', 'expired', 'revoked'));

-- Rôle chatbot message
ALTER TABLE chatbot_messages 
ADD CONSTRAINT chatbot_messages_role_check 
CHECK (role IN ('user', 'assistant'));
```

### Contraintes CHECK sur les Valeurs Numériques

```sql
-- Prix positif
ALTER TABLE properties 
ADD CONSTRAINT properties_price_check 
CHECK (price > 0);

-- Caution positive ou nulle
ALTER TABLE properties 
ADD CONSTRAINT properties_deposit_check 
CHECK (deposit >= 0);

-- Avance positive ou nulle
ALTER TABLE properties 
ADD CONSTRAINT properties_advance_check 
CHECK (advance >= 0);

-- Surface positive
ALTER TABLE properties 
ADD CONSTRAINT properties_surface_check 
CHECK (surface > 0);

-- Chambres positif ou nul
ALTER TABLE properties 
ADD CONSTRAINT properties_bedrooms_check 
CHECK (bedrooms >= 0);

-- Salons positif ou nul
ALTER TABLE properties 
ADD CONSTRAINT properties_living_rooms_check 
CHECK (living_rooms >= 0);

-- Cuisines positif ou nul
ALTER TABLE properties 
ADD CONSTRAINT properties_kitchens_check 
CHECK (kitchens >= 0);

-- Salles de bain positif ou nul
ALTER TABLE properties 
ADD CONSTRAINT properties_bathrooms_check 
CHECK (bathrooms >= 0);

-- Toilettes positif ou nul
ALTER TABLE properties 
ADD CONSTRAINT properties_toilets_check 
CHECK (toilets >= 0);

-- Compteurs positifs ou nuls
ALTER TABLE properties 
ADD CONSTRAINT properties_view_count_check 
CHECK (view_count >= 0);

ALTER TABLE properties 
ADD CONSTRAINT properties_favorite_count_check 
CHECK (favorite_count >= 0);

ALTER TABLE properties 
ADD CONSTRAINT properties_share_count_check 
CHECK (share_count >= 0);

-- Distance positive ou nulle
ALTER TABLE properties 
ADD CONSTRAINT properties_distance_check 
CHECK (distance IS NULL OR distance >= 0);

-- Revenu positif ou nul
ALTER TABLE clients 
ADD CONSTRAINT clients_monthly_income_check 
CHECK (monthly_income IS NULL OR monthly_income >= 0);

-- Durée vidéo positive ou nulle
ALTER TABLE property_videos 
ADD CONSTRAINT property_videos_duration_check 
CHECK (duration IS NULL OR duration >= 0);

-- Ordre positif ou nul
ALTER TABLE categories 
ADD CONSTRAINT categories_order_num_check 
CHECK (order_num >= 0);

ALTER TABLE types 
ADD CONSTRAINT types_order_num_check 
CHECK (order_num >= 0);

ALTER TABLE equipment 
ADD CONSTRAINT equipment_order_num_check 
CHECK (order_num >= 0);

ALTER TABLE property_photos 
ADD CONSTRAINT property_photos_order_num_check 
CHECK (order_num >= 0);

ALTER TABLE property_videos 
ADD CONSTRAINT property_videos_order_num_check 
CHECK (order_num >= 0);

-- Population positive ou nulle
ALTER TABLE cities 
ADD CONSTRAINT cities_population_check 
CHECK (population IS NULL OR population >= 0);

ALTER TABLE districts 
ADD CONSTRAINT districts_population_check 
CHECK (population IS NULL OR population >= 0);

-- Compteurs positifs ou nuls
ALTER TABLE conversations 
ADD CONSTRAINT conversations_message_count_check 
CHECK (message_count >= 0);

ALTER TABLE conversations 
ADD CONSTRAINT conversations_unread_count_check 
CHECK (unread_count >= 0);

ALTER TABLE chatbot_conversations 
ADD CONSTRAINT chatbot_conversations_message_count_check 
CHECK (message_count >= 0);

-- Résultats positifs ou nuls
ALTER TABLE searches 
ADD CONSTRAINT searches_result_count_check 
CHECK (result_count >= 0);

-- Durée visite positive
ALTER TABLE visit_schedules 
ADD CONSTRAINT visit_schedules_visit_duration_check 
CHECK (visit_duration > 0);

-- Délai de réservation positif ou nul
ALTER TABLE visit_schedules 
ADD CONSTRAINT visit_schedules_booking_lead_time_check 
CHECK (booking_lead_time >= 0);
```

### Contraintes CHECK sur les Dates

```sql
-- Date de visite future ou aujourd'hui
ALTER TABLE visits 
ADD CONSTRAINT visits_visit_date_check 
CHECK (visit_date >= CURRENT_DATE);

-- Date d'expiration future
ALTER TABLE verification_documents 
ADD CONSTRAINT verification_documents_expiry_date_check 
CHECK (expiry_date > CURRENT_DATE);
```

---

## Contraintes NOT NULL

### Champs Obligatoires Principaux

```sql
-- Utilisateurs
ALTER TABLE users 
ALTER COLUMN email SET NOT NULL,
ALTER COLUMN first_name SET NOT NULL,
ALTER COLUMN last_name SET NOT NULL,
ALTER COLUMN date_of_birth SET NOT NULL,
ALTER COLUMN role SET NOT NULL,
ALTER COLUMN status SET NOT NULL,
ALTER COLUMN created_at SET NOT NULL,
ALTER COLUMN updated_at SET NOT NULL;

-- Logements
ALTER TABLE properties 
ALTER COLUMN title SET NOT NULL,
ALTER COLUMN description SET NOT NULL,
ALTER COLUMN price SET NOT NULL,
ALTER COLUMN surface SET NOT NULL,
ALTER COLUMN bedrooms SET NOT NULL,
ALTER COLUMN living_rooms SET NOT NULL,
ALTER COLUMN kitchens SET NOT NULL,
ALTER COLUMN bathrooms SET NOT NULL,
ALTER COLUMN toilets SET NOT NULL,
ALTER COLUMN landlord_id SET NOT NULL,
ALTER COLUMN landlord_name SET NOT NULL,
ALTER COLUMN landlord_phone SET NOT NULL,
ALTER COLUMN category_id SET NOT NULL,
ALTER COLUMN category_name SET NOT NULL,
ALTER COLUMN type_id SET NOT NULL,
ALTER COLUMN type_name SET NOT NULL,
ALTER COLUMN status SET NOT NULL,
ALTER COLUMN created_at SET NOT NULL,
ALTER COLUMN updated_at SET NOT NULL;

-- Localisation
ALTER TABLE addresses 
ALTER COLUMN street SET NOT NULL,
ALTER COLUMN postal_code SET NOT NULL,
ALTER COLUMN city_id SET NOT NULL,
ALTER COLUMN city_name SET NOT NULL,
ALTER COLUMN location SET NOT NULL,
ALTER COLUMN created_at SET NOT NULL,
ALTER COLUMN updated_at SET NOT NULL;
```

---

## Contraintes DEFAULT

### Valeurs par Défaut Automatiques

```sql
-- Timestamps
ALTER TABLE users 
ALTER COLUMN created_at SET DEFAULT CURRENT_TIMESTAMP,
ALTER COLUMN updated_at SET DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE properties 
ALTER COLUMN created_at SET DEFAULT CURRENT_TIMESTAMP,
ALTER COLUMN updated_at SET DEFAULT CURRENT_TIMESTAMP;

-- Statuts
ALTER TABLE users 
ALTER COLUMN status SET DEFAULT 'active',
ALTER COLUMN is_verified SET DEFAULT FALSE,
ALTER COLUMN is_active SET DEFAULT TRUE;

ALTER TABLE properties 
ALTER COLUMN status SET DEFAULT 'draft';

ALTER TABLE clients 
ALTER COLUMN verification_status SET DEFAULT 'pending',
ALTER COLUMN status SET DEFAULT 'active';

ALTER TABLE landlords 
ALTER COLUMN verification_status SET DEFAULT 'pending',
ALTER COLUMN status SET DEFAULT 'active',
ALTER COLUMN is_professional SET DEFAULT FALSE;

ALTER TABLE admins 
ALTER COLUMN status SET DEFAULT 'active',
ALTER COLUMN is_super_admin SET DEFAULT FALSE;

ALTER TABLE visits 
ALTER COLUMN status SET DEFAULT 'pending';

ALTER TABLE verification_documents 
ALTER COLUMN verification_status SET DEFAULT 'pending',
ALTER COLUMN status SET DEFAULT 'active';

ALTER TABLE saved_searches 
ALTER COLUMN alert_enabled SET DEFAULT FALSE,
ALTER COLUMN alert_frequency SET DEFAULT 'immediate';

ALTER TABLE user_settings 
ALTER COLUMN language SET DEFAULT 'fr',
ALTER COLUMN timezone SET DEFAULT 'Africa/Abidjan',
ALTER COLUMN email_notifications SET DEFAULT TRUE,
ALTER COLUMN push_notifications SET DEFAULT TRUE,
ALTER COLUMN sms_notifications SET DEFAULT FALSE,
ALTER COLUMN public_profile SET DEFAULT FALSE,
ALTER COLUMN share_location SET DEFAULT FALSE,
ALTER COLUMN theme SET DEFAULT 'light',
ALTER COLUMN newsletter_frequency SET DEFAULT 'immediate';

ALTER TABLE user_sessions 
ALTER COLUMN is_active SET DEFAULT TRUE,
ALTER COLUMN status SET DEFAULT 'active';

-- Compteurs
ALTER TABLE properties 
ALTER COLUMN view_count SET DEFAULT 0,
ALTER COLUMN favorite_count SET DEFAULT 0,
ALTER COLUMN share_count SET DEFAULT 0;

ALTER TABLE conversations 
ALTER COLUMN message_count SET DEFAULT 0,
ALTER COLUMN unread_count SET DEFAULT 0;

ALTER TABLE chatbot_conversations 
ALTER COLUMN message_count SET DEFAULT 0;

ALTER TABLE searches 
ALTER COLUMN result_count SET DEFAULT 0;

-- Ordres
ALTER TABLE categories 
ALTER COLUMN order_num SET DEFAULT 0;

ALTER TABLE types 
ALTER COLUMN order_num SET DEFAULT 0;

ALTER TABLE equipment 
ALTER COLUMN order_num SET DEFAULT 0;

ALTER TABLE property_photos 
ALTER COLUMN order_num SET DEFAULT 0,
ALTER COLUMN is_primary SET DEFAULT FALSE;

ALTER TABLE property_videos 
ALTER COLUMN order_num SET DEFAULT 0;

-- Devise
ALTER TABLE properties 
ALTER COLUMN currency SET DEFAULT 'XOF';
```

---

## Actions ON DELETE

### CASCADE

Suppression automatique des enregistrements liés lorsque l'enregistrement parent est supprimé.

```sql
-- Profile vers User
ON DELETE CASCADE

-- Client vers User
ON DELETE CASCADE

-- Landlord vers User
ON DELETE CASCADE

-- Admin vers User
ON DELETE CASCADE

-- User Settings vers User
ON DELETE CASCADE

-- User Sessions vers User
ON DELETE CASCADE

-- District vers City
ON DELETE CASCADE

-- Property Photos vers Property
ON DELETE CASCADE

-- Property Videos vers Property
ON DELETE CASCADE

-- Conversations vers User (participant1)
ON DELETE CASCADE

-- Conversations vers User (participant2)
ON DELETE CASCADE

-- Messages vers Conversation
ON DELETE CASCADE

-- Messages vers User (sender)
ON DELETE CASCADE

-- Messages vers User (recipient)
ON DELETE CASCADE

-- Notifications vers User
ON DELETE CASCADE

-- Chatbot Conversations vers User
ON DELETE CASCADE

-- Chatbot Messages vers Chatbot Conversation
ON DELETE CASCADE

-- Visits vers Property
ON DELETE CASCADE

-- Visits vers Client
ON DELETE CASCADE

-- Favorites vers User
ON DELETE CASCADE

-- Favorites vers Property
ON DELETE CASCADE

-- Reviews vers User
ON DELETE CASCADE

-- Reviews vers Property
ON DELETE CASCADE

-- Searches vers User
ON DELETE CASCADE

-- Saved Searches vers User
ON DELETE CASCADE
```

### RESTRICT

Empêche la suppression de l'enregistrement parent si des enregistrements liés existent.

```sql
-- Property vers Landlord
ON DELETE RESTRICT

-- Property vers Address
ON DELETE RESTRICT

-- Property vers Category
ON DELETE RESTRICT

-- Property vers Type
ON DELETE RESTRICT

-- Address vers City
ON DELETE RESTRICT
```

### SET NULL

Met à NULL la clé étrangère lorsque l'enregistrement parent est supprimé.

```sql
-- Admin hiérarchie
ON DELETE SET NULL

-- Conversation vers Property
ON DELETE SET NULL

-- Address vers District
ON DELETE SET NULL

-- Report vers Admin (processed_by)
ON DELETE SET NULL

-- Verification Document vers Admin (verified_by)
ON DELETE SET NULL

-- Search vers Category
ON DELETE SET NULL

-- Search vers Type
ON DELETE SET NULL

-- Search vers City
ON DELETE SET NULL

-- Search vers District
ON DELETE SET NULL

-- Saved Search vers Category
ON DELETE SET NULL

-- Saved Search vers Type
ON DELETE SET NULL

-- Saved Search vers City
ON DELETE SET NULL

-- Saved Search vers District
ON DELETE SET NULL

-- Audit Log vers User
ON DELETE SET NULL
```

---

## Validation des Données

### Validation au Niveau Base de Données

Les contraintes CHECK assurent la validation des données au niveau de la base de données, en complément de la validation au niveau application.

### Validation des Emails

```sql
-- Validation du format email via CHECK constraint
ALTER TABLE users 
ADD CONSTRAINT users_email_format_check 
CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
```

### Validation des Téléphones

```sql
-- Validation du format téléphone
ALTER TABLE users 
ADD CONSTRAINT users_phone_format_check 
CHECK (phone IS NULL OR phone ~* '^\+?[0-9]{10,15}$');
```

### Validation des URLs

```sql
-- Validation du format URL
ALTER TABLE profiles 
ADD CONSTRAINT profiles_website_format_check 
CHECK (website IS NULL OR website ~* '^https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(/.*)?$');
```

### Validation des Codes ISO

```sql
-- Validation du code pays ISO
ALTER TABLE users 
ADD CONSTRAINT users_nationality_check 
CHECK (nationality IS NULL OR nationality ~* '^[A-Z]{2}$');

-- Validation du code langue ISO
ALTER TABLE users 
ADD CONSTRAINT users_preferred_language_check 
CHECK (preferred_language ~* '^[a-z]{2}(-[A-Z]{2})?$');

-- Validation du code devise ISO
ALTER TABLE properties 
ADD CONSTRAINT properties_currency_check 
CHECK (currency ~* '^[A-Z]{3}$');
```

---

## Mapping Django ORM

### Contraintes Django ↔ PostgreSQL

| Django | PostgreSQL | Exemple |
|--------|-------------|---------|
| primary_key=True | PRIMARY KEY | id = models.UUIDField(primary_key=True) |
| unique=True | UNIQUE | email = models.EmailField(unique=True) |
| blank=False, null=False | NOT NULL | name = models.CharField(blank=False, null=False) |
| default= | DEFAULT | status = models.CharField(default='active') |
| validators=[] | CHECK | age = models.IntegerField(validators=[MinValueValidator(0)]) |
| ForeignKey(on_delete=CASCADE) | ON DELETE CASCADE | models.ForeignKey('User', on_delete=models.CASCADE) |
| ForeignKey(on_delete=PROTECT) | ON DELETE RESTRICT | models.ForeignKey('User', on_delete=models.PROTECT) |
| ForeignKey(on_delete=SET_NULL) | ON DELETE SET NULL | models.ForeignKey('User', on_delete=models.SET_NULL, null=True) |
| choices= | CHECK | role = models.CharField(choices=[('client', 'Client')]) |

### Contraintes Django Uniques Composites

```python
class Meta:
    constraints = [
        models.UniqueConstraint(fields=['user_id', 'property_id'], name='unique_user_property')
    ]
```

### Contraintes Django Check

```python
class Meta:
    constraints = [
        models.CheckConstraint(check=models.Q(price__gt=0), name='price_positive')
    ]
```

---

## Bonnes Pratiques

### 1. Toujours Définir des Clés Primaires

Chaque table doit avoir une clé primaire pour garantir l'identification unique des enregistrements.

### 2. Utiliser des Clés Étrangères pour les Relations

Les clés étrangères garantissent l'intégrité référentielle entre les tables.

### 3. Choisir l'Action ON DELETE Appropriée

- **CASCADE** : Pour les relations fortes (enfant dépend du parent)
- **RESTRICT** : Pour les relations critiques (ne pas supprimer si utilisé)
- **SET NULL** : Pour les relations optionnelles (peut exister sans parent)

### 4. Utiliser des Contraintes CHECK pour la Validation

Les contraintes CHECK valident les données au niveau de la base de données.

### 5. Utiliser des Contraintes UNIQUE pour Garantir l'Unicité

Les contraintes UNIQUE garantissent l'absence de doublons dans les colonnes critiques.

### 6. Éviter les Contraintes Trop Complexes

Les contraintes complexes peuvent ralentir les écritures. Préférer la validation au niveau application.

### 7. Documenter les Contraintes

Documenter toutes les contraintes pour faciliter la maintenance.

### 8. Tester les Contraintes

Toujours tester les contraintes en environnement de test avant déploiement en production.

### 9. Surveiller les Violations de Contraintes

Surveiller les violations de contraintes pour identifier les problèmes de données.

### 10. Utiliser des Transactions pour les Opérations Complexes

Les transactions garantissent que plusieurs opérations sont atomiques.
