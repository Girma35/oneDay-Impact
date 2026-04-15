import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:one_day/features/challenge/domain/entities/challenge.dart';
import 'package:one_day/features/challenge/domain/entities/completed_challenge.dart';
import 'package:one_day/features/challenge/domain/repositories/completed_challenge_repository.dart';

class SupabaseCompletedChallengeRepository implements CompletedChallengeRepository {
  final SupabaseClient _client;

  SupabaseCompletedChallengeRepository({required SupabaseClient client}) : _client = client;

  @override
  Future<List<CompletedChallenge>> getUserCompletions({int limit = 50}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('completed_challenges')
        .select('*, challenges(*)')
        .eq('user_id', userId)
        .order('verified_at', ascending: false)
        .limit(limit);

    return response.map<CompletedChallenge>((json) => _mapToCompletedChallenge(json)).toList();
  }

  @override
  Future<String> completeChallenge({
    required String challengeId,
    String? proofImageUrl,
  }) async {
    final response = await _client.rpc('complete_challenge', params: {
      'p_challenge_id': challengeId,
      'p_proof_image_url': proofImageUrl,
    });

    return response as String;
  }

  @override
  Future<int> getCompletionsCount() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return 0;

    final response = await _client
        .from('completed_challenges')
        .select('id')
        .eq('user_id', userId);

    return response.length;
  }

  CompletedChallenge _mapToCompletedChallenge(Map<String, dynamic> json) {
    Challenge? challenge;
    if (json['challenges'] != null) {
      final c = json['challenges'] as Map<String, dynamic>;
      challenge = Challenge(
        id: c['id'] as String,
        title: c['title'] as String,
        description: c['description'] as String,
        category: _parseCategory(c['category'] as String),
        imageUrl: c['image_url'] as String,
        impactPoints: c['impact_points'] as int,
        verificationKeywords: (c['verification_keywords'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
      );
    }

    return CompletedChallenge(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      challengeId: json['challenge_id'] as String,
      proofImageUrl: json['proof_image_url'] as String?,
      pointsEarned: json['points_earned'] as int,
      verifiedAt: DateTime.parse(json['verified_at'] as String),
      challenge: challenge,
    );
  }

  ChallengeCategory _parseCategory(String category) {
    return ChallengeCategory.values.firstWhere(
      (e) => e.name == category,
      orElse: () => ChallengeCategory.environment,
    );
  }
}
