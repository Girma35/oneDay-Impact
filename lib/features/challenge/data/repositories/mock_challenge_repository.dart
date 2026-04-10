import 'package:one_day/features/challenge/domain/entities/challenge.dart';
import 'package:one_day/features/challenge/domain/repositories/challenge_repository.dart';

class MockChallengeRepository implements ChallengeRepository {
  @override
  Future<List<Challenge>> getDailyChallenges() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      const Challenge(
        id: '1',
        title: 'Plant a Tree',
        description: 'Plant a native tree in your backyard or community park.',
        category: ChallengeCategory.environment,
        imageUrl: 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09',
        impactPoints: 50,
      ),
      const Challenge(
        id: '2',
        title: 'Visit an Elder',
        description: 'Spend 30 minutes talking with an elderly neighbor.',
        category: ChallengeCategory.elders,
        imageUrl: 'https://images.unsplash.com/photo-1581579438747-1dc8d17bbce4',
        impactPoints: 30,
      ),
      const Challenge(
        id: '3',
        title: 'Street Cleanup',
        description: 'Pick up litter on your street for 15 minutes.',
        category: ChallengeCategory.cleanliness,
        imageUrl: 'https://images.unsplash.com/photo-1563132332-1e0214b80021',
        impactPoints: 20,
      ),
    ];
  }

  @override
  Future<Challenge?> getChallengeById(String id) async {
    final challenges = await getDailyChallenges();
    try {
      return challenges.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
