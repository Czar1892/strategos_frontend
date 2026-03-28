import 'package:flutter/material.dart';
import '../../shared/live_logo_banner.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = [
      {
        'name': 'support@google.com',
        'type': 'Email',
        'verdict': 'Suspicious',
        'time': '2 min ago'
      },
      {
        'name': 'invoice_file.pdf',
        'type': 'File',
        'verdict': 'Malicious',
        'time': '10 min ago'
      },
      {
        'name': 'https://bank-secure-login.net',
        'type': 'Link',
        'verdict': 'Phishing',
        'time': '25 min ago'
      },
      {
        'name': 'client_message.txt',
        'type': 'Text',
        'verdict': 'Safe',
        'time': '1 hr ago'
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF020304),
      body: Stack(
        children: [
          const _BackgroundLayer(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF05060A).withOpacity(0.94),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF4FA3).withOpacity(0.08),
                          blurRadius: 26,
                          spreadRadius: 1,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 30,
                          offset: const Offset(0, 18),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const LiveLogoBanner(height: 220),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => Navigator.pop(context),
                                      icon: const Icon(Icons.arrow_back),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Scan History',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Every file, link, and message scanned through Strategos appears here as a structured record.',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.68),
                                    fontSize: 15,
                                    height: 1.6,
                                  ),
                                ),
                                const SizedBox(height: 22),
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: history.length,
                                  separatorBuilder: (_, __) =>
                                  const SizedBox(height: 14),
                                  itemBuilder: (context, index) {
                                    final item = history[index];
                                    return _HistoryCard(
                                      name: item['name'] as String,
                                      type: item['type'] as String,
                                      verdict: item['verdict'] as String,
                                      time: item['time'] as String,
                                    );
                                  },
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
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String name;
  final String type;
  final String verdict;
  final String time;

  const _HistoryCard({
    required this.name,
    required this.type,
    required this.verdict,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.security),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$type • $time',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          _VerdictBadge(verdict: verdict),
        ],
      ),
    );
  }
}

class _VerdictBadge extends StatelessWidget {
  final String verdict;

  const _VerdictBadge({required this.verdict});

  @override
  Widget build(BuildContext context) {
    Color color;

    switch (verdict) {
      case 'Safe':
        color = Colors.greenAccent;
        break;
      case 'Malicious':
        color = Colors.redAccent;
        break;
      case 'Phishing':
        color = Colors.orangeAccent;
        break;
      default:
        color = const Color(0xFFFF4FA3);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        verdict,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _BackgroundLayer extends StatelessWidget {
  const _BackgroundLayer();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: const Color(0xFF020304)),
        Positioned(
          top: -160,
          left: -180,
          child: _glow(
            size: 340,
            color: const Color(0xFFFF2D9C).withOpacity(0.05),
          ),
        ),
        Positioned(
          bottom: -170,
          right: -180,
          child: _glow(
            size: 320,
            color: const Color(0xFFB54DFF).withOpacity(0.04),
          ),
        ),
      ],
    );
  }

  Widget _glow({
    required double size,
    required Color color,
  }) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: 180,
              spreadRadius: 12,
            ),
          ],
        ),
      ),
    );
  }
}