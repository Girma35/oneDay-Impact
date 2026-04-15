import 'package:equatable/equatable.dart';
import 'package:one_day/features/challenge/domain/entities/challenge.dart';

class CompletedChallenge extends Equatable {
  final String id;
  final String userId;
  final String challengeId;
  final String? proofImageUrl;
  final int pointsEarned;
  final DateTime verifiedAt;

  /// Joined challenge data (optional, populated when fetching with join)
  final Challenge? challenge;

  const CompletedChallenge({
    required this.id,
    required this.userId,
    required this.challengeId,
    this.proofImageUrl,
    required this.pointsEarned,
    required this.verifiedAt,
    this.challenge,
  });

  @override
  List<Object?> get props => [id, userId, challengeId, proofImageUrl, pointsEarned, verifiedAt, challenge];
}
