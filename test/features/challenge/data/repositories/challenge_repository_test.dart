import 'package:flutter_test/flutter_test.dart';
import 'package:one_day/features/challenge/data/repositories/mock_challenge_repository.dart';
import 'package:one_day/features/challenge/domain/entities/challenge.dart';

void main() {
  late MockChallengeRepository repository;

  setUp(() {
    repository = MockChallengeRepository();
  });

  group('MockChallengeRepository', () {
    test('getDailyChallenges returns a list of challenges', () async {
      // act
      final result = await repository.getDailyChallenges();

      // assert
      expect(result, isA<List<Challenge>>());
      expect(result.length, greaterThan(0));
      expect(result[0].title, equals('Plant a Tree'));
    });

    test('getChallengeById returns the correct challenge when it exists', () async {
      // act
      final result = await repository.getChallengeById('2');

      // assert
      expect(result, isNotNull);
      expect(result?.id, equals('2'));
      expect(result?.title, equals('Visit an Elder'));
    });

    test('getChallengeById returns null when it does not exist', () async {
      // act
      final result = await repository.getChallengeById('non-existent');

      // assert
      expect(result, isNull);
    });
  });
}
