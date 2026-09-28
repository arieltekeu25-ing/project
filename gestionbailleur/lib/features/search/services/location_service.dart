import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Statut de la géolocalisation utilisateur
enum LocationStatus {
  granted,
  denied,
  permanentlyDenied,
  disabled,
  unsupported,
  unknown,
}

/// Service d'accès à la géolocalisation GPS réelle (Android, iOS & Web)
class LocationService {
  static LocationService? _instance;

  LocationService._();

  static LocationService get instance {
    _instance ??= LocationService._();
    return _instance!;
  }

  /// Vérifier si le service de localisation est activé sur le périphérique
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      return false;
    }
  }

  /// Obtenir le statut actuel des permissions
  Future<LocationStatus> checkPermission() async {
    try {
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationStatus.disabled;
      }

      final permission = await Geolocator.checkPermission();
      return _mapPermissionToStatus(permission);
    } catch (e) {
      return LocationStatus.unknown;
    }
  }

  /// Demander la permission explicite à l'utilisateur
  Future<LocationStatus> requestPermission() async {
    try {
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationStatus.disabled;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      return _mapPermissionToStatus(permission);
    } catch (e) {
      if (kDebugMode) {
        print('Erreur demande géolocalisation: $e');
      }
      return LocationStatus.unknown;
    }
  }

  /// Récupérer les coordonnées GPS réelles de l'utilisateur
  Future<Position?> getCurrentPosition() async {
    try {
      final status = await requestPermission();
      if (status != LocationStatus.granted) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Erreur récupération position GPS: $e');
      }
      return null;
    }
  }

  LocationStatus _mapPermissionToStatus(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return LocationStatus.granted;
      case LocationPermission.denied:
        return LocationStatus.denied;
      case LocationPermission.deniedForever:
        return LocationStatus.permanentlyDenied;
      case LocationPermission.unableToDetermine:
        return LocationStatus.unknown;
    }
  }
}
