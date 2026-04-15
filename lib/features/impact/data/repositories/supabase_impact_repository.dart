import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:one_day/features/impact/domain/entities/community_goal.dart';
import 'package:one_day/features/impact/domain/repositories/impact_repository.dart';

class SupabaseImpactRepository implements ImpactRepository {
  final SupabaseClient _client;

  SupabaseImpactRepository({required SupabaseClient client}) : _client = client;

  @override
  Future<List<ImpactBreakdownEntry>> getImpactBreakdown() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client.rpc('get_impact_breakdown', params: {
      'p_user_id': userId,
    });

    final List<dynamic> data = response as List<dynamic>;
    return data.map<ImpactBreakdownEntry>((json) {
      final map = json as Map<String, dynamic>;
      return ImpactBreakdownEntry(
        category: map['category'] as String,
        count: map['count'] as int,
        percentage: (map['percentage'] as num).toDouble(),
      );
    }).toList();
  }

  @override
  Future<List<ContributionDay>> getContributionHeatmap({int days = 70}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client.rpc('get_contribution_heatmap', params: {
      'p_user_id': userId,
      'p_days': days,
    });

    final List<dynamic> data = response as List<dynamic>;
    return data.map<ContributionDay>((json) {
      final map = json as Map<String, dynamic>;
      return ContributionDay(
        day: DateTime.parse(map['day'] as String),
        count: map['count'] as int,
      );
    }).toList();
  }

  @override
  Future<List<CommunityGoal>> getActiveCommunityGoals() async {
    final response = await _client
        .from('community_goals')
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: false);

    return response.map<CommunityGoal>((json) => _mapToCommunityGoal(json)).toList();
  }

  CommunityGoal _mapToCommunityGoal(Map<String, dynamic> json) {
    return CommunityGoal(
      id: json['id'] as String,
      title: json['title'] as String,
      targetCount: json['target_count'] as int,
      currentCount: json['current_count'] as int,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
