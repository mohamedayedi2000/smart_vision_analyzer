import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import '../services/ml_kit_service.dart';
import '../services/storage_service.dart';
import '../models/analysis_result.dart';

class TranslationScreen extends StatefulWidget {
  final String? initialText;
  final String? detectedLanguageCode;

  const TranslationScreen({
    super.key,
    this.initialText,
    this.detectedLanguageCode,
  });

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  final StorageService _storageService = StorageService();
  final TextEditingController _textController = TextEditingController();

  OnDeviceTranslator? _translator;
  String _translatedText = '';
  bool _isLoading = false;
  bool _isDownloading = false;
  bool _userChangedTargetLanguage = false; // Track if user manually changed target

  TranslateLanguage _sourceLanguage = TranslateLanguage.english;
  TranslateLanguage _targetLanguage = TranslateLanguage.french;

  final Map<String, TranslateLanguage> _languages = {
    'English': TranslateLanguage.english,
    'French': TranslateLanguage.french,
    'Arabic': TranslateLanguage.arabic,
    'Spanish': TranslateLanguage.spanish,
    'German': TranslateLanguage.german,
    'Italian': TranslateLanguage.italian,
    'Japanese': TranslateLanguage.japanese,
    'Korean': TranslateLanguage.korean,
    'Chinese': TranslateLanguage.chinese,
    'Portuguese': TranslateLanguage.portuguese,
    'Russian': TranslateLanguage.russian,
    'Hindi': TranslateLanguage.hindi,
  };

  @override
  void initState() {
    super.initState();
    if (widget.initialText != null) {
      _textController.text = widget.initialText!;
    }
    if (widget.detectedLanguageCode != null) {
      _updateSourceLanguageFromCode(widget.detectedLanguageCode!);
    }
    _initializeTranslator();
  }

  void _updateSourceLanguageFromCode(String languageCode) {
    final detectedLanguage = _languages.entries
        .firstWhere(
          (entry) => entry.value.bcpCode == languageCode,
      orElse: () => const MapEntry('English', TranslateLanguage.english),
    )
        .value;

    setState(() {
      _sourceLanguage = detectedLanguage;

      // Only auto-set target if user hasn't manually chosen one
      if (!_userChangedTargetLanguage) {
        // Set a sensible default target that's different from source
        if (_sourceLanguage == TranslateLanguage.english) {
          _targetLanguage = TranslateLanguage.french;
        } else {
          _targetLanguage = TranslateLanguage.english;
        }
      }
    });
  }

  void _initializeTranslator() {
    _translator = OnDeviceTranslator(
      sourceLanguage: _sourceLanguage,
      targetLanguage: _targetLanguage,
    );
  }

  Future<void> _detectLanguage() async {
    if (_textController.text.isEmpty) return;

    try {
      final detectedCode =
      await MLKitService().identifyLanguage(_textController.text);

      if (detectedCode != null) {
        final detectedLanguage = _languages.entries
            .firstWhere(
              (entry) => entry.value.bcpCode == detectedCode,
          orElse: () => const MapEntry('English', TranslateLanguage.english),
        )
            .value;

        setState(() {
          _sourceLanguage = detectedLanguage;

          // ✅ FIX: Only change target if user hasn't manually selected one
          // AND if current target is same as detected source
          if (!_userChangedTargetLanguage && _targetLanguage == detectedLanguage) {
            // Set a different language as target
            if (detectedLanguage == TranslateLanguage.english) {
              _targetLanguage = TranslateLanguage.french;
            } else {
              _targetLanguage = TranslateLanguage.english;
            }
          }

          _translator?.close();
          _initializeTranslator();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Detected ${_getLanguageName(_sourceLanguage)} → ${_getLanguageName(_targetLanguage)}',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error detecting language: $e')),
      );
    }
  }

  Future<void> _downloadModel() async {
    setState(() => _isDownloading = true);

    try {
      final modelManager = OnDeviceTranslatorModelManager();

      final isSourceDownloaded =
      await modelManager.isModelDownloaded(_sourceLanguage.bcpCode);
      final isTargetDownloaded =
      await modelManager.isModelDownloaded(_targetLanguage.bcpCode);

      if (!isSourceDownloaded) {
        await modelManager.downloadModel(_sourceLanguage.bcpCode);
      }

      if (!isTargetDownloaded) {
        await modelManager.downloadModel(_targetLanguage.bcpCode);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Language models downloaded successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading models: $e')),
        );
      }
    } finally {
      setState(() => _isDownloading = false);
    }
  }

  Future<void> _translate() async {
    if (_textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter text to translate')),
      );
      return;
    }

    await _detectLanguage();

    setState(() => _isLoading = true);

    try {
      final translatedText =
      await _translator!.translateText(_textController.text);

      setState(() {
        _translatedText = translatedText;
      });

      final result = AnalysisResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        type: 'translation',
        data: {
          'sourceText': _textController.text,
          'translatedText': translatedText,
          'sourceLanguage': _getLanguageName(_sourceLanguage),
          'targetLanguage': _getLanguageName(_targetLanguage),
        },
      );

      await _storageService.saveResult(result);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Error translating: $e\nPlease download language models first.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getLanguageName(TranslateLanguage language) {
    return _languages.entries
        .firstWhere((entry) => entry.value == language)
        .key;
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = temp;

      if (_translatedText.isNotEmpty) {
        final tempText = _textController.text;
        _textController.text = _translatedText;
        _translatedText = tempText;
      }

      // Reset the flag when swapping
      _userChangedTargetLanguage = true;

      _translator?.close();
      _initializeTranslator();
    });
  }

  @override
  void dispose() {
    _translator?.close();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Translation'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _isDownloading ? null : _downloadModel,
            tooltip: 'Download Language Models',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<TranslateLanguage>(
                        value: _sourceLanguage,
                        decoration: const InputDecoration(
                          labelText: 'From',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          isDense: true,
                        ),
                        isExpanded: true,
                        items: _languages.entries.map((entry) {
                          return DropdownMenuItem(
                            value: entry.value,
                            child: Text(
                              entry.key,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _sourceLanguage = value;
                              _translator?.close();
                              _initializeTranslator();
                              _translatedText = '';
                            });
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: IconButton(
                        icon: const Icon(Icons.swap_horiz, color: Colors.teal),
                        onPressed: _swapLanguages,
                        tooltip: 'Swap Languages',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    Expanded(
                      child: DropdownButtonFormField<TranslateLanguage>(
                        value: _targetLanguage,
                        decoration: const InputDecoration(
                          labelText: 'To',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          isDense: true,
                        ),
                        isExpanded: true,
                        items: _languages.entries.map((entry) {
                          return DropdownMenuItem(
                            value: entry.value,
                            child: Text(
                              entry.key,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _targetLanguage = value;
                              _userChangedTargetLanguage = true; // ✅ Mark as manually changed
                              _translator?.close();
                              _initializeTranslator();
                              _translatedText = '';
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enter text (${_getLanguageName(_sourceLanguage)})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: const InputDecoration(
                            hintText: 'Type or paste text here...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading || _isDownloading ? null : _translate,
                icon: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.translate),
                label: Text(_isLoading ? 'Translating...' : 'Translate'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_translatedText.isNotEmpty)
              Expanded(
                child: Card(
                  color: Colors.teal.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Translation (${_getLanguageName(_targetLanguage)})',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 20),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Copied to clipboard'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              tooltip: 'Copy',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              _translatedText,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (_isDownloading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('Downloading language models...'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}