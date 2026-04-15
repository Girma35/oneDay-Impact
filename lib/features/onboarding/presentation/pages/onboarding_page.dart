import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:one_day/core/theme/app_colors.dart';
import 'package:one_day/core/utils/responsive_utils.dart';
import 'package:one_day/features/main_page.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image Placeholder (lake Babogaya or similar)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, AppColors.textPrimary.withValues(alpha: 0.87)],
              ),
            ),
          ),
          SafeArea(
            child: responsiveMaxWidth(
              child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Text(
                    'The Big Idea',
                    style: GoogleFonts.outfit(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppColors.surface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Small daily actions. Massive community impact. Join thousands making a difference.',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      color: AppColors.surface.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const MainPage()),
                      );
                    },
                    child: const Text('Start Your Streak 🔥'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
