import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/app_colors.dart';

/// Branded splash, without changing the existing startup route or timing.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _openHome();
  }

  Future<void> _openHome() async {
    await Future<void>.delayed(const Duration(seconds: 3));
    if (mounted) Navigator.pushReplacementNamed(context, AppRouter.main);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(child: Padding(padding: const EdgeInsets.all(30), child: Stack(children: [
        Positioned(top: 12, left: 0,
          child: Text('G/X  /  47', style: GoogleFonts.outfit(color: AppColors.textSecondary,
            fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 3.1))),
        Align(alignment: Alignment.centerLeft, child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 74, height: 74,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AppColors.gradientStart,
                borderRadius: BorderRadius.circular(19)),
              child: const Icon(Icons.bolt_rounded, size: 45, color: AppColors.darkBackground)),
            const SizedBox(height: 40),
            Text('GamerX47', style: GoogleFonts.outfit(fontSize: 54, fontWeight: FontWeight.w900,
              color: AppColors.textPrimary, letterSpacing: -2.3)),
            const SizedBox(height: 6),
            Text('ADVANCE LIKE LIGHTNING',
              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900,
                color: AppColors.gradientStart, letterSpacing: 2.3)),
            const SizedBox(height: 46),
            Container(height: 2, width: 210, color: AppColors.gradientStart),
          ],
        )),
        Positioned(bottom: 18, right: 0, child: Text('TRAIN  /  TRACK  /  REPEAT',
          style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textSecondary, letterSpacing: 1.3))),
      ]))),
    );
  }
}
