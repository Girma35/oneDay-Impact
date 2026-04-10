import 'package:one_day/features/challenge/domain/entities/challenge.dart';

abstract class ChallengeRepository {
  Future<List<Challenge>> getDailyChallenges();
  Future<Challenge?> getChallengeById(String id);
}
