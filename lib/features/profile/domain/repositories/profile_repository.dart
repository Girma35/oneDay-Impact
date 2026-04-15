import 'package:one_day/features/profile/domain/entities/user_profile.dart';

abstract class ProfileRepository {
  /// Get the current user's profile
  Future<UserProfile?> getCurrentUserProfile();

  /// Get a user's profile by ID
  Future<UserProfile?> getProfileById(String userId);

  /// Update the current user's profile fields
  Future<void> updateProfile({
    String? fullName,
    String? avatarUrl,
    String? username,
  });

  /// Get the global rank percentage for the current user
  Future<int> getGlobalRank();

  /// Get total verified completions count for current user
  Future<int> getVerifiedCount();
}
