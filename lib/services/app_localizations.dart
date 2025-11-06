import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Home Screen
      'app_title': 'Smart Vision Analyzer',
      'ml_features': 'ML Kit Features',
      'powered_by': 'Powered by Google ML Kit - Offline AI Processing',
      'home': 'Home',
      'history': 'History',
      'settings': 'Settings',

      // Features
      'text_recognition': 'Text Recognition',
      'face_detection': 'Face Detection',
      'image_labeling': 'Image Labeling',
      'barcode_scan': 'Barcode Scan',
      'language_id': 'Language ID',
      'translation': 'Translation',

      // Buttons
      'gallery': 'Gallery',
      'camera': 'Camera',
      'analyze': 'Analyze Image',
      'scan': 'Scan Barcodes',
      'detect': 'Detect Faces',
      'extract': 'Extract Text',
      'identify': 'Identify Language',
      'translate': 'Translate',

      // Settings
      'appearance': 'Appearance',
      'preferences': 'Preferences',
      'dark_mode': 'Dark Mode',
      'vibration': 'Vibration',
      'notifications': 'Notifications',
      'sound_effects': 'Sound Effects',
      'language': 'Language',
      'enabled': 'Enabled',
      'disabled': 'Disabled',

      // About
      'about': 'About',
      'version': 'Version',
      'about_app': 'About the App',
      'about_description': 'Smart Vision Analyzer is a powerful mobile application that leverages Google ML Kit to provide advanced computer vision and natural language processing capabilities directly on your device.',
      'ml_services': 'ML Kit Services Used',
      'technologies': 'Technologies',

      // History
      'analysis_history': 'Analysis History',
      'no_history': 'No analysis history',
      'clear_history': 'Clear History',
      'clear_history_message': 'Are you sure you want to delete all analysis history?',
      'cancel': 'Cancel',
      'clear': 'Clear',
      'history_cleared': 'History cleared',

      // Messages
      'select_image': 'Select an image to',
      'enter_text': 'Enter text to',
      'translating': 'Translating...',
      'downloading_models': 'Downloading language models...',
      'models_downloaded': 'Language models downloaded successfully',
      'copied_clipboard': 'Copied to clipboard',
      'error': 'Error',

      // Results
      'extracted_text': 'Extracted Text:',
      'detected_objects': 'Detected Objects:',
      'faces_detected': 'Faces Detected:',
      'barcodes_found': 'Barcodes Found:',
      'detected_language': 'Detected Language',
      'possible_languages': 'Possible Languages:',
      'translation_result': 'Translation',

      // Face Detection
      'smiling': 'Smiling',
      'left_eye': 'Left Eye',
      'right_eye': 'Right Eye',
      'open': 'Open',
      'closed': 'Closed',
      'yes': 'Yes',
      'no': 'No',
      // Inside the 'en' map
      'error_picking_image': 'Error picking image',
      'error_taking_photo': 'Error taking photo',
      'error_extracting_text': 'Error extracting text',
      'no_text_detected': 'No text detected',
      'select_image_to_extract_text': 'Select an image to extract text',

    },
    'fr': {
      // Home Screen
      'app_title': 'Analyseur Vision Intelligent',
      'ml_features': 'Fonctionnalités ML Kit',
      'powered_by': 'Propulsé par Google ML Kit - Traitement IA hors ligne',
      'home': 'Accueil',
      'history': 'Historique',
      'settings': 'Paramètres',

      // Features
      'text_recognition': 'Reconnaissance de texte',
      'face_detection': 'Détection de visage',
      'image_labeling': 'Étiquetage d\'image',
      'barcode_scan': 'Scan de code-barres',
      'language_id': 'ID de langue',
      'translation': 'Traduction',

      // Buttons
      'gallery': 'Galerie',
      'camera': 'Caméra',
      'analyze': 'Analyser l\'image',
      'scan': 'Scanner les codes',
      'detect': 'Détecter les visages',
      'extract': 'Extraire le texte',
      'identify': 'Identifier la langue',
      'translate': 'Traduire',

      // Settings
      'appearance': 'Apparence',
      'preferences': 'Préférences',
      'dark_mode': 'Mode sombre',
      'vibration': 'Vibration',
      'notifications': 'Notifications',
      'sound_effects': 'Effets sonores',
      'language': 'Langue',
      'enabled': 'Activé',
      'disabled': 'Désactivé',

      // About
      'about': 'À propos',
      'version': 'Version',
      'about_app': 'À propos de l\'application',
      'about_description': 'Smart Vision Analyzer est une application mobile puissante qui exploite Google ML Kit pour fournir des capacités avancées de vision par ordinateur et de traitement du langage naturel directement sur votre appareil.',
      'ml_services': 'Services ML Kit utilisés',
      'technologies': 'Technologies',

      // History
      'analysis_history': 'Historique d\'analyse',
      'no_history': 'Aucun historique d\'analyse',
      'clear_history': 'Effacer l\'historique',
      'clear_history_message': 'Êtes-vous sûr de vouloir supprimer tout l\'historique d\'analyse?',
      'cancel': 'Annuler',
      'clear': 'Effacer',
      'history_cleared': 'Historique effacé',

      // Messages
      'select_image': 'Sélectionnez une image pour',
      'enter_text': 'Entrez le texte pour',
      'translating': 'Traduction en cours...',
      'downloading_models': 'Téléchargement des modèles linguistiques...',
      'models_downloaded': 'Modèles linguistiques téléchargés avec succès',
      'copied_clipboard': 'Copié dans le presse-papiers',
      'error': 'Erreur',

      // Results
      'extracted_text': 'Texte extrait:',
      'detected_objects': 'Objets détectés:',
      'faces_detected': 'Visages détectés:',
      'barcodes_found': 'Codes-barres trouvés:',
      'detected_language': 'Langue détectée',
      'possible_languages': 'Langues possibles:',
      'translation_result': 'Traduction',

      // Face Detection
      'smiling': 'Souriant',
      'left_eye': 'Œil gauche',
      'right_eye': 'Œil droit',
      'open': 'Ouvert',
      'closed': 'Fermé',
      'yes': 'Oui',
      'no': 'Non',
      // Inside the 'fr' map
      'error_picking_image': 'Erreur lors de la sélection de l\'image',
      'error_taking_photo': 'Erreur lors de la prise de photo',
      'error_extracting_text': 'Erreur lors de l\'extraction du texte',
      'no_text_detected': 'Aucun texte détecté',
      'select_image_to_extract_text': 'Sélectionnez une image pour extraire le texte',

    },
    'ar': {
      // Home Screen
      'app_title': 'محلل الرؤية الذكية',
      'ml_features': 'ميزات ML Kit',
      'powered_by': 'مدعوم بواسطة Google ML Kit - معالجة الذكاء الاصطناعي دون اتصال',
      'home': 'الرئيسية',
      'history': 'السجل',
      'settings': 'الإعدادات',

      // Features
      'text_recognition': 'التعرف على النص',
      'face_detection': 'كشف الوجه',
      'image_labeling': 'تصنيف الصور',
      'barcode_scan': 'مسح الباركود',
      'language_id': 'تحديد اللغة',
      'translation': 'الترجمة',

      // Buttons
      'gallery': 'المعرض',
      'camera': 'الكاميرا',
      'analyze': 'تحليل الصورة',
      'scan': 'مسح الأكواد',
      'detect': 'كشف الوجوه',
      'extract': 'استخراج النص',
      'identify': 'تحديد اللغة',
      'translate': 'ترجمة',

      // Settings
      'appearance': 'المظهر',
      'preferences': 'التفضيلات',
      'dark_mode': 'الوضع الداكن',
      'vibration': 'الاهتزاز',
      'notifications': 'الإشعارات',
      'sound_effects': 'المؤثرات الصوتية',
      'language': 'اللغة',
      'enabled': 'مفعل',
      'disabled': 'معطل',

      // About
      'about': 'حول',
      'version': 'الإصدار',
      'about_app': 'حول التطبيق',
      'about_description': 'محلل الرؤية الذكية هو تطبيق جوال قوي يستفيد من Google ML Kit لتوفير قدرات متقدمة في رؤية الكمبيوتر ومعالجة اللغة الطبيعية مباشرة على جهازك.',
      'ml_services': 'خدمات ML Kit المستخدمة',
      'technologies': 'التقنيات',

      // History
      'analysis_history': 'سجل التحليل',
      'no_history': 'لا يوجد سجل تحليل',
      'clear_history': 'مسح السجل',
      'clear_history_message': 'هل أنت متأكد من رغبتك في حذف كل سجل التحليل؟',
      'cancel': 'إلغاء',
      'clear': 'مسح',
      'history_cleared': 'تم مسح السجل',

      // Messages
      'select_image': 'اختر صورة لـ',
      'enter_text': 'أدخل النص لـ',
      'translating': 'جارٍ الترجمة...',
      'downloading_models': 'جارٍ تنزيل نماذج اللغة...',
      'models_downloaded': 'تم تنزيل نماذج اللغة بنجاح',
      'copied_clipboard': 'تم النسخ إلى الحافظة',
      'error': 'خطأ',

      // Results
      'extracted_text': 'النص المستخرج:',
      'detected_objects': 'الكائنات المكتشفة:',
      'faces_detected': 'الوجوه المكتشفة:',
      'barcodes_found': 'الأكواد الموجودة:',
      'detected_language': 'اللغة المكتشفة',
      'possible_languages': 'اللغات المحتملة:',
      'translation_result': 'الترجمة',

      // Face Detection
      'smiling': 'يبتسم',
      'left_eye': 'العين اليسرى',
      'right_eye': 'العين اليمنى',
      'open': 'مفتوحة',
      'closed': 'مغلقة',
      'yes': 'نعم',
      'no': 'لا',
      // Inside the 'ar' map
      'error_picking_image': 'حدث خطأ أثناء اختيار الصورة',
      'error_taking_photo': 'حدث خطأ أثناء التقاط الصورة',
      'error_extracting_text': 'حدث خطأ أثناء استخراج النص',
      'no_text_detected': 'لم يتم اكتشاف أي نص',
      'select_image_to_extract_text': 'اختر صورة لاستخراج النص',

    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  String get appTitle => translate('app_title');
  String get mlFeatures => translate('ml_features');
  String get poweredBy => translate('powered_by');
  String get home => translate('home');
  String get history => translate('history');
  String get settings => translate('settings');
  String get error => translate('error');
  String get barcodesFound => translate('barcodes_found');
  String get selectImage => translate('select_image');
  String get textRecognition => translate('text_recognition');
  String get faceDetection => translate('face_detection');
  String get imageLabeling => translate('image_labeling');
  String get barcodeScan => translate('barcode_scan');
  String get languageId => translate('language_id');
  String get translation => translate('translation');
// Face Detection
  String get facesDetected => translate('faces_detected');
  String get face => translate('face');
  String get smiling => translate('smiling');
  String get leftEye => translate('left_eye');
  String get rightEye => translate('right_eye');
  String get yes => translate('yes');
  String get no => translate('no');
  String get open => translate('open');
  String get closed => translate('closed');

  String get gallery => translate('gallery');
  String get camera => translate('camera');
  String get analyze => translate('analyze');
  String get scan => translate('scan');
  String get detect => translate('detect');
  String get extract => translate('extract');
  String get identify => translate('identify');
  String get translateBtn => translate('translate');

  String get appearance => translate('appearance');
  String get preferences => translate('preferences');
  String get darkMode => translate('dark_mode');
  String get vibration => translate('vibration');
  String get notifications => translate('notifications');
  String get soundEffects => translate('sound_effects');
  String get language => translate('language');
  String get enabled => translate('enabled');
  String get disabled => translate('disabled');
// =================== HISTORY STRINGS ===================

  String get analysisHistory => translate('analysis_history');
  String get noHistory => translate('no_history');
  String get clearHistory => translate('clear_history');
  String get clearHistoryMessage => translate('clear_history_message');
  String get cancel => translate('cancel');
  String get clear => translate('clear');
  String get historyCleared => translate('history_cleared');

// =================== RESULTS STRINGS ===================

  String get extractedText => translate('extracted_text');
  String get detectedObjects => translate('detected_objects');
  String get detectedLanguage => translate('detected_language');
  String get possibleLanguages => translate('possible_languages');

  String get about => translate('about');
  String get version => translate('version');
  String get aboutApp => translate('about_app');
  String get aboutDescription => translate('about_description');
  String get mlServices => translate('ml_services');
  String get technologies => translate('technologies');

  String get errorPickingImage => translate('error_picking_image');
  String get errorTakingPhoto => translate('error_taking_photo');
  String get errorExtractingText => translate('error_extracting_text');
  String get noTextDetected => translate('no_text_detected');
  String get selectImageToExtractText => translate('select_image_to_extract_text');

}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'fr', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}