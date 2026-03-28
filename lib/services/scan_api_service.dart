import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/scan_result_model.dart';

class ScanApiService {
  static const String baseUrl = "http://127.0.0.1:8000";

  static Future<ScanResultModel> scanFileBytes({
    required Uint8List bytes,
    required String filename,
  }) async {
    final uri = Uri.parse('$baseUrl/scan/file');

    final request = http.MultipartRequest('POST', uri);
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
      ),
    );

    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode == 200) {
      final jsonData = json.decode(responseBody) as Map<String, dynamic>;
      return ScanResultModel.fromJson(jsonData);
    } else {
      throw Exception(
        'File scan failed: ${streamedResponse.statusCode} $responseBody',
      );
    }
  }

  static Future<ScanResultModel> scanUrl(String url) async {
    final uri = Uri.parse('$baseUrl/scan/url');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'accept': 'application/json',
      },
      body: json.encode({
        'url': url,
      }),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      return ScanResultModel.fromJson(jsonData);
    } else {
      throw Exception(
        'URL scan failed: ${response.statusCode} ${response.body}',
      );
    }
  }

  static Future<ScanResultModel> scanMessage(String message) async {
    final uri = Uri.parse('$baseUrl/scan/message');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'accept': 'application/json',
      },
      body: json.encode({
        'message': message,
      }),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      return ScanResultModel.fromJson(jsonData);
    } else {
      throw Exception(
        'Message scan failed: ${response.statusCode} ${response.body}',
      );
    }
  }
}