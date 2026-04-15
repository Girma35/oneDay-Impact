import 'package:equatable/equatable.dart';

class CommunityGoal extends Equatable {
  final String id;
  final String title;
  final int targetCount;
  final int currentCount;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final DateTime createdAt;

  const CommunityGoal({
    required this.id,
    required this.title,
    required this.targetCount,
    required this.currentCount,
    required this.startDate,
    this.endDate,
    required this.isActive,
    required this.createdAt,
  });

  /// Computed: progress percentage (0-100)
  int get progressPercent {
    if (targetCount == 0) return 0;
    return ((currentCount / targetCount) * 100).round().clamp(0, 100);
  }

  @override
  List<Object?> get props => [id, title, targetCount, currentCount, startDate, endDate, isActive, createdAt];
}

class ImpactBreakdownEntry extends Equatable {
  final String category;
  final int count;
  final double percentage;

  const ImpactBreakdownEntry({
    required this.category,
    required this.count,
    required this.percentage,
  });

  @override
  List<Object?> get props => [category, count, percentage];
}

class ContributionDay extends Equatable {
  final DateTime day;
  final int count;

  const ContributionDay({
    required this.day,
    required this.count,
  });

  /// Heatmap level: 0=none, 1=low, 2=medium, 3=high, 4=very high
  int get level {
    if (count == 0) return 0;
    if (count == 1) return 1;
    if (count == 2) return 2;
    if (count == 3) return 3;
    return 4;
  }

  @override
  List<Object?> get props => [day, count];
}
