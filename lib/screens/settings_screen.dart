import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/AudioService.dart';
import '../services/VibrationService.dart';
import '../services/storage_service.dart';
import '../services/app_localizations.dart';
import '../services/notification_service.dart';


class SettingsScreen extends StatefulWidget {
  final Function(bool)? onThemeChanged;
  final Function(String)? onLanguageChanged;

  const SettingsScreen({super.key, this.onThemeChanged, this.onLanguageChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storageService = StorageService();
  final NotificationService _notificationService = NotificationService();
  final VibrationService _vibrationService = VibrationService();
  final AudioService _audioService = AudioService();

  bool _isDarkMode = false;
  bool _vibrationEnabled = true;
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final isDark = await _storageService.getDarkMode();
    final vibration = await _storageService.getVibrationEnabled();
    final sound = await _storageService.getSoundEnabled();
    final notifications = await _storageService.getNotificationsEnabled();
    final language = await _storageService.getLanguage();

    setState(() {
      _isDarkMode = isDark;
      _vibrationEnabled = vibration;
      _soundEnabled = sound;
      _notificationsEnabled = notifications;
      _selectedLanguage = language;
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    setState(() => _isDarkMode = value);
    await _storageService.setDarkMode(value);
    widget.onThemeChanged?.call(value);

    // Provide feedback
    await _vibrationService.light();
    await _audioService.playClick();

    if (mounted) {
      final localizations = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${value ? localizations.enabled : localizations.disabled} - ${localizations.darkMode}',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _toggleVibration(bool value) async {
    setState(() => _vibrationEnabled = value);
    await _storageService.setVibrationEnabled(value);

    // Test vibration immediately if enabled
    if (value) {
      await _vibrationService.success();
    }
    await _audioService.playClick();

    if (mounted) {
      final localizations = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${localizations.vibration} ${value ? localizations.enabled : localizations.disabled}',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _toggleSound(bool value) async {
    setState(() => _soundEnabled = value);
    await _storageService.setSoundEnabled(value);

    // Test sound immediately if enabled
    await _vibrationService.light();
    if (value) {
      await _audioService.playSuccess();
    }

    if (mounted) {
      final localizations = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${localizations.soundEffects} ${value ? localizations.enabled : localizations.disabled}',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() => _notificationsEnabled = value);
    await _storageService.setNotificationsEnabled(value);

    if (value) {
      // Request permissions and setup daily reminders
      final hasPermission = await _notificationService.requestPermissions();
      if (hasPermission) {
        await _notificationService.showDailyReminder();

        // Show test notification
        await _notificationService.showNotification(
          title: '🔔 Notifications Enabled',
          body: 'You will now receive app updates and reminders!',
        );
      } else {
        // Permission denied, revert the setting
        setState(() => _notificationsEnabled = false);
        await _storageService.setNotificationsEnabled(false);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notification permission denied. Please enable it in settings.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }
    } else {
      // Cancel all notifications
      await _notificationService.cancelDailyReminder();
    }

    await _vibrationService.light();
    await _audioService.playClick();

    if (mounted) {
      final localizations = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${localizations.notifications} ${value ? localizations.enabled : localizations.disabled}',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _changeLanguage(String? newValue) async {
    if (newValue == null) return;

    setState(() => _selectedLanguage = newValue);
    await _storageService.setLanguage(newValue);
    widget.onLanguageChanged?.call(newValue);

    await _vibrationService.light();
    await _audioService.playClick();

    if (mounted) {
      final localizations = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${localizations.language} changed to $newValue',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settings),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            localizations.appearance,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: Icon(
                _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: _isDarkMode ? Colors.blue : Colors.orange,
              ),
              title: Text(localizations.darkMode),
              subtitle: Text(_isDarkMode
                  ? localizations.enabled
                  : localizations.disabled),
              trailing: Switch(
                value: _isDarkMode,
                onChanged: _toggleDarkMode,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            localizations.preferences,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    _vibrationEnabled ? Icons.vibration : Icons.mobile_off,
                    color: _vibrationEnabled ? Colors.blue : Colors.grey,
                  ),
                  title: Text(localizations.vibration),
                  subtitle: Text(_vibrationEnabled
                      ? localizations.enabled
                      : localizations.disabled),
                  trailing: Switch(
                    value: _vibrationEnabled,
                    onChanged: _toggleVibration,
                  ),
                ),
                ListTile(
                  leading: Icon(
                    _notificationsEnabled
                        ? Icons.notifications_active
                        : Icons.notifications_off,
                    color: _notificationsEnabled ? Colors.blue : Colors.grey,
                  ),
                  title: Text(localizations.notifications),
                  subtitle: Text(_notificationsEnabled
                      ? localizations.enabled
                      : localizations.disabled),
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: _toggleNotifications,
                  ),
                ),
                ListTile(
                  leading: Icon(
                    _soundEnabled ? Icons.volume_up : Icons.volume_off,
                    color: _soundEnabled ? Colors.blue : Colors.grey,
                  ),
                  title: Text(localizations.soundEffects),
                  subtitle: Text(_soundEnabled
                      ? localizations.enabled
                      : localizations.disabled),
                  trailing: Switch(
                    value: _soundEnabled,
                    onChanged: _toggleSound,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.language, color: Colors.blue),
                  title: Text(localizations.language),
                  subtitle: Text(_selectedLanguage),
                  trailing: DropdownButton<String>(
                    value: _selectedLanguage,
                    underline: const SizedBox(),
                    onChanged: _changeLanguage,
                    items: <String>['English', 'French', 'Arabic']
                        .map<DropdownMenuItem<String>>(
                          (String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      },
                    ).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            localizations.mlFeatures,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.text_fields, color: Colors.green),
                  title: Text(localizations.textRecognition),
                  subtitle: Text(localizations.extract),
                ),
                ListTile(
                  leading: const Icon(Icons.face, color: Colors.orange),
                  title: Text(localizations.faceDetection),
                  subtitle: Text(localizations.detect),
                ),
                ListTile(
                  leading: const Icon(Icons.label, color: Colors.blue),
                  title: Text(localizations.imageLabeling),
                  subtitle: Text(localizations.analyze),
                ),
                ListTile(
                  leading: const Icon(Icons.qr_code, color: Colors.purple),
                  title: Text(localizations.barcodeScan),
                  subtitle: Text(localizations.scan),
                ),
                ListTile(
                  leading: const Icon(Icons.language, color: Colors.red),
                  title: Text(localizations.languageId),
                  subtitle: Text(localizations.identify),
                ),
                ListTile(
                  leading: const Icon(Icons.translate, color: Colors.teal),
                  title: Text(localizations.translation),
                  subtitle: Text(localizations.translateBtn),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            localizations.about,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info, color: Colors.blue),
                  title: Text(localizations.version),
                  subtitle: const Text('1.0.0'),
                ),
                ListTile(
                  leading: const Icon(Icons.developer_mode, color: Colors.blue),
                  title: Text(localizations.poweredBy),
                  subtitle: const Text('Google ML Kit'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


}