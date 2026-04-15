import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String username;
  final String fullName;
  final String? avatarUrl;
  final int level;
  final int totalXp;
  final int streak;
  final int bestStreak;
  final String rankTitle;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.username,
    required this.fullName,
    this.avatarUrl,
    required this.level,
    required this.totalXp,
    required this.streak,
    required this.bestStreak,
    required this.rankTitle,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Helper: format total XP for display (e.g. 12400 → "12.4K")
  String get displayXp {
    if (totalXp >= 10000) {
      final k = totalXp / 1000;
      return '${k.toStringAsFixed(k % 1 == 0 ? 0 : 1)}K';
    }
    return totalXp.toString();
  }

  /// Helper: formatted rank title for display
  String get displayRankTitle => rankTitle.replaceAll('-', ' ').toUpperCase();

  @override
  List<Object?> get props => [id, username, fullName, avatarUrl, level, totalXp, streak, bestStreak, rankTitle, createdAt, updatedAt];
}
