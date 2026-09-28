# DOCUMENTATION — SYSTEME REEL DES FAVORIS (GESTBAILLEUR)

Ce document décrit l'architecture, la gestion d'état, les endpoints API et le fonctionnement global du système de favoris réels de **GestBailleur**.

---

## 1. Architecture

Le module des favoris suit rigoureusement l'architecture globale du projet :
- **Feature First** (`lib/features/favorites`)
- **MVVM** (`FavoritesPage` ↔ `FavoritesNotifier`)
- **Clean Architecture & Repository Pattern** (`FavoritesRepository` ↔ `ApiService` ↔ Django REST Framework)
- **State Management** (`Riverpod` / `StateNotifierProvider`)

```
Flutter (FavoritesPage / PropertyDetailsPage / PropertyCard)
   ↓ (watch / read)
FavoritesNotifier (favoritesProvider - StateNotifier)
   ↓ (appels asynchrones)
FavoritesRepository
   ↓ (requests HTTP JWT)
ApiService
   ↓
Django REST Framework (/api/v1/favorites/)
   ↓
PostgreSQL (table favorites_favorite)
```

---

## 2. Fichiers et Modèles Frontend

- **[FavoriteModel](file:///c:/Users/william/StudioProjects/BAILLEUR/gestionbailleur/lib/features/favorites/models/favorite_model.dart)** : Modèle représentant un logement en favori avec son ID, la propriété associée (`PropertyModel`), et la date d'ajout.
- **[FavoritesRepository](file:///c:/Users/william/StudioProjects/BAILLEUR/gestionbailleur/lib/features/favorites/repositories/favorites_repository.dart)** : Responsable des appels API HTTP vers le backend Django.
- **[FavoritesNotifier](file:///c:/Users/william/StudioProjects/BAILLEUR/gestionbailleur/lib/features/favorites/providers/favorites_provider.dart)** : ViewModel (Riverpod `StateNotifier`) conservant la liste réelle des favoris, les IDs pour la recherche instantanée ($O(1)$), et la gestion des états (Loading, Error, Success, Empty).
- **[FavoritesPage](file:///c:/Users/william/StudioProjects/BAILLEUR/gestionbailleur/lib/features/favorites/pages/favorites_page.dart)** : Vue principale affichant la grille responsive des favoris réels de l'utilisateur.

---

## 3. Endpoints API Django REST Framework

L'application frontend communique exclusivement avec les endpoints réels backend suivants :

1. **Lister les favoris réels** :
   - `GET /api/v1/favorites/`
   - *Entête* : `Authorization: Bearer <access_token>`
   - *Réponse* : `200 OK` avec liste JSON des logements favoris de l'utilisateur.

2. **Ajouter un logement aux favoris** :
   - `POST /api/v1/favorites/`
   - *Body* : `{"property_id": "<uuid>"}`
   - *Réponse* : `201 Created` (`{"message": "Logement ajouté aux favoris", "is_favorite": true, "property_id": "<uuid>"}`)

3. **Supprimer un logement des favoris** :
   - `DELETE /api/v1/favorites/<uuid:property_id>/`
   - *Réponse* : `204 No Content`

---

## 4. Comportement Utilisateur & Règles métier

### A. Visiteur non connecté
- Peut parcourir la liste des logements et consulter les détails.
- S'il tente d'ajouter un logement aux favoris (icône cœur sur une carte ou sur la page de détail) :
  - **Aucun favori local permanent n'est créé.**
  - Une SnackBar d'information s'affiche : `"Connectez-vous pour ajouter des logements à vos favoris."` avec une action `"Se connecter"` redirigeant vers `/login`.
  - Sur la page `/favorites`, une interface épurée invite l'utilisateur à se connecter.

### B. Utilisateur connecté
- Lors de la connexion, les favoris réels enregistrés dans PostgreSQL sont automatiquement chargés.
- L'icône cœur reflète le véritable statut favori retourné par l'API backend.
- La suppression d'un favori depuis la page `FavoritesPage` ou la page de détail est confirmée et synchronisée avec le backend avant le retrait visuel définitif.
- Le compteur de favoris (ex. `Mes Favoris (3)`) dans la barre de navigation et le tableau de bord affiche toujours la quantité réelle de favoris enregistrés dans PostgreSQL.

---

## 5. Gestion des Erreurs & Empty States

- **Empty State** : Si l'utilisateur connecté n'a aucun favori enregistres :
  - Icône cœur transparent.
  - Message exact : `"Vous n'avez encore aucun logement en favori."`
  - Sous-titre : `"Ajoutez les logements qui vous intéressent pour les retrouver facilement."`
  - Bouton : `"Rechercher un logement"` redirigeant vers la recherche (`/search`).
- **Erreurs réseau & serveur** : Prise en charge des interruptions réseau ou indisponibilités serveur sans crash visuel ni affichage de stack traces techniques à l'utilisateur final. Un bouton `"Réessayer"` permet d'actualiser la liste.
