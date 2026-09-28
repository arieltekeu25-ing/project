# Database Security - GestionBailleur PostgreSQL

## Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Protection des Données Personnelles](#protection-des-données-personnelles)
3. [Hash des Mots de Passe](#hash-des-mots-de-passe)
4. [Gestion des Permissions](#gestion-des-permissions)
5. [Audit et Logging](#audit-et-logging)
6. [Sauvegardes](#sauvegardes)
7. [Restauration](#restauration)
8. [Chiffrement des Données Sensibles](#chiffrement-des-données-sensibles)
9. [Sécurité Réseau](#sécurité-réseau)
10. [Monitoring et Alertes](#monitoring-et-alertes)

---

## Vue d'ensemble

La sécurité de la base de données PostgreSQL est critique pour protéger les données personnelles des utilisateurs et garantir la conformité avec les réglementations (RGPD, etc.).

### Principes de Sécurité

- **Principe du moindre privilège** : Chaque utilisateur a uniquement les permissions nécessaires
- **Défense en profondeur** : Plusieurs couches de sécurité
- **Audit complet** : Toutes les opérations sont tracées
- **Chiffrement** : Données sensibles chiffrées au repos et en transit
- **Sauvegardes régulières** : Sauvegardes automatisées et testées

---

## Protection des Données Personnelles

### Données Personnelles Identifiables (PII)

Les données personnelles suivantes doivent être protégées :

| Donnée | Table | Sensibilité | Protection |
|--------|-------|-------------|------------|
| Email | users | Haute | Chiffrement, accès restreint |
| Téléphone | users | Haute | Chiffrement, accès restreint |
| Date de naissance | users | Haute | Chiffrement, accès restreint |
| Numéro d'identité | clients | Très haute | Chiffrement fort, accès très restreint |
| Revenu mensuel | clients | Haute | Chiffrement, accès restreint |
| Adresse professionnelle | clients | Haute | Chiffrement, accès restreint |
| Numéro fiscal | landlords | Très haute | Chiffrement fort, accès très restreint |
| Adresse du siège | landlords | Haute | Chiffrement, accès restreint |
| Adresse IP | user_sessions, audit_logs | Moyenne | Anonymisation possible |
| Localisation GPS | properties, searches | Haute | Chiffrement, accès restreint |

### Conformité RGPD

- **Droit à l'oubli** : Possibilité de supprimer toutes les données d'un utilisateur
- **Portabilité des données** : Export des données utilisateur
- **Consentement** : Consentement explicite pour le traitement des données
- **Minimisation des données** : Collecter uniquement les données nécessaires
- **Limitation de la conservation** : Suppression automatique des données obsolètes

### Anonymisation des Données

Pour l'analyse et les statistiques, utiliser des données anonymisées :

```sql
-- Anonymisation des emails pour les statistiques
UPDATE users 
SET email = CONCAT('user_', id, '@anonymized.com')
WHERE anonymized = TRUE;

-- Anonymisation des téléphones
UPDATE users 
SET phone = CONCAT('+000', SUBSTRING(phone, 6))
WHERE anonymized = TRUE;
```

---

## Hash des Mots de Passe

### Algorithme de Hash

Utiliser bcrypt ou Argon2 pour le hash des mots de passe :

```python
import bcrypt

def hash_password(password: str) -> str:
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(password.encode('utf-8'), salt)
    return hashed.decode('utf-8')

def verify_password(password: str, hashed: str) -> bool:
    return bcrypt.checkpw(password.encode('utf-8'), hashed.encode('utf-8'))
```

### Stockage du Hash

Le hash du mot de passe est stocké dans la table `users` (colonne `password_hash`).

```sql
ALTER TABLE users 
ADD COLUMN password_hash VARCHAR(255) NOT NULL;

-- Le mot de passe en clair n'est JAMAIS stocké
```

### Politique de Mot de Passe

- **Longueur minimum** : 12 caractères
- **Complexité** : Au moins une majuscule, une minuscule, un chiffre, un caractère spécial
- **Expiration** : Renouvellement recommandé tous les 90 jours
- **Historique** : Ne pas réutiliser les 5 derniers mots de passe

```python
import re

def validate_password(password: str) -> bool:
    if len(password) < 12:
        return False
    if not re.search(r'[A-Z]', password):
        return False
    if not re.search(r'[a-z]', password):
        return False
    if not re.search(r'[0-9]', password):
        return False
    if not re.search(r'[^A-Za-z0-9]', password):
        return False
    return True
```

---

## Gestion des Permissions

### Rôles PostgreSQL

Créer des rôles PostgreSQL avec des permissions spécifiques :

```sql
-- Rôle d'application (accès limité)
CREATE ROLE gestionbailleur_app WITH LOGIN PASSWORD 'secure_password';

-- Rôle d'admin (accès complet)
CREATE ROLE gestionbailleur_admin WITH LOGIN PASSWORD 'very_secure_password';

-- Rôle de lecture seule (pour les rapports)
CREATE ROLE gestionbailleur_readonly WITH LOGIN PASSWORD 'read_password';
```

### Permissions par Rôle

#### gestionbailleur_app (Application)

```sql
-- Permissions SELECT sur toutes les tables
GRANT SELECT ON ALL TABLES IN SCHEMA public TO gestionbailleur_app;

-- Permissions INSERT, UPDATE sur les tables nécessaires
GRANT INSERT, UPDATE ON users TO gestionbailleur_app;
GRANT INSERT, UPDATE ON profiles TO gestionbailleur_app;
GRANT INSERT, UPDATE ON clients TO gestionbailleur_app;
GRANT INSERT, UPDATE ON landlords TO gestionbailleur_app;
GRANT INSERT, UPDATE ON properties TO gestionbailleur_app;
GRANT INSERT, UPDATE ON property_photos TO gestionbailleur_app;
GRANT INSERT, UPDATE ON property_videos TO gestionbailleur_app;
GRANT INSERT, UPDATE ON favorites TO gestionbailleur_app;
GRANT INSERT, UPDATE ON reviews TO gestionbailleur_app;
GRANT INSERT, UPDATE ON conversations TO gestionbailleur_app;
GRANT INSERT, UPDATE ON messages TO gestionbailleur_app;
GRANT INSERT, UPDATE ON notifications TO gestionbailleur_app;
GRANT INSERT, UPDATE ON visits TO gestionbailleur_app;
GRANT INSERT, UPDATE ON visit_schedules TO gestionbailleur_app;
GRANT INSERT, UPDATE ON reports TO gestionbailleur_app;
GRANT INSERT, UPDATE ON searches TO gestionbailleur_app;
GRANT INSERT, UPDATE ON saved_searches TO gestionbailleur_app;
GRANT INSERT, UPDATE ON chatbot_conversations TO gestionbailleur_app;
GRANT INSERT, UPDATE ON chatbot_messages TO gestionbailleur_app;
GRANT INSERT, UPDATE ON user_settings TO gestionbailleur_app;
GRANT INSERT, UPDATE ON user_sessions TO gestionbailleur_app;

-- Permissions DELETE sur les tables nécessaires
GRANT DELETE ON user_sessions TO gestionbailleur_app;
GRANT DELETE ON favorites TO gestionbailleur_app;
GRANT DELETE ON reviews TO gestionbailleur_app;

-- Permissions sur les séquences
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO gestionbailleur_app;
```

#### gestionbailleur_admin (Administrateur)

```sql
-- Permissions complètes sur toutes les tables
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO gestionbailleur_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO gestionbailleur_admin;
```

#### gestionbailleur_readonly (Lecture seule)

```sql
-- Permissions SELECT uniquement
GRANT SELECT ON ALL TABLES IN SCHEMA public TO gestionbailleur_readonly;
```

### Row-Level Security (RLS)

Utiliser RLS pour restreindre l'accès au niveau des lignes :

```sql
-- Activer RLS sur la table users
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Politique : Les utilisateurs ne peuvent voir que leur propre profil
CREATE POLICY user_isolation ON users
    FOR SELECT
    USING (id = current_setting('app.current_user_id')::UUID);

-- Politique : Les admins peuvent voir tous les utilisateurs
CREATE POLICY admin_all_users ON users
    FOR ALL
    TO gestionbailleur_admin
    USING (TRUE);
```

### Permissions au Niveau Application

Les permissions au niveau métier sont gérées dans l'application Django via :

- **Django Permissions** : Permissions par modèle
- **Django Groups** : Groupes d'utilisateurs
- **Custom Permissions** : Permissions personnalisées

```python
# Exemple de permissions Django
class Property(models.Model):
    class Meta:
        permissions = [
            ('can_publish_property', 'Can publish property'),
            ('can_edit_any_property', 'Can edit any property'),
            ('can_delete_any_property', 'Can delete any property'),
        ]
```

---

## Audit et Logging

### Audit Trail

Toutes les opérations critiques doivent être tracées dans la table `audit_logs` :

```sql
-- Structure de la table audit_logs (déjà définie dans MLD)
-- id, user_id, action_type, description, entity_id, entity_type, data, ip_address, user_agent, status, created_at, updated_at
```

### Actions à Auditer

| Action Type | Description | Niveau |
|-------------|-------------|--------|
| user_login | Connexion utilisateur | Info |
| user_logout | Déconnexion utilisateur | Info |
| user_register | Inscription utilisateur | Info |
| user_update | Modification utilisateur | Warning |
| user_delete | Suppression utilisateur | Critical |
| property_create | Création logement | Info |
| property_update | Modification logement | Warning |
| property_delete | Suppression logement | Critical |
| property_publish | Publication logement | Info |
| property_unpublish | Dépublication logement | Warning |
| favorite_add | Ajout favori | Info |
| favorite_remove | Suppression favori | Info |
| review_create | Création avis | Info |
| review_delete | Suppression avis | Warning |
| message_send | Envoi message | Info |
| message_delete | Suppression message | Warning |
| visit_create | Création visite | Info |
| visit_update | Modification visite | Warning |
| visit_delete | Suppression visite | Critical |
| report_create | Création signalement | Warning |
| report_resolve | Résolution signalement | Info |
| admin_action | Action admin | Critical |
| data_export | Export de données | Warning |
| data_import | Import de données | Critical |

### Logging PostgreSQL

Activer le logging PostgreSQL pour tracer toutes les requêtes :

```sql
-- Configuration postgresql.conf
logging_collector = on
log_directory = 'pg_log'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_min_duration_statement = 1000  # Log les requêtes > 1s
log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h '
log_checkpoints = on
log_connections = on
log_disconnections = on
log_duration = on
log_lock_waits = on
log_statement = all  # Log toutes les requêtes
```

### Audit Automatisé via Triggers

Créer des triggers pour l'audit automatique :

```sql
-- Fonction d'audit
CREATE OR REPLACE FUNCTION audit_trigger_func()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_logs (
        user_id,
        action_type,
        description,
        entity_id,
        entity_type,
        data,
        ip_address,
        user_agent,
        status,
        created_at,
        updated_at
    ) VALUES (
        current_setting('app.current_user_id', true)::UUID,
        TG_OP,
        CONCAT(TG_OP, ' on ', TG_TABLE_NAME),
        NEW.id,
        TG_TABLE_NAME,
        row_to_json(NEW),
        current_setting('app.client_ip', true),
        current_setting('app.user_agent', true),
        'active',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger sur la table users
CREATE TRIGGER users_audit_trigger
    AFTER INSERT OR UPDATE OR DELETE ON users
    FOR EACH ROW
    EXECUTE FUNCTION audit_trigger_func();

-- Trigger sur la table properties
CREATE TRIGGER properties_audit_trigger
    AFTER INSERT OR UPDATE OR DELETE ON properties
    FOR EACH ROW
    EXECUTE FUNCTION audit_trigger_func();
```

---

## Sauvegardes

### Stratégie de Sauvegarde

| Type | Fréquence | Rétention | Emplacement |
|------|-----------|-----------|-------------|
| Complète | Quotidienne (nuit) | 30 jours | Cloud (S3) |
| Différentielle | Toutes les 4 heures | 7 jours | Cloud (S3) |
| WAL (Write-Ahead Log) | Continu | 2 jours | Cloud (S3) |
| Snapshot hebdomadaire | Hebdomadaire | 12 semaines | Cloud (S3) |
| Snapshot mensuel | Mensuel | 12 mois | Cloud (S3) |

### Sauvegarde avec pg_dump

```bash
# Sauvegarde complète
pg_dump -h localhost -U gestionbailleur_admin -d gestionbailleur \
  -F c -f /backups/gestionbailleur_$(date +%Y%m%d).dump

# Sauvegarde schéma uniquement
pg_dump -h localhost -U gestionbailleur_admin -d gestionbailleur \
  --schema-only -f /backups/gestionbailleur_schema_$(date +%Y%m%d).sql

# Sauvegarde données uniquement
pg_dump -h localhost -U gestionbailleur_admin -d gestionbailleur \
  --data-only -f /backups/gestionbailleur_data_$(date +%Y%m%d).sql
```

### Sauvegarde avec pgBackRest

```bash
# Installation de pgBackRest
sudo apt-get install pgbackrest

# Configuration /etc/pgbackrest/pgbackrest.conf
[gestionbailleur]
pg1-path=/var/lib/postgresql/14/main
pg1-port=5432
pg1-socket-path=/var/run/postgresql

[global]
repo1-type=s3
repo1-path=/gestionbailleur-backup
repo1-s3-bucket=gestionbailleur-backups
repo1-s3-region=us-east-1
repo1-retention-full=30
repo1-retention-diff=7
repo1-s3-key=AWS_ACCESS_KEY_ID
repo1-s3-key-secret=AWS_SECRET_ACCESS_KEY

# Sauvegarde complète
pgbackrest --stanza=gestionbailleur backup --type=full

# Sauvegarde différentielle
pgbackrest --stanza=gestionbailleur backup --type=diff

# Sauvegarde incrémentale
pgbackrest --stanza=gestionbailleur backup --type=incr
```

### Sauvegarde Automatisée avec Cron

```bash
# Crontab pour les sauvegardes automatisées
# Sauvegarde complète quotidienne à 2h du matin
0 2 * * * pg_dump -h localhost -U gestionbailleur_admin -d gestionbailleur -F c -f /backups/gestionbailleur_$(date +\%Y\%m\%d).dump

# Sauvegarde différentielle toutes les 4 heures
0 */4 * * * pgbackrest --stanza=gestionbailleur backup --type=diff

# Nettoyage des sauvegardes anciennes (plus de 30 jours)
0 3 * * * find /backups -name "gestionbailleur_*.dump" -mtime +30 -delete
```

### Sauvegarde Chiffrée

Chiffrer les sauvegardes avant de les stocker :

```bash
# Chiffrement avec GPG
pg_dump -h localhost -U gestionbailleur_admin -d gestionbailleur -F c \
  | gpg --symmetric --cipher-algo AES256 --compress-algo 1 \
  --output /backups/gestionbailleur_$(date +%Y%m%d).dump.gpg

# Déchiffrement
gpg --decrypt /backups/gestionbailleur_20240101.dump.gpg \
  | pg_restore -h localhost -U gestionbailleur_admin -d gestionbailleur
```

---

## Restauration

### Restauration Complete

```bash
# Restauration depuis un dump
pg_restore -h localhost -U gestionbailleur_admin -d gestionbailleur \
  /backups/gestionbailleur_20240101.dump

# Restauration depuis pgBackRest
pgbackrest --stanza=gestionbailleur restore --delta
```

### Restauration Sélective

```bash
# Restauration d'une table spécifique
pg_restore -h localhost -U gestionbailleur_admin -d gestionbailleur \
  -t users /backups/gestionbailleur_20240101.dump

# Restauration d'un schéma spécifique
pg_restore -h localhost -U gestionbailleur_admin -d gestionbailleur \
  -n public /backups/gestionbailleur_20240101.dump
```

### Point-in-Time Recovery (PITR)

Restaurer la base de données à un point précis dans le temps :

```bash
# Configuration recovery.conf
restore_command = 'aws s3 cp s3://gestionbailleur-backups/wal/%f %p'
recovery_target_time = '2024-01-15 14:30:00'
recovery_target_inclusive = true

# Démarrage PostgreSQL en mode recovery
pg_ctl start -D /var/lib/postgresql/14/main -o '-P'
```

### Test de Restauration

Tester régulièrement les sauvegardes :

```bash
# Script de test de restauration
#!/bin/bash
BACKUP_FILE="/backups/gestionbailleur_$(date +%Y%m%d).dump"
TEST_DB="gestionbailleur_test"

# Créer la base de test
createdb -h localhost -U gestionbailleur_admin $TEST_DB

# Restaurer la sauvegarde
pg_restore -h localhost -U gestionbailleur_admin -d $TEST_DB $BACKUP_FILE

# Vérifier l'intégrité
psql -h localhost -U gestionbailleur_admin -d $TEST_DB -c "SELECT COUNT(*) FROM users;"

# Supprimer la base de test
dropdb -h localhost -U gestionbailleur_admin $TEST_DB
```

---

## Chiffrement des Données Sensibles

### Chiffrement au Repos

Utiliser pgcrypto pour chiffrer les données sensibles :

```sql
-- Extension pgcrypto
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Fonction de chiffrement
CREATE OR REPLACE FUNCTION encrypt_data(data TEXT, key TEXT)
RETURNS TEXT AS $$
BEGIN
    RETURN encode(encrypt(data::bytea, decode(key, 'hex'), 'aes'), 'hex');
END;
$$ LANGUAGE plpgsql;

-- Fonction de déchiffrement
CREATE OR REPLACE FUNCTION decrypt_data(encrypted_data TEXT, key TEXT)
RETURNS TEXT AS $$
BEGIN
    RETURN convert_from(decrypt(decode(encrypted_data, 'hex'), decode(key, 'hex'), 'aes'), 'SQL_ASCII');
END;
$$ LANGUAGE plpgsql;
```

### Chiffrement des Colonnes Sensibles

```sql
-- Chiffrement du numéro d'identité
ALTER TABLE clients 
ADD COLUMN id_number_encrypted TEXT;

UPDATE clients 
SET id_number_encrypted = encrypt_data(id_number, 'encryption_key');

ALTER TABLE clients 
DROP COLUMN id_number;

ALTER TABLE clients 
RENAME COLUMN id_number_encrypted TO id_number;
```

### Chiffrement avec Django

Utiliser Django pour le chiffrement au niveau application :

```python
from cryptography.fernet import Fernet
import os

# Clé de chiffrement
ENCRYPTION_KEY = os.environ.get('ENCRYPTION_KEY')
cipher = Fernet(ENCRYPTION_KEY)

def encrypt_data(data: str) -> str:
    return cipher.encrypt(data.encode()).decode()

def decrypt_data(encrypted_data: str) -> str:
    return cipher.decrypt(encrypted_data.encode()).decode()
```

### Chiffrement en Transit

Toutes les connexions PostgreSQL doivent utiliser SSL/TLS :

```sql
-- Configuration postgresql.conf
ssl = on
ssl_cert_file = '/etc/postgresql/14/main/server.crt'
ssl_key_file = '/etc/postgresql/14/main/server.key'
ssl_ca_file = '/etc/postgresql/14/main/ca.crt'
ssl_ciphers = 'HIGH:MEDIUM:+3DES:!aNULL'
ssl_prefer_server_ciphers = on
```

### Configuration Django SSL

```python
# settings.py
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'gestionbailleur',
        'USER': 'gestionbailleur_app',
        'PASSWORD': os.environ.get('DB_PASSWORD'),
        'HOST': 'localhost',
        'PORT': '5432',
        'OPTIONS': {
            'sslmode': 'require',
        },
    }
}
```

---

## Sécurité Réseau

### Firewall

Configuration du firewall pour restreindre l'accès à PostgreSQL :

```bash
# UFW (Ubuntu)
sudo ufw allow from 10.0.0.0/8 to any port 5432  # Réseau interne
sudo ufw deny 5432  # Refuser les autres connexions

# iptables
sudo iptables -A INPUT -p tcp -s 10.0.0.0/8 --dport 5432 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 5432 -j DROP
```

### VPN

Accéder à PostgreSQL uniquement via VPN :

```bash
# Configuration du serveur VPN
# Seuls les utilisateurs connectés au VPN peuvent accéder à PostgreSQL
```

### IP Whitelist

Autoriser uniquement les IP de confiance :

```sql
-- Configuration pg_hba.conf
# TYPE  DATABASE        USER            ADDRESS                 METHOD
host    gestionbailleur gestionbailleur_app 10.0.0.0/8             scram-sha-256
host    gestionbailleur gestionbailleur_admin 10.0.0.0/8             scram-sha-256
host    gestionbailleur gestionbailleur_readonly 10.0.0.0/8         scram-sha-256
```

---

## Monitoring et Alertes

### Surveillance de la Sécurité

Surveiller les indicateurs de sécurité suivants :

| Indicateur | Seuil d'alerte | Action |
|------------|----------------|--------|
| Tentatives de connexion échouées | > 10/minute | Bloquer l'IP |
| Connexions depuis des IP inconnues | > 5/heure | Alerte admin |
| Requêtes lentes (> 10s) | > 10/heure | Optimiser index |
| Taille de la base de données | > 80% du quota | Nettoyer / Archiver |
| Connexions simultanées | > 90% du max | Scale horizontal |
| Erreurs de contrainte | > 100/jour | Investiguer |

### Outils de Monitoring

- **pg_stat_activity** : Surveillance des connexions actives
- **pg_stat_statements** : Analyse des requêtes lentes
- **pgBadger** : Génération de rapports PostgreSQL
- **Prometheus + Grafana** : Monitoring en temps réel
- **Nagios** : Alertes automatisées

### Alertes Automatisées

```sql
-- Requête pour détecter les connexions échouées
SELECT datname, usename, count(*) as failed_attempts
FROM pg_stat_activity
WHERE state = 'idle' 
GROUP BY datname, usename
HAVING count(*) > 10;
```

### Notification des Incidents

Configurer les notifications pour les incidents de sécurité :

```python
# Exemple de notification via email
from django.core.mail import send_mail

def notify_security_incident(incident_type, details):
    send_mail(
        f'Security Incident: {incident_type}',
        details,
        'security@gestionbailleur.com',
        ['admin@gestionbailleur.com'],
        fail_silently=False,
    )
```

---

## Bonnes Pratiques

### 1. Utiliser des Mots de Passe Forts

Tous les mots de passe doivent être complexes et uniques.

### 2. Rotation Régulière des Mots de Passe

Les mots de passe doivent être changés régulièrement (90 jours).

### 3. Principe du Moindre Privilège

Chaque utilisateur a uniquement les permissions nécessaires.

### 4. Audit Complet

Toutes les opérations critiques doivent être tracées.

### 5. Chiffrement des Données Sensibles

Les données sensibles doivent être chiffrées au repos et en transit.

### 6. Sauvegardes Régulières

Les sauvegardes doivent être automatisées et testées régulièrement.

### 7. Mises à Jour de Sécurité

PostgreSQL et les extensions doivent être régulièrement mises à jour.

### 8. Monitoring Continu

La base de données doit être surveillée en permanence.

### 9. Plan de Reprise d'Activité

Un plan de reprise d'activité doit être documenté et testé.

### 10. Formation de l'Équipe

L'équipe doit être formée aux bonnes pratiques de sécurité.

---

## Checklist de Sécurité

### Avant Mise en Production

- [ ] Tous les mots de passe sont complexes
- [ ] Les permissions sont configurées correctement
- [ ] L'audit est activé
- [ ] Les sauvegardes sont automatisées
- [ ] Le chiffrement est activé
- [ ] Le firewall est configuré
- [ ] Le monitoring est en place
- [ ] Les alertes sont configurées
- [ ] Le plan de reprise est testé
- [ ] L'équipe est formée

### Maintenance Quotidienne

- [ ] Vérifier les logs d'audit
- [ ] Vérifier les sauvegardes
- [ ] Surveiller les performances
- [ ] Vérifier les alertes de sécurité
- [ ] Vérifier les connexions anormales

### Maintenance Hebdomadaire

- [ ] Vérifier l'utilisation du stockage
- [ ] Vérifier les requêtes lentes
- [ ] Vérifier les index fragmentés
- [ ] Tester la restauration
- [ ] Mettre à jour les statistiques

### Maintenance Mensuelle

- [ ] Vérifier les mises à jour de sécurité
- [ ] Réviser les permissions
- [ ] Réviser les politiques de rétention
- [ ] Tester le plan de reprise
- [ ] Former l'équipe
