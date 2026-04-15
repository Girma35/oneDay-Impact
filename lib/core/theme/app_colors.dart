import 'package:flutter/material.dart';

/// Unified color palette for OneDay: White, Red, and Green only.
///
/// - **Red**: accent, action, streak, brand
/// - **Green**: positive, verified, eco, nature
/// - **White/grey**: backgrounds, text, dividers
class AppColors {
  // ── White / Grey Shades (Backgrounds & Text) ──────────────────────
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1E2022);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color divider = Color(0xFFE5E7EB);

  // ── Red Shades (Accents, Streaks, Actions) ─────────────────────────
  static const Color primaryRed = Color(0xFFC02A24);
  static const Color darkRed = Color(0xFF991B1B);
  static const Color lightRed = Color(0xFFFEE2E2);
  static const Color paleRed = Color(0xFFFBE8E8);

  // ── Green Shades (Positive, Verified, Eco) ─────────────────────────
  static const Color primaryGreen = Color(0xFF28853D);
  static const Color darkGreen = Color(0xFF166534);
  static const Color lightGreen = Color(0xFFDCFCE7);
  static const Color paleGreen = Color(0xFFF0FDF4);

  // ── Gradients ──────────────────────────────────────────────────────
  static const LinearGradient redGradient = LinearGradient(
    colors: [primaryRed, Color(0xFFFFA07A)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [darkGreen, primaryGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Utility: map any color to red/green palette ─────────────────────
  /// Maps any color to either [primaryRed] or [primaryGreen].
  /// Uses a simple RGB heuristic: reddish → red, greenish → green, else green.
  static Color mapToRedGreen(Color color) {
    final r = (color.r * 255.0).round().clamp(0, 255);
    final g = (color.g * 255.0).round().clamp(0, 255);
    final b = (color.b * 255.0).round().clamp(0, 255);
    if (r > g && r > b) return primaryRed;
    if (g > r && g > b) return primaryGreen;
    return primaryGreen; // default for neutral/cool colors
  }

  // ── Contribution heatmap shades (green intensity) ──────────────────
  static const Color heatmap0 = Color(0xFFE5E7EB); // grey – no activity
  static const Color heatmap1 = Color(0xFFA5D6A7); // light green
  static const Color heatmap2 = Color(0xFF66BB6A); // medium green
  static const Color heatmap3 = Color(0xFF43A047); // dark green
  static const Color heatmap4 = Color(0xFF1B5E20); // darkest green
}
