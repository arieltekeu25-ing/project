# MLD - Modèle Logique de Données PostgreSQL

## Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Tables PostgreSQL](#tables-postgresql)
3. [Types de Données](#types-de-données)
4. [Indexes](#indexes)
5. [Contraintes](#contraintes)
6. [Triggers](#triggers)

---

## Vue d'ensemble

Le Modèle Logique de Données (MLD) traduit le MCD en tables PostgreSQL avec des types de données spécifiques, des indexes et des contraintes d'intégrité.

### PostgreSQL Version

- **Version minimum** : PostgreSQL 13+
- **Extensions requises** :
  - `uuid-ossp` : Pour la génération d'UUID
  - `postgis` : Pour les données géospatiales
  - `pg_trgm` : Pour la recherche textuelle

---

## Tables PostgreSQL

### users

**Description** : Table des utilisateurs du système.

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    photo_url TEXT,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(20) CHECK (gender IN ('masculine', 'feminine', 'other')),
    nationality CHAR(2),
    preferred_language CHAR(5) DEFAULT 'fr',
    role VARCHAR(20) NOT NULL CHECK (role IN ('client', 'landlord', 'admin')),
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended')),
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP WITH TIME ZONE
);

-- Indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_created_at ON users(created_at DESC);
CREATE INDEX idx_users_last_login_at ON users(last_login_at DESC);

-- Trigger pour updated_at
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

---

### profiles

**Description** : Profils étendus des utilisateurs.

```sql
CREATE TABLE profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    bio TEXT,
    website TEXT,
    linkedin TEXT,
    facebook TEXT,
    twitter TEXT,
    instagram TEXT,
    preferences JSONB,
    interests TEXT,
    is_public_profile BOOLEAN DEFAULT FALSE,
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_profiles_user_id ON profiles(user_id);
CREATE INDEX idx_profiles_status ON profiles(status);

-- Trigger pour updated_at
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

---

### clients

**Description** : Informations spécifiques aux clients.

```sql
CREATE TABLE clients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    id_number VARCHAR(50),
    id_type VARCHAR(20) CHECK (id_type IN ('CNI', 'passport', 'license')),
    profession VARCHAR(100),
    monthly_income DECIMAL(15, 2),
    employer VARCHAR(100),
    work_address TEXT,
    work_phone VARCHAR(20),
    guarantor_name VARCHAR(100),
    guarantor_phone VARCHAR(20),
    guarantor_address TEXT,
    documents JSONB,
    verification_status VARCHAR(20) DEFAULT 'pending' CHECK (verification_status IN ('pending', 'approved', 'rejected')),
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_clients_user_id ON clients(user_id);
CREATE INDEX idx_clients_verification_status ON clients(verification_status);
CREATE INDEX idx_clients_status ON clients(status);

-- Trigger pour updated_at
CREATE TRIGGER update_clients_updated_at
    BEFORE UPDATE ON clients
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

---

### landlords

**Description** : Informations spécifiques aux bailleurs.

```sql
CREATE TABLE landlords (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    company_name VARCHAR(255),
    registration_number VARCHAR(50),
    tax_id VARCHAR(50),
    headquarters_address TEXT,
    website TEXT,
    description TEXT,
    business_phone VARCHAR(20),
    business_email VARCHAR(255),
    properties JSONB,
    legal_documents JSONB,
    is_professional BOOLEAN DEFAULT FALSE,
    verification_status VARCHAR(20) DEFAULT 'pending' CHECK (verification_status IN ('pending', 'approved', 'rejected')),
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_landlords_user_id ON landlords(user_id);
CREATE INDEX idx_landlords_verification_status ON landlords(verification_status);
CREATE INDEX idx_landlords_status ON landlords(status);

-- Trigger pour updated_at
CREATE TRIGGER update_landlords_updated_at
    BEFORE UPDATE ON landlords
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

---

### admins

**Description** : Administrateurs système.

```sql
CREATE TABLE admins (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    permissions JSONB NOT NULL,
    mandat_expiry_date TIMESTAMP WITH TIME ZONE,
    superior_id UUID REFERENCES admins(id) ON DELETE SET NULL,
    is_super_admin BOOLEAN DEFAULT FALSE,
    department VARCHAR(100) NOT NULL,
    position VARCHAR(100),
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_admins_user_id ON admins(user_id);
CREATE INDEX idx_admins_department ON admins(department);
CREATE INDEX idx_admins_status ON admins(status);
CREATE INDEX idx_admins_superior_id ON admins(superior_id);

-- Trigger pour updated_at
CREATE TRIGGER update_admins_updated_at
    BEFORE UPDATE ON admins
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

---

### properties

**Description** : Logements avec toutes leurs caractéristiques.

```sql
CREATE TABLE properties (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    price DECIMAL(15, 2) NOT NULL CHECK (price > 0),
    deposit DECIMAL(15, 2) CHECK (deposit >= 0),
    advance DECIMAL(15, 2) CHECK (advance >= 0),
    currency CHAR(3) DEFAULT 'XOF',
    surface DECIMAL(10, 2) NOT NULL CHECK (surface > 0),
    bedrooms INTEGER NOT NULL CHECK (bedrooms >= 0),
    living_rooms INTEGER NOT NULL CHECK (living_rooms >= 0),
    kitchens INTEGER NOT NULL CHECK (kitchens >= 0),
    bathrooms INTEGER NOT NULL CHECK (bathrooms >= 0),
    toilets INTEGER NOT NULL CHECK (toilets >= 0),
    has_parking BOOLEAN DEFAULT FALSE,
    has_balcony BOOLEAN DEFAULT FALSE,
    has_terrace BOOLEAN DEFAULT FALSE,
    has_internet BOOLEAN DEFAULT FALSE,
    has_ac BOOLEAN DEFAULT FALSE,
    has_generator BOOLEAN DEFAULT FALSE,
    has_well BOOLEAN DEFAULT FALSE,
    pets_allowed BOOLEAN DEFAULT FALSE,
    location GEOGRAPHY(POINT, 4326),
    address_id UUID REFERENCES addresses(id) ON DELETE RESTRICT,
    landlord_id UUID NOT NULL REFERENCES landlords(id) ON DELETE RESTRICT,
    landlord_name VARCHAR(255) NOT NULL,
    landlord_phone VARCHAR(20) NOT NULL,
    category_id VARCHAR(50) NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
    category_name VARCHAR(100) NOT NULL,
    type_id VARCHAR(50) NOT NULL REFERENCES types(id) ON DELETE RESTRICT,
    type_name VARCHAR(100) NOT NULL,
    equipment_ids JSONB,
    photo_urls JSONB,
    video_urls JSONB,
    view_count INTEGER DEFAULT 0 CHECK (view_count >= 0),
    favorite_count INTEGER DEFAULT 0 CHECK (favorite_count >= 0),
    share_count INTEGER DEFAULT 0 CHECK (share_count >= 0),
    distance DECIMAL(10, 2),
    status VARCHAR(20) NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'paused', 'archived')),
    published_at TIMESTAMP WITH TIME ZONE,
    expiry_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_properties_landlord_id ON properties(landlord_id);
CREATE INDEX idx_properties_category_id ON properties(category_id);
CREATE INDEX idx_properties_type_id ON properties(type_id);
CREATE INDEX idx_properties_status ON properties(status);
CREATE INDEX idx_properties_published_at ON properties(published_at DESC);
CREATE INDEX idx_properties_price ON properties(price);
CREATE INDEX idx_properties_surface ON properties(surface);
CREATE INDEX idx_properties_bedrooms ON properties(bedrooms);
CREATE INDEX idx_properties_location ON properties USING GIST(location);
CREATE INDEX idx_properties_landlord_status ON properties(landlord_id, status);
CREATE INDEX idx_properties_category_status ON properties(category_id, status);
CREATE INDEX idx_properties_type_status ON properties(type_id, status);
CREATE INDEX idx_properties_status_published ON properties(status, published_at DESC);
CREATE INDEX idx_properties_price_status ON properties(price, status);
CREATE INDEX idx_properties_surface_status ON properties(surface, status);
CREATE INDEX idx_properties_bedrooms_status ON properties(bedrooms, status);

-- Trigger pour updated_at
CREATE TRIGGER update_properties_updated_at
    BEFORE UPDATE ON properties
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

---

### property_photos

**Description** : Photos des logements.

```sql
CREATE TABLE property_photos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
    url TEXT NOT NULL,
    thumbnail_url TEXT,
    description VARCHAR(255),
    order_num INTEGER DEFAULT 0 CHECK (order_num >= 0),
    is_primary BOOLEAN DEFAULT FALSE,
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_property_photos_property_id ON property_photos(property_id);
CREATE INDEX idx_property_photos_order ON property_photos(property_id, order_num);
CREATE INDEX idx_property_photos_primary ON property_photos(property_id, is_primary);

-- Trigger pour updated_at
CREATE TRIGGER update_property_photos_updated_at
    BEFORE UPDATE ON property_photos
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

---

### property_videos

**Description** : Vidéos des logements.

```sql
CREATE TABLE property_videos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
    url TEXT NOT NULL,
    thumbnail_url TEXT,
    description VARCHAR(255),
    duration INTEGER CHECK (duration >= 0),
    order_num INTEGER DEFAULT 0 CHECK (order_num >= 0),
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_property_videos_property_id ON property_videos(property_id);
CREATE INDEX idx_property_videos_order ON property_videos(property_id, order_num);

-- Trigger pour updated_at
CREATE TRIGGER update_property_videos_updated_at
    BEFORE UPDATE ON property_videos
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

---

### categories

**Description** : Catégories de logements.

```sql
CREATE TABLE categories (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    icon VARCHAR(100),
    order_num INTEGER DEFAULT 0 CHECK (order_num >= 0),
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_categories_order ON categories(order_num);
CREATE INDEX idx_categories_status ON categories(status);

-- Trigger pour updated_at
CREATE TRIGGER update_categories_updated_at
    BEFORE UPDATE ON categories
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

---

### types

**Description** : Types de logements.

```sql
CREATE TABLE types (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    icon VARCHAR(100),
    order_num INTEGER DEFAULT 0 CHECK (order_num >= 0),
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_types_order ON types(order_num);
CREATE INDEX idx_types_status ON types(status);

-- Trigger pour updated_at
CREATE TRIGGER update_types_updated_at
    BEFORE UPDATE ON types
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

---

### equipment

**Description** : Équipements disponibles.

```sql
CREATE TABLE equipment (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    icon VARCHAR(100),
    category VARCHAR(50),
    order_num INTEGER DEFAULT 0 CHECK (order_num >= 0),
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_equipment_category ON equipment(category);
CREATE INDEX idx_equipment_order ON equipment(category, order_num);
CREATE INDEX idx_equipment_status ON equipment(status);

-- Trigger pour updated_at
CREATE TRIGGER update_equipment_updated_at
    BEFORE UPDATE ON equipment
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

---

### cities

**Description** : Villes avec informations géographiques.

```sql
CREATE TABLE cities (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(20),
    country CHAR(2) NOT NULL,
    region VARCHAR(100),
    province VARCHAR(100),
    location GEOGRAPHY(POINT, 4326),
    population INTEGER CHECK (population >= 0),
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(name, country)
);

-- Indexes
CREATE INDEX idx_countries_name ON cities(name);
CREATE INDEX idx_countries_country ON cities(country);
CREATE INDEX idx_countries_status ON cities(status);
CREATE INDEX idx_countries_location ON cities USING GIST(location);

-- Trigger pour updated_at
CREATE TRIGGER update_cities_updated_at
    BEFORE UPDATE ON cities
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

---

### districts

**Description** : Quartiers rattachés aux villes.

```sql
CREATE TABLE districts (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    city_id VARCHAR(50) NOT NULL REFERENCES cities(id) ON DELETE CASCADE,
    city_name VARCHAR(100) NOT NULL,
    code VARCHAR(20),
    description TEXT,
    location GEOGRAPHY(POINT, 4326),
    population INTEGER CHECK (population >= 0),
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(city_id, name)
);

-- Indexes
CREATE INDEX idx_districts_city_id ON districts(city_id);
CREATE INDEX idx_districts_city_name ON districts(city_id, name);
CREATE INDEX idx_districts_status ON districts(status);

-- Trigger pour updated_at
CREATE TRIGGER update_districts_updated_at
    BEFORE UPDATE ON districts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

---

### addresses

**Description** : Adresses physiques avec coordonnées GPS.

```sql
CREATE TABLE addresses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    street VARCHAR(255) NOT NULL,
    number VARCHAR(20),
    complement VARCHAR(255),
    postal_code VARCHAR(20) NOT NULL,
    city_id VARCHAR(50) NOT NULL REFERENCES cities(id) ON DELETE RESTRICT,
    city_name VARCHAR(100) NOT NULL,
    district_id VARCHAR(50) REFERENCES districts(id) ON DELETE SET NULL,
    district_name VARCHAR(100),
    location GEOGRAPHY(POINT, 4326) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_addresses_city_id ON addresses(city_id);
CREATE INDEX idx_addresses_district_id ON addresses(district_id);
CREATE INDEX idx_addresses_status ON addresses(status);
CREATE INDEX idx_addresses_location ON addresses USING GIST(location);

-- Trigger pour updated_at
CREATE TRIGGER update_addresses_updated_at
    BEFORE UPDATE ON addresses
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

---

### favorites

**Description** : Favoris utilisateurs pour les logements.

```sql
CREATE TABLE favorites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
    property_title VARCHAR(255) NOT NULL,
    property_price DECIMAL(15, 2) NOT NULL,
    property_location GEOGRAPHY(POINT, 4326),
    notes TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, property_id)
);

-- Indexes
CREATE INDEX idx_favorites_user_id ON favorites(user_id);
CREATE INDEX idx_favorites_property_id ON favorites(property_id);
CREATE INDEX idx_favorites_user_property ON favorites(user_id, property_id);
CREATE INDEX idx_favorites_created_at ON favorites(created_at DESC);

-- Trigger pour updated_at
CREATE TRIGGER update_favorites_updated_at
    BEFORE UPDATE ON favorites
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

---

### reviews

**Description** : Avis et évaluations des logements.

```sql
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    user_name VARCHAR(255) NOT NULL,
    property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
    property_title VARCHAR(255) NOT NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    landlord_response TEXT,
    response_date TIMESTAMP WITH TIME ZONE,
    is_verified BOOLEAN DEFAULT FALSE,
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, property_id)
);

-- Indexes
CREATE INDEX idx_reviews_user_id ON reviews(user_id);
CREATE INDEX idx_reviews_property_id ON reviews(property_id);
CREATE INDEX idx_reviews_user_property ON reviews(user_id, property_id);
CREATE INDEX idx_reviews_property_rating ON reviews(property_id, rating DESC);
CREATE INDEX idx_reviews_created_at ON reviews(created_at DESC);

-- Trigger pour updated_at
CREATE TRIGGER update_reviews_updated_at
    BEFORE UPDATE ON reviews
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

---

### conversations

**Description** : Conversations entre utilisateurs.

```sql
CREATE TABLE conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    participant1_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    participant1_name VARCHAR(255) NOT NULL,
    participant2_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    participant2_name VARCHAR(255) NOT NULL,
    property_id UUID REFERENCES properties(id) ON DELETE SET NULL,
    property_title VARCHAR(255),
    last_message TEXT,
    last_message_at TIMESTAMP WITH TIME ZONE,
    message_count INTEGER DEFAULT 0 CHECK (message_count >= 0),
    unread_count INTEGER DEFAULT 0 CHECK (unread_count >= 0),
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'archived')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_conversations_participant1_id ON conversations(participant1_id);
CREATE INDEX idx_conversations_participant2_id ON conversations(participant2_id);
CREATE INDEX idx_conversations_property_id ON conversations(property_id);
CREATE INDEX idx_conversations_last_message_at ON conversations(last_message_at DESC);
CREATE INDEX idx_conversations_participant1_status ON conversations(participant1_id, status);
CREATE INDEX idx_conversations_participant2_status ON conversations(participant2_id, status);
CREATE INDEX idx_conversations_property_status ON conversations(property_id, status);
CREATE INDEX idx_conversations_participant1_last ON conversations(participant1_id, last_message_at DESC);
CREATE INDEX idx_conversations_participant2_last ON conversations(participant2_id, last_message_at DESC);

-- Trigger pour updated_at
CREATE TRIGGER update_conversations_updated_at
    BEFORE UPDATE ON conversations
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

---

### messages

**Description** : Messages dans une conversation.

```sql
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    sender_name VARCHAR(255) NOT NULL,
    recipient_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    attachment_url TEXT,
    type VARCHAR(20) NOT NULL DEFAULT 'text' CHECK (type IN ('text', 'image', 'document')),
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP WITH TIME ZONE,
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'deleted')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_messages_conversation_id ON messages(conversation_id);
CREATE INDEX idx_messages_conversation_created ON messages(conversation_id, created_at DESC);
CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_messages_sender_created ON messages(sender_id, created_at DESC);
CREATE INDEX idx_messages_recipient_id ON messages(recipient_id);
CREATE INDEX idx_messages_recipient_read ON messages(recipient_id, is_read);
CREATE INDEX idx_messages_recipient_created ON messages(recipient_id, created_at DESC);

-- Trigger pour updated_at
CREATE TRIGGER update_messages_updated_at
    BEFORE UPDATE ON messages
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

---

### notifications

**Description** : Notifications utilisateurs.

```sql
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    link TEXT,
    type VARCHAR(50) NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP WITH TIME ZONE,
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'archived')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_user_read ON notifications(user_id, is_read);
CREATE INDEX idx_notifications_user_created ON notifications(user_id, created_at DESC);
CREATE INDEX idx_notifications_type ON notifications(type);
CREATE INDEX idx_notifications_type_created ON notifications(type, created_at DESC);

-- Trigger pour updated_at
CREATE TRIGGER update_notifications_updated_at
    BEFORE UPDATE ON notifications
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

---

### visits

**Description** : Visites programmées pour les logements.

```sql
CREATE TABLE visits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
    property_title VARCHAR(255) NOT NULL,
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    client_name VARCHAR(255) NOT NULL,
    landlord_id UUID NOT NULL REFERENCES landlords(id) ON DELETE CASCADE,
    landlord_name VARCHAR(255) NOT NULL,
    visit_date DATE NOT NULL CHECK (visit_date >= CURRENT_DATE),
    start_time TIME,
    end_time TIME,
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'cancelled', 'completed')),
    notes TEXT,
    feedback TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_visits_property_id ON visits(property_id);
CREATE INDEX idx_visits_client_id ON visits(client_id);
CREATE INDEX idx_visits_landlord_id ON visits(landlord_id);
CREATE INDEX idx_visits_visit_date ON visits(visit_date);
CREATE INDEX idx_visits_status_date ON visits(status, visit_date);
CREATE INDEX idx_visits_client_date ON visits(client_id, visit_date);
CREATE INDEX idx_visits_landlord_date ON visits(landlord_id, visit_date);
CREATE INDEX idx_visits_property_date ON visits(property_id, visit_date);
CREATE INDEX idx_visits_client_status ON visits(client_id, status);
CREATE INDEX idx_visits_landlord_status ON visits(landlord_id, status);

-- Trigger pour updated_at
CREATE TRIGGER update_visits_updated_at
    BEFORE UPDATE ON visits
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

---

### visit_schedules

**Description** : Planning des créneaux de visite des bailleurs.

```sql
CREATE TABLE visit_schedules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    landlord_id UUID NOT NULL REFERENCES landlords(id) ON DELETE CASCADE,
    property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
    slots JSONB NOT NULL,
    instructions TEXT,
    visit_duration INTEGER DEFAULT 30 CHECK (visit_duration > 0),
    booking_lead_time INTEGER DEFAULT 24 CHECK (booking_lead_time >= 0),
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_visit_schedules_landlord_id ON visit_schedules(landlord_id);
CREATE INDEX idx_visit_schedules_property_id ON visit_schedules(property_id);
CREATE INDEX idx_visit_schedules_landlord_status ON visit_schedules(landlord_id, status);
CREATE INDEX idx_visit_schedules_property_status ON visit_schedules(property_id, status);

-- Trigger pour updated_at
CREATE TRIGGER update_visit_schedules_updated_at
    BEFORE UPDATE ON visit_schedules
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

---

### reports

**Description** : Signalements de contenu inapproprié.

```sql
CREATE TABLE reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    author_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    entity_id UUID NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    reason VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'resolved', 'rejected')),
    admin_response TEXT,
    processed_at TIMESTAMP WITH TIME ZONE,
    processed_by UUID REFERENCES admins(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_reports_author_id ON reports(author_id);
CREATE INDEX idx_reports_entity ON reports(entity_id, entity_type);
CREATE INDEX idx_reports_entity_status ON reports(entity_id, entity_type, status);
CREATE INDEX idx_reports_status_created ON reports(status, created_at DESC);

-- Trigger pour updated_at
CREATE TRIGGER update_reports_updated_at
    BEFORE UPDATE ON reports
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

---

### verification_documents

**Description** : Documents de vérification utilisateur.

```sql
CREATE TABLE verification_documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    document_type VARCHAR(50) NOT NULL,
    document_number VARCHAR(100) NOT NULL,
    document_url TEXT,
    front_url TEXT,
    back_url TEXT,
    expiry_date DATE NOT NULL,
    verification_status VARCHAR(20) DEFAULT 'pending' CHECK (verification_status IN ('pending', 'approved', 'rejected')),
    comment TEXT,
    verified_at TIMESTAMP WITH TIME ZONE,
    verified_by UUID REFERENCES admins(id) ON DELETE SET NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'expired')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_verification_documents_user_id ON verification_documents(user_id);
CREATE INDEX idx_verification_documents_verification_status ON verification_documents(verification_status);
CREATE INDEX idx_verification_documents_status ON verification_documents(status);
CREATE INDEX idx_verification_documents_expiry_date ON verification_documents(expiry_date);
CREATE INDEX idx_verification_documents_expiry_status ON verification_documents(expiry_date, status);

-- Trigger pour updated_at
CREATE TRIGGER update_verification_documents_updated_at
    BEFORE UPDATE ON verification_documents
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

---

### searches

**Description** : Historique des recherches utilisateurs.

```sql
CREATE TABLE searches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    query TEXT,
    category_id VARCHAR(50) REFERENCES categories(id) ON DELETE SET NULL,
    type_id VARCHAR(50) REFERENCES types(id) ON DELETE SET NULL,
    min_price DECIMAL(15, 2),
    max_price DECIMAL(15, 2),
    min_surface DECIMAL(10, 2),
    max_surface DECIMAL(10, 2),
    min_bedrooms INTEGER,
    max_bedrooms INTEGER,
    city_id VARCHAR(50) REFERENCES cities(id) ON DELETE SET NULL,
    district_id VARCHAR(50) REFERENCES districts(id) ON DELETE SET NULL,
    location GEOGRAPHY(POINT, 4326),
    radius DECIMAL(10, 2),
    equipment_ids JSONB,
    result_count INTEGER DEFAULT 0 CHECK (result_count >= 0),
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_searches_user_id ON searches(user_id);
CREATE INDEX idx_searches_user_created ON searches(user_id, created_at DESC);
CREATE INDEX idx_searches_category_id ON searches(category_id);
CREATE INDEX idx_searches_type_id ON searches(type_id);
CREATE INDEX idx_searches_city_id ON searches(city_id);
CREATE INDEX idx_searches_category_created ON searches(category_id, created_at DESC);

-- Trigger pour updated_at
CREATE TRIGGER update_searches_updated_at
    BEFORE UPDATE ON searches
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

---

### saved_searches

**Description** : Recherches sauvegardées par les utilisateurs.

```sql
CREATE TABLE saved_searches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    query TEXT,
    category_id VARCHAR(50) REFERENCES categories(id) ON DELETE SET NULL,
    type_id VARCHAR(50) REFERENCES types(id) ON DELETE SET NULL,
    min_price DECIMAL(15, 2),
    max_price DECIMAL(15, 2),
    min_surface DECIMAL(10, 2),
    max_surface DECIMAL(10, 2),
    min_bedrooms INTEGER,
    max_bedrooms INTEGER,
    city_id VARCHAR(50) REFERENCES cities(id) ON DELETE SET NULL,
    district_id VARCHAR(50) REFERENCES districts(id) ON DELETE SET NULL,
    location GEOGRAPHY(POINT, 4326),
    radius DECIMAL(10, 2),
    equipment_ids JSONB,
    alert_enabled BOOLEAN DEFAULT FALSE,
    alert_frequency VARCHAR(20) DEFAULT 'immediate' CHECK (alert_frequency IN ('immediate', 'daily', 'weekly')),
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_saved_searches_user_id ON saved_searches(user_id);
CREATE INDEX idx_saved_searches_user_alert ON saved_searches(user_id, alert_enabled);
CREATE INDEX idx_saved_searches_user_status ON saved_searches(user_id, status);

-- Trigger pour updated_at
CREATE TRIGGER update_saved_searches_updated_at
    BEFORE UPDATE ON saved_searches
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

---

### chatbot_conversations

**Description** : Conversations avec le chatbot.

```sql
CREATE TABLE chatbot_conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255),
    context TEXT,
    last_interaction_at TIMESTAMP WITH TIME ZONE,
    message_count INTEGER DEFAULT 0 CHECK (message_count >= 0),
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'archived')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_chatbot_conversations_user_id ON chatbot_conversations(user_id);
CREATE INDEX idx_chatbot_conversations_user_status ON chatbot_conversations(user_id, status);
CREATE INDEX idx_chatbot_conversations_user_last ON chatbot_conversations(user_id, last_interaction_at DESC);

-- Trigger pour updated_at
CREATE TRIGGER update_chatbot_conversations_updated_at
    BEFORE UPDATE ON chatbot_conversations
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

---

### chatbot_messages

**Description** : Messages du chatbot.

```sql
CREATE TABLE chatbot_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID NOT NULL REFERENCES chatbot_conversations(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('user', 'assistant')),
    context TEXT,
    data JSONB,
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_chatbot_messages_conversation_id ON chatbot_messages(conversation_id);
CREATE INDEX idx_chatbot_messages_conversation_created ON chatbot_messages(conversation_id, created_at DESC);
CREATE INDEX idx_chatbot_messages_role ON chatbot_messages(role);
CREATE INDEX idx_chatbot_messages_role_created ON chatbot_messages(role, created_at DESC);

-- Trigger pour updated_at
CREATE TRIGGER update_chatbot_messages_updated_at
    BEFORE UPDATE ON chatbot_messages
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

---

### user_settings

**Description** : Paramètres et préférences utilisateur.

```sql
CREATE TABLE user_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    language CHAR(5) DEFAULT 'fr',
    timezone VARCHAR(50) DEFAULT 'Africa/Abidjan',
    email_notifications BOOLEAN DEFAULT TRUE,
    push_notifications BOOLEAN DEFAULT TRUE,
    sms_notifications BOOLEAN DEFAULT FALSE,
    public_profile BOOLEAN DEFAULT FALSE,
    share_location BOOLEAN DEFAULT FALSE,
    theme VARCHAR(20) DEFAULT 'light' CHECK (theme IN ('light', 'dark')),
    newsletter_frequency VARCHAR(20) DEFAULT 'immediate' CHECK (newsletter_frequency IN ('immediate', 'daily', 'weekly')),
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_user_settings_user_id ON user_settings(user_id);

-- Trigger pour updated_at
CREATE TRIGGER update_user_settings_updated_at
    BEFORE UPDATE ON user_settings
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

---

### user_sessions

**Description** : Sessions utilisateur avec tokens.

```sql
CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    access_token TEXT NOT NULL,
    refresh_token TEXT NOT NULL,
    start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date TIMESTAMP WITH TIME ZONE,
    device_id VARCHAR(255),
    ip_address VARCHAR(45),
    user_agent TEXT,
    location VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'expired', 'revoked')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX idx_user_sessions_access_token ON user_sessions(access_token);
CREATE INDEX idx_user_sessions_refresh_token ON user_sessions(refresh_token);
CREATE INDEX idx_user_sessions_status ON user_sessions(status);

-- Trigger pour updated_at
CREATE TRIGGER update_user_sessions_updated_at
    BEFORE UPDATE ON user_sessions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

---

### audit_logs

**Description** : Logs d'audit du système.

```sql
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action_type VARCHAR(50) NOT NULL,
    description TEXT,
    entity_id UUID,
    entity_type VARCHAR(50),
    data JSONB,
    ip_address VARCHAR(45),
    user_agent TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_action_type ON audit_logs(action_type);
CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_id, entity_type);
CREATE INDEX idx_audit_logs_entity_created ON audit_logs(entity_id, entity_type, created_at DESC);
CREATE INDEX idx_audit_logs_user_created ON audit_logs(user_id, created_at DESC);
CREATE INDEX idx_audit_logs_action_created ON audit_logs(action_type, created_at DESC);

-- Trigger pour updated_at
CREATE TRIGGER update_audit_logs_updated_at
    BEFORE UPDATE ON audit_logs
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

---

## Types de Données

### Types PostgreSQL Utilisés

| Type PostgreSQL | Description | Utilisation |
|----------------|-------------|-------------|
| UUID | Identifiant unique | Clés primaires |
| VARCHAR(n) | Chaîne de caractères variable | Textes courts |
| TEXT | Chaîne de caractères illimitée | Textes longs |
| INTEGER | Entier 4 octets | Compteurs |
| DECIMAL(m, n) | Nombre décimal précis | Prix, montants |
| BOOLEAN | Booléen | Flags |
| DATE | Date | Dates sans heure |
| TIMESTAMP WITH TIME ZONE | Date et heure avec timezone | Timestamps |
| CHAR(n) | Chaîne fixe | Codes ISO |
| JSONB | JSON binaire | Données structurées |
| GEOGRAPHY(POINT, 4326) | Point géospatial (WGS84) | Localisations |

### Conventions de Types

- **UUID** : Pour toutes les clés primaires (sauf tables de référence)
- **VARCHAR(255)** : Pour les champs texte courts (noms, emails, URLs)
- **TEXT** : Pour les champs texte longs (descriptions, commentaires)
- **DECIMAL(15, 2)** : Pour les montants monétaires
- **DECIMAL(10, 2)** : Pour les surfaces et dimensions
- **INTEGER** : Pour les compteurs et nombres entiers
- **BOOLEAN** : Pour les flags (true/false)
- **DATE** : Pour les dates sans heure
- **TIMESTAMP WITH TIME ZONE** : Pour les dates avec heure
- **CHAR(2)** : Pour les codes pays ISO
- **CHAR(5)** : Pour les codes langue ISO
- **CHAR(3)** : Pour les codes devise ISO
- **JSONB** : Pour les données structurées flexibles
- **GEOGRAPHY(POINT, 4326)** : Pour les coordonnées GPS (latitude/longitude)

---

## Indexes

### Indexes Single Field

Les indexes single field sont créés pour les champs fréquemment utilisés dans les filtres et les tris.

### Indexes Composites

Les indexes composites sont créés pour optimiser les requêtes avec plusieurs conditions.

### Indexes GIST (Geospatial)

Les indexes GIST sont créés pour les requêtes géospatiales sur les champs GEOGRAPHY.

### Indexes GIN (JSONB)

Les indexes GIN peuvent être ajoutés pour les champs JSONB si nécessaire.

```sql
-- Exemple d'index GIN pour JSONB
CREATE INDEX idx_properties_equipment_gin ON properties USING GIN(equipment_ids);
```

---

## Contraintes

### Contraintes de Clé Primaire

Toutes les tables ont une clé primaire `id`.

### Contraintes de Clé Étrangère

Les clés étrangères ont les actions suivantes :
- `ON DELETE CASCADE` : Suppression en cascade (relations fortes)
- `ON DELETE RESTRICT` : Empêche la suppression (relations critiques)
- `ON DELETE SET NULL` : Met à NULL (relations optionnelles)

### Contraintes d'Unicité

Les contraintes d'unicité garantissent l'absence de doublons.

### Contraintes CHECK

Les contraintes CHECK valident les valeurs autorisées.

### Contraintes NOT NULL

Les contraintes NOT NULL garantissent la présence de données.

---

## Triggers

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

### Triggers Automatiques

Chaque table a un trigger qui appelle `update_updated_at_column()` avant chaque UPDATE.

### Triggers Personnalisés

Des triggers personnalisés peuvent être ajoutés pour :
- Incrémenter les compteurs (view_count, favorite_count)
- Mettre à jour les champs dénormalisés
- Logger les modifications
- Envoyer des notifications

---

## Fonctions PostgreSQL

### Fonction de Génération d'UUID

```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

### Fonction de Recherche Textuelle

```sql
CREATE EXTENSION IF NOT EXISTS pg_trgm;
```

### Fonction Géospatiale

```sql
CREATE EXTENSION IF NOT EXISTS postgis;
```

---

## Vue d'Ensemble des Tables

| Table | Lignes estimées | Taille estimée | Croissance |
|-------|----------------|----------------|------------|
| users | 100k+ | 50 MB | Rapide |
| profiles | 100k+ | 30 MB | Rapide |
| clients | 80k+ | 40 MB | Rapide |
| landlords | 20k+ | 20 MB | Modérée |
| admins | 100+ | 1 MB | Lente |
| properties | 50k+ | 200 MB | Rapide |
| property_photos | 500k+ | 100 MB | Rapide |
| property_videos | 50k+ | 50 MB | Rapide |
| categories | 20 | 10 KB | Nulle |
| types | 10 | 5 KB | Nulle |
| equipment | 50 | 20 KB | Nulle |
| cities | 100+ | 1 MB | Lente |
| districts | 500+ | 5 MB | Lente |
| addresses | 50k+ | 50 MB | Rapide |
| favorites | 200k+ | 50 MB | Rapide |
| reviews | 100k+ | 50 MB | Rapide |
| conversations | 300k+ | 100 MB | Rapide |
| messages | 5M+ | 2 GB | Rapide |
| notifications | 10M+ | 500 MB | Rapide |
| visits | 200k+ | 50 MB | Rapide |
| visit_schedules | 20k+ | 20 MB | Modérée |
| reports | 10k+ | 20 MB | Modérée |
| verification_documents | 100k+ | 100 MB | Rapide |
| searches | 5M+ | 500 MB | Rapide |
| saved_searches | 200k+ | 50 MB | Rapide |
| chatbot_conversations | 100k+ | 30 MB | Rapide |
| chatbot_messages | 2M+ | 500 MB | Rapide |
| user_settings | 100k+ | 20 MB | Rapide |
| user_sessions | 1M+ | 200 MB | Rapide |
| audit_logs | 10M+ | 2 GB | Rapide |

**Total estimé** : ~7 GB pour 100k utilisateurs
