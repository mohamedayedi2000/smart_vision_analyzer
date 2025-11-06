import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../services/ml_kit_service.dart';
import '../services/app_localizations.dart';

class FaceDetectionScreen extends StatefulWidget {
  const FaceDetectionScreen({super.key});

  @override
  State<FaceDetectionScreen> createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
  final MLKitService _mlKitService = MLKitService();
  final ImagePicker _imagePicker = ImagePicker();

  File? _selectedImage;
  List<Face> _faces = [];
  bool _isLoading = false;

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _faces = [];
        });
      }
    } catch (e) {
      _showError('${AppLocalizations.of(context).error}: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _faces = [];
        });
      }
    } catch (e) {
      _showError('${AppLocalizations.of(context).error}: $e');
    }
  }

  Future<void> _detectFaces() async {
    if (_selectedImage == null) return;

    setState(() => _isLoading = true);

    try {
      final faces = await _mlKitService.detectFaces(_selectedImage!);
      setState(() {
        _faces = faces;
      });
    } catch (e) {
      _showError('${AppLocalizations.of(context).error}: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  void dispose() {
    _mlKitService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.faceDetection),
        backgroundColor: Colors.orange,
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
                child: Stack(
                  children: [
                    Image.file(_selectedImage!, fit: BoxFit.cover),
                    for (final face in _faces) _buildFaceRect(face, localizations),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _detectFaces,
                child: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : Text(localizations.detect),
              ),
              const SizedBox(height: 20),
              if (_faces.isNotEmpty) ...[
                Text(
                  '${localizations.facesDetected}: ${_faces.length}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Expanded(
                  flex: 1,
                  child: ListView.builder(
                    itemCount: _faces.length,
                    itemBuilder: (context, index) {
                      final face = _faces[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange,
                          child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
                        ),
                        title: Text('${localizations.face} ${index + 1}'),
                        subtitle: Text(
                          '${localizations.smiling}: ${_getProbabilityText(face.smilingProbability, localizations)}\n'
                              '${localizations.leftEye}: ${_getProbabilityText(face.leftEyeOpenProbability, localizations)}\n'
                              '${localizations.rightEye}: ${_getProbabilityText(face.rightEyeOpenProbability, localizations)}',
                        ),
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
                      const Icon(Icons.face, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        '${localizations.selectImage} ${localizations.detect.toLowerCase()}',
                        style: const TextStyle(fontSize: 18, color: Colors.grey),
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

  String _getProbabilityText(double? probability, AppLocalizations localizations) {
    if (probability == null) return localizations.disabled; // or Unknown translation if you add
    return probability > 0.5 ? localizations.yes : localizations.no;
  }

  Widget _buildFaceRect(Face face, AppLocalizations localizations) {
    final rect = face.boundingBox;
    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red, width: 2),
        ),
        child: Align(
          alignment: Alignment.topLeft,
          child: Container(
            color: Colors.red,
            padding: const EdgeInsets.all(2),
            child: Text(
              localizations.face,
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ),
      ),
    );
  }
}
