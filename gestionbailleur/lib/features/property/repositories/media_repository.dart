import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/api_service.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/network_exceptions.dart';
import '../models/property_media_model.dart';

/// Repository responsable de la gestion des téléversements et opérations médias
class MediaRepository {
  final ApiService _apiService;

  MediaRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService.instance;

  static const int maxImageBytes = 10 * 1024 * 1024;
  static const int maxVideoBytes = 100 * 1024 * 1024;

  /// Résout un nom de fichier valide avec extension (critique sur Android)
  String _resolveFilename(XFile file, {required bool isVideoHint}) {
    var name = file.name.trim();
    if (name.isEmpty || name == '/' || name == '.') {
      final pathParts = file.path.replaceAll('\\', '/').split('/');
      name = pathParts.isNotEmpty ? pathParts.last : 'media';
    }

    // Nettoyer query params éventuels (content URI)
    if (name.contains('?')) {
      name = name.split('?').first;
    }

    final lower = name.toLowerCase();
    final hasExt = RegExp(r'\.(jpe?g|png|webp|mp4|mov)$').hasMatch(lower);
    if (hasExt) return name;

    final mime = (file.mimeType ?? '').toLowerCase();
    if (mime.contains('png')) return '$name.png';
    if (mime.contains('webp')) return '$name.webp';
    if (mime.contains('mp4') || mime.contains('video/mp4')) return '$name.mp4';
    if (mime.contains('quicktime') || mime.contains('video')) return '$name.mov';
    if (mime.contains('jpeg') || mime.contains('jpg') || mime.contains('image')) {
      return '$name.jpg';
    }
    return isVideoHint ? '$name.mp4' : '$name.jpg';
  }

  MediaType _mediaTypeForFilename(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png')) return MediaType('image', 'png');
    if (lower.endsWith('.webp')) return MediaType('image', 'webp');
    if (lower.endsWith('.mp4')) return MediaType('video', 'mp4');
    if (lower.endsWith('.mov')) return MediaType('video', 'quicktime');
    return MediaType('image', 'jpeg');
  }

  bool _isVideoFilename(String filename) {
    final lower = filename.toLowerCase();
    return lower.endsWith('.mp4') || lower.endsWith('.mov');
  }

  String _friendlyUploadError(Object e, {required String filename, required bool isVideo}) {
    final raw = e.toString();
    if (e is BadRequestException || e is NetworkException) {
      return e.toString().replaceFirst(RegExp(r'^[^:]+:\s*'), '');
    }
    if (raw.contains('SocketException') || raw.contains('Failed host lookup')) {
      return 'Impossible de contacter le serveur. Vérifiez votre connexion.';
    }
    if (raw.contains('TimeoutException') || raw.toLowerCase().contains('timeout')) {
      return isVideo
          ? 'Délai dépassé lors de l\'envoi de la vidéo « $filename ». Réessayez avec un fichier plus léger.'
          : 'Délai dépassé lors de l\'envoi de l\'image « $filename ».';
    }
    if (raw.toLowerCase().contains('ressource non disponible') ||
        raw.contains('PathNotFoundException') ||
        raw.contains('FileSystemException') ||
        raw.contains('No such file')) {
      return 'Le fichier sélectionné n\'est plus accessible. Rouvrez la galerie et sélectionnez-le à nouveau.';
    }
    return 'Impossible d\'envoyer « $filename ». ${raw.length > 180 ? '${raw.substring(0, 180)}…' : raw}';
  }

  /// Téléverse des fichiers images ou vidéos pour un logement avec retry automatique
  Future<List<PropertyMediaModel>> uploadPropertyMedia({
    required String propertyId,
    required List<XFile> files,
    void Function(double progress)? onProgress,
  }) async {
    if (files.isEmpty) return [];

    final multipartFiles = <http.MultipartFile>[];
    for (final file in files) {
      final mimeHint = (file.mimeType ?? '').toLowerCase();
      final isVideoHint = mimeHint.contains('video');
      final filename = _resolveFilename(file, isVideoHint: isVideoHint);
      final isVideo = _isVideoFilename(filename);

      try {
        if (kDebugMode) {
          debugPrint('[MEDIA] Lecture: name=${file.name}, path=${file.path}, mime=${file.mimeType}, resolved=$filename');
        }

        final bytes = await file.readAsBytes();
        final maxSize = isVideo ? maxVideoBytes : maxImageBytes;
        if (bytes.isEmpty) {
          throw Exception('Le fichier « $filename » est vide ou illisible.');
        }
        if (bytes.length > maxSize) {
          final maxMb = maxSize ~/ (1024 * 1024);
          throw Exception(
            isVideo
                ? 'Impossible d\'envoyer cette vidéo. Taille maximale : $maxMb Mo.'
                : 'Impossible d\'envoyer cette image. Taille maximale : $maxMb Mo.',
          );
        }

        if (kDebugMode) {
          debugPrint('[MEDIA] Taille: ${bytes.length} bytes');
        }

        multipartFiles.add(
          http.MultipartFile.fromBytes(
            'files',
            bytes,
            filename: filename,
            contentType: _mediaTypeForFilename(filename),
          ),
        );
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[MEDIA] Erreur lecture/préparation $filename: $e');
        }
        throw Exception(_friendlyUploadError(e, filename: filename, isVideo: isVideo));
      }
    }

    onProgress?.call(0.5);

    // Retry automatique pour les erreurs de connexion
    int maxRetries = 3;
    int attempt = 0;
    
    while (attempt < maxRetries) {
      try {
        if (kDebugMode) {
          debugPrint('[MEDIA] Upload attempt ${attempt + 1}/$maxRetries → ${ApiEndpoints.propertyMedia(propertyId)} (${multipartFiles.length} fichier(s))');
        }
        
        final response = await _apiService.postMultipart(
          ApiEndpoints.propertyMedia(propertyId),
          fields: {},
          files: multipartFiles,
          requireAuth: true,
          timeoutMs: 120000,
        );
        
        if (kDebugMode) {
          debugPrint('[MEDIA] Réponse reçue');
        }

        onProgress?.call(1.0);

        if (response is List) {
          return response
              .map((e) => PropertyMediaModel.fromJson(e as Map<String, dynamic>))
              .toList();
        } else if (response is Map) {
          final error = response['error'] ?? response['message'] ?? 'Erreur inconnue';
          throw Exception(error.toString());
        }
        return [];
      } catch (e) {
        attempt++;
        final errorStr = e.toString().toLowerCase();
        
        // Si c'est une erreur de connexion ou timeout, on réessaie
        if ((errorStr.contains('connexion') || 
             errorStr.contains('timeout') || 
             errorStr.contains('503') ||
             errorStr.contains('network') ||
             errorStr.contains('ressource non')) && 
            attempt < maxRetries) {
          if (kDebugMode) {
            debugPrint('[MEDIA] Retry $attempt/$maxRetries after error: $e');
          }
          // Attendre avec délai exponentiel
          await Future.delayed(Duration(seconds: attempt * 3));
          continue;
        }
        
        // Si ce n'est pas une erreur retryable ou qu'on a épuisé les essais
        if (kDebugMode) {
          debugPrint('[MEDIA] Upload failed after $attempt attempts: $e');
        }
        final firstName = multipartFiles.isNotEmpty ? multipartFiles.first.filename ?? 'média' : 'média';
        final isVideo = _isVideoFilename(firstName);
        throw Exception(_friendlyUploadError(e, filename: firstName, isVideo: isVideo));
      }
    }
    
    return [];
  }

  /// Supprime un média d'un logement (Cloudinary + PostgreSQL)
  Future<void> deletePropertyMedia({
    required String propertyId,
    required String mediaId,
  }) async {
    await _apiService.delete(
      ApiEndpoints.propertyMediaDetail(propertyId, mediaId),
      requireAuth: true,
    );
  }

  /// Définit le média sélectionné comme image principale du logement
  Future<PropertyMediaModel?> setPrimaryMedia({
    required String propertyId,
    required String mediaId,
  }) async {
    final response = await _apiService.patch(
      ApiEndpoints.propertyMediaSetPrimary(propertyId, mediaId),
      requireAuth: true,
    );

    if (response is Map<String, dynamic>) {
      return PropertyMediaModel.fromJson(response);
    }
    return null;
  }

  /// Met à jour l'ordre d'affichage des médias du logement
  Future<List<PropertyMediaModel>> reorderPropertyMedia({
    required String propertyId,
    required List<Map<String, dynamic>> items,
  }) async {
    final response = await _apiService.patch(
      ApiEndpoints.propertyMediaReorder(propertyId),
      body: {'items': items},
      requireAuth: true,
    );

    if (response is List) {
      return response
          .map((e) => PropertyMediaModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Téléverse une photo de profil utilisateur avec retry automatique
  Future<String?> uploadProfilePhoto(XFile file) async {
    final filename = _resolveFilename(file, isVideoHint: false);
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw Exception('La photo sélectionnée est vide ou inaccessible.');
    }
    if (bytes.length > maxImageBytes) {
      throw Exception('Impossible d\'envoyer cette image. Taille maximale : 10 Mo.');
    }

    final multipartFile = http.MultipartFile.fromBytes(
      'photo',
      bytes,
      filename: filename,
      contentType: _mediaTypeForFilename(filename),
    );

    // Retry automatique pour les erreurs de connexion
    int maxRetries = 3;
    int attempt = 0;
    
    while (attempt < maxRetries) {
      try {
        if (kDebugMode) {
          debugPrint('[PROFILE PHOTO] Upload attempt ${attempt + 1}/$maxRetries');
        }
        
        final response = await _apiService.postMultipart(
          ApiEndpoints.userProfilePhoto,
          fields: {},
          files: [multipartFile],
          requireAuth: true,
          timeoutMs: 90000, // 90 secondes pour permettre au backend de se réveiller
        );

        if (response is Map<String, dynamic> && response.containsKey('photo')) {
          return response['photo']?.toString();
        }
        return null;
      } catch (e) {
        attempt++;
        final errorStr = e.toString().toLowerCase();
        
        // Si c'est une erreur de connexion ou timeout, on réessaie
        if ((errorStr.contains('connexion') || 
             errorStr.contains('timeout') || 
             errorStr.contains('503') ||
             errorStr.contains('network')) && 
            attempt < maxRetries) {
          if (kDebugMode) {
            debugPrint('[PROFILE PHOTO] Retry $attempt/$maxRetries after error: $e');
          }
          // Attendre avec délai exponentiel
          await Future.delayed(Duration(seconds: attempt * 3));
          continue;
        }
        
        // Si ce n'est pas une erreur retryable ou qu'on a épuisé les essais
        if (kDebugMode) {
          debugPrint('[PROFILE PHOTO] Upload failed after $attempt attempts: $e');
        }
        rethrow;
      }
    }
    
    return null;
  }

  /// Téléverse une image de logement (retourne l'URL)
  Future<String?> uploadPropertyImage(XFile file, {String? propertyId}) async {
    final filename = _resolveFilename(file, isVideoHint: false);
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw Exception('L\'image sélectionnée est vide ou inaccessible.');
    }
    if (bytes.length > maxImageBytes) {
      throw Exception('Impossible d\'envoyer cette image. Taille maximale : 10 Mo.');
    }

    final multipartFile = http.MultipartFile.fromBytes(
      'files',
      bytes,
      filename: filename,
      contentType: _mediaTypeForFilename(filename),
    );

    String uploadUrl;
    if (propertyId != null && propertyId.isNotEmpty) {
      // Utiliser l'endpoint correct avec propertyId
      uploadUrl = ApiEndpoints.propertyMedia(propertyId);
    } else {
      // Fallback sur l'ancien endpoint (si nécessaire pour la création)
      uploadUrl = ApiEndpoints.propertyUpload;
    }

    if (kDebugMode) {
      debugPrint('[UPLOAD] Using URL: $uploadUrl for property: $propertyId');
    }

    final response = await _apiService.postMultipart(
      uploadUrl,
      fields: {},
      files: [multipartFile],
      requireAuth: true,
    );

    if (response is Map<String, dynamic> && response.containsKey('url')) {
      return response['url']?.toString();
    } else if (response is List && response.isNotEmpty) {
      // Si la réponse est une liste de médias, retourner l'URL du premier
      final firstMedia = response.first;
      if (firstMedia is Map<String, dynamic> && firstMedia.containsKey('secure_url')) {
        return firstMedia['secure_url']?.toString();
      }
    }
    return null;
  }

  /// Supprime la photo de profil utilisateur
  Future<void> deleteProfilePhoto() async {
    await _apiService.delete(
      ApiEndpoints.userProfilePhotoDelete,
      requireAuth: true,
    );
  }
}
