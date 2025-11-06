import 'package:flutter/material.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';

import '../services/ml_kit_service.dart';
import '../services/storage_service.dart';
import '../models/analysis_result.dart';

class LanguageIdentificationScreen extends StatefulWidget {
  const LanguageIdentificationScreen({super.key});

  @override
  State<LanguageIdentificationScreen> createState() =>
      _LanguageIdentificationScreenState();
}

class _LanguageIdentificationScreenState
    extends State<LanguageIdentificationScreen> {
  final MLKitService _mlKitService = MLKitService();
  final StorageService _storageService = StorageService();
  final TextEditingController _textController = TextEditingController();

  String? _detectedLanguage;
  List<IdentifiedLanguage> _possibleLanguages = [];
  bool _isLoading = false;

  // Identify language of the entered text
  Future<void> _identifyLanguage() async {
    if (_textController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      // Identify the most probable language
      _detectedLanguage =
      await _mlKitService.identifyLanguage(_textController.text);

      // Get multiple possible languages with confidence
      _possibleLanguages =
      await _mlKitService.identifyPossibleLanguages(_textController.text);

      // Save the result to storage
      final result = AnalysisResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        type: 'language_identification',
        data: {
          'text': _textController.text,
          'detectedLanguage': _detectedLanguage,
          'possibleLanguages': _possibleLanguages
              .map((lang) => {
            'language': lang.languageTag ?? 'Unknown',
            'confidence': lang.confidence ?? 0.0,
          })
              .toList(),
        },
      );

      await _storageService.saveResult(result);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error identifying language: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language Identification'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Text input field
              TextField(
                controller: _textController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Enter text to identify language',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Identify button
              ElevatedButton(
                onPressed: _isLoading ? null : _identifyLanguage,
                child: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Identify Language'),
              ),
              const SizedBox(height: 20),

              // If a language is detected
              if (_detectedLanguage != null) ...[
                const Text(
                  'Detection Results:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // Main detected language card
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.language, color: Colors.red),
                    title: const Text('Detected Language'),
                    subtitle: Text(_detectedLanguage ?? 'Unknown'),
                  ),
                ),
                const SizedBox(height: 10),

                // List of possible languages
                if (_possibleLanguages.isNotEmpty) ...[
                  const Text(
                    'Possible Languages:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true, // ✅ Prevents overflow
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _possibleLanguages.length,
                    itemBuilder: (context, index) {
                      final lang = _possibleLanguages[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.red,
                            child: Text(
                              '${((lang.confidence ?? 0.0) * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ),
                          title: Text(lang.languageTag ?? 'Unknown'),
                          subtitle: LinearProgressIndicator(
                            value: lang.confidence ?? 0.0,
                            backgroundColor: Colors.grey[300],
                            color: Colors.red,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ] else ...[
                const SizedBox(height: 40),
                const Icon(Icons.language, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Enter text to identify language',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
