# Workflows de Statut - GestionBailleur

## Table des matières

1. [Compte Utilisateur](#compte-utilisateur)
2. [Compte Bailleur](#compte-bailleur)
3. [Logement](#logement)
4. [Visite](#visite)
5. [Conversation](#conversation)
6. [Signalement](#signalement)
7. [Notification](#notification)
8. [Document Verification](#document-verification)
9. [Avis](#avis)
10. [Recherche Enregistrée](#recherche-enregistrée)

---

## Compte Utilisateur

### Workflow de Statut

```
┌──────────┐
│  Créé   │
└────┬─────┘
     │
     ▼
┌──────────┐
│En attente│ ← Email non vérifié
└────┬─────┘
     │
     ▼
┌──────────┐
│  Actif   │ ← Email vérifié
└────┬─────┘
     │
     ├─────────────┐
     │             │
     ▼             ▼
┌──────────┐  ┌──────────┐
│Suspendu  │  │Inactif   │
└────┬─────┘  └────┬─────┘
     │             │
     ▼             ▼
┌──────────┐  ┌──────────┐
│  Actif   │  │ Supprimé │
└──────────┘  └──────────┘
```

### Transitions

| De | Vers | Condition | Action |
|----|------|-----------|--------|
| Créé | En attente | Inscription sans email vérifié | Automatique |
| En attente | Actif | Email vérifié | Automatique |
| Actif | Suspendu | Violation des règles | Administrateur |
| Actif | Inactif | Désactivation utilisateur | Utilisateur |
| Suspendu | Actif | Période de suspension terminée | Administrateur |
| Suspendu | Supprimé | Suspension définitive | Administrateur |
| Inactif | Actif | Réactivation | Utilisateur |
| Inactif | Supprimé | Suppression compte | Utilisateur |

### Règles

- Un compte en attente ne peut pas se connecter
- Un compte suspendu ne peut pas se connecter
- Un compte inactif ne peut pas se connecter
- La suppression est définitive après 30 jours

---

## Compte Bailleur

### Workflow de Statut

```
┌──────────┐
│  Créé   │
└────┬─────┘
     │
     ▼
┌──────────┐
│En attente│ ← Documents soumis
└────┬─────┘
     │
     ├─────────────┐
     │             │
     ▼             ▼
┌──────────┐  ┌──────────┐
│Approuvé  │  │ Rejeté  │
└────┬─────┘  └────┬─────┘
     │             │
     │             ▼
     │       ┌──────────┐
     │       │En attente│ ← Nouvelle soumission
     │       └────┬─────┘
     │             │
     └─────────────┘
     │
     ├─────────────┐
     │             │
     ▼             ▼
┌──────────┐  ┌──────────┐
│Suspendu  │  │Inactif   │
└────┬─────┘  └────┬─────┘
     │             │
     ▼             ▼
┌──────────┐  ┌──────────┐
│  Actif   │  │ Supprimé │
└──────────┘  └──────────┘
```

### Transitions

| De | Vers | Condition | Action |
|----|------|-----------|--------|
| Créé | En attente | Inscription bailleur | Automatique |
| En attente | Approuvé | Documents validés | Administrateur |
| En attente | Rejeté | Documents invalides | Administrateur |
| Rejeté | En attente | Nouvelle soumission | Bailleur |
| Approuvé | Suspendu | Violation | Administrateur |
| Approuvé | Inactif | Désactivation | Bailleur |
| Suspendu | Approuvé | Suspension levée | Administrateur |
| Inactif | Approuvé | Réactivation | Bailleur |

### Règles

- Un bailleur en attente ne peut pas publier de logements
- Un bailleur rejeté peut soumettre à nouveau
- Un bailleur suspendu ne peut pas publier
- Les documents doivent être renouvelés avant expiration

---

## Logement

### Workflow de Statut

```
┌──────────┐
│ Brouillon │ ← Création initiale
└────┬─────┘
     │
     ▼
┌──────────┐
│ Publié   │ ← Publication validée
└────┬─────┘
     │
     ├─────────────┐
     │             │
     ▼             ▼
┌──────────┐  ┌──────────┐
│  Pause   │  │ Archivé  │
└────┬─────┘  └────┬─────┘
     │             │
     ▼             │
┌──────────┐       │
│ Publié   │       │
└────┬─────┘       │
     │             │
     └─────────────┘
     │
     ▼
┌──────────┐
│ Supprimé │ ← Suppression définitive
└──────────┘
```

### Transitions

| De | Vers | Condition | Action |
|----|------|-----------|--------|
| Brouillon | Publié | Bailleur vérifié, minimum 1 photo | Bailleur |
| Publié | Pause | Décision bailleur | Bailleur |
| Pause | Publié | Décision bailleur | Bailleur |
| Publié | Archivé | Plus disponible | Bailleur |
| Archivé | Publié | Remise en vente | Bailleur |
| Publié | Supprimé | Suppression | Bailleur |
| Pause | Supprimé | Suppression | Bailleur |
| Archivé | Supprimé | Suppression | Bailleur |

### Règles

- Un logement en brouillon n'est pas visible
- Un logement en pause n'est pas visible
- Un logement archivé n'est pas visible
- Un logement avec visites en cours ne peut pas être supprimé
- Un logement avec contrats actifs ne peut pas être supprimé
- La suppression est définitive après 30 jours

---

## Visite

### Workflow de Statut

```
┌──────────┐
│En attente│ ← Demande envoyée
└────┬─────┘
     │
     ├─────────────┐
     │             │
     ▼             ▼
┌──────────┐  ┌──────────┐
│ Confirmé │  │ Annulé   │
└────┬─────┘  └──────────┘
     │
     ├─────────────┐
     │             │
     ▼             ▼
┌──────────┐  ┌──────────┐
│Effectué  │  │ Annulé   │ ← Annulé par bailleur
└──────────┘  └──────────┘
```

### Transitions

| De | Vers | Condition | Action |
|----|------|-----------|--------|
| En attente | Confirmé | Bailleur accepte | Bailleur |
| En attente | Annulé | Bailleur refuse | Bailleur |
| En attente | Annulé | Client annule (24h avant) | Client |
| Confirmé | Effectué | Visite réalisée | Bailleur |
| Confirmé | Annulé | Annulation (motif valable) | Bailleur/Client |
| Effectué | - | État final | - |

### Règles

- Une visite en attente doit être confirmée dans les 48h
- Un client ne peut annuler que 24h avant
- Un bailleur peut annuler sans préavis en cas d'urgence
- Une visite confirmée ne peut être modifiée
- Un avis peut être laissé après visite effectuée

---

## Conversation

### Workflow de Statut

```
┌──────────┐
│  Actif   │ ← Conversation ouverte
└────┬─────┘
     │
     ├─────────────┐
     │             │
     ▼             ▼
┌──────────┐  ┌──────────┐
│ Archivé  │  │ Supprimé │
└──────────┘  └──────────┘
```

### Transitions

| De | Vers | Condition | Action |
|----|------|-----------|--------|
| Actif | Archivé | Plus d'activité (30 jours) | Automatique |
| Actif | Archivé | Décision utilisateur | Utilisateur |
| Archivé | Actif | Nouveau message | Automatique |
| Actif | Supprimé | Suppression | Utilisateur |
| Archivé | Supprimé | Suppression | Utilisateur |

### Règles

- Une conversation archivée est réactivée par un nouveau message
- Les messages sont conservés même si conversation supprimée
- Une conversation ne peut avoir que 2 participants
- Les messages ne peuvent pas être modifiés après envoi

---

## Signalement

### Workflow de Statut

```
┌──────────┐
│En attente│ ← Signalement soumis
└────┬─────┘
     │
     ├─────────────┐
     │             │
     ▼             ▼
┌──────────┐  ┌──────────┐
│ En cours │  │ Rejeté   │
└────┬─────┘  └──────────┘
     │
     ├─────────────┐
     │             │
     ▼             ▼
┌──────────┐  ┌──────────┐
│  Résolu  │  │ Rejeté   │
└──────────┘  └──────────┘
```

### Transitions

| De | Vers | Condition | Action |
|----|------|-----------|--------|
| En attente | En cours | Administrateur prend en charge | Administrateur |
| En attente | Rejeté | Signalement infondé | Administrateur |
| En cours | Résolu | Problème résolu | Administrateur |
| En cours | Rejeté | Signalement infondé | Administrateur |

### Règles

- Un signalement doit être traité dans les 7 jours
- L'auteur du signalement reste anonyme
- L'auteur est notifié de la décision
- Les signalements résolus sont conservés 90 jours

---

## Notification

### Workflow de Statut

```
┌──────────┐
│  Actif   │ ← Notification créée
└────┬─────┘
     │
     ▼
┌──────────┐
│  Lue     │ ← Utilisateur marque comme lue
└────┬─────┘
     │
     ▼
┌──────────┐
│ Archivé  │ ← Archivage automatique (90 jours)
└──────────┘
```

### Transitions

| De | Vers | Condition | Action |
|----|------|-----------|--------|
| Actif | Lue | Utilisateur consulte | Automatique |
| Lue | Archivé | 90 jours écoulés | Automatique |
| Actif | Archivé | Archivage manuel | Utilisateur |

### Règles

- Les notifications non lues sont comptées
- Une notification lue ne peut être relue
- Les notifications sont conservées 90 jours
- Les notifications système ne peuvent être supprimées

---

## Document Verification

### Workflow de Statut

```
┌──────────┐
│En attente│ ← Document soumis
└────┬─────┘
     │
     ├─────────────┐
     │             │
     ▼             ▼
┌──────────┐  ┌──────────┐
│Approuvé  │  │ Rejeté   │
└────┬─────┘  └────┬─────┘
     │             │
     │             ▼
     │       ┌──────────┐
     │       │En attente│ ← Nouvelle soumission
     │       └────┬─────┘
     │             │
     └─────────────┘
     │
     ▼
┌──────────┐
│ Expiré   │ ← Date expiration dépassée
└────┬─────┘
     │
     ▼
┌──────────┐
│En attente│ ← Renouvellement
└──────────┘
```

### Transitions

| De | Vers | Condition | Action |
|----|------|-----------|--------|
| En attente | Approuvé | Document valide | Administrateur |
| En attente | Rejeté | Document invalide | Administrateur |
| Rejeté | En attente | Nouvelle soumission | Utilisateur |
| Approuvé | Expiré | Date expiration dépassée | Automatique |
| Expiré | En attente | Renouvellement soumis | Utilisateur |

### Règles

- Un document doit être vérifié dans les 7 jours
- Un document rejeté peut être soumis à nouveau
- L'utilisateur est notifié 30 jours avant expiration
- Les documents expirés doivent être renouvelés
- Les documents sont supprimés après suppression du compte

---

## Avis

### Workflow de Statut

```
┌──────────┐
│  Actif   │ ← Avis publié
└────┬─────┘
     │
     ├─────────────┐
     │             │
     ▼             ▼
┌──────────┐  ┌──────────┐
│ Masqué   │  │ Supprimé │
└──────────┘  └──────────┘
```

### Transitions

| De | Vers | Condition | Action |
|----|------|-----------|--------|
| Actif | Masqué | Contenu inapproprié | Administrateur |
| Actif | Supprimé | Suppression | Administrateur |
| Masqué | Actif | Rétablissement | Administrateur |

### Règles

- Un avis ne peut être modifié après 24h
- Un client ne peut laisser qu'un avis par logement
- Le bailleur peut répondre à un avis
- Les avis masqués ne sont plus visibles
- Un avis supprimé ne peut être restauré

---

## Recherche Enregistrée

### Workflow de Statut

```
┌──────────┐
│  Actif   │ ← Recherche enregistrée
└────┬─────┘
     │
     ├─────────────┐
     │             │
     ▼             ▼
┌──────────┐  ┌──────────┐
│ Inactif  │  │ Supprimé │
└────┬─────┘  └──────────┘
     │
     ▼
┌──────────┐
│  Actif   │ ← Réactivation
└──────────┘
```

### Transitions

| De | Vers | Condition | Action |
|----|------|-----------|--------|
| Actif | Inactif | Désactivation alertes | Utilisateur |
| Inactif | Actif | Réactivation alertes | Utilisateur |
| Actif | Supprimé | Suppression | Utilisateur |
| Inactif | Supprimé | Suppression | Utilisateur |

### Règles

- Une recherche active envoie des alertes
- Les alertes peuvent être immédiates, quotidiennes ou hebdomadaires
- Une recherche inactive n'envoie pas d'alertes
- L'historique des alertes est conservé 90 jours

---

## Session Utilisateur

### Workflow de Statut

```
┌──────────┐
│  Actif   │ ← Connexion réussie
└────┬─────┘
     │
     ├─────────────┐
     │             │
     ▼             ▼
┌──────────┐  ┌──────────┐
│ Expiré   │  │ Révoqué  │
└──────────┘  └──────────┘
```

### Transitions

| De | Vers | Condition | Action |
|----|------|-----------|--------|
| Actif | Expiré | Token expiré (1h) | Automatique |
| Actif | Révoqué | Déconnexion forcée | Administrateur |
| Expiré | Actif | Refresh token valide | Automatique |

### Règles

- Le token access expire après 1 heure
- Le token refresh expire après 7 jours
- Les tokens sont rotatifs
- Un utilisateur peut avoir plusieurs sessions actives
- Les sessions expirées sont nettoyées automatiquement

---

## Planning Visite

### Workflow de Statut

```
┌──────────┐
│  Actif   │ ← Planning créé
└────┬─────┘
     │
     ├─────────────┐
     │             │
     ▼             ▼
┌──────────┐  ┌──────────┐
│ Inactif  │  │ Supprimé │
└────┬─────┘  └──────────┘
     │
     ▼
┌──────────┐
│  Actif   │ ← Réactivation
└──────────┘
```

### Transitions

| De | Vers | Condition | Action |
|----|------|-----------|--------|
| Actif | Inactif | Suspension temporaire | Bailleur |
| Inactif | Actif | Réactivation | Bailleur |
| Actif | Supprimé | Suppression | Bailleur |

### Règles

- Un planning actif accepte les demandes de visite
- Un planning inactif n'accepte pas de demandes
- Les créneaux ne peuvent pas se chevaucher
- Le bailleur peut modifier les créneaux à tout moment

---

## Résumé des États

### États Communs

| État | Description | Final |
|------|-------------|-------|
| Actif | Entité opérationnelle | Non |
| Inactif | Entité désactivée temporairement | Non |
| En attente | En attente de validation/action | Non |
| Supprimé | Entité supprimée | Oui |
| Archivé | Entité archivée | Non |
| Expiré | Période de validité dépassée | Non |

### États Spécifiques

| Entité | États Spécifiques |
|---------|------------------|
| Utilisateur | Suspendu |
| Bailleur | Approuvé, Rejeté |
| Logement | Brouillon, Publié, Pause |
| Visite | Confirmé, Effectué, Annulé |
| Signalement | En cours, Résolu, Rejeté |
| Document | Approuvé, Rejeté, Expiré |
| Avis | Masqué |
| Session | Révoqué |

---

## Automatismes

### Automatismes Temporels

- **En attente → Actif** : Email vérifié (immédiat)
- **Actif → Expiré** : Session expirée (1h)
- **Actif → Archivé** : Notification (90 jours)
- **Approuvé → Expiré** : Document expiré (date expiration)
- **Actif → Archivé** : Conversation (30 jours inactivité)

### Automatismes Conditionnels

- **En attente → Approuvé** : Bailleur vérifié (immédiat)
- **Brouillon → Publié** : Minimum 1 photo (immédiat)
- **En attente → Confirmé** : Bailleur accepte (immédiat)
- **Confirmé → Effectué** : Visite réalisée (immédiat)

### Notifications Automatiques

- Email de vérification lors de l'inscription
- Notification de changement de statut
- Rappel avant expiration de document
- Rappel 24h avant visite
- Notification de nouveau message
