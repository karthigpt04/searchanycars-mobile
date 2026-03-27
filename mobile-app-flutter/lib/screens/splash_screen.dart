import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) context.go('/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [AppColors.gold, AppColors.goldDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'SA',
                  style: GoogleFonts.dmSans(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.bg,
                  ),
                ),
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1, 1),
                  delay: 300.ms,
                  duration: 800.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(delay: 300.ms, duration: 800.ms),

            const SizedBox(height: 24),

            // Brand name
            RichText(
              text: TextSpan(
                style: GoogleFonts.dmSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
                children: const [
                  TextSpan(
                    text: 'SEARCH',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  TextSpan(
                    text: 'ANY',
                    style: TextStyle(color: AppColors.gold),
                  ),
                  TextSpan(
                    text: 'CARS',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(
                  delay: 1200.ms,
                  duration: 600.ms,
                  curve: Curves.easeOut,
                )
                .slideY(
                  begin: 0.3,
                  end: 0,
                  delay: 1200.ms,
                  duration: 600.ms,
                ),

            const SizedBox(height: 12),

            // Tagline
            Text(
              'INDIA\'S TRUSTED PLATFORM',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                letterSpacing: 4,
              ),
            ).animate().fadeIn(delay: 1500.ms, duration: 600.ms),

            const SizedBox(height: 32),

            // Loading line
            Container(
              height: 2,
              width: 60,
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(1),
              ),
            ).animate().scaleX(
                  begin: 0,
                  end: 1,
                  delay: 2000.ms,
                  duration: 800.ms,
                  curve: Curves.easeOut,
                ),
          ],
        ),
      ),
    );
  }
}
