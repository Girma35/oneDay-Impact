import 'package:equatable/equatable.dart';

class Achievement extends Equatable {
  final String id;
  final String key;
  final String title;
  final String description;
  final String iconName;
  final String colorHex;
  final String bgColorHex;
  final Map<String, dynamic> criteria;

  const Achievement({
    required this.id,
    required this.key,
    required this.title,
    required this.description,
    required this.iconName,
    required this.colorHex,
    required this.bgColorHex,
    required this.criteria,
  });

  @override
  List<Object?> get props => [id, key, title, description, iconName, colorHex, bgColorHex, criteria];
}

class UserAchievement extends Equatable {
  final String id;
  final String userId;
  final String achievementId;
  final DateTime unlockedAt;

  /// Joined data from the achievement record
  final Achievement? achievement;

  const UserAchievement({
    required this.id,
    required this.userId,
    required this.achievementId,
    required this.unlockedAt,
    this.achievement,
  });

  @override
  List<Object?> get props => [id, userId, achievementId, unlockedAt, achievement];
}
