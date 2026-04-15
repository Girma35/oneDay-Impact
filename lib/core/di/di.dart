import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:one_day/features/challenge/domain/repositories/challenge_repository.dart';
import 'package:one_day/features/challenge/domain/repositories/completed_challenge_repository.dart';
import 'package:one_day/features/challenge/domain/repositories/verification_repository.dart';
import 'package:one_day/features/challenge/data/repositories/supabase_challenge_repository.dart';
import 'package:one_day/features/challenge/data/repositories/supabase_completed_challenge_repository.dart';
import 'package:one_day/features/challenge/data/repositories/hf_verification_repository.dart';

import 'package:one_day/features/profile/domain/repositories/profile_repository.dart';
import 'package:one_day/features/profile/domain/repositories/achievement_repository.dart';
import 'package:one_day/features/profile/data/repositories/supabase_profile_repository.dart';
import 'package:one_day/features/profile/data/repositories/supabase_achievement_repository.dart';

import 'package:one_day/features/impact/domain/repositories/impact_repository.dart';
import 'package:one_day/features/impact/data/repositories/supabase_impact_repository.dart';
import 'package:one_day/core/utils/app_refresh_notifier.dart';
import 'package:one_day/core/utils/location_service.dart';

final getIt = GetIt.instance;

/// Call once after Supabase.initialize() in main.dart
void setupDependencies() {
  // ── Core ──────────────────────────────────────────────────────────
  final supabase = Supabase.instance.client;
  getIt.registerSingleton<SupabaseClient>(supabase);

  // ── Challenge feature ─────────────────────────────────────────────
  getIt.registerLazySingleton<ChallengeRepository>(
    () => SupabaseChallengeRepository(client: supabase),
  );
  getIt.registerLazySingleton<CompletedChallengeRepository>(
    () => SupabaseCompletedChallengeRepository(client: supabase),
  );
  getIt.registerLazySingleton<VerificationRepository>(
    () => HFVerificationRepository(),
  );

  // ── Profile feature ────────────────────────────────────────────────
  getIt.registerLazySingleton<ProfileRepository>(
    () => SupabaseProfileRepository(client: supabase),
  );
  getIt.registerLazySingleton<AchievementRepository>(
    () => SupabaseAchievementRepository(client: supabase),
  );

  // ── Impact feature ────────────────────────────────────────────────
  getIt.registerLazySingleton<ImpactRepository>(
    () => SupabaseImpactRepository(client: supabase),
  );

  // ── Shared utilities ────────────────────────────────────────────────
  getIt.registerLazySingleton<AppRefreshNotifier>(
    () => AppRefreshNotifier(),
  );
  getIt.registerLazySingleton<LocationService>(
    () => LocationService(),
  );
}
