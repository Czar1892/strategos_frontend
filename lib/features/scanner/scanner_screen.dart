import 'dart:convert';
import '../../shared/live_logo_banner.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  static const String baseUrl = 'https://strategos-backend.onrender.com';

  int selectedTab = 2; // 0 = URL, 1 = MESSAGE, 2 = FILE

  final TextEditingController urlController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  PlatformFile? selectedFile;

  bool isLoading = false;
  String resultTitle = '';
  String resultBody = '';
  String errorText = '';

  final String guestId =
      'guest_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch}';

  @override
  void dispose() {
    urlController.dispose();
    messageController.dispose();
    super.dispose();
  }

  Map<String, String> _jsonHeaders() {
    return {
      'Content-Type': 'application/json',
      'X-Guest-Id': guestId,
    };
  }

  Future<void> _pickFile() async {
    setState(() {
      errorText = '';
      resultTitle = '';
      resultBody = '';
    });

    final result = await FilePicker.platform.pickFiles(withData: true);

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        selectedFile = result.files.first;
      });
    }
  }

  void _removeFile() {
    setState(() {
      selectedFile = null;
      errorText = '';
      resultTitle = '';
      resultBody = '';
    });
  }

  Future<void> _scanUrl() async {
    final value = urlController.text.trim();
    if (value.isEmpty) {
      setState(() {
        errorText = 'Please enter a URL first.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorText = '';
      resultTitle = '';
      resultBody = '';
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/scan/url'),
        headers: _jsonHeaders(),
        body: jsonEncode({
          'url': value,
        }),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          resultTitle = 'URL Scan Result';
          resultBody = _formatScanResult(body);
        });
      } else {
        setState(() {
          errorText = _extractError(body, fallback: 'URL scan failed.');
        });
      }
    } catch (e) {
      setState(() {
        errorText = 'Scan failed: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _scanMessage() async {
    final value = messageController.text.trim();
    if (value.isEmpty) {
      setState(() {
        errorText = 'Please enter a suspicious message first.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorText = '';
      resultTitle = '';
      resultBody = '';
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/scan/message'),
        headers: _jsonHeaders(),
        body: jsonEncode({
          'message': value,
        }),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          resultTitle = 'Message Scan Result';
          resultBody = _formatScanResult(body);
        });
      } else {
        setState(() {
          errorText = _extractError(body, fallback: 'Message scan failed.');
        });
      }
    } catch (e) {
      setState(() {
        errorText = 'Scan failed: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _scanFile() async {
    if (selectedFile == null) {
      setState(() {
        errorText = 'Please upload a file first.';
      });
      return;
    }

    if (selectedFile!.bytes == null) {
      setState(() {
        errorText = 'Selected file has no readable bytes.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorText = '';
      resultTitle = '';
      resultBody = '';
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/scan/file'),
      );

      request.headers['X-Guest-Id'] = guestId;

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          selectedFile!.bytes!,
          filename: selectedFile!.name,
        ),
      );

      final streamed = await request.send();
      final responseBody = await streamed.stream.bytesToString();

      Map<String, dynamic> body;
      try {
        body = jsonDecode(responseBody) as Map<String, dynamic>;
      } catch (_) {
        body = {'detail': responseBody};
      }

      if (streamed.statusCode == 200) {
        setState(() {
          resultTitle = 'File Scan Result';
          resultBody = _formatScanResult(body);
        });
      } else {
        setState(() {
          errorText = _extractError(body, fallback: 'File scan failed.');
        });
      }
    } catch (e) {
      setState(() {
        errorText = 'Scan failed: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _extractError(Map<String, dynamic> body, {required String fallback}) {
    final detail = body['detail'];
    if (detail is String && detail.isNotEmpty) return detail;
    return fallback;
  }

  String _formatScanResult(Map<String, dynamic> body) {
    final verdict = body['verdict']?.toString() ?? 'unknown';
    final score = body['score']?.toString() ?? '-';
    final summary = body['summary']?.toString() ?? '';
    final scanType = body['scan_type']?.toString() ?? '';
    final filename = body['filename']?.toString() ?? '';

    final signals = body['signals'];
    final engines = body['engines'];
    final strategic = body['strategic'];

    final buffer = StringBuffer();
    buffer.writeln('Verdict: $verdict');
    buffer.writeln('Score: $score');

    if (scanType.isNotEmpty) {
      buffer.writeln('Type: $scanType');
    }
    if (filename.isNotEmpty) {
      buffer.writeln('Target: $filename');
    }
    if (summary.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln(summary);
    }

    if (signals is List && signals.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('Signals:');
      for (final item in signals) {
        buffer.writeln('- $item');
      }
    }

    if (engines is Map && engines.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('Engines:');
      engines.forEach((key, value) {
        buffer.writeln('- $key: $value');
      });
    }

    if (strategic is Map && strategic.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('Strategic:');
      strategic.forEach((key, value) {
        buffer.writeln('- $key: $value');
      });
    }

    return buffer.toString().trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020304),
      appBar: AppBar(
        backgroundColor: const Color(0xFF020304),
        elevation: 0,
        title: const Text(
          'Strategos Scanner',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF05060A),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'THREAT INTELLIGENCE SCAN',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.72),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Upload a file and let Strategos evaluate it.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Files are uploaded to your backend, processed through your detection logic, and returned with a verdict, score, and signals.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.68),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _tabButton(
                          label: 'URL',
                          index: 0,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _tabButton(
                          label: 'MESSAGE',
                          index: 1,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _tabButton(
                          label: 'UPLOAD FILE',
                          index: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (selectedTab == 0) _buildUrlPanel(),
                  if (selectedTab == 1) _buildMessagePanel(),
                  if (selectedTab == 2) _buildFilePanel(),
                  const SizedBox(height: 18),
                  if (errorText.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2B0E17),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0x66FF4FA3),
                        ),
                      ),
                      child: Text(
                        errorText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  if (errorText.isNotEmpty) const SizedBox(height: 18),
                  if (resultBody.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.06),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            resultTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SelectableText(
                            resultBody,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.82),
                              fontSize: 14,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabButton({required String label, required int index}) {
    final selected = selectedTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
          errorText = '';
          resultTitle = '';
          resultBody = '';
        });
      },
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFFF4FA3)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? const Color(0xFFFF4FA3)
                : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? const Color(0xFF05060A) : Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUrlPanel() {
    return Column(
      children: [
        TextField(
          controller: urlController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Paste URL here',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.03),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.06),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.06),
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(18)),
              borderSide: BorderSide(
                color: Color(0xFFFF4FA3),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            onPressed: isLoading ? null : _scanUrl,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4FA3),
              foregroundColor: const Color(0xFF05060A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF05060A),
                      ),
                    ),
                  )
                : const Text(
                    'Scan URL',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessagePanel() {
    return Column(
      children: [
        TextField(
          controller: messageController,
          maxLines: 8,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Paste suspicious message here',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.03),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.06),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.06),
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(18)),
              borderSide: BorderSide(
                color: Color(0xFFFF4FA3),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            onPressed: isLoading ? null : _scanMessage,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4FA3),
              foregroundColor: const Color(0xFF05060A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF05060A),
                      ),
                    ),
                  )
                : const Text(
                    'Scan Message',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilePanel() {
    return Column(
      children: [
        GestureDetector(
          onTap: isLoading ? null : _pickFile,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 220),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.06),
              ),
            ),
            child: selectedFile == null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.upload_file,
                          color: Colors.white,
                          size: 46,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Choose a file to scan',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.82),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.insert_drive_file,
                          color: Colors.white,
                          size: 46,
                        ),
                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            selectedFile!.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'File ready for scanning',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.72),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            const Spacer(),
            TextButton(
              onPressed: isLoading ? null : _removeFile,
              child: const Text(
                'Remove file',
                style: TextStyle(
                  color: Color(0xFFFF4FA3),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            onPressed: isLoading ? null : _scanFile,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4FA3),
              foregroundColor: const Color(0xFF05060A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF05060A),
                      ),
                    ),
                  )
                : const Text(
                    'Scan File',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
          ),
        ),
      ],
    );
  }
}
