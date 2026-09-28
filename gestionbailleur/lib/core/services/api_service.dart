import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../network/network_exceptions.dart';
import 'secure_storage_service.dart';

/// Service API pour les requêtes HTTP
class ApiService {
  static ApiService? _instance;
  final SecureStorageService _secureStorage = SecureStorageService.instance;
  static bool _isWarmingUp = false;
  static DateTime? _lastWarmUpTime;

  ApiService._();

  /// Instance singleton
  static ApiService get instance {
    _instance ??= ApiService._();
    return _instance!;
  }

  /// Vérifier la connexion internet
  Future<bool> _checkInternetConnection() async {
    try {
      if (kDebugMode) {
        print('🌐 Vérification de la connexion internet...');
      }
      
      // Sur Flutter Web, InternetAddress.lookup n'est pas supporté
      // On assume que la connexion fonctionne sur le web
      if (kIsWeb) {
        if (kDebugMode) {
          print('🌐 Web : connexion internet assumée active');
        }
        return true;
      }
      
      // Essayer de résoudre google.com avec timeout court
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      
      if (kDebugMode) {
        print('🌐 Connexion internet: ${result.isNotEmpty && result[0].rawAddress.isNotEmpty}');
      }
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('🌐 Erreur connexion internet: $e');
      }
      // Sur le web, on retourne true même en cas d'erreur car la vérification n'est pas supportée
      if (kIsWeb) {
        return true;
      }
      return false;
    }
  }

  /// Ping le backend pour le réveiller du spindown Render
  Future<void> warmUpBackend() async {
    // Éviter les warm-ups multiples et inutiles
    if (_isWarmingUp) {
      if (kDebugMode) {
        print('🔥 Warm-up déjà en cours, skip...');
      }
      return;
    }
    
    // Si le dernier warm-up était il y a moins de 3 minutes, skip
    if (_lastWarmUpTime != null) {
      final timeSinceLastWarmUp = DateTime.now().difference(_lastWarmUpTime!);
      if (timeSinceLastWarmUp.inMinutes < 3) {
        if (kDebugMode) {
          print('🔥 Warm-up récent (${timeSinceLastWarmUp.inSeconds}s), skip...');
        }
        return;
      }
    }
    
    _isWarmingUp = true;
    
    try {
      if (kDebugMode) {
        print('🔥 Réveil du backend Render (warm-up)...');
      }
      
      // Faire une requête simple pour réveiller le backend avec timeout plus long
      final uri = Uri.parse('${AppConfig.apiBaseUrl}/api/v1/health/');
      await http.get(uri).timeout(const Duration(seconds: 30));
      
      _lastWarmUpTime = DateTime.now();
      
      if (kDebugMode) {
        print('🔥 Backend réveillé avec succès');
      }
    } catch (e) {
      _lastWarmUpTime = DateTime.now(); // Marquer comme tenté même si échec
      if (kDebugMode) {
        print('🔥 Warm-up backend (attendu pour Render spindown): $e');
      }
      // On ignore les erreurs, c'est juste un warm-up
    } finally {
      _isWarmingUp = false;
    }
  }

  /// Obtenir les headers avec authentification
  Future<Map<String, String>> _getHeaders({bool requireAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Attacher le token d'authentification s'il existe en stockage local
    final token = await _secureStorage.getAccessToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// Requête GET avec retry automatique pour erreurs 503
  Future<dynamic> get(
    String endpoint, {
    bool requireAuth = true,
    Map<String, String>? queryParams,
    int maxRetries = 5, // Augmenté à 5 pour Render spindown
  }) async {
    // Vérifier la connexion internet avant la première tentative
    final hasInternet = await _checkInternetConnection();
    if (!hasInternet) {
      throw NetworkException(
        'Aucune connexion internet détectée. Vérifiez votre connexion et réessayez.',
      );
    }
    
    int attempt = 0;
    
    while (attempt < maxRetries) {
      try {
        final headers = await _getHeaders(requireAuth: requireAuth);
        
        var uri = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
        if (queryParams != null) {
          uri = uri.replace(queryParameters: queryParams);
        }

        if (kDebugMode) {
          print('🌐 API GET URL: $uri (attempt ${attempt + 1}/$maxRetries)');
          print('🌐 API Base URL: ${AppConfig.apiBaseUrl}');
        }

        final response = await http
            .get(uri, headers: headers)
            .timeout(const Duration(milliseconds: AppConfig.apiTimeout));

        // Si succès ou erreur non retryable, retourner directement
        if (response.statusCode != 503) {
          return _handleResponse(response);
        }
        
        // Erreur 503 - Render spindown, retenter avec délai très long
        attempt++;
        if (attempt < maxRetries) {
          if (kDebugMode) {
            print('⚠️ 503 Service Unavailable (Render spindown) - Retry $attempt/$maxRetries');
          }
          // Délai très long pour Render spindown (jusqu'à 75s)
          final delay = Duration(seconds: attempt * 20);
          if (kDebugMode) {
            print('⏱️ Attente de ${delay.inSeconds}s avant retry (Render spindown)...');
          }
          await Future.delayed(delay);
        }
      } catch (e) {
        // Si c'est une erreur de timeout ou connexion, on peut retenter
        final errorStr = e.toString().toLowerCase();
        if ((errorStr.contains('timeout') || errorStr.contains('connection') || errorStr.contains('socket')) && 
            attempt < maxRetries - 1) {
          attempt++;
          if (kDebugMode) {
            print('⚠️ Connection error - Retry $attempt/$maxRetries');
          }
          // Délai très long pour Render spindown
          await Future.delayed(Duration(seconds: attempt * 15));
          continue;
        }
        throw _handleError(e);
      }
    }
    
    // Après tous les essais, lancer une erreur
    throw NetworkException(
      'Le serveur met du temps à démarrer (Render spindown). Veuillez réessayer dans quelques instants.',
    );
  }

  /// Requête POST avec retry automatique pour erreurs 503
  Future<dynamic> post(
    String endpoint, {
    dynamic body,
    bool requireAuth = false,
    int maxRetries = 5, // Augmenté à 5 pour Render spindown
  }) async {
    // Vérifier la connexion internet avant la première tentative
    final hasInternet = await _checkInternetConnection();
    if (!hasInternet) {
      throw NetworkException(
        'Aucune connexion internet détectée. Vérifiez votre connexion et réessayez.',
      );
    }
    
    int attempt = 0;
    
    while (attempt < maxRetries) {
      try {
        final headers = await _getHeaders(requireAuth: requireAuth);
        final uri = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');

        if (kDebugMode) {
          print('🌐 API POST URL: $uri (attempt ${attempt + 1}/$maxRetries)');
          print('🌐 API Base URL: ${AppConfig.apiBaseUrl}');
        }

        final response = await http
            .post(
              uri,
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            )
            .timeout(const Duration(milliseconds: AppConfig.apiTimeout));

        // Si succès ou erreur non retryable, retourner directement
        if (response.statusCode != 503) {
          return _handleResponse(response);
        }
        
        // Erreur 503 - Render spindown, retenter avec délai très long
        attempt++;
        if (attempt < maxRetries) {
          if (kDebugMode) {
            print('⚠️ 503 Service Unavailable (Render spindown) - Retry $attempt/$maxRetries');
          }
          // Délai très long pour Render spindown (jusqu'à 75s)
          final delay = Duration(seconds: attempt * 20);
          if (kDebugMode) {
            print('⏱️ Attente de ${delay.inSeconds}s avant retry (Render spindown)...');
          }
          await Future.delayed(delay);
        }
      } catch (e) {
        final errorStr = e.toString().toLowerCase();
        if ((errorStr.contains('timeout') || errorStr.contains('connection') || errorStr.contains('socket')) && 
            attempt < maxRetries - 1) {
          attempt++;
          if (kDebugMode) {
            print('⚠️ Connection error - Retry $attempt/$maxRetries');
          }
          // Délai très long pour Render spindown
          await Future.delayed(Duration(seconds: attempt * 15));
          continue;
        }
        throw _handleError(e);
      }
    }
    
    throw NetworkException(
      'Le serveur met du temps à démarrer (Render spindown). Veuillez réessayer dans quelques instants.',
    );
  }

  /// Requête PUT
  Future<dynamic> put(
    String endpoint, {
    dynamic body,
    bool requireAuth = true,
  }) async {
    try {
      final headers = await _getHeaders(requireAuth: requireAuth);
      final uri = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');

      final response = await http
          .put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(milliseconds: AppConfig.apiTimeout));

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Requête PATCH
  Future<dynamic> patch(
    String endpoint, {
    dynamic body,
    bool requireAuth = true,
  }) async {
    try {
      final headers = await _getHeaders(requireAuth: requireAuth);
      final uri = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');

      final response = await http
          .patch(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(milliseconds: AppConfig.apiTimeout));

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Requête Multipart pour l'upload de médias (photos, vidéos)
  Future<dynamic> postMultipart(
    String endpoint, {
    required Map<String, String> fields,
    List<http.MultipartFile>? files,
    bool requireAuth = true,
    int? timeoutMs,
  }) async {
    try {
      final uri = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
      final request = http.MultipartRequest('POST', uri);

      if (requireAuth) {
        final token = await _secureStorage.getAccessToken();
        if (token != null) {
          request.headers['Authorization'] = 'Bearer $token';
        }
      }

      request.fields.addAll(fields);
      if (files != null) {
        request.files.addAll(files);
      }

      final streamedResponse = await request
          .send()
          .timeout(Duration(milliseconds: timeoutMs ?? AppConfig.apiTimeout));
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Requête DELETE
  Future<dynamic> delete(
    String endpoint, {
    bool requireAuth = true,
  }) async {
    try {
      final headers = await _getHeaders(requireAuth: requireAuth);
      final uri = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');

      final response = await http
          .delete(uri, headers: headers)
          .timeout(const Duration(milliseconds: AppConfig.apiTimeout));

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Gérer la réponse
  dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        if (response.body.isEmpty) return null;
        return jsonDecode(response.body);
      case 204:
        return null;
      case 400:
        final error = jsonDecode(response.body);
        String errorMessage = 'Bad Request';
        if (error is Map) {
          if (error['message'] != null) {
            errorMessage = error['message'].toString();
          } else if (error['detail'] != null) {
            errorMessage = error['detail'].toString();
          } else if (error['error'] != null) {
            errorMessage = error['error'].toString();
          } else {
            final errorsList = <String>[];
            error.forEach((key, value) {
              if (value is List) {
                errorsList.add(value.join(', '));
              } else if (value is String) {
                errorsList.add(value);
              }
            });
            if (errorsList.isNotEmpty) {
              errorMessage = errorsList.join('\n');
            }
          }
        } else if (error is String) {
          errorMessage = error;
        }
        throw BadRequestException(errorMessage);
      case 401:
        throw UnauthorizedException('Non autorisé - Veuillez vous reconnecter');
      case 403:
        throw ForbiddenException('Accès refusé');
      case 404:
        throw NotFoundException('Ressource non trouvée');
      case 503:
        throw NetworkException(
          'Service temporairement indisponible - Réessayez dans quelques instants',
          statusCode: 503,
        );
      case 500:
        throw ServerException('Erreur serveur - Veuillez réessayer plus tard');
      default:
        // Vérifier si c'est une erreur de connexion
        final errorStr = response.body.toString().toLowerCase();
        if (errorStr.contains('connection refused') || 
            errorStr.contains('failed host lookup') ||
            errorStr.contains('network unreachable') ||
            errorStr.contains('socket') ||
            errorStr.contains('timeout')) {
          throw NetworkException(
            'Impossible de se connecter au serveur. Vérifiez votre connexion internet.',
            statusCode: response.statusCode,
          );
        }
        throw NetworkException(
          'Erreur inconnue: ${response.statusCode}',
          statusCode: response.statusCode,
        );
    }
  }

  /// Gérer les erreurs
  NetworkException _handleError(dynamic error) {
    if (error is NetworkException) {
      return error;
    }
    
    // Vérifier si c'est une erreur de connexion
    final errorStr = error.toString().toLowerCase();
    if (errorStr.contains('connection refused') || 
        errorStr.contains('failed host lookup') ||
        errorStr.contains('network unreachable') ||
        errorStr.contains('socket') ||
        errorStr.contains('timeout')) {
      return NetworkException(
        'Impossible de se connecter au serveur. Vérifiez votre connexion internet.',
      );
    }
    
    return NetworkException(error.toString());
  }
}
