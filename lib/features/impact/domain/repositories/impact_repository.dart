import 'package:one_day/features/impact/domain/entities/community_goal.dart';

abstract class ImpactRepository {
  /// Get the impact breakdown by category for the current user
  Future<List<ImpactBreakdownEntry>> getImpactBreakdown();

  /// Get the contribution heatmap data for the current user
  Future<List<ContributionDay>> getContributionHeatmap({int days = 70});

  /// Get the active community goals
  Future<List<CommunityGoal>> getActiveCommunityGoals();
}
