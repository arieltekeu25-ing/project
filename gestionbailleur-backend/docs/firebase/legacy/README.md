# Documentation Firebase (Legacy)

**IMPORTANT : Cette documentation est conservée uniquement comme référence historique.**

Firebase n'est PLUS utilisé comme base de données pour le projet GestionBailleur.

## Architecture Actuelle

- **PostgreSQL** : Base de données principale pour toutes les données métier
- **Firebase Storage** : Stockage des images/documents (optionnel)
- **Firebase Cloud Messaging** : Notifications push (optionnel)

## Documentation Firebase Conservée

Les documents suivants sont conservés dans ce dossier pour référence potentielle :

- **FIRESTORE_SCHEMA.md** - Schéma Firestore (non utilisé)
- **COLLECTIONS.md** - Collections Firestore (non utilisé)
- **DOCUMENT_STRUCTURE.md** - Structure des documents Firestore (non utilisé)
- **SECURITY_RULES.md** - Règles de sécurité Firestore (non utilisé)
- **INDEXES.md** - Indexes Firestore (non utilisé)
- **STORAGE_STRUCTURE.md** - Structure Firebase Storage (référence pour stockage fichiers)

## Utilisation Future de Firebase

Si Firebase est utilisé dans le futur, ce sera uniquement pour :

1. **Firebase Storage** - Stockage des images et documents
2. **Firebase Cloud Messaging** - Notifications push mobile

Aucune donnée métier ne sera stockée dans Firestore.
