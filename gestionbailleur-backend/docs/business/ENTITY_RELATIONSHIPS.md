# Relations entre Entités - GestionBailleur

## Vue d'ensemble

Ce document décrit toutes les relations entre les entités du système GestionBailleur.

## Diagramme des Relations Principales

```
┌─────────────────┐
│   Utilisateur    │
└────────┬────────┘
         │
         ├──────────────┬──────────────┬──────────────┐
         │              │              │              │
         ▼              ▼              ▼              ▼
┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│   Profil    │ │   Client    │ │  Bailleur   │ │Administrateur│
└─────────────┘ └──────┬──────┘ └──────┬──────┘ └─────────────┘
                      │               │
                      │               │
                      ▼               ▼
               ┌─────────────┐ ┌─────────────┐
               │   Favori    │ │  Logement   │
               └──────┬──────┘ └──────┬──────┘
                      │               │
                      │               │
                      └───────┬───────┘
                              │
                              ▼
                       ┌─────────────┐
                       │  Adresse    │
                       └──────┬──────┘
                              │
                              ▼
                       ┌─────────────┐
                       │    Ville    │
                       └──────┬──────┘
                              │
                              ▼
                       ┌─────────────┐
                       │  Quartier   │
                       └─────────────┘
```

## Relations Détaillées

### 1. Utilisateur

**Relations :**
- **1:1** avec Profil
- **1:1** avec Client (si rôle = client)
- **1:1** avec Bailleur (si rôle = bailleur)
- **1:1** avec Administrateur (si rôle = administrateur)
- **1:N** avec SessionUtilisateur
- **1:N** with ParametreUtilisateur
- **1:N** avec Favori
- **1:N** avec Avis
- **1:N** avec Conversation (participant1 ou participant2)
- **1:N** avec Message (expéditeur ou destinataire)
- **1:N** avec Visite (client)
- **1:N** avec Notification
- **1:N** avec Historique
- **1:N** avec Recherche
- **1:N** avec RechercheEnregistree
- **1:N** avec DocumentVerification
- **1:N** avec ChatbotConversation
- **1:N** avec Signalement (auteur)

```
Utilisateur (1) ──── (1) Profil
Utilisateur (1) ──── (0..1) Client
Utilisateur (1) ──── (0..1) Bailleur
Utilisateur (1) ──── (0..1) Administrateur
Utilisateur (1) ──── (N) SessionUtilisateur
Utilisateur (1) ──── (N) ParametreUtilisateur
Utilisateur (1) ──── (N) Favori
Utilisateur (1) ──── (N) Avis
Utilisateur (1) ──── (N) Conversation
Utilisateur (1) ──── (N) Message
Utilisateur (1) ──── (N) Visite
Utilisateur (1) ──── (N) Notification
Utilisateur (1) ──── (N) Historique
Utilisateur (1) ──── (N) Recherche
Utilisateur (1) ──── (N) RechercheEnregistree
Utilisateur (1) ──── (N) DocumentVerification
Utilisateur (1) ──── (N) ChatbotConversation
Utilisateur (1) ──── (N) Signalement
```

### 2. Profil

**Relations :**
- **N:1** avec Utilisateur

```
Profil (1) ──── (1) Utilisateur
```

### 3. Client

**Relations :**
- **N:1** avec Utilisateur
- **1:N** avec Visite

```
Client (1) ──── (1) Utilisateur
Client (1) ──── (N) Visite
```

### 4. Bailleur

**Relations :**
- **N:1** avec Utilisateur
- **1:N** avec Logement
- **1:N** avec Visite
- **1:N** avec PlanningVisite

```
Bailleur (1) ──── (1) Utilisateur
Bailleur (1) ──── (N) Logement
Bailleur (1) ──── (N) Visite
Bailleur (1) ──── (N) PlanningVisite
```

### 5. Administrateur

**Relations :**
- **N:1** avec Utilisateur
- **N:1** avec Administrateur (superieur_id)
- **1:N** avec Administrateur (superieur)
- **1:N** avec DocumentVerification (verifie_par)
- **1:N** avec Signalement (traite_par)

```
Administrateur (1) ──── (1) Utilisateur
Administrateur (1) ──── (0..1) Administrateur (superieur)
Administrateur (1) ──── (N) Administrateur (subordonnés)
Administrateur (1) ──── (N) DocumentVerification
Administrateur (1) ──── (N) Signalement
```

### 6. Adresse

**Relations :**
- **N:1** avec Ville
- **N:1** avec Quartier
- **1:N** avec Logement

```
Adresse (1) ──── (1) Ville
Adresse (1) ──── (0..1) Quartier
Adresse (1) ──── (N) Logement
```

### 7. Ville

**Relations :**
- **1:N** avec Quartier
- **1:N** avec Adresse

```
Ville (1) ──── (N) Quartier
Ville (1) ──── (N) Adresse
```

### 8. Quartier

**Relations :**
- **N:1** avec Ville
- **1:N** avec Adresse

```
Quartier (1) ──── (1) Ville
Quartier (1) ──── (N) Adresse
```

### 9. Logement

**Relations :**
- **N:1** avec Bailleur
- **N:1** with Adresse
- **N:1** avec CategorieLogement
- **N:1** avec TypeLogement
- **1:N** avec PhotoLogement
- **1:N** avec VideoLogement
- **N:N** avec Equipement (via JSON)
- **1:N** avec Favori
- **1:N** avec Avis
- **1:N** with Conversation
- **1:N** avec Visite
- **1:N** with PlanningVisite
- **1:N** avec Recherche (via filtres)
- **1:N** avec RechercheEnregistree (via filtres)
- **1:N** avec Signalement

```
Logement (1) ──── (1) Bailleur
Logement (1) ──── (1) Adresse
Logement (1) ──── (1) CategorieLogement
Logement (1) ──── (1) TypeLogement
Logement (1) ──── (N) PhotoLogement
Logement (1) ──── (N) VideoLogement
Logement (1) ──── (N) Equipement
Logement (1) ──── (N) Favori
Logement (1) ──── (N) Avis
Logement (1) ──── (N) Conversation
Logement (1) ──── (N) Visite
Logement (1) ──── (N) PlanningVisite
Logement (1) ──── (N) Signalement
```

### 10. CategorieLogement

**Relations :**
- **1:N** avec Logement

```
CategorieLogement (1) ──── (N) Logement
```

### 11. TypeLogement

**Relations :**
- **1:N** avec Logement

```
TypeLogement (1) ──── (N) Logement
```

### 12. PhotoLogement

**Relations :**
- **N:1** avec Logement

```
PhotoLogement (1) ──── (1) Logement
```

### 13. VideoLogement

**Relations :**
- **N:1** avec Logement

```
VideoLogement (1) ──── (1) Logement
```

### 14. Equipement

**Relations :**
- **N:N** avec Logement (via JSON dans Logement.equipements)

```
Equipement (1) ──── (N) Logement
```

### 15. Favori

**Relations :**
- **N:1** avec Utilisateur
- **N:1** avec Logement

```
Favori (1) ──── (1) Utilisateur
Favori (1) ──── (1) Logement
```

### 16. Avis

**Relations :**
- **N:1** avec Utilisateur
- **N:1** avec Logement

```
Avis (1) ──── (1) Utilisateur
Avis (1) ──── (1) Logement
```

### 17. Conversation

**Relations :**
- **N:1** avec Utilisateur (participant1)
- **N:1** avec Utilisateur (participant2)
- **N:1** avec Logement
- **1:N** avec Message

```
Conversation (1) ──── (1) Utilisateur (participant1)
Conversation (1) ──── (1) Utilisateur (participant2)
Conversation (1) ──── (1) Logement
Conversation (1) ──── (N) Message
```

### 18. Message

**Relations :**
- **N:1** avec Conversation
- **N:1** avec Utilisateur (expediteur)
- **N:1** avec Utilisateur (destinataire)

```
Message (1) ──── (1) Conversation
Message (1) ──── (1) Utilisateur (expediteur)
Message (1) ──── (1) Utilisateur (destinataire)
```

### 19. ChatbotConversation

**Relations :**
- **N:1** avec Utilisateur
- **1:N** avec ChatbotMessage

```
ChatbotConversation (1) ──── (1) Utilisateur
ChatbotConversation (1) ──── (N) ChatbotMessage
```

### 20. ChatbotMessage

**Relations :**
- **N:1** avec ChatbotConversation

```
ChatbotMessage (1) ──── (1) ChatbotConversation
```

### 21. Notification

**Relations :**
- **N:1** avec Utilisateur

```
Notification (1) ──── (1) Utilisateur
```

### 22. Historique

**Relations :**
- **N:1** avec Utilisateur
- **N:1** avec Entité (entite_id, entite_type)

```
Historique (1) ──── (1) Utilisateur
Historique (1) ──── (1) Entité
```

### 23. Recherche

**Relations :**
- **N:1** avec Utilisateur
- **N:1** avec CategorieLogement (facultatif)
- **N:1** avec TypeLogement (facultatif)
- **N:1** avec Ville (facultatif)
- **N:1** avec Quartier (facultatif)

```
Recherche (1) ──── (1) Utilisateur
Recherche (1) ──── (0..1) CategorieLogement
Recherche (1) ──── (0..1) TypeLogement
Recherche (1) ──── (0..1) Ville
Recherche (1) ──── (0..1) Quartier
```

### 24. RechercheEnregistree

**Relations :**
- **N:1** avec Utilisateur
- **N:1** avec CategorieLogement (facultatif)
- **N:1** avec TypeLogement (facultatif)
- **N:1** avec Ville (facultatif)
- **N:1** avec Quartier (facultatif)

```
RechercheEnregistree (1) ──── (1) Utilisateur
RechercheEnregistree (1) ──── (0..1) CategorieLogement
RechercheEnregistree (1) ──── (0..1) TypeLogement
RechercheEnregistree (1) ──── (0..1) Ville
RechercheEnregistree (1) ──── (0..1) Quartier
```

### 25. Visite

**Relations :**
- **N:1** with Logement
- **N:1** avec Client
- **N:1** avec Bailleur

```
Visite (1) ──── (1) Logement
Visite (1) ──── (1) Client
Visite (1) ──── (1) Bailleur
```

### 26. PlanningVisite

**Relations :**
- **N:1** avec Bailleur
- **N:1** avec Logement

```
PlanningVisite (1) ──── (1) Bailleur
PlanningVisite (1) ──── (1) Logement
```

### 27. Signalement

**Relations :**
- **N:1** avec Utilisateur (auteur)
- **N:1** with Entité (entite_id, entite_type)
- **N:1** avec Administrateur (traite_par)

```
Signalement (1) ──── (1) Utilisateur (auteur)
Signalement (1) ──── (1) Entité
Signalement (1) ──── (0..1) Administrateur (traite_par)
```

### 28. DocumentVerification

**Relations :**
- **N:1** avec Utilisateur
- **N:1** avec Administrateur (verifie_par)

```
DocumentVerification (1) ──── (1) Utilisateur
DocumentVerification (1) ──── (0..1) Administrateur (verifie_par)
```

### 29. SessionUtilisateur

**Relations :**
- **N:1** avec Utilisateur

```
SessionUtilisateur (1) ──── (1) Utilisateur
```

### 30. ParametreUtilisateur

**Relations :**
- **N:1** avec Utilisateur

```
ParametreUtilisateur (1) ──── (1) Utilisateur
```

## Flux de Données Principaux

### Flux de Création de Logement

```
Utilisateur (Bailleur)
    ↓
Bailleur
    ↓
Logement
    ↓
├── PhotoLogement
├── VideoLogement
└── Equipement
```

### Flux de Recherche

```
Utilisateur
    ↓
Recherche / RechercheEnregistree
    ↓
├── CategorieLogement
├── TypeLogement
├── Ville
├── Quartier
└── Equipement
    ↓
Logement
```

### Flux de Messagerie

```
Utilisateur (Client)
    ↓
Conversation
    ↓
Message
    ↓
Utilisateur (Bailleur)
```

### Flux de Visite

```
Utilisateur (Client)
    ↓
Visite
    ↓
├── Logement
├── Client
└── Bailleur
    ↓
PlanningVisite
```

### Flux de Vérification

```
Utilisateur
    ↓
DocumentVerification
    ↓
Administrateur
```

## Contraintes d'Intégrité

### Unicité
- email dans Utilisateur
- telephone dans Utilisateur
- nom dans CategorieLogement
- nom dans TypeLogement
- nom + pays dans Ville
- nom + ville_id dans Quartier

### Clés Étrangères
- utilisateur_id dans Profil, Client, Bailleur, Administrateur
- ville_id dans Adresse, Quartier
- quartier_id dans Adresse
- bailleur_id dans Logement, Visite, PlanningVisite
- logement_id dans PhotoLogement, VideoLogement, Favori, Avis, Conversation, Visite, PlanningVisite, Signalement
- categorie_id dans Logement
- type_id dans Logement
- conversation_id dans Message
- utilisateur_id dans Favori, Avis, Notification, Historique, Recherche, RechercheEnregistree, DocumentVerification, SessionUtilisateur, ParametreUtilisateur, ChatbotConversation, Signalement

### Cascade
- Suppression Utilisateur → Suppression Profil, Client, Bailleur, Administrateur, SessionUtilisateur, ParametreUtilisateur
- Suppression Ville → Suppression Quartier, Adresse
- Suppression Logement → Suppression PhotoLogement, VideoLogement, Favori, Avis, Conversation, Visite, PlanningVisite, Signalement
- Suppression Conversation → Suppression Message
- Suppression ChatbotConversation → Suppression ChatbotMessage

### Restriction
- Suppression Bailleur avec Logements → Interdit
- Suppression Logement avec Visites actives → Interdit
- Suppression Ville avec Quartiers → Interdit
