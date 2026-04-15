import 'package:flutter/material.dart';
import 'package:one_day/core/theme/app_colors.dart';

/// Maps an icon name string (from the database) to a Flutter IconData.
IconData iconFromName(String name) {
  const iconMap = {
    'wb_sunny': Icons.wb_sunny_rounded,
    'fitness_center': Icons.fitness_center_rounded,
    'eco': Icons.eco_rounded,
    'local_florist': Icons.local_florist_rounded,
    'emoji_events': Icons.emoji_events_rounded,
    'volunteer_activism': Icons.volunteer_activism_rounded,
    'groups': Icons.groups_rounded,
    'public': Icons.public_rounded,
    'energy_savings_leaf': Icons.energy_savings_leaf_rounded,
    'school': Icons.school_rounded,
    'water_drop': Icons.water_drop_rounded,
    'star': Icons.star_rounded,
  };
  return iconMap[name] ?? Icons.star_rounded;
}

/// Parses a hex color string (e.g. "#FF9800" or "FF9800") to a Flutter Color.
Color colorFromHex(String hex) {
  final buffer = StringBuffer();
  if (hex.length == 6 || hex.length == 7) buffer.write('ff');
  buffer.write(hex.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

/// Maps a challenge category name to a display color.
Color categoryColor(String category) {
  switch (category.toUpperCase()) {
    case 'ENVIRONMENT':
    case 'ENVIRONMENTAL':
      return AppColors.primaryGreen;
    case 'ELDERS':
    case 'SOCIAL':
      return AppColors.primaryRed;
    case 'EDUCATION':
    case 'SELF-CARE':
      return AppColors.darkRed;
    case 'CLEANLINESS':
    case 'CIVIC':
      return AppColors.textSecondary;
    case 'FARMING':
      return AppColors.darkGreen;
    case 'WATER':
      return AppColors.primaryGreen;
    default:
      return AppColors.textSecondary;
  }
}

/// Maps a challenge category name to a display icon.
IconData categoryIcon(String category) {
  switch (category.toUpperCase()) {
    case 'ENVIRONMENT':
    case 'ENVIRONMENTAL':
      return Icons.energy_savings_leaf_rounded;
    case 'ELDERS':
    case 'SOCIAL':
      return Icons.volunteer_activism_rounded;
    case 'EDUCATION':
      return Icons.school_rounded;
    case 'CLEANLINESS':
    case 'CIVIC':
      return Icons.cleaning_services_rounded;
    case 'FARMING':
      return Icons.agriculture_rounded;
    case 'WATER':
      return Icons.water_drop_rounded;
    default:
      return Icons.task_alt_rounded;
  }
}

/// Formats a date as a relative time label (TODAY, YESTERDAY, etc.).
String formatTimeLabel(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inDays == 0) return 'TODAY';
  if (diff.inDays == 1) return 'YESTERDAY';
  if (diff.inDays < 7) return '${diff.inDays} DAYS AGO';
  return '${dt.day}/${dt.month}/${dt.year}';
}

/// Formats an integer count with K suffix for thousands and comma separation.
String formatCount(int count) {
  if (count >= 10000) {
    final k = count / 1000;
    return '${k.toStringAsFixed(k % 1 == 0 ? 0 : 1)}K';
  }
  return count.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]},',
  );
}

/// Formats XP value for display (e.g. 12400 → "12.4K", 500 → "500").
String formatXp(int xp) {
  if (xp >= 10000) {
    final k = xp / 1000;
    return '${k.toStringAsFixed(k % 1 == 0 ? 0 : 1)}K';
  }
  return xp.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]},',
  );
}
