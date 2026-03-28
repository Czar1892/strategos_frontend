import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  PlatformFile? selectedFile;
  String resultText = '';
  bool isLoading = false;

  // 🔥 YOUR LIVE BACKEND
  final String baseUrl = 'https://strategos-backend.onrender.com';

  // 🔥 TEMP GUEST ID (required by backend)
  String guestId = 'guest_${DateTime.now().millisecondsSinceEpoch}';

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        selectedFile = result.files.first;
        resultText = '';
      });
    }
  }

  Future<void> scanFile() async {
    if (selectedFile == null) return;

    setState(() {
      isLoading = true;
      resultText = '';
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/scan/file'),
      );

      // 🔥 IMPORTANT HEADER
      request.headers['X-Guest-Id'] = guestId;

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          selectedFile!.bytes!,
          filename: selectedFile!.name,
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);

        setState(() {
          resultText =
              'Verdict: ${data['verdict']}\nScore: ${data['score']}\nSummary: ${data['summary']}';
        });
      } else {
        setState(() {
          resultText = 'Error: $responseBody';
        });
      }
    } catch (e) {
      setState(() {
        resultText = 'Scan failed: $e';
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020304),
      appBar: AppBar(
        title: const Text('Strategos Scanner'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: pickFile,
              child: const Text('Upload File'),
            ),
            const SizedBox(height: 20),
            if (selectedFile != null)
              Text(
                selectedFile!.name,
                style: const TextStyle(color: Colors.white),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : scanFile,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Scan File'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  resultText,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
