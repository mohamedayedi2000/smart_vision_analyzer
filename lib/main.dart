import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:smart_vision_analyzer/screens/history_screen.dart';
import 'package:smart_vision_analyzer/screens/home_screen.dart';
import 'package:smart_vision_analyzer/services/app_localizations.dart';
import 'package:smart_vision_analyzer/services/notification_service.dart';
import 'package:smart_vision_analyzer/services/storage_service.dart';
import 'app/theme.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  // ✅ Handle notification tap
  NotificationService.onNotificationTap = (payload) {
    if (payload == 'open_history') {
      navigatorKey.currentState?.pushNamed('/history');
    }
  };

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final StorageService _storageService = StorageService();
  bool _isDarkMode = false;
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final isDark = await _storageService.getDarkMode();
    final language = await _storageService.getLanguage();

    setState(() {
      _isDarkMode = isDark;
      _locale = _getLocaleFromLanguage(language);
    });
  }

  Locale _getLocaleFromLanguage(String language) {
    switch (language) {
      case 'French':
        return const Locale('fr');
      case 'Arabic':
        return const Locale('ar');
      default:
        return const Locale('en');
    }
  }

  void _toggleTheme(bool isDark) {
    setState(() {
      _isDarkMode = isDark;
    });
    _storageService.setDarkMode(isDark);
  }

  void _changeLanguage(String language) {
    setState(() {
      _locale = _getLocaleFromLanguage(language);
    });
    _storageService.setLanguage(language);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Smart Vision Analyzer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
        Locale('ar'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routes: {
        '/history': (context) => const HistoryScreen(),
      },
      home: HomeScreen(
        onThemeChanged: _toggleTheme,
        onLanguageChanged: _changeLanguage,
      ),
    );
  }
}
