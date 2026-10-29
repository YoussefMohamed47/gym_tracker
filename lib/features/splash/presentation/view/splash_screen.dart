import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/router/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _boltController;
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();

    // Lightning bolt pulsing controller
    _boltController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // Glow ring pulsing controller
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _navigateToHome();
  }

  @override
  void dispose() {
    _boltController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRouter.main);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F1A),
      body: Stack(
        children: [
          // Background lightning streaks
          Positioned.fill(
            child: CustomPaint(
              painter: _LightningBackgroundPainter(),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo + glow ring + bolt stack
                AnimatedBuilder(
                  animation: _glowController,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer pulsing glow ring
                        Container(
                          width: 130 + 20 * _glowController.value,
                          height: 130 + 20 * _glowController.value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFFD700).withValues(
                              alpha: 0.04 + 0.06 * _glowController.value,
                            ),
                          ),
                        ),
                        // Inner circle bg
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              colors: [
                                Color(0xFF1A1C2E),
                                Color(0xFF0D0F1A),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD700).withValues(
                                  alpha: 0.2 + 0.3 * _glowController.value,
                                ),
                                blurRadius: 28 + 12 * _glowController.value,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        // Lightning bolt
                        AnimatedBuilder(
                          animation: _boltController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 1.0 + 0.06 * _boltController.value,
                              child: child,
                            );
                          },
                          child: ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFFFFE066), Color(0xFFFFD700), Color(0xFFFFA500)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ).createShader(bounds),
                            child: const Icon(
                              Icons.bolt_rounded,
                              size: 64,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                )
                    .animate()
                    .scale(
                      duration: 700.ms,
                      curve: Curves.easeOutBack,
                      begin: const Offset(0.3, 0.3),
                      end: const Offset(1.0, 1.0),
                    )
                    .shimmer(
                      delay: 900.ms,
                      duration: 1800.ms,
                      color: const Color(0xFFFFD700),
                    ),

                const SizedBox(height: 32),

                // App Name
                Text(
                  'GamerX47',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 450.ms, duration: 700.ms)
                    .slideY(begin: 0.25, end: 0),

                const SizedBox(height: 8),

                // Tagline
                Text(
                  'ADVANCE LIKE LIGHTNING',
                  style: GoogleFonts.montserrat(
                    color: const Color(0xFFFFD700),
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.5,
                  ),
                ).animate().fadeIn(delay: 900.ms, duration: 700.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Draws faint background lightning streak lines for atmosphere.
class _LightningBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // A few subtle diagonal streaks
    final streaks = [
      [Offset(size.width * 0.1, 0), Offset(size.width * 0.25, size.height * 0.35), Offset(size.width * 0.15, size.height * 0.5), Offset(size.width * 0.3, size.height)],
      [Offset(size.width * 0.8, 0), Offset(size.width * 0.65, size.height * 0.3), Offset(size.width * 0.75, size.height * 0.55), Offset(size.width * 0.6, size.height)],
      [Offset(size.width * 0.5, 0), Offset(size.width * 0.55, size.height * 0.2), Offset(size.width * 0.45, size.height * 0.4)],
    ];

    final colors = [
      const Color(0xFFFFD700).withValues(alpha: 0.07),
      const Color(0xFFFFD700).withValues(alpha: 0.05),
      const Color(0xFFFFD700).withValues(alpha: 0.04),
    ];

    for (int i = 0; i < streaks.length; i++) {
      paint.color = colors[i % colors.length];
      final path = Path()..moveTo(streaks[i][0].dx, streaks[i][0].dy);
      for (int j = 1; j < streaks[i].length; j++) {
        path.lineTo(streaks[i][j].dx, streaks[i][j].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_LightningBackgroundPainter oldDelegate) => false;
}
