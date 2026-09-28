# Règles Métier - GestionBailleur

## Table des matières

1. [Authentification et Comptes](#authentification-et-comptes)
2. [Gestion des Utilisateurs](#gestion-des-utilisateurs)
3. [Logements](#logements)
4. [Catégories et Types](#catégories-et-types)
5. [Recherche et Filtres](#recherche-et-filtres)
6. [Favoris](#favoris)
7. [Messagerie](#messagerie)
8. [Visites](#visites)
9. [Avis et Évaluations](#avis-et-évaluations)
10. [Notifications](#notifications)
11. [Signalements](#signalements)
12. [Vérification](#vérification)
13. [Chatbot](#chatbot)
14. [Fichiers](#fichiers)

---

## Authentification et Comptes

### Inscription
- Un utilisateur peut s'inscrire avec email/mot de passe
- Un utilisateur peut s'inscrire via réseaux sociaux (Google, Facebook, Apple)
- Un utilisateur peut s'inscrire via numéro de téléphone
- L'email doit être unique dans le système
- Le numéro de téléphone doit être unique
- Le mot de passe doit respecter les exigences de sécurité (min 8 caractères, majuscule, minuscule, chiffre, spécial)
- L'email doit être vérifié avant activation complète du compte

### Connexion
- Un utilisateur peut se connecter avec email/mot de passe
- Un utilisateur peut se connecter via réseaux sociaux
- Un utilisateur peut se connecter via numéro de téléphone + OTP
- Après 5 tentatives échouées, le compte est temporairement bloqué (15 minutes)
- Les tokens JWT expirent après 1 heure
- Les tokens de refresh expirent après 7 jours

### Rôles
- **Visiteur** : Non connecté, accès limité
- **Client** : Locataire potentiel
- **Bailleur** : Propriétaire de logements
- **Administrateur** : Gestionnaire de la plateforme

### Vérification Email
- Un email de vérification est envoyé lors de l'inscription
- Le lien de vérification expire après 24 heures
- L'utilisateur peut demander un nouvel email de vérification (max 3/jour)

### Réinitialisation Mot de Passe
- Un utilisateur peut demander une réinitialisation via email
- Le lien de réinitialisation expire après 1 heure
- Le nouveau mot de passe doit être différent des 3 précédents

---

## Gestion des Utilisateurs

### Profil Utilisateur
- Un utilisateur doit compléter son profil pour certaines fonctionnalités
- Les informations personnelles sont modifiables par l'utilisateur
- La photo de profil est optionnelle mais recommandée
- Les réseaux sociaux sont optionnels

### Profil Client
- Un client doit fournir ses informations de contact
- Un client peut ajouter un garant (optionnel)
- Un client peut uploader des documents d'identité
- Les documents du client doivent être vérifiés par un administrateur

### Profil Bailleur
- Un bailleur doit être vérifié avant de publier des annonces
- Un bailleur professionnel doit fournir des documents juridiques
- Un bailleur peut avoir plusieurs biens immobiliers
- Un bailleur peut suspendre temporairement son compte

### Profil Administrateur
- Un administrateur a accès à toutes les fonctionnalités
- Un administrateur peut être assigné à un département spécifique
- Un administrateur peut avoir un supérieur hiérarchique
- Un super administrateur a tous les droits

### Suspension de Compte
- Un administrateur peut suspendre un compte pour violation
- La suspension peut être temporaire ou permanente
- L'utilisateur concerné est notifié de la suspension
- Un utilisateur suspendu ne peut pas se connecter

---

## Logements

### Création de Logement
- Seul un bailleur vérifié peut créer un logement
- Un logement doit avoir au minimum une photo
- Le titre du logement est obligatoire (max 100 caractères)
- La description est obligatoire (min 50 caractères)
- Le prix est obligatoire et doit être positif
- La localisation est obligatoire
- La catégorie et le type sont obligatoires

### Publication de Logement
- Un logement créé est automatiquement en brouillon
- Un bailleur peut publier un logement après validation
- Un logement publié est visible par tous les visiteurs
- Un logement peut être mis en pause par le bailleur
- Un logement en pause n'est plus visible

### Modification de Logement
- Le bailleur peut modifier son logement à tout moment
- Les modifications sont soumises à validation si elles affectent le prix
- L'historique des modifications est conservé
- Les modifications majeures nécessitent une nouvelle validation

### Suppression de Logement
- Un bailleur peut supprimer son logement
- Un logement avec des visites en cours ne peut pas être supprimé
- Un logement avec des contrats actifs ne peut pas être supprimé
- La suppression est définitive après 30 jours

### Photos de Logement
- Un logement peut avoir jusqu'à 20 photos
- La photo principale est affichée en premier
- Les photos doivent être en format JPG, PNG ou WEBP
- La taille maximale par photo est 5MB
- L'ordre des photos peut être modifié

### Vidéos de Logement
- Un logement peut avoir jusqu'à 5 vidéos
- Les vidéos doivent être en format MP4, AVI ou MOV
- La taille maximale par vidéo est 100MB
- La durée maximale par vidéo est 5 minutes

### Équipements
- Un logement peut avoir plusieurs équipements
- Les équipements sont prédéfinis dans le système
- Le bailleur peut sélectionner les équipements disponibles
- Les équipements personnalisés ne sont pas autorisés

### Prix et Conditions
- Le prix est exprimé en FCFA (devise par défaut)
- Le cautionnement est optionnel (max 3 mois de loyer)
- L'avance est optionnelle (max 2 mois de loyer)
- Le bailleur peut modifier le prix (avec validation)

### Statistiques de Logement
- Le nombre de vues est compté pour chaque logement
- Le nombre de favoris est compté
- Le nombre de partages est compté
- Ces statistiques sont visibles par le bailleur uniquement

---

## Catégories et Types

### Catégories de Logement
- Les catégories sont prédéfinies par l'administration
- Exemples : Appartement, Villa, Studio, Bureau, Terrain
- Une catégorie peut être désactivée mais pas supprimée
- L'ordre des catégories est configurable

### Types de Logement
- Les types définissent l'usage : Location, Vente, Colocation
- Un type peut être désactivé mais pas supprimé
- L'ordre des types est configurable

### Relation Catégorie/Type
- Un logement appartient à une seule catégorie
- Un logement appartient à un seul type
- La combinaison catégorie/type doit être valide

---

## Recherche et Filtres

### Recherche Textuelle
- Les visiteurs peuvent effectuer une recherche textuelle
- La recherche porte sur le titre et la description
- La recherche est insensible à la casse
- Les résultats sont triés par pertinence

### Filtres Avancés
- Les utilisateurs peuvent filtrer par prix (min/max)
- Les utilisateurs peuvent filtrer par surface (min/max)
- Les utilisateurs peuvent filtrer par nombre de pièces
- Les utilisateurs peuvent filtrer par localisation
- Les utilisateurs peuvent filtrer par équipements
- Les utilisateurs peuvent filtrer par disponibilité

### Recherche Géolocalisée
- Les utilisateurs peuvent rechercher autour d'une position
- Le rayon de recherche est configurable (1km à 50km)
- Les résultats sont triés par distance

### Recherche Enregistrée
- Un utilisateur connecté peut enregistrer une recherche
- Une recherche enregistrée peut avoir un nom personnalisé
- L'utilisateur peut activer des alertes pour une recherche enregistrée
- Les alertes peuvent être immédiates, quotidiennes ou hebdomadaires

### Historique de Recherche
- L'historique de recherche est conservé pour chaque utilisateur
- L'historique est limité aux 50 dernières recherches
- L'utilisateur peut effacer son historique

---

## Favoris

### Ajout aux Favoris
- Un utilisateur connecté peut ajouter un logement aux favoris
- Un logement ne peut être ajouté qu'une fois par utilisateur
- L'utilisateur peut ajouter une note personnelle
- L'ajout aux favoris est instantané

### Retrait des Favoris
- L'utilisateur peut retirer un logement des favoris
- Le retrait est instantané
- L'historique des favoris est conservé

### Liste des Favoris
- L'utilisateur peut voir tous ses favoris
- Les favoris peuvent être triés par date, prix ou pertinence
- Les favoris peuvent être filtrés par catégorie

---

## Messagerie

### Création de Conversation
- Un client peut initier une conversation avec un bailleur
- La conversation est liée à un logement spécifique
- Un bailleur ne peut pas initier une conversation
- Une conversation ne peut avoir que 2 participants

### Messages
- Les messages sont chronologiques
- Les messages peuvent contenir du texte
- Les messages peuvent contenir des pièces jointes (max 10MB)
- Les messages ne peuvent pas être modifiés après envoi
- Les messages ne peuvent pas être supprimés

### Lecture des Messages
- L'expéditeur peut voir si son message a été lu
- Le destinataire reçoit une notification pour chaque message
- Les messages non lus sont comptés par conversation

### Pièces Jointes
- Les pièces jointes sont limitées à 10MB par fichier
- Les formats autorisés : images, PDF, documents
- Les pièces jointes sont stockées de manière sécurisée

### Modération
- Les messages contenant du contenu inapproprié peuvent être signalés
- Un administrateur peut supprimer un message inapproprié
- L'auteur du message est notifié en cas de suppression

---

## Visites

### Demande de Visite
- Un client peut demander une visite pour un logement
- Le bailleur doit avoir défini des créneaux de visite
- Le client doit choisir un créneau disponible
- La demande de visite doit être confirmée par le bailleur

### Confirmation de Visite
- Le bailleur peut accepter ou refuser une demande
- Le bailleur peut proposer un autre créneau
- Le client est notifié de la décision
- Une visite confirmée ne peut être annulée que 24h avant

### Planning de Visite
- Le bailleur définit ses créneaux de disponibilité
- Les créneaux peuvent être récurrents (hebdomadaire)
- Le bailleur peut suspendre temporairement les visites
- Deux visites ne peuvent pas se chevaucher

### Déroulement de Visite
- Le bailleur et le client reçoivent un rappel 24h avant
- Le bailleur peut marquer la visite comme effectuée
- Le client peut laisser un avis après la visite
- Les visites non effectuées sont notées

### Historique de Visites
- L'historique des visites est conservé
- Le bailleur peut voir toutes ses visites
- Le client peut voir ses visites passées

---

## Avis et Évaluations

### Publication d'Avis
- Un client peut laisser un avis après une visite effectuée
- Un avis doit contenir une note (1 à 5 étoiles)
- Un avis peut contenir un commentaire
- Un client ne peut laisser qu'un avis par logement
- Les avis sont visibles par tous les visiteurs

### Modération des Avis
- Les avis contenant du contenu inapproprié peuvent être signalés
- Un administrateur peut modérer ou supprimer un avis
- L'auteur de l'avis est notifié en cas de suppression

### Réponse du Bailleur
- Le bailleur peut répondre à un avis
- La réponse est visible avec l'avis
- La réponse ne peut être modifiée après envoi

### Calcul de la Note Moyenne
- La note moyenne est calculée automatiquement
- Seuls les avis vérifiés sont comptés
- La note est affichée avec une décimale

---

## Notifications

### Types de Notifications
- Nouveau message
- Demande de visite
- Confirmation de visite
- Nouvel avis
- Mise à jour de logement favori
- Alertes de recherche
- Notifications système

### Canaux de Notification
- Email (configurable)
- Push notification (application mobile)
- SMS (configurable)
- In-app notification

### Préférences de Notification
- L'utilisateur peut configurer ses préférences
- L'utilisateur peut désactiver certains types de notifications
- L'utilisateur peut choisir la fréquence des alertes

### Lecture des Notifications
- Les notifications non lus sont comptées
- Une notification marquée comme lue ne peut être relue
- L'historique des notifications est conservé (90 jours)

---

## Signalements

### Types de Signalement
- Logement inapproprié
- Contenu offensant
- Arnaque suspectée
- Utilisateur abusif
- Autre

### Processus de Signalement
- Tout utilisateur connecté peut signaler
- Le signalement doit contenir un motif
- Le signalement peut contenir une description
- L'auteur du signalement reste anonyme

### Traitement des Signalements
- Un administrateur est notifié pour chaque signalement
- L'administrateur peut enquêter sur le signalement
- L'administrateur peut prendre des mesures (suspension, suppression)
- L'auteur du signalement est notifié de la décision

### Statistiques de Signalement
- Le nombre de signalements est compté par utilisateur
- Les utilisateurs avec trop de signalements peuvent être bannis

---

## Vérification

### Documents Requis
- Pièce d'identité (CNI, passeport)
- Justificatif de domicile
- Revenus (pour clients)
- Documents juridiques (pour bailleurs)

### Processus de Vérification
- L'utilisateur upload ses documents
- Les documents sont soumis à vérification
- Un administrateur vérifie les documents
- La vérification peut être acceptée ou refusée

### Expiration des Documents
- Les documents ont une date d'expiration
- L'utilisateur est notifié avant expiration
- Les documents expirés doivent être renouvelés

### Confidentialité
- Les documents sont stockés de manière sécurisée
- Seuls les administrateurs autorisés peuvent y accéder
- Les documents sont supprimés après suppression du compte

---

## Chatbot

### Fonctionnalités
- Le chatbot peut répondre aux questions fréquentes
- Le chatbot peut aider à la recherche de logements
- Le chatbot peut orienter vers les bonnes ressources
- Le chatbot ne peut pas effectuer d'actions

### Limitations
- Le chatbot ne peut pas accéder aux données personnelles
- Le chatbot ne peut pas modifier des données
- Le chatbot ne peut pas prendre de décisions

### Historique des Conversations
- L'historique des conversations chatbot est conservé
- L'utilisateur peut effacer son historique
- Les conversations sont utilisées pour améliorer le chatbot

---

## Fichiers

### Upload de Fichiers
- Les fichiers sont limités à 10MB
- Les formats autorisés sont définis par type
- Les fichiers sont scannés pour détecter les virus
- Les fichiers sont stockés de manière sécurisée

### Types de Fichiers
- Images : JPG, PNG, WEBP, GIF
- Documents : PDF, DOC, DOCX, TXT
- Vidéos : MP4, AVI, MOV, MKV

### Suppression de Fichiers
- Les fichiers peuvent être supprimés par leur propriétaire
- Les fichiers utilisés ne peuvent pas être supprimés
- Les fichiers sont supprimés définitivement après 30 jours

### Stockage
- Les fichiers sont stockés sur S3 en production
- Les fichiers sont stockés localement en développement
- Les fichiers sont compressés automatiquement
