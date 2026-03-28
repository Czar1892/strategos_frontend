import 'dart:math' as math;
import 'package:flutter/material.dart';

class LiveLogoBanner extends StatefulWidget {
  final double height;

  const LiveLogoBanner({
    super.key,
    this.height = 220,
  });

  @override
  State<LiveLogoBanner> createState() => _LiveLogoBannerState();
}

class _LiveLogoBannerState extends State<LiveLogoBanner>
    with TickerProviderStateMixin {
  late final AnimationController _glowController;
  late final AnimationController _sweepController;
  late final AnimationController _floatController;

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _sweepController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _glowController,
        _sweepController,
        _floatController,
      ]),
      builder: (context, child) {
        final glow = 0.45 + (_glowController.value * 0.55);
        final floatY = (_floatController.value - 0.5) * 4;

        return Container(
          width: double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF4FA3).withOpacity(0.10 * glow),
                blurRadius: 36,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: const Color(0xFF8B5CF6).withOpacity(0.05 * glow),
                blurRadius: 60,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Transform.translate(
                  offset: Offset(0, floatY),
                  child: Image.asset(
                    'assets/branding/strategos_logo_full.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFF05060A),
                        alignment: Alignment.center,
                        child: const Text(
                          'Strategos by Czarina',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Container(
                  color: Colors.black.withOpacity(0.28),
                ),

                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.10),
                          Colors.white.withOpacity(0.03),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: -28,
                  left: -28,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFF4FA3).withOpacity(0.035 * glow),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF4FA3).withOpacity(0.14 * glow),
                          blurRadius: 80,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  bottom: -22,
                  right: -18,
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF8B5CF6).withOpacity(0.03 * glow),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withOpacity(0.12 * glow),
                          blurRadius: 70,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),

                Positioned.fill(
                  child: IgnorePointer(
                    child: Transform.translate(
                      offset: Offset(
                        (_sweepController.value * 700) - 350,
                        0,
                      ),
                      child: Transform.rotate(
                        angle: -math.pi / 7,
                        child: Container(
                          width: 95,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.white.withOpacity(0.015),
                                Colors.white.withOpacity(0.08),
                                Colors.white.withOpacity(0.02),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: const Color(0xFFFF4FA3).withOpacity(0.18),
                      width: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}