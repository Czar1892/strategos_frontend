class EngineDetailModel {
  final String name;
  final String status;
  final bool matched;
  final String? details;

  EngineDetailModel({
    required this.name,
    required this.status,
    required this.matched,
    this.details,
  });

  factory EngineDetailModel.fromJson(Map<String, dynamic> json) {
    return EngineDetailModel(
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      matched: json['matched'] ?? false,
      details: json['details'],
    );
  }
}

class ScanResultModel {
  final bool success;
  final String filename;
  final String scanType;
  final String verdict;
  final int score;
  final String summary;
  final List<String> signals;
  final List<String> engines;
  final List<EngineDetailModel> engineDetails;

  ScanResultModel({
    required this.success,
    required this.filename,
    required this.scanType,
    required this.verdict,
    required this.score,
    required this.summary,
    required this.signals,
    required this.engines,
    required this.engineDetails,
  });

  factory ScanResultModel.fromJson(Map<String, dynamic> json) {
    return ScanResultModel(
      success: json['success'] ?? false,
      filename: json['filename'] ?? '',
      scanType: json['scan_type'] ?? '',
      verdict: json['verdict'] ?? '',
      score: json['score'] ?? 0,
      summary: json['summary'] ?? '',
      signals: List<String>.from(json['signals'] ?? []),
      engines: List<String>.from(json['engines'] ?? []),
      engineDetails: (json['engine_details'] as List? ?? [])
          .map((e) => EngineDetailModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}