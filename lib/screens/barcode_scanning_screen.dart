import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

class BarcodeScanningScreen extends StatefulWidget {
  const BarcodeScanningScreen({super.key});

  @override
  State<BarcodeScanningScreen> createState() => _BarcodeScanningScreenState();
}

class _BarcodeScanningScreenState extends State<BarcodeScanningScreen> {
  late CameraController _cameraController;
  late BarcodeScanner _barcodeScanner;
  bool _isInitialized = false;
  bool _isProcessing = false;
  List<Barcode> _barcodes = [];

  @override
  void initState() {
    super.initState();
    _barcodeScanner = BarcodeScanner();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final backCamera = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
    );

    _cameraController = CameraController(
      backCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController.initialize();
    if (!mounted) return;

    setState(() => _isInitialized = true);
  }

  Future<void> _captureAndScan() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final picture = await _cameraController.takePicture();
      final file = File(picture.path);

      final inputImage = InputImage.fromFile(file);
      final barcodes = await _barcodeScanner.processImage(inputImage);

      if (barcodes.isNotEmpty) {
        setState(() => _barcodes = barcodes);
        debugPrint('✅ Detected: ${barcodes.map((b) => b.displayValue).join(", ")}');
      } else {
        debugPrint('ℹ️ No barcode detected');
      }
    } catch (e) {
      debugPrint('❌ Scan failed: $e');
    } finally {
      _isProcessing = false;
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _barcodeScanner.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Barcode Scanner"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CameraPreview(_cameraController),
          Positioned(
            bottom: 20,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text("Scan"),
              onPressed: _captureAndScan,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          if (_barcodes.isNotEmpty) _buildResultBox(),
        ],
      ),
    );
  }

  Widget _buildResultBox() {
    return Positioned(
      bottom: 100,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: _barcodes.map((barcode) {
            return Text(
              barcode.displayValue ?? "Unknown",
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            );
          }).toList(),
        ),
      ),
    );
  }
}
