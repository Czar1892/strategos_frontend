import 'package:flutter/material.dart';
import '../../shared/live_logo_banner.dart';
import '../../services/billing_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  final BillingService billingService = BillingService();

  String selectedPlan = 'yearly';
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (selectedPlan == 'free') {
      Navigator.pushNamed(context, '/scanner');
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      await billingService.startZiinaPayment(
        planCode: 'yearly_99_aed',
        test: true,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment error: $e'),
          backgroundColor: const Color(0xFF181A20),
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
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
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 860),
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
                          const LiveLogoBanner(height: 240),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Center(
                                  child: Text(
                                    'Create Account',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 34,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Center(
                                  child: ConstrainedBox(
                                    constraints:
                                    const BoxConstraints(maxWidth: 620),
                                    child: Text(
                                      'Start free for limited protection or choose the paid plan for higher scan volume, deeper analysis, and a proper scan history you can rely on.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.68),
                                        fontSize: 15,
                                        height: 1.6,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),
                                const _SectionLabel('Email'),
                                const SizedBox(height: 8),
                                _Field(
                                  controller: emailController,
                                  hint: 'Enter your email',
                                ),
                                const SizedBox(height: 16),
                                const _SectionLabel('Password'),
                                const SizedBox(height: 8),
                                _Field(
                                  controller: passwordController,
                                  hint: 'Create your password',
                                  obscureText: true,
                                ),
                                const SizedBox(height: 16),
                                const _SectionLabel('Confirm Password'),
                                const SizedBox(height: 8),
                                _Field(
                                  controller: confirmPasswordController,
                                  hint: 'Confirm your password',
                                  obscureText: true,
                                ),
                                const SizedBox(height: 28),
                                const _SectionLabel('Choose Plan'),
                                const SizedBox(height: 14),
                                _PlanCard(
                                  title: 'Free',
                                  subtitle: '5 scans',
                                  details:
                                  'Built for occasional checks when you only need a quick verdict before opening or clicking.',
                                  price: '\$0',
                                  badge: 'Starter',
                                  selected: selectedPlan == 'free',
                                  onTap: () {
                                    setState(() {
                                      selectedPlan = 'free';
                                    });
                                  },
                                ),
                                const SizedBox(height: 14),
                                _PlanCard(
                                  title: 'Yearly',
                                  subtitle: '100 scans per month',
                                  details:
                                  'Built for users who scan often and need more coverage, stronger continuity, and saved records of what was analyzed.',
                                  price: '\$9/mo',
                                  badge: 'Recommended',
                                  selected: selectedPlan == 'yearly',
                                  onTap: () {
                                    setState(() {
                                      selectedPlan = 'yearly';
                                    });
                                  },
                                ),
                                const SizedBox(height: 18),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.03),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.06),
                                    ),
                                  ),
                                  child: Text(
                                    selectedPlan == 'free'
                                        ? 'Free gives you limited scanning for quick protection.'
                                        : 'Yearly gives you more monthly scanning capacity and makes Strategos practical for regular use.',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.74),
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 26),
                                SizedBox(
                                  width: double.infinity,
                                  height: 58,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : _handleContinue,
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor:
                                      const Color(0xFFFF4FA3),
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
                                        strokeWidth: 2.2,
                                        valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                          Color(0xFF05060A),
                                        ),
                                      ),
                                    )
                                        : Text(
                                      selectedPlan == 'free'
                                          ? 'Create Free Account'
                                          : 'Continue with Yearly Plan',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Center(
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/login',
                                      );
                                    },
                                    child: const Text(
                                      'Already have an account? Log In',
                                      style: TextStyle(
                                        color: Color(0xFFFF4FA3),
                                        fontWeight: FontWeight.w700,
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;

  const _Field({
    required this.controller,
    required this.hint,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFFA6AAB8),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.04),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          borderSide: BorderSide(
            color: Color(0xFFFF4FA3),
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String details;
  final String price;
  final String badge;
  final bool selected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.title,
    required this.subtitle,
    required this.details,
    required this.price,
    required this.badge,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = selected ? const Color(0xFFFF4FA3) : Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFFF4FA3).withOpacity(0.10)
              : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected
                ? const Color(0xFFFF4FA3)
                : Colors.white.withOpacity(0.08),
            width: selected ? 1.4 : 1,
          ),
          boxShadow: selected
              ? [
            BoxShadow(
              color: const Color(0xFFFF4FA3).withOpacity(0.18),
              blurRadius: 24,
              spreadRadius: 1,
            ),
          ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4FA3).withOpacity(0.14),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Color(0xFFFF4FA3),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: accent,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.80),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  price,
                  style: TextStyle(
                    color: selected
                        ? const Color(0xFFFF4FA3)
                        : Colors.white.withOpacity(0.78),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              details,
              style: TextStyle(
                color: Colors.white.withOpacity(0.62),
                fontSize: 14,
                height: 1.55,
              ),
            ),
          ],
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