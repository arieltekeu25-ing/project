import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// État du thème de l'application
class ThemeState {
  final ThemeMode themeMode;
  final bool isDarkMode;

  const ThemeState({
    this.themeMode = ThemeMode.system,
    this.isDarkMode = false,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    bool? isDarkMode,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

/// Provider pour le thème de l'application
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

/// Notifier pour la gestion du thème
class ThemeNotifier extends StateNotifier<ThemeState> {
  static const String _themeKey = 'theme_mode';
  static const String _darkModeKey = 'dark_mode';
  SharedPreferences? _prefs;
  bool _isInitialized = false;

  ThemeNotifier() : super(const ThemeState()) {
    // Charger le thème de manière asynchrone
    _loadTheme();
  }

  /// Charger le thème depuis les préférences
  Future<void> _loadTheme() async {
    _prefs = await SharedPreferences.getInstance();
    final themeModeIndex = _prefs?.getInt(_themeKey);
    final isDarkMode = _prefs?.getBool(_darkModeKey);

    // Priorité: darkMode manuel > themeMode sauvegardé > système
    ThemeMode themeMode;
    bool darkMode;

    if (isDarkMode != null) {
      // Si darkMode est explicitement défini, l'utiliser
      darkMode = isDarkMode;
      themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    } else if (themeModeIndex != null) {
      // Sinon utiliser themeMode sauvegardé
      themeMode = ThemeMode.values[themeModeIndex.clamp(0, ThemeMode.values.length - 1)];
      darkMode = themeMode == ThemeMode.dark;
    } else {
      // Sinon utiliser le thème système
      themeMode = ThemeMode.system;
      darkMode = false;
    }

    // Ne mettre à jour que si les valeurs sont différentes pour éviter les rebuilds inutiles
    if (state.themeMode != themeMode || state.isDarkMode != darkMode) {
      state = ThemeState(
        themeMode: themeMode,
        isDarkMode: darkMode,
      );
    }
    _isInitialized = true;
  }

  /// Définir le mode de thème
  Future<void> setThemeMode(ThemeMode mode) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setInt(_themeKey, mode.index);
    state = state.copyWith(themeMode: mode);
  }

  /// Activer/Désactiver le mode sombre manuel
  Future<void> setDarkMode(bool isDark) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setBool(_darkModeKey, isDark);
    
    if (isDark) {
      state = state.copyWith(
        themeMode: ThemeMode.dark,
        isDarkMode: true,
      );
    } else {
      state = state.copyWith(
        themeMode: ThemeMode.light,
        isDarkMode: false,
      );
    }
  }

  /// Réinitialiser au thème système
  Future<void> resetToSystem() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setInt(_themeKey, ThemeMode.system.index);
    await _prefs!.remove(_darkModeKey);
    
    state = const ThemeState(
      themeMode: ThemeMode.system,
      isDarkMode: false,
    );
  }

  /// S'assurer que le thème est chargé (appelé après connexion/déconnexion)
  Future<void> ensureThemeLoaded() async {
    if (!_isInitialized) {
      await _loadTheme();
    } else {
      // Recharger depuis SharedPreferences pour s'assurer que les valeurs sont à jour
      _prefs ??= await SharedPreferences.getInstance();
      final themeModeIndex = _prefs!.getInt(_themeKey);
      final isDarkMode = _prefs!.getBool(_darkModeKey);

      // Priorité: darkMode manuel > themeMode sauvegardé > système
      ThemeMode themeMode;
      bool darkMode;

      if (isDarkMode != null) {
        darkMode = isDarkMode;
        themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
      } else if (themeModeIndex != null) {
        themeMode = ThemeMode.values[themeModeIndex.clamp(0, ThemeMode.values.length - 1)];
        darkMode = themeMode == ThemeMode.dark;
      } else {
        themeMode = ThemeMode.system;
        darkMode = false;
      }

      // Toujours mettre à jour pour garantir la cohérence
      state = ThemeState(
        themeMode: themeMode,
        isDarkMode: darkMode,
      );
    }
  }
}
