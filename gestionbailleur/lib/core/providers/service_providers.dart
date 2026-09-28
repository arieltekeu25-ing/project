import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/secure_storage_service.dart';

/// Provider pour ApiService
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService.instance;
});

/// Provider pour SecureStorageService
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService.instance;
});
