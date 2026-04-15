import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:one_day/features/profile/domain/entities/user_profile.dart';
import 'package:one_day/features/profile/domain/repositories/profile_repository.dart';

class SupabaseProfileRepository implements ProfileRepository {
  final SupabaseClient _client;

  SupabaseProfileRepository({required SupabaseClient client}) : _client = client;

  @override
  Future<UserProfile?> getCurrentUserProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return _mapToProfile(response);
  }

  @override
  Future<UserProfile?> getProfileById(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return _mapToProfile(response);
  }

  @override
  Future<void> updateProfile({
    String? fullName,
    String? avatarUrl,
    String? username,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final updates = <String, dynamic>{};
    if (fullName != null) updates['full_name'] = fullName;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    if (username != null) updates['username'] = username;

    if (updates.isNotEmpty) {
      await _client.from('profiles').update(updates).eq('id', userId);
    }
  }

  @override
  Future<int> getGlobalRank() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return 50;

    final response = await _client.rpc('get_global_rank', params: {
      'p_user_id': userId,
    });

    return (response as int?) ?? 50;
  }

  @override
  Future<int> getVerifiedCount() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return 0;

    final response = await _client
        .from('completed_challenges')
        .select('id')
        .eq('user_id', userId);

    return response.length;
  }

  UserProfile _mapToProfile(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      username: json['username'] as String,
      fullName: json['full_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      level: json['level'] as int,
      totalXp: json['total_xp'] as int,
      streak: json['streak'] as int,
      bestStreak: json['best_streak'] as int,
      rankTitle: json['rank_title'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
