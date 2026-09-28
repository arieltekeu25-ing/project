# Database Indexes - GestionBailleur PostgreSQL

## Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Indexes par Table](#indexes-par-table)
3. [Indexes Composites](#indexes-composites)
4. [Indexes Géospatiaux](#indexes-géospatiaux)
5. [Indexes GIN (JSONB)](#indexes-gin-jsonb)
6. [Stratégies d'Optimisation](#stratégies-doptimisation)
7. [Maintenance des Indexes](#maintenance-des-indexes)

---

## Vue d'ensemble

Les indexes sont essentiels pour optimiser les performances des requêtes PostgreSQL. Ce document définit tous les indexes nécessaires pour la base de données GestionBailleur.

### Principes d'Indexation

- **Indexer les clés étrangères** : Pour optimiser les jointures
- **Indexer les champs de filtre** : Pour les WHERE clauses fréquentes
- **Indexer les champs de tri** : Pour les ORDER BY
- **Indexer les champs uniques** : Pour garantir l'unicité
- **Indexer les champs géospatiaux** : Pour les requêtes de proximité
- **Éviter les indexes inutiles** : Pour ne pas ralentir les écritures

---

## Indexes par Table

### users

| Nom de l'index | Type | Colonnes | Description |
|----------------|------|----------|-------------|
| idx_users_email | B-tree | email | Recherche par email (unique) |
| idx_users_phone | B-tree | phone | Recherche par téléphone (unique) |
| idx_users_role | B-tree | role | Filtrage par rôle |
| idx_users_status | B-tree | status | Filtrage par statut |
| idx_users_created_at | B-tree | created_at DESC | Tri par date de création |
| idx_users_last_login_at | B-tree | last_login_at DESC | Tri par dernière connexion |

**Justification** :
- `email` et `phone` : Index unique pour garantir l'unicité et optimiser les connexions
- `role` : Filtrage fréquent pour les permissions
- `status` : Filtrage pour les utilisateurs actifs
- `created_at` : Tri pour les listes d'utilisateurs
- `last_login_at` : Tri pour l'activité récente

---

### profiles

| Nom de l'index | Type | Colonnes | Description |
|----------------|------|----------|-------------|
| idx_profiles_user_id | B-tree | user_id | Recherche par utilisateur (unique) |
| idx_profiles_status | B-tree | status | Filtrage par statut |

**Justification** :
- `user_id` : Jointure avec users
- `status` : Filtrage des profils actifs

---

### clients

| Nom de l'index | Type | Colonnes | Description |
|----------------|------|----------|-------------|
| idx_clients_user_id | B-tree | user_id | Recherche par utilisateur (unique) |
| idx_clients_verification_status | B-tree | verification_status | Filtrage par statut de vérification |
| idx_clients_status | B-tree | status | Filtrage par statut |

**Justification** :
- `user_id` : Jointure avec users
- `verification_status` : Filtrage des clients vérifiés
- `status` : Filtrage des clients actifs

---

### landlords

| Nom de l'index | Type | Colonnes | Description |
|----------------|------|----------|-------------|
| idx_landlords_user_id | B-tree | user_id | Recherche par utilisateur (unique) |
| idx_landlords_verification_status | B-tree | verification_status | Filtrage par statut de vérification |
| idx_landlords_status | B-tree | status | Filtrage par statut |

**Justification** :
- `user_id` : Jointure avec users
- `verification_status` : Filtrage des bailleurs vérifiés
- `status` : Filtrage des bailleurs actifs

---

### admins

| Nom de l'index | Type | Colonnes | Description |
|----------------|------|----------|-------------|
| idx_admins_user_id | B-tree | user_id | Recherche par utilisateur (unique) |
| idx_admins_department | B-tree | department | Filtrage par département |
| idx_admins_status | B-tree | status | Filtrage par statut |
| idx_admins_superior_id | B-tree | superior_id | Hiérarchie des admins |

**Justification** :
- `user_id` : Jointure avec users
- `department` : Filtrage par département
- `status` : Filtrage des admins actifs
- `superior_id` : Navigation dans la hiérarchie

---

### properties

| Nom de l'index | Type | Colonnes | Description |
|----------------|------|----------|-------------|
| idx_properties_landlord_id | B-tree | landlord_id | Filtrage par bailleur |
| idx_properties_category_id | B-tree | category_id | Filtrage par catégorie |
| idx_properties_type_id | B-tree | type_id | Filtrage par type |
| idx_properties_status | B-tree | status | Filtrage par statut |
| idx_properties_published_at | B-tree | published_at DESC | Tri par date de publication |
| idx_properties_price | B-tree | price | Tri par prix |
| idx_properties_surface | B-tree | surface | Tri par surface |
| idx_properties_bedrooms | B-tree | bedrooms | Filtrage par nombre de chambres |
| idx_properties_location | GIST | location | Recherche géospatiale |
| idx_properties_landlord_status | B-tree | landlord_id, status | Logements d'un bailleur par statut |
| idx_properties_category_status | B-tree | category_id, status | Logements d'une catégorie par statut |
| idx_properties_type_status | B-tree | type_id, status | Logements d'un type par statut |
| idx_properties_status_published | B-tree | status, published_at DESC | Logements par statut triés par date |
| idx_properties_price_status | B-tree | price, status | Logements par statut et prix |
| idx_properties_surface_status | B-tree | surface, status | Logements par statut et surface |
| idx_properties_bedrooms_status | B-tree | bedrooms, status | Logements par statut et chambres |

**Justification** :
- `landlord_id` : Filtrage des logements d'un bailleur
- `category_id`, `type_id` : Filtrage par catégorie et type
- `status` : Filtrage des logements publiés
- `published_at` : Tri pour les logements récents
- `price`, `surface`, `bedrooms` : Tri et filtrage pour la recherche
- `location` : Recherche géospatiale (proximité)
- Indexes composites : Optimisation des requêtes multi-critères

---

### property_photos

| Nom de l'index | Type | Colonnes | Description |
|----------------|------|----------|-------------|
| idx_property_photos_property_id | B-tree | property_id | Filtrage par logement |
| idx_property_photos_order | B-tree | property_id, order_num | Tri par ordre |
| idx_property_photos_primary | B-tree | property_id, is_primary | Recherche de la photo principale |

**Justification** :
- `property_id` : Jointure avec properties
- `order_num` : Tri des photos dans l'ordre
- `is_primary` : Recherche de la photo principale

---

### property_videos

| Nom de l'index | Type | Colonnes | Description |
|----------------|------|----------|-------------|
| idx_property_videos_property_id | B-tree | property_id | Filtrage par logement |
| idx_property_videos_order | B-tree | property_id, order_num | Tri par ordre |

**Justification** :
- `property_id` : Jointure avec properties
- `order_num` : Tri des vidéos dans l'ordre

---

### categories

| Nom de l'index | Type | Colonnes | Description |
|----------------|------|----------|-------------|
| idx_categories_order | B-tree | order_num | Tri par ordre |
| idx_categories_status | B-tree | status | Filtrage par statut |

**Justification** :
- `order_num` : Tri pour l'affichage
- `status` : Filtrage des catégories actives

---

### types

| Nom de l'index | Type | Colonnes | Description |
|----------------|------|----------|-------------|
| idx_types_order | B-tree | order_num | Tri par ordre |
| idx_types_status | B-tree | status | Filtrage par statut |

**Justification** :
- `order_num` : Tri pour l'affichage
- `status` : Filtrage des types actifs

---

### equipment

| Nom de l'index | Type | Colonnes | Description |
|----------------|------|----------|-------------|
| idx_equipment_category | B-tree | category | Filtrage par catégorie |
| idx_equipment_order | B-tree | category, order_num | Tri par catégorie et ordre |
| idx_equipment_status | B-tree | status | Filtrage par statut |

**Justification** :
- `category` : Filtrage par catégorie
- `order_num` : Tri pour l'affichage
- `status` : Filtrage des équipements actifs

---

### cities

| Nom de l'index | Type | Colonnes | Description |
|----------------|------|----------|-------------|
| idx_cities_name | B-tree | name | Recherche par nom |
| idx_cities_country | B-tree | country | Filtrage par pays |
| idx_cities_status | B-tree | status | Filtrage par statut |
| idx_cities_location | GIST | location | Recherche géospatiale |

**Justification** :
- `name` : Recherche de ville par nom
- `country` : Filtrage par pays
- `status` : Filtrage des villes actives
- `location` : Recherche géospatiale

---

### districts

| Nom de l'index | Type | Colonnes | Description |
|----------------|------|----------|-------------|
| idx_districts_city_id | B-tree | city_id | Filtrage par ville |
| idx_districts_city_name | B-tree | city_id, name | Recherche par ville et nom |
| idx_districts_status | B-tree | status | Filtrage par statut |

**Justification** :
- `city_id` : Jointure avec cities
- `city_id, name` : Recherche de quartier dans une ville
- `status` : Filtrage des quartiers actifs

---

### addresses

| Nom de l'index | Type | Colonnes | Description |
|----------------|------|----------|-------------|
| idx_addresses_city_id | B-tree | city_id | Filtrage par ville |
| idx_addresses_district_id | B-tree | district_id | Filtrage par quartier |
| idx_addresses_status | B-tree | status | Filtrage par statut |
| idx_addresses_location | GIST | location | Recherche géospatiale |

**Justification** :
- `city_id`, `district_id` : Jointure avec cities et districts
- `status` : Filtrage des adresses actives
- `location` : Recherche géospatiale

---

### favorites

| Nom de l'index | Type | Colonnes | Description |
|----------------|------|----------|-------------|
| idx_favorites_user_id | B-tree | user_id | Filtrage par utilisateur |
| idx_favorites_property_id | B-tree | property_id | Filtrage par logement |
| idx_favorites_user_property | B-tree | user_id, property_id | Contrainte d'unicité |
| idx_favorites_created_at | B-tree | created_at DESC | Tri par date de création |

**Justification** :
- `user_id` : Liste des favoris d'un utilisateur
- `property_id` : Liste des utilisateurs qui ont favorisé
- `user_id, property_id` : Garantir l'unicité
- `created_at` : Tri par date d'ajout

---

### reviews

| Nom de l'index | Type | Colonnes | Description |
|----------------|------|----------|-------------|
| idx_reviews_user_id | B-tree | user_id | Filtrage par utilisateur |
| idx_reviews_property_id | B-tree | property_id | Filtrage par logement |
| idx_reviews_user_property | B-tree | user_id, property_id | Contrainte d'unicité |
| idx_reviews_property_rating | B-tree | property_id, rating DESC | Avis d'un logement triés par note |
| idx_reviews_created_at | B-tree | created_at DESC | Tri par date de création |

**Justification** :
- `user_id` : Avis d'un utilisateur
- `property_id` : Avis d'un logement
- `user_id, property_id` : Garantir l'unicité (un avis par utilisateur par logement)
- `rating` : Tri par note pour les meilleurs avis
- `created_at` : Tri par date

---

### conversations

| Nom de l'index | Type | Colonnes | Description |
|----------------|------|----------|-------------|
| idx_conversations_participant1_id | B-tree | participant1_id | Conversations du participant 1 |
| idx_conversations_participant2_id | B-tree | participant2_id | Conversations du participant 2 |
| idx_conversations_property_id | B-tree | property_id | Conversations d'un logement |
| idx_conversations_last_message_at | B-tree | last_message_at DESC | Tri par dernier message |
| idx_conversations_participant1_status | B-tree | participant1_id, status | Conversations du participant 1 par statut |
| idx_conversations_participant2_status | B-tree | participant2_id, status | Conversations du participant 2 par statut |
| idx_conversations_property_status | B-tree | property_id, status | Conversations d'un logement par statut |
| idx_conversations_participant1_last | B-tree | participant1_id, last_message_at DESC | Conversations du participant 1 triées par activité |
| idx_conversations_participant2_last | B-tree | participant2_id, last_message_at DESC | Conversations du participant 2 triées par activité |

**Justification** :
- `participant1_id`, `participant2_id` : Liste des conversations d'un utilisateur
- `property_id` : Conversations liées à un logement
- `last_message_at` : Tri par activité récente
- Indexes composites : Optimisation des requêtes multi-critères

---

### messages

| Nom de l'index | Type | Colonnes | Description |
|----------------|------|----------|-------------|
| idx_messages_conversation_id | B-tree | conversation_id | Filtrage par conversation |
| idx_messages_conversation_created | B-tree | conversation_id, created_at DESC | Messages d'une conversation triés par date |
| idx_messages_sender_id | B-tree | sender_id | Messages envoyés par un utilisateur |
| idx_messages_sender_created | B-tree | sender_id, created_at DESC | Messages envoyés triés par date |
| idx_messages_recipient_id | B-tree | recipient_id | Messages reçus par un utilisateur |
| idx_messages_recipient_read | B-tree | recipient_id, is_read | Messages non lus d'un utilisateur |
| idx_messages_recipient_created | B-tree | recipient_id, created_at DESC | Messages reçus triés par date |

**Justification** :
- `conversation_id` : Jointure avec conversations
- `created_at` : Tri chronologique des messages
- `sender_id`, `recipient_id` : Liste des messages d'un utilisateur
- `is_read` : Filtrage des messages non lus
- Indexes composites : Optimisation des requêtes fréquentes

---

### notifications

| Nom de l'index | Type | Colonnes | Description |
|----------------|------|----------|-------------|
| idx_notifications_user_id | B-tree | user_id | Filtrage par utilisateur |
| idx_notifications_user_read | B-tree | user_id, is_read | Notifications d'un utilisateur par statut de lecture |
| idx_notifications_user_created | B-tree | user_id, created_at DESC | Notifications d'un utilisateur triées par date |
| idx_notifications_type | B-tree | type | Filtrage par type |
| idx_notifications_type_created | B-tree | type, created_at DESC | Notifications par type triées par date |

**Justification** :
- `user_id` : Liste des notifications d'un utilisateur
- `is_read` : Filtrage des notifications non lues
- `created_at` : Tri par date
- `type` : Filtrage par type de notification
- Indexes composites : Optimisation des requêtes fréquentes

---

### visits

| Nom de l'index | Type | Colonnes | Description |
|----------------|------|----------|-------------|
| idx_visits_property_id | B-tree | property_id | Filtrage par logement |
| idx_visits_client_id | B-tree | client_id | Filtrage par client |
| idx_visits_landlord_id | B-tree | landlord_id | Filtrage par bailleur |
| idx_visits_visit_date | B-tree | visit_date | Tri par date de visite |
| idx_visits_status_date | B-tree | status, visit_date | Visites par statut et date |
| idx_visits_client_date | B-tree | client_id, visit_date | Visites d'un client triées par date |
| idx_visits_landlord_date | B-tree | landlord_id, visit_date | Visites d'un bailleur triées par date |
| idx_visits_property_date | B-tree | property_id, visit_date | Visites d'un logement triées par date |
| idx_visits_client_status | B-tree | client_id, status | Visites d'un client par statut |
| idx_visits_landlord_status | B-tree | landlord_id, status | Visites d'un bailleur par statut |

**Justification** :
- `property_id`, `client_id`, `landlord_id` : Jointures avec les tables correspondantes
- `visit_date` : Tri par date de visite
- `status` : Filtrage par statut de visite
- Indexes composites : Optimisation des requêtes multi-critères

---

### visit_schedules

| Nom de l'index | Type | Colonnes | Description |
|----------------|------|----------|-------------|
| idx_visit_schedules_landlord_id | B-tree | landlord_id | Filtrage par bailleur |
| idx_visit_schedules_property_id | B-tree | property_id | Filtrage par logement |
| idx_visit_schedules_landlord_status | B-tree | landlord_id, status | Planning d'un bailleur par statut |
| idx_visit_schedules_property_status | B-tree | property_id, status | Planning d'un logement par statut |

**Justification** :
- `landlord_id`, `property_id` : Jointures avec les tables correspondantes
- `status` : Filtrage des plannings actifs
- Indexes composites : Optimisation des requêtes multi-critères

---

### reports

| Nom de l'index | Type | Colonnes | Description |
|----------------|------|----------|-------------|
| idx_reports_author_id | B-tree | author_id | Filtrage par auteur |
| idx_reports_entity | B-tree | entity_id, entity_type | Signalements d'une entité |
| idx_reports_entity_status | B-tree | entity_id, entity_type, status | Signalements d'une entité par statut |
| idx_reports_status_created | B-tree | status, created_at DESC | Signalements par statut triés par date |

**Justification** :
- `author_id` : Signalements d'un utilisateur
- `entity_id, entity_type` : Signalements d'une entité spécifique
- `status` : Filtrage par statut de traitement
- `created_at` : Tri par date

---

### verification_documents

| Nom de l'index | Type | Colonnes | Description |
|----------------|------|----------|-------------|
| idx_verification_documents_user_id | B-tree | user_id | Filtrage par utilisateur |
| idx_verification_documents_verification_status | B-tree | verification_status | Filtrage par statut de vérification |
| idx_verification_documents_status | B-tree | status | Filtrage par statut |
| idx_verification_documents_expiry_date | B-tree | expiry_date | Tri par date d'expiration |
| idx_verification_documents_expiry_status | B-tree | expiry_date, status | Documents par date d'expiration et statut |

**Justification** :
- `user_id` : Documents d'un utilisateur
- `verification_status` : Filtrage par statut de vérification
- `status` : Filtrage des documents actifs
- `expiry_date` : Tri par date d'expiration
- Indexes composites : Optimisation des requêtes multi-critères

---

### searches

| Nom de l'index | Type | Colonnes | Description |
|----------------|------|----------|-------------|
| idx_searches_user_id | B-tree | user_id | Filtrage par utilisateur |
| idx_searches_user_created | B-tree | user_id, created_at DESC | Recherches d'un utilisateur triées par date |
| idx_searches_category_id | B-tree | category_id | Filtrage par catégorie |
| idx_searches_type_id | B-tree | type_id | Filtrage par type |
| idx_searches_city_id | B-tree | city_id | Filtrage par ville |
| idx_searches_category_created | B-tree | category_id, created_at DESC | Recherches d'une catégorie triées par date |

**Justification** :
- `user_id` : Historique de recherche d'un utilisateur
- `category_id`, `type_id`, `city_id` : Filtrage par critères de recherche
- `created_at` : Tri par date
- Indexes composites : Optimisation des requêtes fréquentes

---

### saved_searches

| Nom de l'index | Type | Colonnes | Description |
|----------------|------|----------|-------------|
| idx_saved_searches_user_id | B-tree | user_id | Filtrage par utilisateur |
| idx_saved_searches_user_alert | B-tree | user_id, alert_enabled | Recherches sauvegardées avec alertes |
| idx_saved_searches_user_status | B-tree | user_id, status | Recherches sauvegardées par statut |

**Justification** :
- `user_id` : Recherches sauvegardées d'un utilisateur
- `alert_enabled` : Filtrage des recherches avec alertes activées
- `status` : Filtrage des recherches actives

---

### chatbot_conversations

| Nom de l'index | Type | Colonnes | Description |
|----------------|------|----------|-------------|
| idx_chatbot_conversations_user_id | B-tree | user_id | Filtrage par utilisateur |
| idx_chatbot_conversations_user_status | B-tree | user_id, status | Conversations d'un utilisateur par statut |
| idx_chatbot_conversations_user_last | B-tree | user_id, last_interaction_at DESC | Conversations triées par activité |

**Justification** :
- `user_id` : Conversations d'un utilisateur
- `status` : Filtrage des conversations actives
- `last_interaction_at` : Tri par activité récente

---

### chatbot_messages

| Nom de l'index | Type | Colonnes | Description |
|----------------|------|----------|-------------|
| idx_chatbot_messages_conversation_id | B-tree | conversation_id | Filtrage par conversation |
| idx_chatbot_messages_conversation_created | B-tree | conversation_id, created_at DESC | Messages d'une conversation triés par date |
| idx_chatbot_messages_role | B-tree | role | Filtrage par rôle |
| idx_chatbot_messages_role_created | B-tree | role, created_at DESC | Messages par rôle triés par date |

**Justification** :
- `conversation_id` : Jointure avec chatbot_conversations
- `created_at` : Tri chronologique
- `role` : Filtrage par rôle (user/assistant)

---

### user_settings

| Nom de l'index | Type | Colonnes | Description |
|----------------|------|----------|-------------|
| idx_user_settings_user_id | B-tree | user_id | Recherche par utilisateur (unique) |

**Justification** :
- `user_id` : Jointure avec users (relation 1:1)

---

### user_sessions

| Nom de l'index | Type | Colonnes | Description |
|----------------|------|----------|-------------|
| idx_user_sessions_user_id | B-tree | user_id | Filtrage par utilisateur |
| idx_user_sessions_access_token | B-tree | access_token | Recherche par token d'accès |
| idx_user_sessions_refresh_token | B-tree | refresh_token | Recherche par token de rafraîchissement |
| idx_user_sessions_status | B-tree | status | Filtrage par statut |

**Justification** :
- `user_id` : Sessions d'un utilisateur
- `access_token`, `refresh_token` : Validation des tokens
- `status` : Filtrage des sessions actives

---

### audit_logs

| Nom de l'index | Type | Colonnes | Description |
|----------------|------|----------|-------------|
| idx_audit_logs_user_id | B-tree | user_id | Filtrage par utilisateur |
| idx_audit_logs_action_type | B-tree | action_type | Filtrage par type d'action |
| idx_audit_logs_entity | B-tree | entity_id, entity_type | Logs d'une entité |
| idx_audit_logs_entity_created | B-tree | entity_id, entity_type, created_at DESC | Logs d'une entité triés par date |
| idx_audit_logs_user_created | B-tree | user_id, created_at DESC | Logs d'un utilisateur triés par date |
| idx_audit_logs_action_created | B-tree | action_type, created_at DESC | Logs par type d'action triés par date |

**Justification** :
- `user_id` : Logs d'un utilisateur
- `action_type` : Filtrage par type d'action
- `entity_id, entity_type` : Logs d'une entité spécifique
- `created_at` : Tri par date
- Indexes composites : Optimisation des requêtes d'audit

---

## Indexes Composites

### Indexes Composites Critiques

Les indexes composites sont essentiels pour optimiser les requêtes avec plusieurs conditions.

#### Recherche de Logements

```sql
-- Logements par bailleur et statut
CREATE INDEX idx_properties_landlord_status ON properties(landlord_id, status);

-- Logements par catégorie et statut
CREATE INDEX idx_properties_category_status ON properties(category_id, status);

-- Logements par type et statut
CREATE INDEX idx_properties_type_status ON properties(type_id, status);

-- Logements par statut et date de publication
CREATE INDEX idx_properties_status_published ON properties(status, published_at DESC);

-- Logements par statut et prix
CREATE INDEX idx_properties_price_status ON properties(price, status);

-- Logements par statut et surface
CREATE INDEX idx_properties_surface_status ON properties(surface, status);

-- Logements par statut et chambres
CREATE INDEX idx_properties_bedrooms_status ON properties(bedrooms, status);
```

#### Recherche de Conversations

```sql
-- Conversations du participant 1 par statut
CREATE INDEX idx_conversations_participant1_status ON conversations(participant1_id, status);

-- Conversations du participant 2 par statut
CREATE INDEX idx_conversations_participant2_status ON conversations(participant2_id, status);

-- Conversations du participant 1 triées par activité
CREATE INDEX idx_conversations_participant1_last ON conversations(participant1_id, last_message_at DESC);

-- Conversations du participant 2 triées par activité
CREATE INDEX idx_conversations_participant2_last ON conversations(participant2_id, last_message_at DESC);
```

#### Recherche de Messages

```sql
-- Messages d'une conversation triés par date
CREATE INDEX idx_messages_conversation_created ON messages(conversation_id, created_at DESC);

-- Messages envoyés par un utilisateur triés par date
CREATE INDEX idx_messages_sender_created ON messages(sender_id, created_at DESC);

-- Messages reçus par un utilisateur triés par date
CREATE INDEX idx_messages_recipient_created ON messages(recipient_id, created_at DESC);

-- Messages non lus d'un utilisateur
CREATE INDEX idx_messages_recipient_read ON messages(recipient_id, is_read);
```

#### Recherche de Visites

```sql
-- Visites d'un client par date
CREATE INDEX idx_visits_client_date ON visits(client_id, visit_date);

-- Visites d'un bailleur par date
CREATE INDEX idx_visits_landlord_date ON visits(landlord_id, visit_date);

-- Visites d'un logement par date
CREATE INDEX idx_visits_property_date ON visits(property_id, visit_date);

-- Visites par statut et date
CREATE INDEX idx_visits_status_date ON visits(status, visit_date);

-- Visites d'un client par statut
CREATE INDEX idx_visits_client_status ON visits(client_id, status);

-- Visites d'un bailleur par statut
CREATE INDEX idx_visits_landlord_status ON visits(landlord_id, status);
```

#### Recherche de Notifications

```sql
-- Notifications d'un utilisateur par statut de lecture
CREATE INDEX idx_notifications_user_read ON notifications(user_id, is_read);

-- Notifications d'un utilisateur triées par date
CREATE INDEX idx_notifications_user_created ON notifications(user_id, created_at DESC);

-- Notifications par type triées par date
CREATE INDEX idx_notifications_type_created ON notifications(type, created_at DESC);
```

---

## Indexes Géospatiaux

### Indexes GIST pour PostGIS

Les indexes GIST (Generalized Search Tree) sont utilisés pour les requêtes géospatiales avec PostGIS.

```sql
-- Index géospatial pour les logements
CREATE INDEX idx_properties_location ON properties USING GIST(location);

-- Index géospatial pour les villes
CREATE INDEX idx_cities_location ON cities USING GIST(location);

-- Index géospatial pour les quartiers
CREATE INDEX idx_districts_location ON districts USING GIST(location);

-- Index géospatial pour les adresses
CREATE INDEX idx_addresses_location ON addresses USING GIST(location);

-- Index géospatial pour les favoris
CREATE INDEX idx_favorites_property_location ON favorites USING GIST(property_location);

-- Index géospatial pour les recherches
CREATE INDEX idx_searches_location ON searches USING GIST(location);

-- Index géospatial pour les recherches sauvegardées
CREATE INDEX idx_saved_searches_location ON saved_searches USING GIST(location);
```

### Requêtes Géospatiales Optimisées

```sql
-- Recherche de logements dans un rayon de 5 km
SELECT * FROM properties
WHERE ST_DWithin(location, ST_MakePoint(-4.0083, 5.3453)::geography, 5000)
AND status = 'published'
ORDER BY location <-> ST_MakePoint(-4.0083, 5.3453)::geography
LIMIT 20;

-- Recherche de villes dans un rayon de 50 km
SELECT * FROM cities
WHERE ST_DWithin(location, ST_MakePoint(-4.0083, 5.3453)::geography, 50000)
ORDER BY location <-> ST_MakePoint(-4.0083, 5.3453)::geography;
```

---

## Indexes GIN (JSONB)

### Indexes GIN pour JSONB

Les indexes GIN (Generalized Inverted Index) sont utilisés pour les champs JSONB pour optimiser les requêtes sur les données structurées.

```sql
-- Index GIN pour les équipements des logements
CREATE INDEX idx_properties_equipment_gin ON properties USING GIN(equipment_ids);

-- Index GIN pour les préférences utilisateur
CREATE INDEX idx_profiles_preferences_gin ON profiles USING GIN(preferences);

-- Index GIN pour les permissions admin
CREATE INDEX idx_admins_permissions_gin ON admins USING GIN(permissions);

-- Index GIN pour les créneaux de visite
CREATE INDEX idx_visit_schedules_slots_gin ON visit_schedules USING GIN(slots);

-- Index GIN pour les documents utilisateur
CREATE INDEX idx_clients_documents_gin ON clients USING GIN(documents);

-- Index GIN pour les documents juridiques bailleur
CREATE INDEX idx_landlords_legal_documents_gin ON landlords USING GIN(legal_documents);

-- Index GIN pour les données d'audit
CREATE INDEX idx_audit_logs_data_gin ON audit_logs USING GIN(data);

-- Index GIN pour les données chatbot
CREATE INDEX idx_chatbot_messages_data_gin ON chatbot_messages USING GIN(data);
```

### Requêtes JSONB Optimisées

```sql
-- Recherche de logements avec un équipement spécifique
SELECT * FROM properties
WHERE equipment_ids @> '["eq_ac"]'::jsonb
AND status = 'published';

-- Recherche de logements avec plusieurs équipements
SELECT * FROM properties
WHERE equipment_ids ?| ARRAY['eq_ac', 'eq_internet', 'eq_generator']
AND status = 'published';

-- Recherche de profils avec une préférence spécifique
SELECT * FROM profiles
WHERE preferences @> '{"theme": "dark"}'::jsonb;
```

---

## Stratégies d'Optimisation

### 1. Indexes de Couverture

Les indexes de couverture incluent tous les champs nécessaires pour une requête, évitant ainsi d'accéder à la table principale.

```sql
-- Index de couverture pour la liste des logements publiés
CREATE INDEX idx_properties_published_cover ON properties(status, published_at DESC)
INCLUDE (title, price, surface, bedrooms, landlord_name, landlord_phone);
```

### 2. Indexes Partiels

Les indexes partiels n'indexent que les lignes qui satisfont une condition, réduisant la taille de l'index.

```sql
-- Index partiel pour les logements publiés uniquement
CREATE INDEX idx_properties_published_partial ON properties(published_at DESC)
WHERE status = 'published';

-- Index partiel pour les notifications non lues
CREATE INDEX idx_notifications_unread_partial ON notifications(user_id, created_at DESC)
WHERE is_read = FALSE;
```

### 3. Indexes d'Expression

Les indexes d'expression permettent d'indexer des expressions calculées.

```sql
-- Index sur le prix converti en euros
CREATE INDEX idx_properties_price_eur ON properties((price / 655.95))
WHERE currency = 'XOF';

-- Index sur le nom en minuscule pour recherche insensible à la casse
CREATE INDEX idx_users_email_lower ON users(LOWER(email));
```

### 4. Indexes de Texte Complet (Full-Text Search)

Pour la recherche textuelle avancée, utiliser les indexes GIN avec pg_trgm.

```sql
-- Index de trigramme pour recherche textuelle
CREATE INDEX idx_properties_title_trgm ON properties USING GIN(title gin_trgm_ops);
CREATE INDEX idx_properties_description_trgm ON properties USING GIN(description gin_trgm_ops);

-- Recherche textuelle
SELECT * FROM properties
WHERE title % 'appartement moderne'
AND status = 'published';
```

### 5. Indexes de Hash

Les indexes de hash sont plus rapides pour les égalités simples mais ne supportent pas les comparaisons de plage.

```sql
-- Index de hash pour l'email (alternative à B-tree)
CREATE INDEX idx_users_email_hash ON users USING HASH(email);
```

---

## Maintenance des Indexes

### 1. Analyse des Indexes

Analyser régulièrement l'utilisation des indexes pour identifier ceux qui sont inutilisés.

```sql
-- Voir l'utilisation des indexes
SELECT schemaname, tablename, indexname, idx_scan, idx_tup_read, idx_tup_fetch
FROM pg_stat_user_indexes
ORDER BY idx_scan;

-- Voir les indexes non utilisés
SELECT schemaname, tablename, indexname
FROM pg_stat_user_indexes
WHERE idx_scan = 0
AND indexname NOT LIKE '%_pkey';
```

### 2. Rebuild des Indexes

Les indexes fragmentés doivent être rebuild pour restaurer les performances.

```sql
-- Rebuild d'un index
REINDEX INDEX idx_properties_landlord_status;

-- Rebuild de tous les indexes d'une table
REINDEX TABLE properties;
```

### 3. Vacuum et Analyze

Exécuter régulièrement VACUUM et ANALYZE pour optimiser les indexes.

```sql
-- Vacuum et analyse d'une table
VACUUM ANALYZE properties;

-- Vacuum complet de la base de données
VACUUM FULL ANALYZE;
```

### 4. Monitoring de la Taille des Indexes

Surveiller la taille des indexes pour éviter une croissance excessive.

```sql
-- Taille des indexes par table
SELECT schemaname, tablename, pg_size_pretty(pg_indexes_size(schemaname||'.'||tablename)) as size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_indexes_size(schemaname||'.'||tablename) DESC;
```

### 5. Suppression des Indexes Inutilisés

Supprimer les indexes qui ne sont pas utilisés pour améliorer les performances d'écriture.

```sql
-- Suppression d'un index inutilisé
DROP INDEX IF EXISTS idx_properties_unused;
```

---

## Bonnes Pratiques

### 1. Indexer les Clés Étrangères

Toujours indexer les clés étrangères pour optimiser les jointures.

### 2. Éviter les Indexes Redondants

Ne pas créer d'indexes qui sont des préfixes d'autres indexes.

### 3. Limiter le Nombre d'Indexes

Trop d'indexes peuvent ralentir les écritures. Créer uniquement les indexes nécessaires.

### 4. Utiliser des Indexes Composites

Pour les requêtes avec plusieurs conditions, les indexes composites sont plus efficaces.

### 5. Indexer les Colonnes de Tri

Les colonnes utilisées dans ORDER BY doivent être indexées.

### 6. Indexer les Colonnes de Filtrage

Les colonnes utilisées dans WHERE doivent être indexées si elles sont sélectives.

### 7. Utiliser des Indexes Partiels

Pour les tables avec beaucoup de données, les indexes partiels réduisent la taille.

### 8. Surveiller l'Utilisation

Utiliser pg_stat_user_indexes pour surveiller l'utilisation des indexes.

### 9. Rebuild Régulièrement

Rebuild les indexes fragmentés pour maintenir les performances.

### 10. Tester les Indexes

Toujours tester les indexes en environnement de test avant déploiement en production.
