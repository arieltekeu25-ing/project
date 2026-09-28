/// Enpoints API pour la communication avec le backend Django REST Framework
class ApiEndpoints {
  ApiEndpoints._(); // Constructeur privé pour empêcher l'instanciation

  // Logements & Annonces (Listings)
  static const String properties = '/api/v1/properties/';
  static const String propertyCreate = '/api/v1/properties/create/';
  static String propertyDetail(String id) => '/api/v1/properties/$id/';
  static String propertyUpdate(String id) => '/api/v1/properties/$id/';
  static String propertyDelete(String id) => '/api/v1/properties/$id/';
  static String propertyPublish(String id) => '/api/v1/properties/$id/publish/';
  static String propertyHide(String id) => '/api/v1/properties/$id/hide/';
  static String propertyUnhide(String id) => '/api/v1/properties/$id/unhide/';
  static const String searchProperties = '/api/v1/properties/search/';
  static String landlordProperties(String landlordId) => '/api/v1/properties/?landlord=$landlordId';

  // Favoris
  static const String favorites = '/api/v1/favorites/';
  static String favoriteDetail(String id) => '/api/v1/favorites/$id/';

  // Catégories
  static const String categories = '/api/v1/categories/';

  // Bailleurs & Profils
  static const String landlordProfile = '/api/v1/auth/landlord-profile/';

  // Visites
  static const String myVisits = '/api/v1/visits/my/';
  static const String landlordVisits = '/api/v1/visits/landlord/';
  static String visitDetail(String id) => '/api/v1/visits/$id/';
  static const String createVisit = '/api/v1/visits/create/';
  static String visitUpdate(String id) => '/api/v1/visits/$id/update/';
  static String visitCancel(String id) => '/api/v1/visits/$id/cancel/';
  static String visitAcceptReschedule(String id) => '/api/v1/visits/$id/accept-reschedule/';
  static String visitDelete(String id) => '/api/v1/visits/$id/';

  // Médias Logements
  static String propertyMedia(String propertyId) => '/api/v1/properties/$propertyId/media/';
  static String propertyMediaDetail(String propertyId, String mediaId) => '/api/v1/properties/$propertyId/media/$mediaId/';
  static String propertyMediaSetPrimary(String propertyId, String mediaId) => '/api/v1/properties/$propertyId/media/$mediaId/set-primary/';
  static String propertyMediaReorder(String propertyId) => '/api/v1/properties/$propertyId/media/reorder/';
  static const String propertyUpload = '/api/v1/properties/upload/';

  // Photo de profil Utilisateur
  static const String userProfileMe = '/api/v1/profiles/me/';
  static const String userProfilePhoto = '/api/v1/profiles/me/photo/';
  static const String userProfilePhotoDelete = '/api/v1/profiles/me/photo/delete/';

  // Chatbot IA
  static const String chatbotConversations = '/api/v1/chatbot/conversations/';
  static String chatbotConversationDetail(String id) => '/api/v1/chatbot/conversations/$id/';
  static String chatbotMessages(String id) => '/api/v1/chatbot/conversations/$id/messages/';
  static const String chatbotSend = '/api/v1/chatbot/send/';
}


