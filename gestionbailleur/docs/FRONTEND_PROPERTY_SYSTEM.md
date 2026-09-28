# Documentation Technique — Système Réel des Logements et Annonces (GestBailleur Frontend)

## Architecture Générale
L'application Flutter `GestBailleur` respecte strictement l'architecture **Feature First / MVVM / Clean Architecture** avec **Riverpod** et **GoRouter**.

```
Flutter Client (Mobile / Web)
   ↓
Page / View (Widgets / Formulaires / Responsive Grid)
   ↓
ViewModel / Notifier (PropertyNotifier / Riverpod)
   ↓
Repository (PropertyRepository)
   ↓
Network Layer (ApiService HTTP REST / ApiEndpoints)
   ↓
Django REST Framework (Backend API)
   ↓
PostgreSQL (Database)
```

> **Règle de Sécurité Absolue** : Aucun accès direct à PostgreSQL n'est effectué depuis Flutter. Toutes les données transitent via des requêtes HTTP REST authentifiées par jeton JWT Bearer (`ApiService`).

---

## Directives & Zéro Donnée Fictive (*Zero Fake Data*)

1. **Aucun Mock / Aucune Valeur Manuelle** : Les nombres de biens ("1250", "890"), avis ou faux profils ont été bannis.
2. **États Vides (*Empty States*)** : Si le backend ne retourne aucun logement, la page affiche le composant `DSState` ou des conteneurs vides professionnels avec message approprié (ex: *"Aucun logement disponible pour le moment"*).
3. **Statut Réel des Bailleurs** : La publication de logement (`PublishPropertyPage`) vérifie le statut `StatutCompte.actif` du bailleur connecté. Si le compte est en attente ou non validé par l'administrateur, un bandeau d'avertissement est affiché et la soumission est bloquée.

---

## Modèles Principaux (`PropertyModel`)

Le modèle `PropertyModel` (`lib/features/home/models/property_model.dart`) est en correspondance exacte avec le modèle Django REST (`apps.listings.models.Property`) :

- **Champs principaux** : `id`, `title`, `description`, `propertyType`, `status`, `rentPrice`, `charges`, `deposit`, `surface`, `rooms`, `bedrooms`, `bathrooms`, `floor`.
- **Équipements** : `furnished`, `parking`, `balcony`, `terrace`, `elevator`, `garden`, `pool`, `airConditioning`, `heating`.
- **Localisation** : `latitude`, `longitude`, `addressDetails` (`city`, `district`, `street`, `country`, `postalCode`).
- **Médias** : `mainPhoto`, `images` (liste), `videoUrl`.
- **Bailleur** : `landlordId`, `landlordName`, `landlordEmail`, `landlordPhoto`, `landlordStatus`, `landlordIsVerified`.
- **Statistiques & Métadonnées** : `viewsCount`, `inquiriesCount`, `createdAt`, `updatedAt`, `isFavorite`.

---

## Catégories & Charte Graphique

Les cartes de catégories (`CategoryCard`) respectent la règle graphique imposée :
- **Icône** : Blanche (`color: Colors.white`) sur conteneur translucide.
- **Fond de Carte** : Coloré (`backgroundColor: theme.colorScheme.primary`, Teals, Purple, Orange).
- **Contraste Élevé** : Textes et sous-titres blancs.
- **Compteur Dynamique** : Les compteurs de logements par catégorie sont calculés en temps réel à partir de la liste des logements réels renvoyés par l'API (`propertyProvider`).

---

## Recherche & Géolocalisation

### Recherche Avancée
L'écran `SearchPage` interroge le backend avec des paramètres de requête HTTP (`GET /api/v1/properties/search/`) :
- `city`, `property_type`, `min_price`, `max_price`, `min_bedrooms`, `furnished`.

### Tri par Proximité GPS ("Logements autour de moi")
- Formule trigonométrique Haversine appliquée sur `(latitude, longitude)` pour calculer la distance réelle en kilomètres.
- Tri automatique par proximité.
- Possibilité d'utiliser la position GPS de l'appareil ou de saisir manuellement les coordonnées.

---

## Médias (Photos & Vidéos)

- **Gestion multi-photos** : Ajout d'URLs/fichiers avec prévisualisation, sélection de l'image principale et suppression.
- **Support Vidéo** : Intégration de prévisualisation vidéo (`videoUrl`).
- **Upload Backend** : Préparé pour l'envoi Multipart vers Django REST via `ApiService.instance.postMultipart()`.

---

## Validation & Qualité Code

- Score `flutter analyze` : **0 issue found!** (Aucune erreur, aucun avertissement, aucun linter info).
- Responsive : Testé pour Android Téléphone, Android Tablette, Web Mobile et Web Desktop.
