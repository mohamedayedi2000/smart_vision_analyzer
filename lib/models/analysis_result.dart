class AnalysisResult {
  final String id;
  final DateTime timestamp;
  final String type;
  final Map<String, dynamic> data;
  final String? imagePath;

  AnalysisResult({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.data,
    this.imagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'data': data,
      'imagePath': imagePath,
    };
  }

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'],
      data: json['data'],
      imagePath: json['imagePath'],
    );
  }
}