import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:one_day/features/challenge/domain/entities/challenge.dart';
import 'package:one_day/features/challenge/domain/repositories/challenge_repository.dart';

class SupabaseChallengeRepository implements ChallengeRepository {
  final SupabaseClient _client;

  SupabaseChallengeRepository({required SupabaseClient client}) : _client = client;

  @override
  Future<List<Challenge>> getDailyChallenges() async {
    final today = DateTime.now().toIso8601String().split('T').first;

    // Try fetching today's challenges first
    var response = await _client
        .from('challenges')
        .select()
        .eq('active_date', today)
        .order('impact_points', ascending: false);

    // Fallback: if no challenges for today, fetch all active challenges
    if (response.isEmpty) {
      response = await _client
          .from('challenges')
          .select()
          .order('impact_points', ascending: false)
          .limit(10);
    }

    return response.map<Challenge>((json) => _mapToChallenge(json)).toList();
  }

  @override
  Future<Challenge?> getChallengeById(String id) async {
    final response = await _client
        .from('challenges')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return _mapToChallenge(response);
  }

  Challenge _mapToChallenge(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: _parseCategory(json['category'] as String),
      imageUrl: json['image_url'] as String,
      impactPoints: json['impact_points'] as int,
      verificationKeywords: (json['verification_keywords'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }

  ChallengeCategory _parseCategory(String category) {
    return ChallengeCategory.values.firstWhere(
      (e) => e.name == category,
      orElse: () => ChallengeCategory.environment,
    );
  }
}
