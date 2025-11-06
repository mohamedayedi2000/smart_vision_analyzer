import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ml_kit_service.dart';
import '../services/storage_service.dart';
import '../models/analysis_result.dart';
import '../widgets/result_card.dart';
import '../services/app_localizations.dart';

class ImageAnalysisScreen extends StatefulWidget {
  const ImageAnalysisScreen({super.key});

  @override
  State<ImageAnalysisScreen> createState() => _ImageAnalysisScreenState();
}

class _ImageAnalysisScreenState extends State<ImageAnalysisScreen> {
  final MLKitService _mlKitService = MLKitService();
  final StorageService _storageService = StorageService();
  final ImagePicker _imagePicker = ImagePicker();

  File? _selectedImage;
  List<ImageLabel> _labels = [];
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _labels = [];
      });
    }
  }

  Future<void> _takePhoto() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _labels = [];
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() => _isLoading = true);

    try {
      _labels = await _mlKitService.analyzeImageLabels(_selectedImage!);

      final result = AnalysisResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        type: 'image_labeling',
        data: {
          'labels': _labels.map((label) => {
            'label': label.label ?? 'Unknown',
            'confidence': label.confidence ?? 0.0,
          }).toList(),
        },
        imagePath: _selectedImage!.path,
      );

      await _storageService.saveResult(result);
    } catch (e) {
      final localizations = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${localizations.error}: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.imageLabeling),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
            if (_selectedImage != null) ...[
              Expanded(
                flex: 2,
                child: Image.file(_selectedImage!, fit: BoxFit.cover),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _analyzeImage,
                child: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : Text(localizations.analyze),
              ),
              const SizedBox(height: 20),
              if (_labels.isNotEmpty) ...[
                Text(
                  '${localizations.detectedObjects}:',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Expanded(
                  flex: 3,
                  child: ListView.builder(
                    itemCount: _labels.length,
                    itemBuilder: (context, index) {
                      final label = _labels[index];
                      return ResultCard(
                        title: label.label ?? 'Unknown',
                        confidence: label.confidence ?? 0.0,
                      );
                    },
                  ),
                ),
              ],
            ] else ...[
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.image, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        '${localizations.selectImage} ${localizations.analyze.toLowerCase()}',
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
