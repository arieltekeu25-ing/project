# Dictionnaire de Données - GestionBailleur

## Table des matières

1. [Utilisateur](#utilisateur)
2. [Profil](#profil)
3. [Adresse](#adresse)
4. [Client](#client)
5. [Bailleur](#bailleur)
6. [Administrateur](#administrateur)
7. [Ville](#ville)
8. [Quartier](#quartier)
9. [Logement](#logement)
10. [CatégorieLogement](#categorielogement)
11. [TypeLogement](#typelogement)
12. [PhotoLogement](#photologement)
13. [VideoLogement](#videologement)
14. [Equipement](#equipement)
15. [Favori](#favori)
16. [Avis](#avis)
17. [Conversation](#conversation)
18. [Message](#message)
19. [ChatbotConversation](#chatbotconversation)
20. [ChatbotMessage](#chatbotmessage)
21. [Notification](#notification)
22. [Historique](#historique)
23. [Recherche](#recherche)
24. [RechercheEnregistree](#rechercheenregistree)
25. [Visite](#visite)
26. [PlanningVisite](#planningvisite)
27. [Signalement](#signalement)
28. [DocumentVerification](#documentverification)
29. [SessionUtilisateur](#sessionutilisateur)
30. [ParametreUtilisateur](#parametreutilisateur)

---

## Utilisateur

**Description** : Utilisateur de base du système avec informations d'authentification

| Attribut | Type | Défaut | Obligatoire | Contraintes | Exemple |
|----------|------|--------|-------------|-------------|---------|
| id | UUID | - | Oui | UUID v4 | 550e8400-e29b-41d4-a716-446655440000 |
| email | String(255) | - | Oui | Unique, format email | jean.dupont@example.com |
| telephone | String(20) | null | Non | Unique, format international | +2250707070707 |
| nom | String(100) | - | Oui | Min 2 caractères | Dupont |
| prenom | String(100) | - | Oui | Min 2 caractères | Jean |
| photo_url | String(500) | null | Non | URL valide | https://example.com/photo.jpg |
| date_naissance | Date | - | Oui | >= 13 ans | 1990-01-15 |
| sexe | String(10) | null | Non | 'masculin', 'féminin', 'autre' | masculin |
| nationalite | String(100) | null | Non | Code pays ISO | CI |
| langue_preferee | String(10) | fr | Non | Code langue ISO | fr |
| role | String(20) | - | Oui | 'client', 'bailleur', 'administrateur' | client |
| statut | String(20) | actif | Oui | 'actif', 'inactif', 'suspendu' | actif |
| est_verifie | Boolean | false | Non | - | true |
| est_actif | Boolean | true | Non | - | true |
| date_creation | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |
| date_modification | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |
| derniere_connexion | DateTime | null | Non | - | 2024-01-20 14:45:00 |

---

## Profil

**Description** : Profil étendu de l'utilisateur avec informations sociales

| Attribut | Type | Défaut | Obligatoire | Contraintes | Exemple |
|----------|------|--------|-------------|-------------|---------|
| id | UUID | - | Oui | UUID v4 | 550e8400-e29b-41d4-a716-446655440001 |
| utilisateur_id | UUID | - | Oui | FK vers Utilisateur | 550e8400-e29b-41d4-a716-446655440000 |
| bio | Text | null | Non | Max 500 caractères | Passionné d'immobilier |
| site_web | String(255) | null | Non | URL valide | https://jdupont.com |
| linkedin | String(255) | null | Non | URL valide | https://linkedin.com/in/jdupont |
| facebook | String(255) | null | Non | URL valide | https://facebook.com/jdupont |
| twitter | String(255) | null | Non | URL valide | https://twitter.com/jdupont |
| instagram | String(255) | null | Non | URL valide | https://instagram.com/jdupont |
| preferences | JSON | null | Non | Structure JSON valide | {"theme": "dark"} |
| centre_interets | Text | null | Non | Max 300 caractères | Immobilier, voyage |
| profil_public | Boolean | false | Non | - | true |
| statut | String(20) | actif | Oui | 'actif', 'inactif' | actif |
| date_creation | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |
| date_modification | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |

---

## Adresse

**Description** : Adresse physique avec coordonnées GPS

| Attribut | Type | Défaut | Obligatoire | Contraintes | Exemple |
|----------|------|--------|-------------|-------------|---------|
| id | UUID | - | Oui | UUID v4 | 550e8400-e29b-41d4-a716-446655440002 |
| rue | String(255) | - | Oui | Min 5 caractères | Rue du Commerce |
| numero | String(20) | null | Non | - | 123 |
| complement | String(255) | null | Non | - | Appartement 4B |
| code_postal | String(20) | - | Oui | - | 01 BP 1234 |
| ville_id | UUID | - | Oui | FK vers Ville | 550e8400-e29b-41d4-a716-446655440010 |
| quartier_id | UUID | null | Non | FK vers Quartier | 550e8400-e29b-41d4-a716-446655440011 |
| latitude | Decimal(10,8) | null | Non | -90 à 90 | 5.3456789 |
| longitude | Decimal(11,8) | null | Non | -180 à 180 | -4.1234567 |
| statut | String(20) | actif | Oui | 'actif', 'inactif' | actif |
| date_creation | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |
| date_modification | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |

---

## Client

**Description** : Informations spécifiques au client (locataire)

| Attribut | Type | Défaut | Obligatoire | Contraintes | Exemple |
|----------|------|--------|-------------|-------------|---------|
| id | UUID | - | Oui | UUID v4 | 550e8400-e29b-41d4-a716-446655440003 |
| utilisateur_id | UUID | - | Oui | FK vers Utilisateur | 550e8400-e29b-41d4-a716-446655440000 |
| numero_piece_identite | String(50) | null | Non | - | CI1234567890 |
| type_piece_identite | String(50) | null | Non | 'CNI', 'Passeport', 'Permis' | CNI |
| profession | String(100) | null | Non | - | Ingénieur |
| revenu_mensuel | Decimal(12,2) | null | Non | >= 0 | 500000.00 |
| employeur | String(255) | null | Non | - | Société ABC |
| adresse_travail | String(255) | null | Non | - | Zone Industrielle |
| telephone_travail | String(20) | null | Non | - | +2250707070708 |
| garant_nom | String(100) | null | Non | - | Pierre Martin |
| garant_telephone | String(20) | null | Non | - | +2250707070709 |
| garant_adresse | String(255) | null | Non | - | Rue de la Paix |
| documents | JSON | [] | Non | Liste d'URLs | ["doc1.pdf", "doc2.pdf"] |
| statut_verification | String(30) | en_attente | Non | 'en_attente', 'approuve', 'refuse' | approuve |
| statut | String(20) | actif | Oui | 'actif', 'inactif' | actif |
| date_creation | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |
| date_modification | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |

---

## Bailleur

**Description** : Informations spécifiques au bailleur (propriétaire)

| Attribut | Type | Défaut | Obligatoire | Contraintes | Exemple |
|----------|------|--------|-------------|-------------|---------|
| id | UUID | - | Oui | UUID v4 | 550e8400-e29b-41d4-a716-446655440004 |
| utilisateur_id | UUID | - | Oui | FK vers Utilisateur | 550e8400-e29b-41d4-a716-446655440000 |
| raison_sociale | String(255) | null | Non | - | SCI Immo Abidjan |
| numero_registre_commerce | String(50) | null | Non | - | CI-ABJ-2024-B-12345 |
| numero_contribuable | String(50) | null | Non | - | 1234567890 |
| adresse_siege | String(255) | null | Non | - | Plateau, Abidjan |
| site_web | String(255) | null | Non | URL valide | https://immoabidjan.com |
| description | Text | null | Non | Max 1000 caractères | Spécialiste immobilier |
| telephone_professionnel | String(20) | null | Non | - | +2250707070710 |
| email_professionnel | String(255) | null | Non | Format email | contact@immoabidjan.com |
| biens | JSON | [] | Non | Liste d'UUIDs | ["uuid1", "uuid2"] |
| documents_juridiques | JSON | [] | Non | Liste d'URLs | ["doc1.pdf"] |
| est_professionnel | Boolean | false | Non | - | true |
| statut_verification | String(30) | en_attente | Non | 'en_attente', 'approuve', 'refuse' | approuve |
| statut | String(20) | actif | Oui | 'actif', 'inactif' | actif |
| date_creation | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |
| date_modification | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |

---

## Administrateur

**Description** : Informations spécifiques à l'administrateur système

| Attribut | Type | Défaut | Obligatoire | Contraintes | Exemple |
|----------|------|--------|-------------|-------------|---------|
| id | UUID | - | Oui | UUID v4 | 550e8400-e29b-41d4-a716-446655440005 |
| utilisateur_id | UUID | - | Oui | FK vers Utilisateur | 550e8400-e29b-41d4-a716-446655440000 |
| permissions | JSON | [] | Non | Liste de permissions | ["manage_users", "manage_properties"] |
| date_expiration_mandat | Date | null | Non | - | 2025-12-31 |
| superieur_id | UUID | null | Non | FK vers Administrateur | 550e8400-e29b-41d4-a716-446655440006 |
| est_super_admin | Boolean | false | Non | - | false |
| departement | String(100) | - | Oui | - | Support |
| fonction | String(100) | null | Non | - | Modérateur |
| statut | String(20) | actif | Oui | 'actif', 'inactif' | actif |
| date_creation | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |
| date_modification | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |

---

## Ville

**Description** : Ville avec informations géographiques

| Attribut | Type | Défaut | Obligatoire | Contraintes | Exemple |
|----------|------|--------|-------------|-------------|---------|
| id | UUID | - | Oui | UUID v4 | 550e8400-e29b-41d4-a716-446655440010 |
| nom | String(100) | - | Oui | Unique par pays | Abidjan |
| code | String(10) | null | Non | - | ABJ |
| pays | String(100) | null | Non | Code pays ISO | CI |
| region | String(100) | null | Non | - | Lagunes |
| province | String(100) | null | Non | - | Abidjan |
| latitude | Decimal(10,8) | null | Non | -90 à 90 | 5.3456789 |
| longitude | Decimal(11,8) | null | Non | -180 à 180 | -4.1234567 |
| population | Integer | 0 | Non | >= 0 | 5000000 |
| statut | String(20) | actif | Oui | 'actif', 'inactif' | actif |
| date_creation | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |
| date_modification | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |

---

## Quartier

**Description** : Quartier rattaché à une ville

| Attribut | Type | Défaut | Obligatoire | Contraintes | Exemple |
|----------|------|--------|-------------|-------------|---------|
| id | UUID | - | Oui | UUID v4 | 550e8400-e29b-41d4-a716-446655440011 |
| nom | String(100) | - | Oui | - | Cocody |
| ville_id | UUID | - | Oui | FK vers Ville | 550e8400-e29b-41d4-a716-446655440010 |
| code | String(10) | null | Non | - | COC |
| description | Text | null | Non | Max 500 caractères | Quartier résidentiel |
| latitude | Decimal(10,8) | null | Non | -90 à 90 | 5.3456789 |
| longitude | Decimal(11,8) | null | Non | -180 à 180 | -4.1234567 |
| population | Integer | 0 | Non | >= 0 | 100000 |
| statut | String(20) | actif | Oui | 'actif', 'inactif' | actif |
| date_creation | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |
| date_modification | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |

---

## Logement

**Description** : Logement avec toutes ses caractéristiques

| Attribut | Type | Défaut | Obligatoire | Contraintes | Exemple |
|----------|------|--------|-------------|-------------|---------|
| id | UUID | - | Oui | UUID v4 | 550e8400-e29b-41d4-a716-446655440020 |
| titre | String(200) | - | Oui | Min 5, max 200 caractères | Appartement moderne Cocody |
| description | Text | - | Oui | Min 50 caractères | Bel appartement 3 pièces... |
| prix | Decimal(12,2) | - | Oui | > 0 | 150000.00 |
| caution | Decimal(12,2) | null | Non | >= 0 | 450000.00 |
| avance | Decimal(12,2) | null | Non | >= 0 | 300000.00 |
| devise | String(10) | XOF | Oui | - | XOF |
| surface | Decimal(10,2) | - | Oui | > 0 | 120.50 |
| nombre_chambres | Integer | - | Oui | >= 0 | 3 |
| nombre_salons | Integer | - | Oui | >= 0 | 1 |
| nombre_cuisines | Integer | - | Oui | >= 0 | 1 |
| nombre_salles_de_bain | Integer | - | Oui | >= 0 | 2 |
| nombre_toilettes | Integer | - | Oui | >= 0 | 2 |
| parking | Boolean | false | Non | - | true |
| balcon | Boolean | false | Non | - | true |
| terrasse | Boolean | false | Non | - | false |
| internet | Boolean | false | Non | - | true |
| climatisation | Boolean | false | Non | - | true |
| groupe_electrogene | Boolean | false | Non | - | false |
| forage | Boolean | false | Non | - | true |
| animaux_autorises | Boolean | false | Non | - | false |
| latitude | Decimal(10,8) | - | Oui | -90 à 90 | 5.3456789 |
| longitude | Decimal(11,8) | - | Oui | -180 à 180 | -4.1234567 |
| adresse_id | UUID | - | Oui | FK vers Adresse | 550e8400-e29b-41d4-a716-446655440002 |
| bailleur_id | UUID | - | Oui | FK vers Bailleur | 550e8400-e29b-41d4-a716-446655440004 |
| categorie_id | UUID | - | Oui | FK vers CategorieLogement | 550e8400-e29b-41d4-a716-446655440030 |
| type_id | UUID | - | Oui | FK vers TypeLogement | 550e8400-e29b-41d4-a716-446655440031 |
| equipements | JSON | [] | Non | Liste d'UUIDs | ["uuid1", "uuid2"] |
| photos | JSON | [] | Non | Liste d'URLs | ["photo1.jpg", "photo2.jpg"] |
| videos | JSON | [] | Non | Liste d'URLs | ["video1.mp4"] |
| nombre_vues | Integer | 0 | Non | >= 0 | 150 |
| nombre_favoris | Integer | 0 | Non | >= 0 | 25 |
| nombre_partages | Integer | 0 | Non | >= 0 | 10 |
| distance | Decimal(10,2) | null | Non | >= 0 | 5.5 |
| statut | String(20) | brouillon | Oui | 'brouillon', 'publie', 'pause', 'archive' | publie |
| date_publication | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |
| date_expiration | DateTime | null | Non | - | 2024-12-31 23:59:59 |
| date_creation | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |
| date_modification | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |

---

## CategorieLogement

**Description** : Catégorie de logement

| Attribut | Type | Défaut | Obligatoire | Contraintes | Exemple |
|----------|------|--------|-------------|-------------|---------|
| id | UUID | - | Oui | UUID v4 | 550e8400-e29b-41d4-a716-446655440030 |
| nom | String(100) | - | Oui | Unique | Appartement |
| description | Text | null | Non | Max 500 caractères | Logement en immeuble |
| icone | String(50) | null | Non | - | apartment |
| ordre | Integer | 0 | Non | >= 0 | 1 |
| statut | String(20) | actif | Oui | 'actif', 'inactif' | actif |
| date_creation | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |
| date_modification | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |

---

## TypeLogement

**Description** : Type de logement (location, vente, etc.)

| Attribut | Type | Défaut | Obligatoire | Contraintes | Exemple |
|----------|------|--------|-------------|-------------|---------|
| id | UUID | - | Oui | UUID v4 | 550e8400-e29b-41d4-a716-446655440031 |
| nom | String(100) | - | Oui | Unique | Location |
| description | Text | null | Non | Max 500 caractères | Location à long terme |
| icone | String(50) | null | Non | - | rent |
| ordre | Integer | 0 | Non | >= 0 | 1 |
| statut | String(20) | actif | Oui | 'actif', 'inactif' | actif |
| date_creation | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |
| date_modification | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |

---

## PhotoLogement

**Description** : Photo d'un logement

| Attribut | Type | Défaut | Obligatoire | Contraintes | Exemple |
|----------|------|--------|-------------|-------------|---------|
| id | UUID | - | Oui | UUID v4 | 550e8400-e29b-41d4-a716-446655440040 |
| logement_id | UUID | - | Oui | FK vers Logement | 550e8400-e29b-41d4-a716-446655440020 |
| url | String(500) | - | Oui | URL valide | https://example.com/photo.jpg |
| miniature_url | String(500) | null | Non | URL valide | https://example.com/thumb.jpg |
| description | String(255) | null | Non | Max 255 caractères | Salon principal |
| ordre | Integer | 0 | Non | >= 0 | 1 |
| est_principale | Boolean | false | Non | - | true |
| statut | String(20) | actif | Oui | 'actif', 'inactif' | actif |
| date_creation | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |
| date_modification | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |

---

## VideoLogement

**Description** : Vidéo d'un logement

| Attribut | Type | Défaut | Obligatoire | Contraintes | Exemple |
|----------|------|--------|-------------|-------------|---------|
| id | UUID | - | Oui | UUID v4 | 550e8400-e29b-41d4-a716-446655440041 |
| logement_id | UUID | - | Oui | FK vers Logement | 550e8400-e29b-41d4-a716-446655440020 |
| url | String(500) | - | Oui | URL valide | https://example.com/video.mp4 |
| miniature_url | String(500) | null | Non | URL valide | https://example.com/thumb.jpg |
| description | String(255) | null | Non | Max 255 caractères | Visite guidée |
| duree | Integer | 0 | Non | >= 0, en secondes | 180 |
| ordre | Integer | 0 | Non | >= 0 | 1 |
| statut | String(20) | actif | Oui | 'actif', 'inactif' | actif |
| date_creation | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |
| date_modification | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |

---

## Equipement

**Description** : Équipement disponible dans un logement

| Attribut | Type | Défaut | Obligatoire | Contraintes | Exemple |
|----------|------|--------|-------------|-------------|---------|
| id | UUID | - | Oui | UUID v4 | 550e8400-e29b-41d4-a716-446655440050 |
| nom | String(100) | - | Oui | Unique | Climatisation |
| description | Text | null | Non | Max 500 caractères | Climatisation réversible |
| icone | String(50) | null | Non | - | ac |
| categorie | String(50) | - | Oui | - | confort |
| ordre | Integer | 0 | Non | >= 0 | 1 |
| statut | String(20) | actif | Oui | 'actif', 'inactif' | actif |
| date_creation | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |
| date_modification | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |

---

## Favori

**Description** : Favori d'un utilisateur pour un logement

| Attribut | Type | Défaut | Obligatoire | Contraintes | Exemple |
|----------|------|--------|-------------|-------------|---------|
| id | UUID | - | Oui | UUID v4 | 550e8400-e29b-41d4-a716-446655440060 |
| utilisateur_id | UUID | - | Oui | FK vers Utilisateur | 550e8400-e29b-41d4-a716-446655440000 |
| logement_id | UUID | - | Oui | FK vers Logement | 550e8400-e29b-41d4-a716-446655440020 |
| notes | Text | null | Non | Max 500 caractères | Très bien situé |
| statut | String(20) | actif | Oui | 'actif', 'inactif' | actif |
| date_creation | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |
| date_modification | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |

---

## Avis

**Description** : Avis et évaluation d'un logement

| Attribut | Type | Défaut | Obligatoire | Contraintes | Exemple |
|----------|------|--------|-------------|-------------|---------|
| id | UUID | - | Oui | UUID v4 | 550e8400-e29b-41d4-a716-446655440070 |
| utilisateur_id | UUID | - | Oui | FK vers Utilisateur | 550e8400-e29b-41d4-a716-446655440000 |
| logement_id | UUID | - | Oui | FK vers Logement | 550e8400-e29b-41d4-a716-446655440020 |
| note | Integer | - | Oui | 1 à 5 | 5 |
| commentaire | Text | null | Non | Max 1000 caractères | Très satisfait |
| reponse_bailleur | Text | null | Non | Max 1000 caractères | Merci pour votre avis |
| date_reponse | DateTime | NOW | Non | - | 2024-01-16 10:30:00 |
| est_verifie | Boolean | false | Non | - | true |
| statut | String(20) | actif | Oui | 'actif', 'inactif' | actif |
| date_creation | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |
| date_modification | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |

---

## Conversation

**Description** : Conversation entre deux utilisateurs

| Attribut | Type | Défaut | Obligatoire | Contraintes | Exemple |
|----------|------|--------|-------------|-------------|---------|
| id | UUID | - | Oui | UUID v4 | 550e8400-e29b-41d4-a716-446655440080 |
| participant1_id | UUID | - | Oui | FK vers Utilisateur | 550e8400-e29b-41d4-a716-446655440000 |
| participant2_id | UUID | - | Oui | FK vers Utilisateur | 550e8400-e29b-41d4-a716-446655440001 |
| logement_id | UUID | - | Oui | FK vers Logement | 550e8400-e29b-41d4-a716-446655440020 |
| dernier_message | Text | null | Non | Max 500 caractères | Bonjour, intéressé par... |
| date_dernier_message | DateTime | NOW | Non | - | 2024-01-15 10:30:00 |
| nombre_messages | Integer | 0 | Non | >= 0 | 15 |
| nombre_messages_non_lus | Integer | 0 | Non | >= 0 | 2 |
| statut | String(20) | actif | Oui | 'actif', 'inactif', 'archive' | actif |
| date_creation | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |
| date_modification | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |

---

## Message

**Description** : Message dans une conversation

| Attribut | Type | Défaut | Obligatoire | Contraintes | Exemple |
|----------|------|--------|-------------|-------------|---------|
| id | UUID | - | Oui | UUID v4 | 550e8400-e29b-41d4-a716-446655440081 |
| conversation_id | UUID | - | Oui | FK vers Conversation | 550e8400-e29b-41d4-a716-446655440080 |
| expediteur_id | UUID | - | Oui | FK vers Utilisateur | 550e8400-e29b-41d4-a716-446655440000 |
| destinataire_id | UUID | - | Oui | FK vers Utilisateur | 550e8400-e29b-41d4-a716-446655440001 |
| contenu | Text | - | Oui | Max 5000 caractères | Bonjour, je suis intéressé... |
| piece_jointe_url | String(500) | null | Non | URL valide | https://example.com/file.pdf |
| type | String(20) | texte | Oui | 'texte', 'image', 'document' | texte |
| est_lu | Boolean | false | Non | - | true |
| date_lecture | DateTime | NOW | Non | - | 2024-01-15 10:35:00 |
| statut | String(20) | actif | Oui | 'actif', 'supprime' | actif |
| date_creation | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |
| date_modification | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |

---

## ChatbotConversation

**Description** : Conversation avec le chatbot

| Attribut | Type | Défaut | Obligatoire | Contraintes | Exemple |
|----------|------|--------|-------------|-------------|---------|
| id | UUID | - | Oui | UUID v4 | 550e8400-e29b-41d4-a716-446655440090 |
| utilisateur_id | UUID | - | Oui | FK vers Utilisateur | 550e8400-e29b-41d4-a716-446655440000 |
| titre | String(255) | null | Non | - | Recherche appartement |
| contexte | Text | null | Non | Max 1000 caractères | Recherche 3 pièces Cocody |
| date_derniere_interaction | DateTime | NOW | Non | - | 2024-01-15 10:30:00 |
| nombre_messages | Integer | 0 | Non | >= 0 | 10 |
| statut | String(20) | actif | Oui | 'actif', 'inactif', 'archive' | actif |
| date_creation | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |
| date_modification | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |

---

## ChatbotMessage

**Description** : Message du chatbot

| Attribut | Type | Défaut | Obligatoire | Contraintes | Exemple |
|----------|------|--------|-------------|-------------|---------|
| id | UUID | - | Oui | UUID v4 | 550e8400-e29b-41d4-a716-446655440091 |
| conversation_id | UUID | - | Oui | FK vers ChatbotConversation | 550e8400-e29b-41d4-a716-446655440090 |
| contenu | Text | - | Oui | Max 5000 caractères | Je peux vous aider... |
| role | String(20) | - | Oui | 'user', 'assistant' | assistant |
| contexte | Text | null | Non | Max 1000 caractères | Contexte de la requête |
| donnees | JSON | null | Non | Structure JSON valide | {"logements": 5} |
| statut | String(20) | actif | Oui | 'actif', 'inactif' | actif |
| date_creation | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |
| date_modification | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |

---

## Notification

**Description** : Notification utilisateur

| Attribut | Type | Défaut | Obligatoire | Contraintes | Exemple |
|----------|------|--------|-------------|-------------|---------|
| id | UUID | - | Oui | UUID v4 | 550e8400-e29b-41d4-a716-446655440100 |
| utilisateur_id | UUID | - | Oui | FK vers Utilisateur | 550e8400-e29b-41d4-a716-446655440000 |
| titre | String(255) | - | Oui | Min 5 caractères | Nouveau message |
| message | Text | - | Oui | Max 1000 caractères | Vous avez reçu un message... |
| lien | String(500) | null | Non | URL valide | https://example.com/messages |
| type | String(50) | - | Oui | - | message |
| est_lue | Boolean | false | Non | - | false |
| date_lecture | DateTime | NOW | Non | - | 2024-01-15 10:35:00 |
| statut | String(20) | actif | Oui | 'actif', 'archive' | actif |
| date_creation | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |
| date_modification | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |

---

## Historique

**Description** : Historique des actions utilisateur

| Attribut | Type | Défaut | Obligatoire | Contraintes | Exemple |
|----------|------|--------|-------------|-------------|---------|
| id | UUID | - | Oui | UUID v4 | 550e8400-e29b-41d4-a716-446655440110 |
| utilisateur_id | UUID | - | Oui | FK vers Utilisateur | 550e8400-e29b-41d4-a716-446655440000 |
| type_action | String(50) | - | Oui | - | create_property |
| description | Text | null | Non | Max 500 caractères | Création logement |
| entite_id | UUID | null | Non | - | 550e8400-e29b-41d4-a716-446655440020 |
| entite_type | String(50) | null | Non | - | Logement |
| donnees | JSON | null | Non | Structure JSON valide | {"prix": 150000} |
| statut | String(20) | actif | Oui | 'actif', 'inactif' | actif |
| date_creation | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |
| date_modification | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |

---

## Recherche

**Description** : Recherche effectuée par un utilisateur

| Attribut | Type | Défaut | Obligatoire | Contraintes | Exemple |
|----------|------|--------|-------------|-------------|---------|
| id | UUID | - | Oui | UUID v4 | 550e8400-e29b-41d4-a716-446655440120 |
| utilisateur_id | UUID | - | Oui | FK vers Utilisateur | 550e8400-e29b-41d4-a716-446655440000 |
| terme | String(255) | null | Non | - | appartement cocody |
| categorie_id | UUID | null | Non | FK vers CategorieLogement | 550e8400-e29b-41d4-a716-446655440030 |
| type_id | UUID | null | Non | FK vers TypeLogement | 550e8400-e29b-41d4-a716-446655440031 |
| prix_min | Decimal(12,2) | null | Non | >= 0 | 50000.00 |
| prix_max | Decimal(12,2) | null | Non | >= 0 | 200000.00 |
| surface_min | Decimal(10,2) | null | Non | >= 0 | 50.00 |
| surface_max | Decimal(10,2) | null | Non | >= 0 | 200.00 |
| nombre_chambres_min | Integer | null | Non | >= 0 | 2 |
| nombre_chambres_max | Integer | null | Non | >= 0 | 4 |
| ville_id | UUID | null | Non | FK vers Ville | 550e8400-e29b-41d4-a716-446655440010 |
| quartier_id | UUID | null | Non | FK vers Quartier | 550e8400-e29b-41d4-a716-446655440011 |
| latitude | Decimal(10,8) | null | Non | -90 à 90 | 5.3456789 |
| longitude | Decimal(11,8) | null | Non | -180 à 180 | -4.1234567 |
| rayon | Decimal(10,2) | null | Non | >= 0, en km | 5.0 |
| equipements | JSON | [] | Non | Liste d'UUIDs | ["uuid1", "uuid2"] |
| resultats | Integer | 0 | Non | >= 0 | 25 |
| statut | String(20) | actif | Oui | 'actif', 'inactif' | actif |
| date_creation | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |
| date_modification | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |

---

## RechercheEnregistree

**Description** : Recherche sauvegardée par un utilisateur

| Attribut | Type | Défaut | Obligatoire | Contraintes | Exemple |
|----------|------|--------|-------------|-------------|---------|
| id | UUID | - | Oui | UUID v4 | 550e8400-e29b-41d4-a716-446655440121 |
| utilisateur_id | UUID | - | Oui | FK vers Utilisateur | 550e8400-e29b-41d4-a716-446655440000 |
| nom | String(255) | - | Oui | - | Ma recherche idéale |
| terme | String(255) | null | Non | - | appartement cocody |
| categorie_id | UUID | null | Non | FK vers CategorieLogement | 550e8400-e29b-41d4-a716-446655440030 |
| type_id | UUID | null | Non | FK vers TypeLogement | 550e8400-e29b-41d4-a716-446655440031 |
| prix_min | Decimal(12,2) | null | Non | >= 0 | 50000.00 |
| prix_max | Decimal(12,2) | null | Non | >= 0 | 200000.00 |
| surface_min | Decimal(10,2) | null | Non | >= 0 | 50.00 |
| surface_max | Decimal(10,2) | null | Non | >= 0 | 200.00 |
| nombre_chambres_min | Integer | null | Non | >= 0 | 2 |
| nombre_chambres_max | Integer | null | Non | >= 0 | 4 |
| ville_id | UUID | null | Non | FK vers Ville | 550e8400-e29b-41d4-a716-446655440010 |
| quartier_id | UUID | null | Non | FK vers Quartier | 550e8400-e29b-41d4-a716-446655440011 |
| latitude | Decimal(10,8) | null | Non | -90 à 90 | 5.3456789 |
| longitude | Decimal(11,8) | null | Non | -180 à 180 | -4.1234567 |
| rayon | Decimal(10,2) | null | Non | >= 0, en km | 5.0 |
| equipements | JSON | [] | Non | Liste d'UUIDs | ["uuid1", "uuid2"] |
| alerte_active | Boolean | false | Non | - | true |
| frequence_alerte | String(20) | immediat | Non | 'immediat', 'quotidien', 'hebdomadaire' | quotidien |
| statut | String(20) | actif | Oui | 'actif', 'inactif' | actif |
| date_creation | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |
| date_modification | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |

---

## Visite

**Description** : Visite programmée pour un logement

| Attribut | Type | Défaut | Obligatoire | Contraintes | Exemple |
|----------|------|--------|-------------|-------------|---------|
| id | UUID | - | Oui | UUID v4 | 550e8400-e29b-41d4-a716-446655440130 |
| logement_id | UUID | - | Oui | FK vers Logement | 550e8400-e29b-41d4-a716-446655440020 |
| client_id | UUID | - | Oui | FK vers Client | 550e8400-e29b-41d4-a716-446655440003 |
| bailleur_id | UUID | - | Oui | FK vers Bailleur | 550e8400-e29b-41d4-a716-446655440004 |
| date_visite | Date | - | Oui | - | 2024-01-20 |
| heure_debut | String(10) | null | Non | Format HH:MM | 10:00 |
| heure_fin | String(10) | null | Non | Format HH:MM | 11:00 |
| statut_visite | String(30) | en_attente | Oui | 'en_attente', 'confirme', 'annule', 'effectue' | confirme |
| notes | Text | null | Non | Max 500 caractères | Apporter pièce identité |
| feedback | Text | null | Non | Max 1000 caractères | Tr bonne visite |
| statut | String(20) | actif | Oui | 'actif', 'inactif' | actif |
| date_creation | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |
| date_modification | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |

---

## PlanningVisite

**Description** : Planning des créneaux de visite d'un bailleur

| Attribut | Type | Défaut | Obligatoire | Contraintes | Exemple |
|----------|------|--------|-------------|-------------|---------|
| id | UUID | - | Oui | UUID v4 | 550e8400-e29b-41d4-a716-446655440131 |
| bailleur_id | UUID | - | Oui | FK vers Bailleur | 550e8400-e29b-41d4-a716-446655440004 |
| logement_id | UUID | - | Oui | FK vers Logement | 550e8400-e29b-41d4-a716-446655440020 |
| creneaux | JSON | [] | Non | Liste de créneaux | ["Lundi 10-12", "Mercredi 14-16"] |
| instructions | Text | null | Non | Max 500 caractères | Appeler avant venue |
| duree_visite | Integer | 30 | Non | >= 0, en minutes | 30 |
| delai_reservation | Integer | 24 | Non | >= 0, en heures | 24 |
| statut | String(20) | actif | Oui | 'actif', 'inactif' | actif |
| date_creation | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |
| date_modification | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |

---

## Signalement

**Description** : Signalement de contenu inapproprié

| Attribut | Type | Défaut | Obligatoire | Contraintes | Exemple |
|----------|------|--------|-------------|-------------|---------|
| id | UUID | - | Oui | UUID v4 | 550e8400-e29b-41d4-a716-446655440140 |
| auteur_id | UUID | - | Oui | FK vers Utilisateur | 550e8400-e29b-41d4-a716-446655440000 |
| entite_id | UUID | - | Oui | - | 550e8400-e29b-41d4-a716-446655440020 |
| entite_type | String(50) | - | Oui | - | Logement |
| motif | String(100) | - | Oui | - | Contenu inapproprié |
| description | Text | null | Non | Max 1000 caractères | Photos ne correspondent pas |
| statut_signalement | String(30) | en_attente | Oui | 'en_attente', 'en_cours', 'resolu', 'rejete' | resolu |
| reponse_admin | Text | null | Non | Max 1000 caractères | Signalement traité |
| date_traitement | DateTime | null | Non | - | 2024-01-16 10:30:00 |
| traite_par_id | UUID | null | Non | FK vers Administrateur | 550e8400-e29b-41d4-a716-446655440005 |
| statut | String(20) | actif | Oui | 'actif', 'inactif' | actif |
| date_creation | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |
| date_modification | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |

---

## DocumentVerification

**Description** : Document de vérification utilisateur

| Attribut | Type | Défaut | Obligatoire | Contraintes | Exemple |
|----------|------|--------|-------------|-------------|---------|
| id | UUID | - | Oui | UUID v4 | 550e8400-e29b-41d4-a716-446655440150 |
| utilisateur_id | UUID | - | Oui | FK vers Utilisateur | 550e8400-e29b-41d4-a716-446655440000 |
| type_document | String(50) | - | Oui | - | CNI |
| numero_document | String(50) | - | Oui | - | CI1234567890 |
| url_document | String(500) | null | Non | URL valide | https://example.com/doc.pdf |
| url_recto | String(500) | null | Non | URL valide | https://example.com/recto.jpg |
| url_verso | String(500) | null | Non | URL valide | https://example.com/verso.jpg |
| date_expiration | Date | - | Oui | - | 2030-01-15 |
| statut_verification | String(30) | en_attente | Oui | 'en_attente', 'approuve', 'refuse' | approuve |
| commentaire | Text | null | Non | Max 500 caractères | Document valide |
| date_verification | DateTime | null | Non | - | 2024-01-16 10:30:00 |
| verifie_par_id | UUID | null | Non | FK vers Administrateur | 550e8400-e29b-41d4-a716-446655440005 |
| statut | String(20) | actif | Oui | 'actif', 'inactif', 'expire' | actif |
| date_creation | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |
| date_modification | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |

---

## SessionUtilisateur

**Description** : Session utilisateur avec tokens

| Attribut | Type | Défaut | Obligatoire | Contraintes | Exemple |
|----------|------|--------|-------------|-------------|---------|
| id | UUID | - | Oui | UUID v4 | 550e8400-e29b-41d4-a716-446655440160 |
| utilisateur_id | UUID | - | Oui | FK vers Utilisateur | 550e8400-e29b-41d4-a716-446655440000 |
| token_access_token | String(500) | - | Oui | JWT token | eyJhbGciOiJIUzI1NiIs... |
| token_refresh_token | String(500) | null | Non | JWT token | eyJhbGciOiJIUzI1NiIs... |
| date_debut | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |
| date_fin | DateTime | null | Non | - | 2024-01-22 10:30:00 |
| device_id | String(255) | null | Non | - | device123 |
| ip_address | String(50) | null | Non | - | 192.168.1.1 |
| user_agent | String(500) | null | Non | - | Mozilla/5.0... |
| localisation | String(255) | null | Non | - | Abidjan, CI |
| est_active | Boolean | true | Non | - | true |
| statut | String(20) | actif | Oui | 'actif', 'expire', 'revoque' | actif |
| date_creation | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |
| date_modification | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |

---

## ParametreUtilisateur

**Description** : Paramètres et préférences utilisateur

| Attribut | Type | Défaut | Obligatoire | Contraintes | Exemple |
|----------|------|--------|-------------|-------------|---------|
| id | UUID | - | Oui | UUID v4 | 550e8400-e29b-41d4-a716-446655440170 |
| utilisateur_id | UUID | - | Oui | FK vers Utilisateur | 550e8400-e29b-41d4-a716-446655440000 |
| langue | String(10) | fr | Non | Code langue ISO | fr |
| fuseau_horaire | String(50) | UTC | Non | - | Africa/Abidjan |
| notifications_email | Boolean | true | Non | - | true |
| notifications_push | Boolean | true | Non | - | true |
| notifications_sms | Boolean | false | Non | - | false |
| profil_public | Boolean | false | Non | - | false |
| localisation_partagee | Boolean | false | Non | - | false |
| theme | String(20) | null | Non | 'light', 'dark' | dark |
| frequence_newsletter | String(20) | null | Non | 'quotidien', 'hebdomadaire', 'mensuel' | hebdomadaire |
| statut | String(20) | actif | Oui | 'actif', 'inactif' | actif |
| date_creation | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |
| date_modification | DateTime | NOW | Oui | - | 2024-01-15 10:30:00 |
