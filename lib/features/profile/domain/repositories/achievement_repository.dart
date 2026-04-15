import 'package:one_day/features/profile/domain/entities/achievement.dart';

abstract class AchievementRepository {
  /// Get all achievement definitions
  Future<List<Achievement>> getAllAchievements();

  /// Get the current user's unlocked achievements (with joined achievement data)
  Future<List<UserAchievement>> getUserAchievements();

  /// Get all achievements with unlocked status for current user
  Future<List<UserAchievement>> getAllWithStatus();
}
