import 'package:gestionbailleur/core/network/api_endpoints.dart';
import 'package:gestionbailleur/core/network/network_exceptions.dart';
import 'package:gestionbailleur/core/services/api_service.dart';
import '../../domain/models/visite.dart';

/// Repository pour la gestion des demandes de visite
class VisitRepository {
  final ApiService _apiService = ApiService.instance;

  /// Récupérer les demandes de visite du client connecté
  Future<List<Visite>> getMyVisits() async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.myVisits,
        requireAuth: true,
      );

      List<Visite> visits;
      if (response is List) {
        visits = response.map((json) => Visite.fromMap(json)).toList();
      } else {
        visits = [];
      }

      return visits;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer les demandes de visite reçues par le bailleur
  Future<List<Visite>> getLandlordVisits() async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.landlordVisits,
        requireAuth: true,
      );

      List<Visite> visits;
      if (response is List) {
        visits = response.map((json) => Visite.fromMap(json)).toList();
      } else {
        visits = [];
      }

      return visits;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer les détails d'une demande de visite
  Future<Visite> getVisitDetail(String visitId) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.visitDetail(visitId),
        requireAuth: true,
      );

      return Visite.fromMap(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Créer une nouvelle demande de visite
  Future<Visite> createVisit({
    required String propertyId,
    required DateTime requestedDate,
    required String requestedTime,
    String? message,
  }) async {
    try {
      final body = {
        'property': propertyId,
        'requested_date': requestedDate.toIso8601String().split('T')[0],
        'requested_time': requestedTime,
        if (message != null && message.isNotEmpty) 'message': message,
      };

      final response = await _apiService.post(
        ApiEndpoints.createVisit,
        body: body,
        requireAuth: true,
      );

      return Visite.fromMap(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Mettre à jour une demande de visite (accepter, refuser, reprogrammer)
  Future<Visite> updateVisit({
    required String visitId,
    String? status,
    String? landlordResponse,
    DateTime? rescheduledDate,
    String? rescheduledTime,
    String? rescheduledMessage,
  }) async {
    try {
      final body = <String, dynamic>{};
      
      if (status != null) body['status'] = status;
      if (landlordResponse != null) body['landlord_response'] = landlordResponse;
      if (rescheduledDate != null) {
        body['rescheduled_date'] = rescheduledDate.toIso8601String().split('T')[0];
      }
      if (rescheduledTime != null) body['rescheduled_time'] = rescheduledTime;
      if (rescheduledMessage != null) body['rescheduled_message'] = rescheduledMessage;

      final response = await _apiService.put(
        ApiEndpoints.visitUpdate(visitId),
        body: body,
        requireAuth: true,
      );

      return Visite.fromMap(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Annuler une demande de visite
  Future<Visite> cancelVisit(String visitId) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.visitCancel(visitId),
        requireAuth: true,
      );

      return Visite.fromMap(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Accepter une proposition de reprogrammation
  Future<Visite> acceptReschedule(String visitId) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.visitAcceptReschedule(visitId),
        requireAuth: true,
      );

      return Visite.fromMap(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Supprimer une demande de visite (suppression locale uniquement)
  Future<bool> deleteVisit(String visitId) async {
    try {
      // Pour l'instant, nous supprimons seulement localement dans le provider
      // car il n'y a pas d'endpoint backend pour la suppression des visites
      // Cette méthode retourne true pour permettre la suppression locale
      return true;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Gérer les erreurs
  NetworkException _handleError(dynamic error) {
    if (error is NetworkException) {
      return error;
    }
    return NetworkException(error.toString());
  }
}
