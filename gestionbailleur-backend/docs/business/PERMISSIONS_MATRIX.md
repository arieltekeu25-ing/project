# Matrice des Permissions - GestionBailleur

## Table des matières

1. [Légende](#légende)
2. [Gestion des Comptes](#gestion-des-comptes)
3. [Gestion des Logements](#gestion-des-logements)
4. [Gestion des Visites](#gestion-des-visites)
5. [Messagerie](#messagerie)
6. [Avis et Évaluations](#avis-et-évaluations)
7. [Signalements](#signalements)
8. [Administration](#administration)

---

## Légende

- ✅ **Autorisé** - L'action est permise
- ❌ **Non autorisé** - L'action n'est pas permise
- 🔒 **Conditionnel** - L'action est permise sous certaines conditions
- 📋 **Lecture seule** - Seule la lecture est permise

---

## Gestion des Comptes

| Action | Visiteur | Client | Bailleur | Administrateur |
|--------|----------|--------|----------|----------------|
| S'inscrire | ✅ | ❌ | ❌ | ❌ |
| Se connecter | ✅ | ✅ | ✅ | ✅ |
| Voir son profil | ❌ | ✅ | ✅ | ✅ |
| Modifier son profil | ❌ | ✅ | ✅ | ✅ |
| Voir profil autre utilisateur | 📋 | 📋 | 📋 | ✅ |
| Supprimer son compte | ❌ | ✅ | ✅ | ❌ |
| Vérifier email | ✅ | ✅ | ✅ | ✅ |
| Réinitialiser mot de passe | ✅ | ✅ | ✅ | ✅ |
| Gérer ses paramètres | ❌ | ✅ | ✅ | ✅ |
| Voir ses documents | ❌ | ✅ | ✅ | ✅ |
| Uploader documents | ❌ | ✅ | ✅ | ❌ |
| Suspendre un compte | ❌ | ❌ | ❌ | ✅ |
| Bannir un utilisateur | ❌ | ❌ | ❌ | ✅ |
| Voir tous les utilisateurs | ❌ | ❌ | ❌ | ✅ |
| Modifier rôle utilisateur | ❌ | ❌ | ❌ | ✅ |

---

## Gestion des Logements

| Action | Visiteur | Client | Bailleur | Administrateur |
|--------|----------|--------|----------|----------------|
| Voir liste logements | ✅ | ✅ | ✅ | ✅ |
| Voir détail logement | ✅ | ✅ | ✅ | ✅ |
| Rechercher logements | ✅ | ✅ | ✅ | ✅ |
| Créer un logement | ❌ | ❌ | 🔒 | ❌ |
| Modifier son logement | ❌ | ❌ | ✅ | ✅ |
| Supprimer son logement | ❌ | ❌ | 🔒 | ✅ |
| Publier un logement | ❌ | ❌ | 🔒 | ✅ |
| Mettre en pause logement | ❌ | ❌ | ✅ | ✅ |
| Archiver logement | ❌ | ❌ | ✅ | ✅ |
| Ajouter photos | ❌ | ❌ | ✅ | ✅ |
| Supprimer photos | ❌ | ❌ | ✅ | ✅ |
| Ajouter vidéos | ❌ | ❌ | ✅ | ✅ |
| Supprimer vidéos | ❌ | ❌ | ✅ | ✅ |
| Modifier prix | ❌ | ❌ | 🔒 | ✅ |
| Voir statistiques logement | ❌ | ❌ | ✅ | ✅ |
| Signaler un logement | ❌ | ✅ | ❌ | ✅ |
| Approuver logement | ❌ | ❌ | ❌ | ✅ |
| Rejeter logement | ❌ | ❌ | ❌ | ✅ |
| Voir tous les logements | ❌ | ❌ | ❌ | ✅ |
| Modifier logement autre | ❌ | ❌ | ❌ | ✅ |

**Conditions :**
- 🔒 Créer logement : Bailleur doit être vérifié
- 🔒 Supprimer logement : Aucune visite en cours, aucun contrat actif
- 🔒 Modifier prix : Soumis à validation si variation > 10%
- 🔒 Publier logement : Bailleur vérifié, minimum 1 photo

---

## Gestion des Favoris

| Action | Visiteur | Client | Bailleur | Administrateur |
|--------|----------|--------|----------|----------------|
| Voir ses favoris | ❌ | ✅ | ✅ | ✅ |
| Ajouter aux favoris | ❌ | ✅ | ✅ | ✅ |
| Retirer des favoris | ❌ | ✅ | ✅ | ✅ |
| Voir favoris autre | ❌ | ❌ | ❌ | ✅ |

---

## Gestion des Visites

| Action | Visiteur | Client | Bailleur | Administrateur |
|--------|----------|--------|----------|----------------|
| Demander une visite | ❌ | ✅ | ❌ | ✅ |
| Voir ses visites | ❌ | ✅ | ✅ | ✅ |
| Accepter une visite | ❌ | ❌ | ✅ | ✅ |
| Refuser une visite | ❌ | ❌ | ✅ | ✅ |
| Proposer autre créneau | ❌ | ❌ | ✅ | ✅ |
| Annuler une visite | ❌ | 🔒 | 🔒 | ✅ |
| Marquer visite effectuée | ❌ | ❌ | ✅ | ✅ |
| Voir planning visites | ❌ | ❌ | ✅ | ✅ |
| Créer planning visites | ❌ | ❌ | ✅ | ❌ |
| Modifier planning visites | ❌ | ❌ | ✅ | ✅ |
| Supprimer planning visites | ❌ | ❌ | ✅ | ✅ |
| Voir toutes les visites | ❌ | ❌ | ❌ | ✅ |

**Conditions :**
- 🔒 Annuler visite : Minimum 24h avant le créneau
- 🔒 Annuler visite : Bailleur peut annuler sans délai si motif valable

---

## Messagerie

| Action | Visiteur | Client | Bailleur | Administrateur |
|--------|----------|--------|----------|----------------|
| Initier conversation | ❌ | ✅ | ❌ | ✅ |
| Répondre à message | ❌ | ✅ | ✅ | ✅ |
| Voir ses conversations | ❌ | ✅ | ✅ | ✅ |
| Voir conversation autre | ❌ | ❌ | ❌ | ✅ |
| Envoyer message | ❌ | ✅ | ✅ | ✅ |
| Envoyer pièce jointe | ❌ | ✅ | ✅ | ✅ |
| Supprimer message | ❌ | ❌ | ❌ | ✅ |
| Signaler message | ❌ | ✅ | ✅ | ✅ |
| Voir toutes les conversations | ❌ | ❌ | ❌ | ✅ |
| Modérer conversation | ❌ | ❌ | ❌ | ✅ |

---

## Avis et Évaluations

| Action | Visiteur | Client | Bailleur | Administrateur |
|--------|----------|--------|----------|----------------|
| Voir avis logement | ✅ | ✅ | ✅ | ✅ |
| Laisser un avis | ❌ | 🔒 | ❌ | ✅ |
| Modifier son avis | ❌ | ✅ | ❌ | ✅ |
| Supprimer son avis | ❌ | ❌ | ❌ | ✅ |
| Répondre à un avis | ❌ | ❌ | ✅ | ✅ |
| Signaler un avis | ❌ | ✅ | ✅ | ✅ |
| Supprimer un avis | ❌ | ❌ | ❌ | ✅ |
| Voir tous les avis | ❌ | ❌ | ❌ | ✅ |

**Conditions :**
- 🔒 Laisser avis : Visite effectuée, 1 avis par logement maximum

---

## Signalements

| Action | Visiteur | Client | Bailleur | Administrateur |
|--------|----------|--------|----------|----------------|
| Signaler contenu | ❌ | ✅ | ✅ | ✅ |
| Voir ses signalements | ❌ | ✅ | ✅ | ✅ |
| Traiter signalement | ❌ | ❌ | ❌ | ✅ |
| Rejeter signalement | ❌ | ❌ | ❌ | ✅ |
| Voir tous les signalements | ❌ | ❌ | ❌ | ✅ |
| Supprimer signalement | ❌ | ❌ | ❌ | ✅ |

---

## Recherche

| Action | Visiteur | Client | Bailleur | Administrateur |
|--------|----------|--------|----------|----------------|
| Effectuer recherche | ✅ | ✅ | ✅ | ✅ |
| Enregistrer recherche | ❌ | ✅ | ✅ | ✅ |
| Modifier recherche enregistrée | ❌ | ✅ | ✅ | ✅ |
| Supprimer recherche enregistrée | ❌ | ✅ | ✅ | ✅ |
| Activer alertes recherche | ❌ | ✅ | ✅ | ✅ |
| Voir historique recherche | ❌ | ✅ | ✅ | ✅ |
| Voir recherches autres | ❌ | ❌ | ❌ | ✅ |

---

## Notifications

| Action | Visiteur | Client | Bailleur | Administrateur |
|--------|----------|--------|----------|----------------|
| Voir ses notifications | ❌ | ✅ | ✅ | ✅ |
| Marquer comme lue | ❌ | ✅ | ✅ | ✅ |
| Configurer préférences | ❌ | ✅ | ✅ | ✅ |
| Envoyer notification | ❌ | ❌ | ❌ | ✅ |
| Voir notifications autres | ❌ | ❌ | ❌ | ✅ |

---

## Chatbot

| Action | Visiteur | Client | Bailleur | Administrateur |
|--------|----------|--------|----------|----------------|
| Utiliser chatbot | ✅ | ✅ | ✅ | ✅ |
| Voir historique chatbot | ❌ | ✅ | ✅ | ✅ |
| Supprimer conversation chatbot | ❌ | ✅ | ✅ | ✅ |
| Voir conversations chatbot autres | ❌ | ❌ | ❌ | ✅ |

---

## Vérification

| Action | Visiteur | Client | Bailleur | Administrateur |
|--------|----------|--------|----------|----------------|
| Uploader documents | ❌ | ✅ | ✅ | ❌ |
| Voir statut vérification | ❌ | ✅ | ✅ | ✅ |
| Approuver documents | ❌ | ❌ | ❌ | ✅ |
| Rejeter documents | ❌ | ❌ | ❌ | ✅ |
| Demander nouvelle vérification | ❌ | ✅ | ✅ | ❌ |
| Voir tous les documents | ❌ | ❌ | ❌ | ✅ |

---

## Administration

| Action | Visiteur | Client | Bailleur | Administrateur |
|--------|----------|--------|----------|----------------|
| Accéder admin panel | ❌ | ❌ | ❌ | ✅ |
| Voir statistiques globales | ❌ | ❌ | ❌ | ✅ |
| Gérer catégories | ❌ | ❌ | ❌ | ✅ |
| Gérer types | ❌ | ❌ | ❌ | ✅ |
| Gérer équipements | ❌ | ❌ | ❌ | ✅ |
| Gérer villes | ❌ | ❌ | ❌ | ✅ |
| Gérer quartiers | ❌ | ❌ | ❌ | ✅ |
| Voir logs système | ❌ | ❌ | ❌ | ✅ |
| Gérer administrateurs | ❌ | ❌ | ❌ | 🔒 |
| Exporter données | ❌ | ❌ | ❌ | ✅ |
| Configurer système | ❌ | ❌ | ❌ | 🔒 |

**Conditions :**
- 🔒 Gérer administrateurs : Seul super administrateur
- 🔒 Configurer système : Seul super administrateur

---

## Permissions Spéciales par Rôle

### Visiteur
- Peut consulter les logements publiqués
- Peut s'inscrire et se connecter
- Peut utiliser le chatbot
- Peut effectuer des recherches

### Client
- Toutes les permissions visiteur
- Peut contacter les bailleurs
- Peut demander des visites
- Peut laisser des avis (après visite)
- Peut gérer ses favoris
- Peut enregistrer des recherches

### Bailleur
- Toutes les permissions visiteur
- Peut créer et gérer ses logements
- Peut répondre aux messages
- Peut gérer les visites
- Peut répondre aux avis
- Peut définir son planning de visites
- Doit être vérifié pour publier

### Administrateur
- Toutes les permissions
- Peut modérer le contenu
- Peut gérer les utilisateurs
- Peut accéder aux statistiques
- Peut configurer le système
- Peut voir toutes les données

---

## Restrictions Spéciales

### Restrictions Temporelles
- Un client ne peut pas annuler une visite moins de 24h avant
- Un bailleur ne peut pas modifier le prix plus de 2 fois par mois
- Un utilisateur ne peut pas laisser plus d'un avis par logement

### Restrictions Quantitatives
- Un logement maximum 20 photos
- Un logement maximum 5 vidéos
- Une conversation maximum 2 participants
- Une recherche maximum 50 filtres

### Restrictions de Contenu
- Les messages ne peuvent pas être modifiés après envoi
- Les avis ne peuvent pas être modifiés après 24h
- Les signalements sont anonymes pour l'auteur

### Restrictions de Sécurité
- Un utilisateur suspendu ne peut pas se connecter
- Un bailleur non vérifié ne peut pas publier
- Les documents expirés doivent être renouvelés
