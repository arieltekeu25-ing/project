# GestBailleur — Module Média & Stockage Cloudinary

## 1. Vue d'ensemble & Architecture

Le module média de **GestBailleur** orchestre la gestion intégrale et sécurisée des images et des vidéos entre le client mobile/web Flutter, l'API REST Framework Django, la base de données PostgreSQL et le service de stockage Cloudinary.

```
Flutter (Android/Web)
        │
        │ HTTP REST (Multipart / JSON)
        ▼
Django REST Framework ──── Cloudinary (Stockage Fichiers Binaires)
        │
        ▼
PostgreSQL (Métadonnées & Références Métier)
```

- **Cloudinary** stocke la totalité des binaires (images et vidéos).
- **PostgreSQL** conserve l'intégrité métier, les relations et les références (`cloudinary_public_id`, `secure_url`, `resource_type`, `format`, `width`, `height`, `duration`, `file_size`, `order`, `is_primary`).
- **Flutter** ne communique **jamais** avec Cloudinary directement et ne possède aucune clé secrète (`CLOUDINARY_API_SECRET` reste strictement côté backend).

---

## 2. Variables d'Environnement

Côté Backend Django (`.env`) :
```env
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
```

*Note : Les identifiants réels sont strictement conservés dans le fichier `.env` ignorer par Git.*

---

## 3. Dossiers Cloudinary

Les fichiers sont organisés dans des sous-dossiers spécifiques :
- Logements — Images : `gestbailleur/properties/{property_id}/images/`
- Logements — Vidéos : `gestbailleur/properties/{property_id}/videos/`
- Profils Utilisateurs : `gestbailleur/profiles/{user_id}/`

---

## 4. Modèles de Données PostgreSQL

### `PropertyMedia` (`apps.listings.models.PropertyMedia`)
- `id` (UUID)
- `property` (ForeignKey vers `Property`)
- `cloudinary_public_id` (CharField)
- `secure_url` (URLField)
- `resource_type` (Choices: `image`, `video`)
- `format` (CharField)
- `width`, `height` (IntegerField, optional)
- `duration` (FloatField, optional — pour les vidéos)
- `file_size` (BigIntegerField, optional)
- `order` (IntegerField)
- `is_primary` (BooleanField)
- `created_at`, `updated_at`, `is_deleted`, `deleted_at`

### `UserProfile` (`apps.profiles.models.UserProfile`)
- `photo` (URLField - `secure_url` Cloudinary)
- `photo_cloudinary_public_id` (CharField - `public_id` Cloudinary pour suppression)

---

## 5. Endpoints REST API Django

### Médias de Logements
- `POST /api/v1/properties/{property_id}/media/` : Upload d'un ou plusieurs médias (images max 10MB, vidéos max 100MB).
- `DELETE /api/v1/properties/{property_id}/media/{media_id}/` : Suppression réelle Cloudinary + PostgreSQL.
- `PATCH /api/v1/properties/{property_id}/media/{media_id}/set-primary/` : Définition de l'image principale.
- `PATCH /api/v1/properties/{property_id}/media/reorder/` : Réordonnancement de la liste des médias.

### Photo de Profil Utilisateur
- `GET /api/v1/profiles/me/` : Récupération du profil et de l'URL photo réelle.
- `POST /api/v1/profiles/me/photo/` : Upload/Remplacement de la photo de profil.
- `DELETE /api/v1/profiles/me/photo/delete/` : Suppression de la photo de profil.

---

## 6. Sécurité & Droits d'Accès

- **Authentification** : Token JWT obligatoire (`Authorization: Bearer <token>`).
- **Validation Bailleur** : Seuls les utilisateurs enregistrés comme `BAILLEUR` avec un compte `ACTIF` peuvent modifier les logements et médias.
- **Propriété** : Vérification stricte que le logement appartient au bailleur effectuant la requête.
- **Validation bivalente** : Extensions (`.jpg`, `.png`, `.webp`, `.mp4`, `.mov`) et tailles vérifiées à la fois côté Flutter et côté Django.

---

## 7. Nettoyage & Stratégie de Rollback

- **Attamocité DB & Clean-up Cloudinary** : Si l'insertion PostgreSQL échoue après qu'un fichier a été téléversé sur Cloudinary, le fichier Cloudinary est immédiatement détruit afin d'éviter tout fichier orphelin.
- **Suppression d'images** : Lorsqu'un bailleur supprime une image, le fichier est d'abord détruit sur Cloudinary avant que l'enregistrement PostgreSQL ne soit supprimé.
- **Archivage vs Suppression** : Si un logement est masqué ou archivé (soft-delete), ses médias sont préservés pour permettre la restauration. Si le logement est hard-deleted, ses médias Cloudinary sont définitivement nettoyés.

---

## 8. Intégration Flutter

- **Sélection** : `image_picker` (support images multiples et vidéo).
- **Lecteur Vidéo** : `video_player` intégré avec le widget `CloudinaryVideoPlayerWidget` lisant les flux via `secure_url` HTTPS.
- **State Management** : Riverpod (`propertyMediaProvider`, `authProvider`).
- **Photo par défaut** : Avatar UI neutre avec les initiales si l'utilisateur n'a pas de photo (aucune fausse URL enregistrée).

---

## 9. Tests & Validation

1. **Backend Tests** : `python manage.py test apps.listings.tests.test_media`
2. **Real Integration Test** : `python manage.py check` & `python scripts/test_cloudinary_real.py` (valide l'envoi et le nettoyage réel).
3. **Flutter Static Analysis** : `flutter analyze`
