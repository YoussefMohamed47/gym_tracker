import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/utils/app_colors.dart';

/// Animated LiftFuel splash: the Lottie logo plays once, the wordmark slides
/// in under it, then the app opens. No fixed wait beyond the animation.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _hold = Duration(milliseconds: 350);
  // Used only if the animation can't load, so the app never gets stuck here.
  static const _fallback = Duration(milliseconds: 1500);

  /// The Lottie frame the native splash image was rendered from
  /// (tool/render_branding.sh, tool/generate_splash_lottie.py NATIVE_FRAME).
  static const _nativeFrame = 35.0;

  /// Logo box size; the native splash image is this size at 4x.
  static const _logoSize = 220.0;

  late final AnimationController _controller = AnimationController(vsync: this);
  bool _opened = false;

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future<void>.delayed(_hold, _openHome);
      }
    });
  }

  void _openHome() {
    if (_opened || !mounted) return;
    _opened = true;
    Navigator.pushReplacementNamed(context, AppRouter.main);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      // The logo sits at the exact centre of the whole screen, like the
      // native splash, so the hand-over has no jump. Text goes below it.
      body: LayoutBuilder(
        builder: (context, box) {
          final centerY = box.maxHeight / 2;
          return Stack(
            children: [
              Positioned(
                left: (box.maxWidth - _logoSize) / 2,
                top: centerY - _logoSize / 2,
                width: _logoSize,
                height: _logoSize,
                child: Lottie.asset(
                  'assets/animations/splash_logo.json',
                  controller: _controller,
                  repeat: false,
                  onLoaded: (composition) {
                    // Continue from the still frame the native splash shows,
                    // so the hand-over doesn't replay the pop-in.
                    _controller
                      ..duration = composition.duration
                      ..forward(
                        from: _nativeFrame / composition.durationFrames,
                      );
                  },
                  errorBuilder: (context, error, stack) {
                    Future<void>.delayed(_fallback, _openHome);
                    return const Icon(
                      Icons.bolt_rounded,
                      size: 96,
                      color: AppColors.gradientStart,
                    );
                  },
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: centerY + _logoSize / 2 + 8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(text: 'Lift'),
                              TextSpan(
                                text: 'Fuel',
                                style: TextStyle(
                                  foreground: Paint()
                                    ..shader =
                                        const LinearGradient(
                                          colors: [
                                            AppColors.gradientStart,
                                            AppColors.completedGreen,
                                          ],
                                        ).createShader(
                                          const Rect.fromLTWH(0, 0, 120, 50),
                                        ),
                                ),
                              ),
                            ],
                          ),
                          style: GoogleFonts.outfit(
                            fontSize: 46,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            letterSpacing: -1.8,
                          ),
                        )
                        .animate(delay: 250.ms)
                        .fadeIn(duration: 380.ms)
                        .slideY(begin: .35, end: 0, curve: Curves.easeOutCubic),
                    const SizedBox(height: 6),
                    Text(
                          'TRAIN  ·  FUEL  ·  REPEAT',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: AppColors.gradientStart,
                            letterSpacing: 2.6,
                          ),
                        )
                        .animate(delay: 450.ms)
                        .fadeIn(duration: 350.ms)
                        .slideY(begin: .5, end: 0, curve: Curves.easeOutCubic),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 22 + bottomInset,
                child: Text(
                  'تمرينك وأكلك في مكان واحد',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ).animate(delay: 650.ms).fadeIn(duration: 400.ms),
              ),
            ],
          );
        },
      ),
    );
  }
}
