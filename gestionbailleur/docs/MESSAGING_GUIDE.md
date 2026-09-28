# DOCUMENTATION — SYSTEME DE MESSAGERIE REELLE CLIENT ↔ BAILLEUR & NOTIFICATIONS (GESTBAILLEUR)

Ce document décrit l'architecture, la gestion d'état, les endpoints API et le fonctionnement global du système de messagerie réelle entre clients et bailleurs pour **GestBailleur**.

---

## 1. Architecture Globale

Le module de messagerie suit l'architecture Clean Architecture / MVVM du projet :

```
Flutter (MessagesPage / ChatThreadPage / NotificationsPage)
   ↓ (watch / read)
ChatNotifier / MessagesNotifier / NotificationsNotifier (Riverpod StateNotifiers)
   ↓ (appels asynchrones HTTP REST & WebSocket Abstraction)
ChatRepository / NotificationsRepository / ChatWebSocketService
   ↓ (requests HTTP JWT)
Django REST Framework (/api/v1/messages/ & /api/v1/notifications/)
   ↓
PostgreSQL (tables user_messages_conversation, user_messages_message, notifications_notification)
```

---

## 2. Fichiers et Modèles Frontend

- **[ConversationModel](file:///c:/Users/william/StudioProjects/BAILLEUR/gestionbailleur/lib/features/chat/models/conversation_model.dart)** : Modèle de conversation réelle comprenant les identifiants client, bailleur, le logement associé (`PropertyModel`), le correspondant, le dernier message et le compteur de non lus.
- **[MessageModel](file:///c:/Users/william/StudioProjects/BAILLEUR/gestionbailleur/lib/features/chat/models/message_model.dart)** : Modèle de message réels (expéditeur, destinataire, contenu, statut `isRead`, `readAt`, horodatage).
- **[NotificationModel](file:///c:/Users/william/StudioProjects/BAILLEUR/gestionbailleur/lib/features/notifications/models/notification_model.dart)** : Modèle de notification réelle.
- **[ChatRepository](file:///c:/Users/william/StudioProjects/BAILLEUR/gestionbailleur/lib/features/chat/repositories/chat_repository.dart)** : Responsable des appels HTTP avec le backend Django.
- **[ChatWebSocketService](file:///c:/Users/william/StudioProjects/BAILLEUR/gestionbailleur/lib/features/chat/services/chat_websocket_service.dart)** : Service d'abstraction WebSocket préparé pour Django Channels.
- **[MessagesPage](file:///c:/Users/william/StudioProjects/BAILLEUR/gestionbailleur/lib/features/chat/pages/messages_page.dart)** : Vue des conversations réelles adaptative (split-screen sur Web/Desktop, liste sur Mobile).
- **[ChatThreadPage](file:///c:/Users/william/StudioProjects/BAILLEUR/gestionbailleur/lib/features/chat/pages/chat_thread_page.dart)** : Vue du fil de discussion actif avec bannière du logement, bulles alignées et zone de saisie.

---

## 3. Endpoints API Django REST Framework

L'application communique avec les endpoints backend réels suivants :

1. **Lister les conversations réelles** : `GET /api/v1/messages/conversations/`
2. **Démarrer ou récupérer une conversation pour un logement** : `POST /api/v1/messages/conversations/` (`{"property_id": "<uuid>"}`)
3. **Détails d'une conversation** : `GET /api/v1/messages/conversations/<id>/`
4. **Lister les messages d'une conversation** : `GET /api/v1/messages/conversations/<id>/messages/`
5. **Envoyer un message** : `POST /api/v1/messages/conversations/<id>/messages/` (`{"content": "..."}`)
6. **Marquer les messages comme lus** : `POST /api/v1/messages/conversations/<id>/read/`
7. **Compteur global de messages non lus** : `GET /api/v1/messages/unread-count/`
8. **Lister les notifications** : `GET /api/v1/notifications/`
9. **Compteur global de notifications non lues** : `GET /api/v1/notifications/unread-count/`
10. **Marquer les notifications comme lues** : `POST /api/v1/notifications/mark-read/`

---

## 4. Règles de Sécurité Backend & Comportement Métier

### A. Sécurité Backend Django
- **Contrôle d'accès strict** : Seuls les participants (`client` ou `landlord`) d'une conversation peuvent lire ou envoyer des messages dans cette conversation.
- **Auto-message interdit** : Le backend rejette toute tentative de message à soi-même (ex. un bailleur contactant son propre logement).

### B. Parcours Client & Parcours Bailleur
- **Côté Client** : Sur la page de détail d'un logement, le client clique sur `"Contacter le bailleur"`. Si le client n'est pas connecté, une SnackBar l'invite à se connecter vers `/login`. S'il est connecté, la conversation pour ce logement est créée/récupérée et le fil de discussion s'ouvre.
- **Côté Bailleur** : Le bailleur consulte sa messagerie et voit la liste des clients qui l'ont contacté, avec le logement concerné, le dernier message et le badge des messages non lus. Il peut répondre directement.

---

## 5. Design Responsive & Temps Réel

- **Web / Desktop** : Vue Split-Screen avec la liste des conversations à gauche (360px) et le fil de discussion sélectionné à droite.
- **Mobile** : Liste des conversations en plein écran puis navigation vers le fil de discussion.
- **WebSocket (Django Channels)** : L'abstraction `ChatWebSocketService` est initialisée et prête à recevoir les événements `ws://` dès que le service Django Channels est déployé en production.
