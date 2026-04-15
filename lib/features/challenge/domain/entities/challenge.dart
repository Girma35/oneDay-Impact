import 'package:equatable/equatable.dart';

enum ChallengeCategory {
  environment,
  elders,
  education,
  cleanliness,
  farming,
  water;
}

class Challenge extends Equatable {
  final String id;
  final String title;
  final String description;
  final ChallengeCategory category;
  final String imageUrl;
  final int impactPoints;
  final List<String> verificationKeywords;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.impactPoints,
    this.verificationKeywords = const [],
  });

  @override
  List<Object?> get props => [id, title, description, category, imageUrl, impactPoints, verificationKeywords];
}
