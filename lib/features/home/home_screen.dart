import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _glowController;
  late final AnimationController _sweepController;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    )..repeat();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _glowController.dispose();
    _sweepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020304),
      body: Stack(
        children: [
          const _BackgroundLayer(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 920),
                  child: Column(
                    children: [
                      _HomeHeroCard(
                        floatController: _floatController,
                        glowController: _glowController,
                        sweepController: _sweepController,
                      ),
                    ],
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

class _HomeHeroCard extends StatelessWidget {
  final AnimationController floatController;
  final AnimationController glowController;
  final AnimationController sweepController;

  const _HomeHeroCard({
    required this.floatController,
    required this.glowController,
    required this.sweepController,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 700;

        return AnimatedBuilder(
          animation: Listenable.merge([
            floatController,
            glowController,
            sweepController,
          ]),
          builder: (context, child) {
            final double glow = 0.45 + (glowController.value * 0.55);

            return ClipRRect(
              borderRadius: BorderRadius.circular(34),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                    isMobile ? 16 : 26,
                    isMobile ? 16 : 26,
                    isMobile ? 16 : 26,
                    isMobile ? 20 : 28,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(34),
                    color: Colors.white.withOpacity(0.045),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF4FA3).withOpacity(0.07 * glow),
                        blurRadius: 28,
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.34),
                        blurRadius: 28,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _HomeBanner(
                        isMobile: isMobile,
                        glow: glow,
                        sweepValue: sweepController.value,
                        floatValue: floatController.value,
                      ),
                      SizedBox(height: isMobile ? 18 : 22),
                      Text(
                        'STRATEGOS by Czarina',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.58),
                          fontSize: isMobile ? 10.5 : 11.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Strategos is built for environments where decisions matter',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 24 : 36,
                          fontWeight: FontWeight.w800,
                          height: 1.06,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 620),
                        child: Text(
                          'Links, messages, and files are evaluated through behavior, structure, and underlying patterns to Detect Malware, Viruses, and Phishing.Because threats are rarely obvious.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.72),
                            fontSize: isMobile ? 13 : 14.5,
                            height: 1.6,
                          ),
                        ),
                      ),
                      SizedBox(height: isMobile ? 20 : 26),
                      _ActionSection(isMobile: isMobile),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _HomeBanner extends StatelessWidget {
  final bool isMobile;
  final double glow;
  final double sweepValue;
  final double floatValue;

  const _HomeBanner({
    required this.isMobile,
    required this.glow,
    required this.sweepValue,
    required this.floatValue,
  });

  @override
  Widget build(BuildContext context) {
    final double logoFloatY = (floatValue - 0.5) * 4;

    return Container(
      width: double.infinity,
      height: isMobile ? 180 : 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: const Color(0xFF05060A).withOpacity(0.86),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF07080C),
                    Color(0xFF05060A),
                    Color(0xFF090710),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -24,
              left: -20,
              child: Container(
                width: isMobile ? 120 : 160,
                height: isMobile ? 120 : 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF4FA3).withOpacity(0.04 * glow),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF4FA3).withOpacity(0.13 * glow),
                      blurRadius: 90,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: Transform.translate(
                offset: Offset(0, logoFloatY),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 10 : 18,
                    vertical: isMobile ? 12 : 18,
                  ),
                  child: Center(
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: Image.asset(
                        'assets/branding/strategos_logo_full.png',
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                        errorBuilder: (context, error, stackTrace) {
                          return Text(
                            'Strategos by Czarina',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile ? 20 : 26,
                              fontWeight: FontWeight.w700,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // fixed logo fit
            Positioned.fill(
              child: Transform.translate(
                offset: Offset(0, logoFloatY),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 18 : 28,
                    vertical: isMobile ? 20 : 28,
                  ),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: isMobile ? 260 : 460,
                      height: isMobile ? 90 : 140,
                      child: Image.asset(
                        'assets/branding/strategos_logo_full.png',
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                        errorBuilder: (context, error, stackTrace) {
                          return Text(
                            'Strategos by Czarina',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile ? 20 : 26,
                              fontWeight: FontWeight.w700,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.06),
                      Colors.white.withOpacity(0.015),
                      Colors.transparent,
                      Colors.black.withOpacity(0.10),
                    ],
                    stops: const [0.0, 0.12, 0.45, 1.0],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: Transform.translate(
                  offset: Offset((sweepValue * 760) - 380, 0),
                  child: Transform.rotate(
                    angle: -math.pi / 8,
                    child: Container(
                      width: 110,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white.withOpacity(0.01),
                            Colors.white.withOpacity(0.08),
                            Colors.white.withOpacity(0.018),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionSection extends StatelessWidget {
  final bool isMobile;

  const _ActionSection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Column(
        children: [
          _GlassActionButton(
            label: 'Log In',
            filled: false,
            onTap: () {
              Navigator.pushNamed(context, '/login');
            },
          ),
          const SizedBox(height: 12),
          _GlassActionButton(
            label: 'Sign Up',
            filled: true,
            onTap: () {
              Navigator.pushNamed(context, '/signup');
            },
          ),
          const SizedBox(height: 12),
          _GlassOutlineButton(
            label: 'Continue as Guest',
            onTap: () {
              Navigator.pushNamed(context, '/scanner');
            },
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _GlassActionButton(
                label: 'Log In',
                filled: false,
                onTap: () {
                  Navigator.pushNamed(context, '/login');
                },
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _GlassActionButton(
                label: 'Sign Up',
                filled: true,
                onTap: () {
                  Navigator.pushNamed(context, '/signup');
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _GlassOutlineButton(
          label: 'Continue as Guest',
          onTap: () {
            Navigator.pushNamed(context, '/scanner');
          },
        ),
      ],
    );
  }
}

class _GlassActionButton extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _GlassActionButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: filled
              ? const Color(0xFFFF4FA3)
              : Colors.white.withOpacity(0.07),
          foregroundColor: filled ? const Color(0xFF05060A) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
            side: BorderSide(
              color: filled
                  ? const Color(0xFFFF4FA3)
                  : Colors.white.withOpacity(0.10),
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: filled ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _GlassOutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _GlassOutlineButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(
            color: const Color(0xFFFF4FA3).withOpacity(0.22),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          backgroundColor: Colors.white.withOpacity(0.02),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
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
          top: -140,
          left: -180,
          child: IgnorePointer(
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF2D9C).withOpacity(0.05),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF2D9C).withOpacity(0.10),
                    blurRadius: 180,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -120,
          right: -170,
          child: IgnorePointer(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8B5CF6).withOpacity(0.04),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.10),
                    blurRadius: 170,
                    spreadRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -160,
          right: -120,
          child: IgnorePointer(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF4FA3).withOpacity(0.03),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF4FA3).withOpacity(0.08),
                    blurRadius: 150,
                    spreadRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}