import 'package:one_day/features/challenge/domain/entities/completed_challenge.dart';

abstract class CompletedChallengeRepository {
  /// Get the current user's completed challenges (most recent first)
  Future<List<CompletedChallenge>> getUserCompletions({int limit = 50});

  /// Record a challenge completion via the secure complete_challenge() RPC
  /// Returns the completion ID, or a sentinel UUID if duplicate
  Future<String> completeChallenge({
    required String challengeId,
    String? proofImageUrl,
  });

  /// Get completions count for the current user
  Future<int> getCompletionsCount();
}
