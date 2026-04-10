import 'dart:io';

abstract class VerificationRepository {
  Future<bool> verifyChallengeCompletion({
    required String challengeDescription,
    required File image,
  });
}
