import '../../shared/live_logo_banner.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const StrategosApp());
}

class StrategosApp extends StatelessWidget {
  const StrategosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Strategos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020304),
        primaryColor: const Color(0xFFFF4FA3),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const ScannerScreen(),
    );
  }
}

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  PlatformFile? _selectedFile;
  bool _isLoading = false;
  Map<String, dynamic>? _scanResult;
  String? _errorMessage;

  final String _baseUrl = 'https://strategos-backend.onrender.com';
  late final String _guestId;

  @override
  void initState() {
    super.initState();
    _guestId =
        'guest_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch}';
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {
          _scanResult = null;
          _errorMessage = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _urlController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleScan() async {
    setState(() {
      _isLoading = true;
      _scanResult = null;
      _errorMessage = null;
    });

    try {
      http.Response response;

      if (_tabController.index == 0) {
        final url = _urlController.text.trim();
        if (url.isEmpty) {
          throw Exception('Enter a URL first');
        }

        response = await http.post(
          Uri.parse('$_baseUrl/scan/url'),
          headers: {
            'Content-Type': 'application/json',
            'X-Guest-Id': _guestId,
          },
          body: jsonEncode({'url': url}),
        );
      } else if (_tabController.index == 1) {
        final message = _messageController.text.trim();
        if (message.isEmpty) {
          throw Exception('Enter a message first');
        }

        response = await http.post(
          Uri.parse('$_baseUrl/scan/message'),
          headers: {
            'Content-Type': 'application/json',
            'X-Guest-Id': _guestId,
          },
          body: jsonEncode({'message': message}),
        );
      } else {
        if (_selectedFile == null) {
          throw Exception('Please select a file first');
        }

        if (_selectedFile!.bytes == null) {
          throw Exception('Selected file could not be read');
        }

        final request =
            http.MultipartRequest('POST', Uri.parse('$_baseUrl/scan/file'));
        request.headers['X-Guest-Id'] = _guestId;

        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            _selectedFile!.bytes!,
            filename: _selectedFile!.name,
          ),
        );

        final streamedResponse = await request.send();
        response = await http.Response.fromStream(streamedResponse);
      }

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _scanResult = decoded as Map<String, dynamic>;
        });
      } else {
        setState(() {
          _errorMessage = _extractError(decoded);
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _extractError(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final detail = decoded['detail'];
      if (detail is String && detail.isNotEmpty) {
        return detail;
      }
    }
    return 'Analysis failed';
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFile = result.files.single;
        _scanResult = null;
        _errorMessage = null;
      });
    }
  }

  Color _verdictColor(String verdict) {
    switch (verdict.toLowerCase()) {
      case 'malicious':
        return const Color(0xFFFF4FA3);
      case 'suspicious':
        return const Color(0xFFFF8A4F);
      case 'safe':
        return const Color(0xFF6EE7B7);
      default:
        return Colors.white;
    }
  }

  String _displayConfidence(dynamic confidence) {
    if (confidence == null) return 'STANDARD';
    final text = confidence.toString().toUpperCase();
    if (text.isEmpty) return 'STANDARD';
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.2,
            colors: [
              const Color(0xFFFF4FA3).withOpacity(0.06),
              const Color(0xFF020304),
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 22, 18, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 28),
                      _buildTabInterface(),
                      const SizedBox(height: 22),
                      _buildInputSection(),
                      const SizedBox(height: 24),
                      _buildActionButton(),
                      if (_isLoading) _buildLoadingIndicator(),
                      if (_errorMessage != null) _buildErrorState(),
                      if (_scanResult != null) _buildResultCard(),
                      const SizedBox(height: 34),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF4FA3).withOpacity(0.06),
            blurRadius: 32,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STRATEGOS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              color: const Color(0xFFFF4FA3).withOpacity(0.88),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intelligence Scanner',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w300,
              color: Colors.white.withOpacity(0.94),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Files, links, and suspicious messages evaluated through layered threat analysis.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.52),
              fontSize: 13,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabInterface() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFFFF4FA3).withOpacity(0.18),
          border: Border.all(
            color: const Color(0xFFFF4FA3).withOpacity(0.35),
          ),
        ),
        labelColor: const Color(0xFFFF4FA3),
        unselectedLabelColor: Colors.white.withOpacity(0.42),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        tabs: const [
          Tab(text: 'URL'),
          Tab(text: 'MESSAGE'),
          Tab(text: 'FILE'),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: [
        _buildTextField(
          key: const ValueKey('url'),
          controller: _urlController,
          hint: 'Enter target URL...',
          icon: Icons.link_rounded,
          maxLines: 1,
        ),
        _buildTextField(
          key: const ValueKey('message'),
          controller: _messageController,
          hint: 'Paste suspicious message...',
          icon: Icons.description_outlined,
          maxLines: 6,
        ),
        _buildFileUploadArea(key: const ValueKey('file')),
      ][_tabController.index],
    );
  }

  Widget _buildTextField({
    required Key key,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required int maxLines,
  }) {
    return Container(
      key: key,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.24)),
          prefixIcon: Icon(
            icon,
            color: Colors.white.withOpacity(0.32),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildFileUploadArea({required Key key}) {
    return GestureDetector(
      key: key,
      onTap: _pickFile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              color: const Color(0xFFFF4FA3).withOpacity(0.64),
              size: 34,
            ),
            const SizedBox(height: 14),
            Text(
              _selectedFile == null
                  ? 'Select object for analysis'
                  : _selectedFile!.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.68),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (_selectedFile != null) ...[
              const SizedBox(height: 8),
              Text(
                '${((_selectedFile!.size) / 1024).toStringAsFixed(1)} KB',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.34),
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleScan,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFFF4FA3),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF4FA3).withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.1,
                  ),
                )
              : const Text(
                  'INITIATE ANALYSIS',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.3,
                    color: Color(0xFF020304),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(top: 26),
      child: Center(
        child: Text(
          'CONSULTING THREAT MATRICES...',
          style: TextStyle(
            color: Colors.white.withOpacity(0.28),
            fontSize: 11,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      margin: const EdgeInsets.only(top: 28),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x33FF4FA3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x55FF4FA3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline,
            color: Color(0xFFFF4FA3),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    final res = _scanResult!;
    final verdict = (res['verdict'] ?? 'unknown').toString();
    final score = res['score'] ?? 0;
    final summary = (res['summary'] ?? 'No summary available').toString();
    final confidence = _displayConfidence(res['confidence']);
    final signals = (res['signals'] as List?) ?? const [];
    final engineDetails = (res['engine_details'] as List?) ?? const [];
    final strategic =
        (res['strategic'] ?? res['strategic_note'] ?? '').toString();

    return Container(
      margin: const EdgeInsets.only(top: 34),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0C10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 40,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: const Color(0xFFFF4FA3).withOpacity(0.04),
            blurRadius: 26,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 10,
            spacing: 12,
            children: [
              Text(
                'ANALYSIS REPORT',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.34),
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4FA3).withOpacity(0.10),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: const Color(0xFFFF4FA3).withOpacity(0.22),
                  ),
                ),
                child: Text(
                  '$confidence CONFIDENCE',
                  style: const TextStyle(
                    color: Color(0xFFFF4FA3),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  verdict.toUpperCase(),
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: _verdictColor(verdict),
                    letterSpacing: 1,
                  ),
                ),
              ),
              _buildScoreIndicator(score),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.07),
          ),
          const SizedBox(height: 22),
          Text(
            'EXECUTIVE SUMMARY',
            style: TextStyle(
              color: Colors.white.withOpacity(0.48),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            summary,
            style: TextStyle(
              color: Colors.white.withOpacity(0.84),
              height: 1.6,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 22),
          if (signals.isNotEmpty) ...[
            Text(
              'SIGNALS',
              style: TextStyle(
                color: Colors.white.withOpacity(0.48),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.3,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: signals
                  .map((s) => _buildChip(s.toString()))
                  .toList(),
            ),
            const SizedBox(height: 24),
          ],
          if (engineDetails.isNotEmpty) ...[
            Text(
              'ENGINE DETAILS',
              style: TextStyle(
                color: Colors.white.withOpacity(0.48),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            ...engineDetails.map(
              (e) => _buildEngineCard(
                e is Map<String, dynamic>
                    ? e
                    : Map<String, dynamic>.from(e as Map),
              ),
            ),
            const SizedBox(height: 22),
          ],
          if (strategic.isNotEmpty) _buildStrategicNote(strategic),
        ],
      ),
    );
  }

  Widget _buildScoreIndicator(dynamic score) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          score.toString(),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Color(0xFFFF4FA3),
          ),
        ),
        Text(
          'THREAT SCORE',
          style: TextStyle(
            fontSize: 9,
            color: Colors.white.withOpacity(0.30),
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFF4FA3).withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFFF4FA3).withOpacity(0.18),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFFF4FA3),
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildEngineCard(Map<String, dynamic> engine) {
    final name = (engine['name'] ?? 'Engine').toString();
    final status = (engine['status'] ?? 'unknown').toString();
    final reason = (engine['reason'] ?? '').toString();
    final details = (engine['details'] ?? '').toString();
    final matched = engine['matched'] == true;

    Color statusColor;
    if (status == 'completed' && matched) {
      statusColor = const Color(0xFFFF4FA3);
    } else if (status == 'completed') {
      statusColor = const Color(0xFF6EE7B7);
    } else {
      statusColor = const Color(0xFFFF8A4F);
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.025),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: statusColor.withOpacity(0.22)),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.9,
                  ),
                ),
              ),
            ],
          ),
          if (reason.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              reason,
              style: TextStyle(
                color: Colors.white.withOpacity(0.76),
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ],
          if (details.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              details,
              style: TextStyle(
                color: Colors.white.withOpacity(0.42),
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStrategicNote(String note) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'STRATEGIC DIRECTIVE',
            style: TextStyle(
              color: Color(0xFFFF4FA3),
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            note,
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontSize: 12,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
