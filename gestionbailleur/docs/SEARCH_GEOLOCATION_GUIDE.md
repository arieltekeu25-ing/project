# DOCUMENTATION — RECHERCHE AVANCÉE ET GÉOLOCALISATION RÉELLE (GESTBAILLEUR)

Ce document détaille l'architecture, la géolocalisation GPS réelle, le moteur de recherche et les composants du système de recherche avancée pour **GestBailleur**.

---

## 1. Architecture Globale

```
Flutter (SearchPage / SearchFilterModal / SearchMapView)
   ↓ (watch / read)
SearchNotifier & searchProvider (Riverpod MVVM)
   ↓ (LocationService via geolocator & SearchRepository via ApiService)
Django REST Framework (/api/v1/properties/search/ & /api/v1/properties/options/)
   ↓ (Requêtes SQL avec calcul de distance Haversine)
PostgreSQL (Tables listings_property, locations_address)
```

---

## 2. Fichiers et Composants Frontend

- **[SearchFilterModel](file:///c:/Users/william/StudioProjects/BAILLEUR/gestionbailleur/lib/features/search/models/search_filter_model.dart)** : Modèle immutable des filtres (mots-clés, ville, quartier, type de bien, loyer min/max, surface min/max, chambres, meublé, coordonnées GPS `userLatitude`/`userLongitude`, rayon, tri, `SearchMode`).
- **[SearchOptionsModel](file:///c:/Users/william/StudioProjects/BAILLEUR/gestionbailleur/lib/features/search/models/search_options_model.dart)** : Modèle des choix de filtres dynamiques extraits de PostgreSQL (`cities`, `districts`, `propertyTypes`, `minPrice`, `maxPrice`).
- **[LocationService](file:///c:/Users/william/StudioProjects/BAILLEUR/gestionbailleur/lib/features/search/services/location_service.dart)** : Service d'accès GPS réel (`geolocator`) gérant la demande de permission explicite, la vérification du statut (`granted`, `denied`, `permanentlyDenied`, `disabled`) et la saisie des coordonnées GPS latitude/longitude.
- **[SearchRepository](file:///c:/Users/william/StudioProjects/BAILLEUR/gestionbailleur/lib/features/search/repositories/search_repository.dart)** : Repository HTTP.
- **[SearchNotifier](file:///c:/Users/william/StudioProjects/BAILLEUR/gestionbailleur/lib/features/search/providers/search_provider.dart)** : ViewModel Riverpod gérant la recherche avec debounce (400ms), la géolocalisation, les options et l'état d'affichage (Liste, Grille, Carte).
- **[SearchPage](file:///c:/Users/william/StudioProjects/BAILLEUR/gestionbailleur/lib/features/search/pages/search_page.dart)** : Interface principale de recherche avec barre de recherche, pilules de filtres actifs (Pills), sélecteur de mode de recherche (`SearchMode.manual`, `SearchMode.advanced`, `SearchMode.ai`) et basculement Liste/Grille/Carte.
- **[SearchFilterModal](file:///c:/Users/william/StudioProjects/BAILLEUR/gestionbailleur/lib/features/search/widgets/search_filter_modal.dart)** : Modal Bottom Sheet de filtrage avec champs numériques validés et bouton "Utiliser ma position GPS".
- **[SearchMapView](file:///c:/Users/william/StudioProjects/BAILLEUR/gestionbailleur/lib/features/search/widgets/search_map_view.dart)** : Composant cartographique interactif basé sur `flutter_map` (OpenStreetMap) affichant la position GPS de l'utilisateur et les marqueurs réels des logements.

---

## 3. API & Endpoints Backend Django REST

1. **Recherche & Géolocalisation** : `GET /api/v1/properties/search/`
   - Paramètres de requête : `q`, `city`, `district`, `property_type`, `min_price`, `max_price`, `min_surface`, `max_surface`, `bedrooms`, `furnished`, `latitude`, `longitude`, `radius_km`, `ordering`.
   - Calcul de distance : Formule Haversine appliquée sur le backend pour chaque logement possédant des coordonnées GPS d'adresse.
   - Tri supporté : `-created_at` (plus récent), `rent_price` (prix croissant), `-rent_price` (prix décroissant), `distance` (proximité GPS), `-views_count` (pertinence).
2. **Options de Filtres Dynamiques** : `GET /api/v1/properties/options/`
   - Extrait dynamiquement les villes uniques, quartiers uniques, types de logements et bornes de prix directement enregistrés en base PostgreSQL.

---

## 4. Gestion de la Géolocalisation & Permissions GPS

- **Demande de permission** : Conforme aux règles d'accès. Le message explicatif *"GestBailleur utilise votre position pour vous proposer les logements proches de vous."* est affiché lors de l'activation.
- **Comportement en cas de refus** : Si l'utilisateur refuse la géolocalisation ou si le service GPS est désactivé, le système bascule de manière transparente sur la recherche classique par ville ou quartier sans bloquer l'application.
- **Affichage des distances** : La distance réelle est formatée (`850 m`, `2,4 km`) uniquement si les coordonnées GPS sont valides et calculées.

---

## 5. Préparation pour l'IA (SearchMode)

L'énumération `SearchMode` permet d'isoler la logique de recherche :
- `SearchMode.manual` : Recherche simple par mots-clés et filtres basiques.
- `SearchMode.advanced` : Recherche multicritère avancée avec géolocalisation.
- `SearchMode.ai` : Emplacement d'abstraction préparé pour la future intégration du moteur de recherche en langage naturel basé sur l'IA (développé ultérieurement sur le serveur Python).
