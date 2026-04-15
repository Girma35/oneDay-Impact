import 'package:cross_file/cross_file.dart';

abstract class VerificationRepository {
  Future<bool> verifyChallengeCompletion({
    required String challengeDescription,
    required List<String> verificationKeywords,
    required XFile image,
  });
}
