import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:one_day/features/profile/domain/entities/achievement.dart';
import 'package:one_day/features/profile/domain/repositories/achievement_repository.dart';

class SupabaseAchievementRepository implements AchievementRepository {
  final SupabaseClient _client;

  SupabaseAchievementRepository({required SupabaseClient client}) : _client = client;

  @override
  Future<List<Achievement>> getAllAchievements() async {
    final response = await _client
        .from('achievements')
        .select()
        .order('title');

    return response.map<Achievement>((json) => _mapToAchievement(json)).toList();
  }

  @override
  Future<List<UserAchievement>> getUserAchievements() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('user_achievements')
        .select('*, achievements(*)')
        .eq('user_id', userId)
        .order('unlocked_at', ascending: false);

    return response.map<UserAchievement>((json) => _mapToUserAchievement(json)).toList();
  }

  @override
  Future<List<UserAchievement>> getAllWithStatus() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    // Get all achievements
    final allAchievements = await getAllAchievements();
    // Get user's unlocked achievements
    final unlocked = await getUserAchievements();

    // Build merged list: unlocked ones have the full UserAchievement, locked ones are placeholders
    return allAchievements.map((ach) {
      final existing = unlocked.where((ua) => ua.achievementId == ach.id).firstOrNull;
      if (existing != null) return existing;
      return UserAchievement(
        id: '',
        userId: userId,
        achievementId: ach.id,
        unlockedAt: DateTime.fromMillisecondsSinceEpoch(0),
        achievement: ach,
      );
    }).toList();
  }

  Achievement _mapToAchievement(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      key: json['key'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      iconName: json['icon_name'] as String,
      colorHex: json['color_hex'] as String,
      bgColorHex: json['bg_color_hex'] as String,
      criteria: json['criteria'] as Map<String, dynamic>,
    );
  }

  UserAchievement _mapToUserAchievement(Map<String, dynamic> json) {
    Achievement? achievement;
    if (json['achievements'] != null) {
      achievement = _mapToAchievement(json['achievements'] as Map<String, dynamic>);
    }
    return UserAchievement(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      achievementId: json['achievement_id'] as String,
      unlockedAt: DateTime.parse(json['unlocked_at'] as String),
      achievement: achievement,
    );
  }
}
