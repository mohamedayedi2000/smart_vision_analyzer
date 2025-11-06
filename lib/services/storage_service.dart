// lib/services/storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_vision_analyzer/services/AudioService.dart';
import 'package:smart_vision_analyzer/services/VibrationService.dart';
import 'package:smart_vision_analyzer/services/notification_service.dart';
import '../models/analysis_result.dart';

/// Handles all persistent storage (settings + analysis history)
/// and triggers user feedback (sound, vibration, notification).
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // ============================================================
  // 🔹 ANALYSIS HISTORY MANAGEMENT
  // ============================================================

  /// Saves a new analysis result and triggers user feedback.
  Future<void> saveResult(AnalysisResult result) async {
    final prefs = await SharedPreferences.getInstance();

    final results = await getResults();
    results.add(result);

    final jsonList = results.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList('analysis_results', jsonList);

    // Trigger notification, sound, and vibration (if enabled)
    await _notifyNewHistory(result);
  }

  /// Retrieves the saved analysis history list.
  Future<List<AnalysisResult>> getResults() async {
    final prefs = await SharedPreferences.getInstance();
    final resultsJson = prefs.getStringList('analysis_results');
    if (resultsJson == null) return [];

    return resultsJson.map((jsonString) {
      try {
        return AnalysisResult.fromJson(jsonDecode(jsonString));
      } catch (_) {
        // Skip invalid entries
        return null;
      }
    }).whereType<AnalysisResult>().toList();
  }

  /// Clears the saved history.
  Future<void> clearResults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('analysis_results');
  }

  /// Shows a notification + sound + vibration for new results.
  Future<void> _notifyNewHistory(AnalysisResult result) async {
    final prefs = await SharedPreferences.getInstance();

    final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    final soundEnabled = prefs.getBool('sound_enabled') ?? true;
    final vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;

    // 🛎️ Show notification if enabled
    if (notificationsEnabled) {
      final notificationService = NotificationService();
      await notificationService.initialize();
      await notificationService.showNotification(
        title: '🕒 New History Entry Added',
        body: '${result.type} result saved successfully.',
        payload: 'open_history',
      );
    }

    // 🔊 Play success sound (non-blocking)
    if (soundEnabled) {
      final audioService = AudioService();
      await audioService.playSuccess();
    }

    // 💥 Vibrate lightly
    if (vibrationEnabled) {
      final vibrationService = VibrationService();
      await vibrationService.light();
    }
  }

  // ============================================================
  // ⚙️ USER SETTINGS MANAGEMENT
  // ============================================================

  // === THEME ===
  Future<void> setDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', isDark);
  }

  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('dark_mode') ?? false;
  }

  // === SOUND ===
  Future<void> setSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', enabled);
  }

  Future<bool> getSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('sound_enabled') ?? true;
  }

  // === VIBRATION ===
  Future<void> setVibrationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vibration_enabled', enabled);
  }

  Future<bool> getVibrationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('vibration_enabled') ?? true;
  }

  // === NOTIFICATIONS ===
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
  }

  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true;
  }

  // === LANGUAGE ===
  Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
  }

  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('language') ?? 'English';
  }

  // === COMBINED SETTINGS ===
  Future<Map<String, dynamic>> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'darkMode': prefs.getBool('dark_mode') ?? false,
      'soundEnabled': prefs.getBool('sound_enabled') ?? true,
      'vibrationEnabled': prefs.getBool('vibration_enabled') ?? true,
      'notificationsEnabled': prefs.getBool('notifications_enabled') ?? true,
      'language': prefs.getString('language') ?? 'English',
    };
  }
}
