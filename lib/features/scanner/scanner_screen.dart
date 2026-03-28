import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../models/scan_result_model.dart';
import '../../services/scan_api_service.dart';
import '../../shared/live_logo_banner.dart';
import 'result_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  String selectedMode = 'file';

  Uint8List? selectedFileBytes;
  String? selectedFileName;
  bool isScanning = false;
  String? errorMessage;

  final TextEditingController urlController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  @override
  void dispose() {
    urlController.dispose();
    messageController.dispose();
    super.dispose();
  }

  Future<void> pickFile() async {
    setState(() {
      errorMessage = null;
    });

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
      type: FileType.any,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        selectedFileBytes = result.files.single.bytes!;
        selectedFileName = result.files.single.name;
      });
    } else {
      setState(() {
        errorMessage = 'No file was selected.';
      });
    }
  }

  Future<void> scanSelectedInput() async {
    setState(() {
      errorMessage = null;
    });

    try {
      setState(() {
        isScanning = true;
      });

      late final ScanResultModel scanResult;

      if (selectedMode == 'file') {
        if (selectedFileBytes == null || selectedFileName == null) {
          setState(() {
            errorMessage = 'Please upload a file first.';
            isScanning = false;
          });
          return;
        }

        scanResult = await ScanApiService.scanFileBytes(
          bytes: selectedFileBytes!,
          filename: selectedFileName!,
        );
      } else if (selectedMode == 'url') {
        final url = urlController.text.trim();

        if (url.isEmpty) {
          setState(() {
            errorMessage = 'Please enter a URL first.';
            isScanning = false;
          });
          return;
        }

        scanResult = await ScanApiService.scanUrl(url);
      } else {
        final message = messageController.text.trim();

        if (message.isEmpty) {
          setState(() {
            errorMessage = 'Please enter a message first.';
            isScanning = false;
          });
          return;
        }

        scanResult = await ScanApiService.scanMessage(message);
      }

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(result: scanResult),
        ),
      );
    } catch (e) {
      setState(() {
        errorMessage = 'Scan failed. ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          isScanning = false;
        });
      }
    }
  }

  void clearFile() {
    setState(() {
      selectedFileBytes = null;
      selectedFileName = null;
      errorMessage = null;
    });
  }

  String _primaryButtonLabel() {
    switch (selectedMode) {
      case 'url':
        return 'Scan URL';
      case 'message':
        return 'Scan Message';
      default:
        return 'Scan File';
    }
  }

  String _titleText() {
    switch (selectedMode) {
      case 'url':
        return 'Enter a URL and let Strategos evaluate it.';
      case 'message':
        return 'Paste a message and let Strategos evaluate it.';
      default:
        return 'Upload a file and let Strategos evaluate it.';
    }
  }

  String _descriptionText() {
    switch (selectedMode) {
      case 'url':
        return 'URLs are analyzed through your backend and returned with a verdict, score, and signals.';
      case 'message':
        return 'Messages are analyzed through your backend and returned with a verdict, score, and signals.';
      default:
        return 'Files are uploaded to your backend, processed through your detection logic, and returned with a verdict, score, and signals.';
    }
  }

  Widget _buildModeContent() {
    switch (selectedMode) {
      case 'url':
        return _InputGlassBox(
          child: TextField(
            controller: urlController,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter URL here',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.42),
                fontSize: 14.5,
              ),
            ),
          ),
        );

      case 'message':
        return _InputGlassBox(
          child: TextField(
            controller: messageController,
            minLines: 5,
            maxLines: 8,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Paste suspicious message or text here',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.42),
                fontSize: 14.5,
              ),
            ),
          ),
        );

      default:
        return GestureDetector(
          onTap: isScanning ? null : pickFile,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white.withOpacity(0.03),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.upload_file_rounded,
                  size: 42,
                  color: Colors.white.withOpacity(0.86),
                ),
                const SizedBox(height: 12),
                Text(
                  selectedFileName ?? 'Upload file',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  selectedFileName == null
                      ? 'Tap here to upload a file for detection'
                      : 'File ready for scanning',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.62),
                    fontSize: 13.5,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020304),
      appBar: AppBar(
        backgroundColor: const Color(0xFF020304),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Scanner',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              children: [
                const LiveLogoBanner(height: 220),
                const SizedBox(height: 22),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white.withOpacity(0.04),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF4FA3).withOpacity(0.05),
                        blurRadius: 20,
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.30),
                        blurRadius: 24,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'THREAT INTELLIGENCE SCAN',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.55),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.8,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _titleText(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _descriptionText(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.72),
                          fontSize: 14.5,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 22),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isMobile = constraints.maxWidth < 700;

                          if (isMobile) {
                            return Column(
                              children: [
                                _ModeButton(
                                  label: 'URL',
                                  isActive: selectedMode == 'url',
                                  onTap: () {
                                    setState(() {
                                      selectedMode = 'url';
                                      errorMessage = null;
                                    });
                                  },
                                ),
                                const SizedBox(height: 10),
                                _ModeButton(
                                  label: 'MESSAGE',
                                  isActive: selectedMode == 'message',
                                  onTap: () {
                                    setState(() {
                                      selectedMode = 'message';
                                      errorMessage = null;
                                    });
                                  },
                                ),
                                const SizedBox(height: 10),
                                _ModeButton(
                                  label: 'UPLOAD FILE',
                                  isActive: selectedMode == 'file',
                                  onTap: () {
                                    setState(() {
                                      selectedMode = 'file';
                                      errorMessage = null;
                                    });
                                  },
                                ),
                              ],
                            );
                          }

                          return Row(
                            children: [
                              Expanded(
                                child: _ModeButton(
                                  label: 'URL',
                                  isActive: selectedMode == 'url',
                                  onTap: () {
                                    setState(() {
                                      selectedMode = 'url';
                                      errorMessage = null;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _ModeButton(
                                  label: 'MESSAGE',
                                  isActive: selectedMode == 'message',
                                  onTap: () {
                                    setState(() {
                                      selectedMode = 'message';
                                      errorMessage = null;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _ModeButton(
                                  label: 'UPLOAD FILE',
                                  isActive: selectedMode == 'file',
                                  onTap: () {
                                    setState(() {
                                      selectedMode = 'file';
                                      errorMessage = null;
                                    });
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 18),
                      _buildModeContent(),
                      if (selectedMode == 'file' && selectedFileName != null) ...[
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: isScanning ? null : clearFile,
                            child: const Text(
                              'Remove file',
                              style: TextStyle(
                                color: Color(0xFFFF4FA3),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                      if (errorMessage != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: const Color(0xFFFF4FA3).withOpacity(0.10),
                            border: Border.all(
                              color: const Color(0xFFFF4FA3).withOpacity(0.25),
                            ),
                          ),
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isScanning ? null : scanSelectedInput,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xFFFF4FA3),
                            disabledBackgroundColor:
                            Colors.white.withOpacity(0.08),
                            foregroundColor: const Color(0xFF05060A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child: isScanning
                              ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF05060A),
                              ),
                            ),
                          )
                              : Text(
                            _primaryButtonLabel(),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
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
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: isActive
              ? const Color(0xFFFF4FA3)
              : Colors.white.withOpacity(0.06),
          foregroundColor: isActive ? const Color(0xFF05060A) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
            side: BorderSide(
              color: isActive
                  ? const Color(0xFFFF4FA3)
                  : Colors.white.withOpacity(0.10),
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _InputGlassBox extends StatelessWidget {
  final Widget child;

  const _InputGlassBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withOpacity(0.03),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: child,
    );
  }
}