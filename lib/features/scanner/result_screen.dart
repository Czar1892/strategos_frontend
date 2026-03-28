import 'package:flutter/material.dart';
import '../../models/scan_result_model.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.result,
  });

  final ScanResultModel result;

  @override
  Widget build(BuildContext context) {
    final Color verdictColor = _getVerdictColor(result.verdict);

    return Scaffold(
      backgroundColor: const Color(0xFF020304),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Scan Result'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RiskCard(result: result, color: verdictColor),
                const SizedBox(height: 18),
                _ScanDetailsCard(result: result),
                const SizedBox(height: 18),
                _EngineResultsCard(engineDetails: result.engineDetails),
                const SizedBox(height: 18),
                _GuidanceCard(result: result),
                const SizedBox(height: 18),
                _SignalsCard(signals: result.signals),
                const SizedBox(height: 24),
                _ActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getVerdictColor(String verdict) {
    switch (verdict.toLowerCase()) {
      case 'malicious':
        return const Color(0xFFFF4FA3);
      case 'suspicious':
        return const Color(0xFFFFA94D);
      default:
        return const Color(0xFF52FFA8);
    }
  }
}

class _RiskCard extends StatelessWidget {
  const _RiskCard({
    required this.result,
    required this.color,
  });

  final ScanResultModel result;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _glass(),
      child: Column(
        children: [
          Text(
            '${result.score}',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'RISK SCORE',
            style: TextStyle(
              color: Colors.white70,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            result.verdict.toUpperCase(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            result.summary,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanDetailsCard extends StatelessWidget {
  const _ScanDetailsCard({required this.result});

  final ScanResultModel result;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _glass(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title('SCAN DETAILS'),
          const SizedBox(height: 16),
          _row('Target', result.filename),
          _row('Type', result.scanType),
          _row('Verdict', result.verdict),
          _row('Score', '${result.score} / 100'),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EngineResultsCard extends StatelessWidget {
  const _EngineResultsCard({required this.engineDetails});

  final List<EngineDetailModel> engineDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _glass(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title('ENGINES USED'),
          const SizedBox(height: 18),
          ...engineDetails.map((engine) {
            final bool matched = engine.matched;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.white.withOpacity(0.03),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    engine.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Status: ${engine.status}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Matched: ${matched ? "YES" : "NO"}',
                    style: TextStyle(
                      color: matched
                          ? const Color(0xFFFF4FA3)
                          : const Color(0xFF52FFA8),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (engine.details != null &&
                      engine.details!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      engine.details!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _GuidanceCard extends StatelessWidget {
  const _GuidanceCard({required this.result});

  final ScanResultModel result;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _glass(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title('GUIDANCE'),
          const SizedBox(height: 12),
          Text(
            result.summary,
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignalsCard extends StatelessWidget {
  const _SignalsCard({required this.signals});

  final List<String> signals;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _glass(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title('SIGNALS'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: signals.map((s) {
              return Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: Colors.white.withOpacity(0.05),
                ),
                child: Text(
                  s,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            backgroundColor: const Color(0xFFFF4FA3),
          ),
          child: const Text('Scan Again'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
          ),
          child: const Text('View History'),
        ),
      ],
    );
  }
}

BoxDecoration _glass() {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(26),
    color: Colors.white.withOpacity(0.04),
    border: Border.all(
      color: Colors.white.withOpacity(0.08),
    ),
  );
}

Widget _title(String text) {
  return Text(
    text,
    style: TextStyle(
      color: const Color(0xFFFF4FA3).withOpacity(0.9),
      fontWeight: FontWeight.w800,
      letterSpacing: 1.5,
    ),
  );
}