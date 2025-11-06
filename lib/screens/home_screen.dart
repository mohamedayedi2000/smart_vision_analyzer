import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
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
  final StorageService _storageService = StorageService();
  bool _vibrationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final vibration = await _storageService.getVibrationEnabled();
    setState(() {
      _vibrationEnabled = vibration;
    });
  }

  void _vibrate() async {
    if (!_vibrationEnabled) return;
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 50);
    }
  }

  List<Widget> get _screens => [
    _HomeContent(vibrationEnabled: _vibrationEnabled),
    const HistoryScreen(),
    SettingsScreen(
      onThemeChanged: widget.onThemeChanged,
      onLanguageChanged: widget.onLanguageChanged,
    ),
  ];

  void _onItemTapped(int index) {
    _vibrate();
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // close the drawer after selection
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
            onPressed: () {
              _vibrate();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
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
                color: Colors.blue,
              ),
              child: Center(
                child: Text(
                  localizations.appTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: Text(localizations.home),
              selected: _selectedIndex == 0,
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: Text(localizations.history),
              selected: _selectedIndex == 1,
              onTap: () => _onItemTapped(1),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(localizations.settings),
              selected: _selectedIndex == 2,
              onTap: () => _onItemTapped(2),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info),
              title: Text(localizations.about),
              onTap: () {
                _vibrate();
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
    );
  }
}

class _HomeContent extends StatefulWidget {
  final bool vibrationEnabled;

  const _HomeContent({required this.vibrationEnabled});

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  void _vibrate() async {
    if (!widget.vibrationEnabled) return;
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 50);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isRTL = Localizations.localeOf(context).languageCode == 'ar';

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.mlFeatures,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              localizations.poweredBy,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                children: [
                  _buildFeatureCard(
                    localizations.textRecognition,
                    Icons.text_fields,
                    Colors.green,
                        () {
                      _vibrate();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            const TextRecognitionScreen()),
                      );
                    },
                  ),
                  _buildFeatureCard(
                    localizations.faceDetection,
                    Icons.face,
                    Colors.orange,
                        () {
                      _vibrate();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            const FaceDetectionScreen()),
                      );
                    },
                  ),
                  _buildFeatureCard(
                    localizations.imageLabeling,
                    Icons.label,
                    Colors.blue,
                        () {
                      _vibrate();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ImageAnalysisScreen()),
                      );
                    },
                  ),
                  _buildFeatureCard(
                    localizations.barcodeScan,
                    Icons.qr_code,
                    Colors.purple,
                        () {
                      _vibrate();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            const BarcodeScanningScreen()),
                      );
                    },
                  ),
                  _buildFeatureCard(
                    localizations.languageId,
                    Icons.language,
                    Colors.red,
                        () {
                      _vibrate();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            const LanguageIdentificationScreen()),
                      );
                    },
                  ),
                  _buildFeatureCard(
                    localizations.translation,
                    Icons.translate,
                    Colors.teal,
                        () {
                      _vibrate();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const TranslationScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
