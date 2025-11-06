import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_entity_extraction/google_mlkit_entity_extraction.dart';
import '../services/ml_kit_service.dart';
import '../services/app_localizations.dart';
import 'translation_screen.dart';

class TextRecognitionScreen extends StatefulWidget {
  const TextRecognitionScreen({super.key});

  @override
  State<TextRecognitionScreen> createState() => _TextRecognitionScreenState();
}

class _TextRecognitionScreenState extends State<TextRecognitionScreen> {
  final MLKitService _mlKitService = MLKitService();
  final ImagePicker _imagePicker = ImagePicker();
  EntityExtractor? _entityExtractor;

  File? _selectedImage;
  String _extractedText = '';
  bool _isLoading = false;
  String? _detectedLanguageCode;
  List<EntityAnnotation> _entities = [];
  bool _isExtractingEntities = false;

  @override
  void initState() {
    super.initState();
    _entityExtractor = EntityExtractor(language: EntityExtractorLanguage.english);
  }

  Future<void> _pickImage() async {
    final localizations = AppLocalizations.of(context);
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _extractedText = '';
          _detectedLanguageCode = null;
          _entities.clear();
        });
      }
    } catch (e) {
      _showError('${localizations.errorPickingImage}: $e');
    }
  }

  Future<void> _takePhoto() async {
    final localizations = AppLocalizations.of(context);
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _extractedText = '';
          _detectedLanguageCode = null;
          _entities.clear();
        });
      }
    } catch (e) {
      _showError('${localizations.errorTakingPhoto}: $e');
    }
  }

  Future<void> _extractText() async {
    if (_selectedImage == null) return;

    setState(() => _isLoading = true);

    try {
      final text = await _mlKitService.extractTextFromImage(_selectedImage!);
      setState(() => _extractedText = text);

      if (_extractedText.isNotEmpty) {
        // Detect language automatically
        final detectedCode = await _mlKitService.identifyLanguage(_extractedText);
        setState(() => _detectedLanguageCode = detectedCode);

        // ✅ Dynamically set the entity extractor language based on detected language
        try {
          _entityExtractor?.close();
          final supportedLangs = {
            'en': EntityExtractorLanguage.english,
            'ar': EntityExtractorLanguage.arabic,
            'fr': EntityExtractorLanguage.french,
            'de': EntityExtractorLanguage.german,
            'es': EntityExtractorLanguage.spanish,
            'it': EntityExtractorLanguage.italian,
            'hi': EntityExtractorLanguage.thai,
            'zh': EntityExtractorLanguage.chinese,
          };

          _entityExtractor = EntityExtractor(
            language: supportedLangs[detectedCode] ?? EntityExtractorLanguage.english,
          );
        } catch (e) {
          debugPrint('EntityExtractor setup failed: $e');
        }

        // ✅ Automatically extract entities after setting correct language
        await _extractEntities();
      }
    } catch (e) {
      final localizations = AppLocalizations.of(context);
      _showError('${localizations.errorExtractingText}: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }


  Future<void> _extractEntities() async {
    if (_extractedText.isEmpty) return;

    setState(() => _isExtractingEntities = true);

    try {
      final annotations = await _entityExtractor!.annotateText(_extractedText);
      setState(() {
        _entities = annotations;
      });
    } catch (e) {
      // Silently fail or show a subtle message
      debugPrint('Entity extraction error: $e');
    } finally {
      setState(() => _isExtractingEntities = false);
    }
  }

  String _getEntityTypeName(EntityType type) {
    switch (type) {
      case EntityType.address:
        return 'Address';
      case EntityType.dateTime:
        return 'Date/Time';
      case EntityType.email:
        return 'Email';
      case EntityType.phone:
        return 'Phone';
      case EntityType.money:
        return 'Money';
      case EntityType.url:
        return 'URL';
      case EntityType.flightNumber:
        return 'Flight';
      case EntityType.paymentCard:
        return 'Card';
      default:
        return 'Other';
    }
  }

  IconData _getEntityIcon(EntityType type) {
    switch (type) {
      case EntityType.address:
        return Icons.location_on;
      case EntityType.dateTime:
        return Icons.calendar_today;
      case EntityType.email:
        return Icons.email;
      case EntityType.phone:
        return Icons.phone;
      case EntityType.money:
        return Icons.attach_money;
      case EntityType.url:
        return Icons.link;
      case EntityType.flightNumber:
        return Icons.flight;
      case EntityType.paymentCard:
        return Icons.credit_card;
      default:
        return Icons.label;
    }
  }

  Color _getEntityColor(EntityType type) {
    switch (type) {
      case EntityType.address:
        return Colors.red;
      case EntityType.dateTime:
        return Colors.blue;
      case EntityType.email:
        return Colors.orange;
      case EntityType.phone:
        return Colors.green;
      case EntityType.money:
        return Colors.purple;
      case EntityType.url:
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _navigateToTranslator() {
    if (_extractedText.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TranslationScreen(
          initialText: _extractedText,
          detectedLanguageCode: _detectedLanguageCode,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mlKitService.dispose();
    _entityExtractor?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.textRecognition),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            /// --- Buttons: Pick or Take Image ---
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: Text(localizations.gallery),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _takePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: Text(localizations.camera),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// --- Image Display or Placeholder ---
            if (_selectedImage != null) ...[
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(_selectedImage!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 20),

              /// --- Extract Text Button ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _extractText,
                  icon: _isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(Icons.document_scanner),
                  label: Text(_isLoading ? 'Extracting...' : localizations.extract),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// --- Extracted Text Section ---
              if (_extractedText.isNotEmpty) ...[
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Extracted Text Header
                        Row(
                          children: [
                            const Icon(Icons.text_fields, size: 20, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(
                              '${localizations.extractedText}:',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Extracted Text Container
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white, // pure white background
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _extractedText,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black, // pure black text
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Detected Language
                        if (_detectedLanguageCode != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                const Icon(Icons.language, size: 18, color: Colors.blue),
                                const SizedBox(width: 6),
                                Text(
                                  '${localizations.detectedLanguage}: $_detectedLanguageCode',
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontSize: 14,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Entities Section
                        if (_entities.isNotEmpty) ...[
                          const Divider(height: 30),
                          Row(
                            children: [
                              const Icon(Icons.label, size: 20, color: Colors.indigo),
                              const SizedBox(width: 8),
                              Text(
                                'Entities Found (${_entities.length}):',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ..._entities.map((entity) {
                            final firstEntity = entity.entities.first;
                            final entityType = firstEntity.type;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              elevation: 1,
                              child: ListTile(
                                dense: true,
                                leading: Icon(
                                  _getEntityIcon(entityType),
                                  color: _getEntityColor(entityType),
                                  size: 24,
                                ),
                                title: Text(
                                  entity.text,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                  ),
                                ),
                                subtitle: Text(
                                  _getEntityTypeName(entityType),
                                  style: TextStyle(
                                    color: _getEntityColor(entityType),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 10),
                        ] else if (_isExtractingEntities)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 12),
                                Text('Extracting entities...'),
                              ],
                            ),
                          ),

                        const SizedBox(height: 10),

                        /// --- Translate Button ---
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _navigateToTranslator,
                            icon: const Icon(Icons.translate),
                            label: Text(localizations.translateBtn),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ] else ...[
              /// --- No Image Selected Placeholder ---
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.image, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        localizations.selectImageToExtractText,
                        style: const TextStyle(fontSize: 18, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}