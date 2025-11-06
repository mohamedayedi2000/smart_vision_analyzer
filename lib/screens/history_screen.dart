import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/analysis_result.dart';
import '../widgets/result_card.dart';
import '../services/app_localizations.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final StorageService _storageService = StorageService();
  List<AnalysisResult> _results = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    setState(() => _isLoading = true);
    final results = await _storageService.getResults();
    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  Future<void> _clearHistory() async {
    final localizations = AppLocalizations.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.clearHistory),
        content: Text(localizations.clearHistoryMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(localizations.clear),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storageService.clearResults();
      setState(() {
        _results = [];
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.historyCleared)),
        );
      }
    }
  }

  String _getAnalysisType(String type, AppLocalizations localizations) {
    switch (type) {
      case 'text_recognition':
        return localizations.textRecognition;
      case 'face_detection':
        return localizations.faceDetection;
      case 'image_labeling':
        return localizations.imageLabeling;
      case 'barcode_scanning':
        return localizations.barcodeScan;
      case 'language_identification':
        return localizations.languageId;
      default:
        return 'Analysis';
    }
  }

  IconData _getAnalysisIcon(String type) {
    switch (type) {
      case 'text_recognition':
        return Icons.text_fields;
      case 'face_detection':
        return Icons.face;
      case 'image_labeling':
        return Icons.label;
      case 'barcode_scanning':
        return Icons.qr_code;
      case 'language_identification':
        return Icons.language;
      default:
        return Icons.analytics;
    }
  }

  Color _getAnalysisColor(String type) {
    switch (type) {
      case 'text_recognition':
        return Colors.green;
      case 'face_detection':
        return Colors.orange;
      case 'image_labeling':
        return Colors.blue;
      case 'barcode_scanning':
        return Colors.purple;
      case 'language_identification':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.analysisHistory),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          if (_results.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _clearHistory,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              localizations.noHistory,
              style:
              const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _results.length,
        itemBuilder: (context, index) {
          final result = _results.reversed.toList()[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getAnalysisColor(result.type),
                child: Icon(
                  _getAnalysisIcon(result.type),
                  color: Colors.white,
                ),
              ),
              title: Text(
                  _getAnalysisType(result.type, localizations)),
              subtitle: Text(
                '${result.timestamp.day}/${result.timestamp.month}/${result.timestamp.year} '
                    '${result.timestamp.hour}:${result.timestamp.minute.toString().padLeft(2, '0')}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showResultDetails(result, localizations);
              },
            ),
          );
        },
      ),
    );
  }

  void _showResultDetails(
      AnalysisResult result, AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getAnalysisType(result.type, localizations)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Date: ${result.timestamp.toString()}'),
              const SizedBox(height: 16),
              if (result.data.containsKey('labels'))
                ..._buildLabelResults(result.data['labels'], localizations),
              if (result.data.containsKey('text'))
                _buildTextResult(result.data['text'], localizations),
              if (result.data.containsKey('faces'))
                _buildFaceResults(result.data['faces'], localizations),
              if (result.data.containsKey('barcodes'))
                _buildBarcodeResults(result.data['barcodes'], localizations),
              if (result.data.containsKey('detectedLanguage'))
                _buildLanguageResults(result.data, localizations),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLabelResults(
      List<dynamic> labels, AppLocalizations localizations) {
    return [
      Text(
        '${localizations.detectedObjects}:',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      ...labels.map((label) => ResultCard(
        title: label['label'],
        confidence: label['confidence'],
      )),
    ];
  }

  Widget _buildTextResult(String text, AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${localizations.extractedText}:',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text.isEmpty ? localizations.noHistory : text,
          ),
        ),
      ],
    );
  }

  Widget _buildFaceResults(List<dynamic> faces, AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${localizations.facesDetected}: ${faces.length}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...faces.asMap().entries.map((entry) => ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.orange,
            child: Text(
              '${entry.key + 1}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text('${localizations.face} ${entry.key + 1}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (entry.value['smilingProbability'] != null)
                Text(
                    '${localizations.smiling}: ${entry.value['smilingProbability'] > 0.5 ? localizations.yes : localizations.no}'),
              if (entry.value['leftEyeOpenProbability'] != null)
                Text(
                    '${localizations.leftEye}: ${entry.value['leftEyeOpenProbability'] > 0.5 ? localizations.open : localizations.closed}'),
              if (entry.value['rightEyeOpenProbability'] != null)
                Text(
                    '${localizations.rightEye}: ${entry.value['rightEyeOpenProbability'] > 0.5 ? localizations.open : localizations.closed}'),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildBarcodeResults(
      List<dynamic> barcodes, AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${localizations.barcodesFound}: ${barcodes.length}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...barcodes.map((barcode) => ListTile(
          leading: const Icon(Icons.qr_code, color: Colors.purple),
          title: Text(barcode['value']),
          subtitle: Text('Format: ${barcode['format']}'),
        )),
      ],
    );
  }

  Widget _buildLanguageResults(
      Map<String, dynamic> data, AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${localizations.detectedLanguage}: ${data['detectedLanguage'] ?? 'Unknown'}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        if (data.containsKey('possibleLanguages'))
          ..._buildPossibleLanguages(data['possibleLanguages'], localizations),
      ],
    );
  }

  List<Widget> _buildPossibleLanguages(
      List<dynamic> languages, AppLocalizations localizations) {
    return [
      const SizedBox(height: 8),
      Text(
        '${localizations.possibleLanguages}:',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      ...languages.map((lang) => ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.red,
          child: Text(
            '${(lang['confidence'] * 100).toStringAsFixed(0)}%',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        title: Text(lang['language']),
        subtitle: LinearProgressIndicator(
          value: lang['confidence'],
          backgroundColor: Colors.grey[300],
          color: Colors.red,
        ),
      )),
    ];
  }
}
