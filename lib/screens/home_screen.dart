import 'package:flutter/material.dart';
import '../services/AudioService.dart';
import '../services/VibrationService.dart';
import '../services/app_localizations.dart';
import '../services/storage_service.dart';

import 'about_screen.dart';
import 'text_recognition_screen.dart';
import 'face_detection_screen.dart';
import 'image_analysis_screen.dart';
import 'barcode_scanning_screen.dart';
import 'language_identification_screen.dart';
import 'translation_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(bool)? onThemeChanged;
  final Function(String)? onLanguageChanged;

  const HomeScreen({super.key, this.onThemeChanged, this.onLanguageChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final VibrationService _vibrationService = VibrationService();
  final AudioService _audioService = AudioService();

  List<Widget> get _screens => [
    const _HomeContent(),
    const HistoryScreen(),
    SettingsScreen(
      onThemeChanged: widget.onThemeChanged,
      onLanguageChanged: widget.onLanguageChanged,
    ),
  ];

  Future<void> _provideFeedback() async {
    final prefs = await StorageService().getSettings();

    if (prefs['vibrationEnabled'] == true) {
      await _vibrationService.light();
    }
    if (prefs['soundEnabled'] == true) {
      await _audioService.playClick();
    }
  }


  void _onItemTapped(int index) async {
    await _provideFeedback();
    setState(() {
      _selectedIndex = index;
    });
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.appTitle),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () async {
              await _provideFeedback();
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutScreen()),
                );
              }
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.blueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.remove_red_eye, size: 48, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    localizations.appTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.blue),
              title: Text(localizations.home),
              selected: _selectedIndex == 0,
              selectedTileColor: Colors.blue.withOpacity(0.1),
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.purple),
              title: Text(localizations.history),
              selected: _selectedIndex == 1,
              selectedTileColor: Colors.purple.withOpacity(0.1),
              onTap: () => _onItemTapped(1),
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.orange),
              title: Text(localizations.settings),
              selected: _selectedIndex == 2,
              selectedTileColor: Colors.orange.withOpacity(0.1),
              onTap: () => _onItemTapped(2),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.teal),
              title: Text(localizations.about),
              onTap: () async {
                await _provideFeedback();
                if (mounted) {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutScreen()),
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
    );
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent>
    with SingleTickerProviderStateMixin {
  final VibrationService _vibrationService = VibrationService();
  final AudioService _audioService = AudioService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _provideFeedback() async {
    final prefs = await StorageService().getSettings();

    if (prefs['vibrationEnabled'] == true) {
      await _vibrationService.light();
    }
    if (prefs['soundEnabled'] == true) {
      await _audioService.playClick();
    }
  }


  Future<void> _navigateToScreen(Widget screen) async {
    await _provideFeedback();
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isRTL = Localizations.localeOf(context).languageCode == 'ar';

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations.mlFeatures,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            localizations.poweredBy,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Features Grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio:
                  MediaQuery.of(context).size.width < 400 ? 0.9 : 1.0,
                  children: [
                    _buildFeatureCard(
                      localizations.textRecognition,
                      localizations.extract,
                      Icons.text_fields,
                      Colors.green,
                          () => _navigateToScreen(const TextRecognitionScreen()),
                    ),
                    _buildFeatureCard(
                      localizations.faceDetection,
                      localizations.detect,
                      Icons.face,
                      Colors.orange,
                          () => _navigateToScreen(const FaceDetectionScreen()),
                    ),
                    _buildFeatureCard(
                      localizations.imageLabeling,
                      localizations.analyze,
                      Icons.label,
                      Colors.blue,
                          () => _navigateToScreen(const ImageAnalysisScreen()),
                    ),
                    _buildFeatureCard(
                      localizations.barcodeScan,
                      localizations.scan,
                      Icons.qr_code,
                      Colors.purple,
                          () => _navigateToScreen(const BarcodeScanningScreen()),
                    ),
                    _buildFeatureCard(
                      localizations.languageId,
                      localizations.identify,
                      Icons.language,
                      Colors.red,
                          () => _navigateToScreen(
                          const LanguageIdentificationScreen()),
                    ),
                    _buildFeatureCard(
                      localizations.translation,
                      localizations.translateBtn,
                      Icons.translate,
                      Colors.teal,
                          () => _navigateToScreen(const TranslationScreen()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
      String title,
      String subtitle,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    final displayColor =
    color is MaterialColor ? color.shade700 : color.withOpacity(0.8);

    return Card(
      elevation: 3,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.05),
                color.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, size: 30, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: displayColor,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.fade,
                softWrap: true,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.fade,
                softWrap: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
