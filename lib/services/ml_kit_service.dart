import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_entity_extraction/google_mlkit_entity_extraction.dart';

class MLKitService {
  static final MLKitService _instance = MLKitService._internal();
  factory MLKitService() => _instance;
  MLKitService._internal();

  // --- Core recognizers ---
  final FaceDetector faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
      enableClassification: true,
      enableTracking: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  final ImageLabeler imageLabeler =
  ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.5));

  final BarcodeScanner barcodeScanner = BarcodeScanner();
  final LanguageIdentifier languageIdentifier =
  LanguageIdentifier(confidenceThreshold: 0.5);

  /// --- Extract text from image (Arabic + English + others auto-detected) ---
  Future<String> extractTextFromImage(File image) async {
    final inputImage = InputImage.fromFile(image);
    RecognizedText? recognizedText;

    // ✅ Use the default text recognizer (it automatically supports multiple languages)
    final textRecognizer = TextRecognizer();

    try {
      // Process the image to extract text
      recognizedText = await textRecognizer.processImage(inputImage);
    } catch (e) {
      print('❌ Error during text recognition: $e');
    } finally {
      // Always close the recognizer to free memory
      await textRecognizer.close();
    }

    // ✅ Optional step: Fix Arabic text direction if it's reversed
    String text = recognizedText?.text ?? '';
    if (_looksLikeArabic(text)) {
      text = _fixArabicText(text);
    }

    return text;
  }

  /// ✅ Simple helper to detect if the recognized text contains Arabic characters
  bool _looksLikeArabic(String text) {
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(text);
  }

  /// ✅ Helper to fix Arabic text (removes unnecessary spaces and fixes line issues)
  String _fixArabicText(String text) {
    // You can improve this later for better Arabic shaping or direction handling
    return text
        .split('\n')
        .map((line) => line.trim())
        .join('\n')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  /// --- Detect faces in an image ---
  Future<List<Face>> detectFaces(File image) async {
    final inputImage = InputImage.fromFile(image);
    return await faceDetector.processImage(inputImage);
  }

  /// --- Analyze image labels (objects, scenes, etc.) ---
  Future<List<ImageLabel>> analyzeImageLabels(File image) async {
    final inputImage = InputImage.fromFile(image);
    return await imageLabeler.processImage(inputImage);
  }

  /// --- Scan barcodes (QR, EAN, etc.) ---
  Future<List<Barcode>> scanBarcodes(File image) async {
    final inputImage = InputImage.fromFile(image);
    return await barcodeScanner.processImage(inputImage);
  }

  /// --- Identify primary language of text ---
  Future<String?> identifyLanguage(String text) async {
    try {
      final langCode = await languageIdentifier.identifyLanguage(text);
      if (langCode == 'und') return null; // undefined
      return langCode;
    } catch (_) {
      return null;
    }
  }

  /// --- Identify multiple possible languages ---
  Future<List<IdentifiedLanguage>> identifyPossibleLanguages(String text) async {
    try {
      return await languageIdentifier.identifyPossibleLanguages(text);
    } catch (_) {
      return [];
    }
  }

  /// --- Extract entities like dates, money, addresses, etc. ---
  Future<List<EntityAnnotation>> extractEntities(
      String text, String? languageCode) async {
    EntityExtractorLanguage lang = EntityExtractorLanguage.english;

    switch (languageCode) {
      case 'ar':
        lang = EntityExtractorLanguage.english; // Arabic not supported yet
        break;
      case 'fr':
        lang = EntityExtractorLanguage.french;
        break;
      case 'de':
        lang = EntityExtractorLanguage.german;
        break;
      case 'es':
        lang = EntityExtractorLanguage.spanish;
        break;
      case 'it':
        lang = EntityExtractorLanguage.italian;
        break;
      case 'zh':
        lang = EntityExtractorLanguage.chinese;
        break;
      case 'hi':
        lang = EntityExtractorLanguage.thai;
        break;
      default:
        lang = EntityExtractorLanguage.english;
    }

    final entityExtractor = EntityExtractor(language: lang);
    final annotations = await entityExtractor.annotateText(text);
    await entityExtractor.close();

    return annotations;
  }

  /// --- Dispose all ML resources ---
  void dispose() {
    faceDetector.close();
    imageLabeler.close();
    barcodeScanner.close();
    languageIdentifier.close();
  }
}
