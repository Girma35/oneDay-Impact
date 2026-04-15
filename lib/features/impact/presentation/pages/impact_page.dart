import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:one_day/core/di/di.dart';
import 'package:one_day/core/theme/app_colors.dart';
import 'package:one_day/core/utils/responsive_utils.dart';
import 'package:one_day/core/utils/app_refresh_notifier.dart';
import 'package:one_day/core/utils/icon_utils.dart';
import 'package:one_day/core/utils/location_service.dart';
import 'package:one_day/features/profile/domain/entities/user_profile.dart';
import 'package:one_day/features/profile/domain/repositories/profile_repository.dart';
import 'package:one_day/features/profile/domain/repositories/achievement_repository.dart';
import 'package:one_day/features/profile/domain/entities/achievement.dart';
import 'package:one_day/features/challenge/domain/repositories/completed_challenge_repository.dart';
import 'package:one_day/features/challenge/domain/entities/completed_challenge.dart';
import 'package:one_day/features/impact/domain/entities/community_goal.dart';
import 'package:one_day/features/impact/domain/repositories/impact_repository.dart';

class ImpactPage extends StatelessWidget {
  const ImpactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _ImpactDataLoader(
          builder: (profile, achievements, completions, breakdown, heatmap, communityGoals, verifiedCount, onRefresh) {
            return RefreshIndicator(
              onRefresh: onRefresh,
              color: AppColors.primaryRed,
              child: responsiveMaxWidth(
                child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAppBar(profile).animate().fadeIn().slideY(begin: -0.1),
                    const SizedBox(height: 16),
                    _buildHeroLevelCard(profile).animate().fadeIn(delay: 50.ms).slideY(begin: 0.1),
                    const SizedBox(height: 24),
                    _buildMetricsGrid(profile, completions, verifiedCount).animate().fadeIn(delay: 150.ms),
                    const SizedBox(height: 24),
                    _buildImpactBreakdown(breakdown).animate().fadeIn(delay: 250.ms).slideX(begin: -0.05),
                    const SizedBox(height: 24),
                    _buildContributionGrid(heatmap).animate().fadeIn(delay: 350.ms).slideX(begin: 0.05),
                    const SizedBox(height: 24),
                    if (communityGoals.isNotEmpty)
                      _buildGlobalCommunityGoal(communityGoals.first).animate().fadeIn(delay: 450.ms).slideY(begin: 0.1),
                    const SizedBox(height: 24),
                    _buildAchievements(achievements).animate().fadeIn(delay: 550.ms),
                    const SizedBox(height: 24),
                    _buildRecentActivity(completions).animate().fadeIn(delay: 650.ms).slideY(begin: 0.1),
                    const SizedBox(height: 100),
                  ],
                ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(UserProfile? profile) {
    final avatarUrl = profile?.avatarUrl ?? 'https://i.pravatar.cc/150?img=11';
    final locationService = getIt<LocationService>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryRed,
                backgroundImage: NetworkImage(avatarUrl),
              ),
              const SizedBox(width: 12),
              ListenableBuilder(
                listenable: locationService,
                builder: (context, _) {
                  return Text(
                    locationService.cityName,
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.italic,
                      color: AppColors.primaryRed,
                      letterSpacing: -0.5,
                    ),
                  );
                },
              ),
            ],
          ),
          Icon(Icons.notifications_rounded, color: AppColors.textSecondary, size: 28),
        ],
      ),
    );
  }

  Widget _buildHeroLevelCard(UserProfile? profile) {
    final level = profile?.level ?? 1;
    final totalXp = profile?.totalXp ?? 0;
    final rankTitle = profile?.displayRankTitle ?? 'BEGINNER';
    final avatarUrl = profile?.avatarUrl ?? 'https://i.pravatar.cc/150?img=60';

    // XP progress calculation
    final xpForCurrentLevel = (level - 1) * (level - 1) * 50;
    final xpForNextLevel = level * level * 50;
    final xpInLevel = totalXp - xpForCurrentLevel;
    final xpNeeded = xpForNextLevel - xpForCurrentLevel;
    final progressPercent = xpNeeded > 0 ? ((xpInLevel / xpNeeded) * 100).round().clamp(0, 100) : 0;
    final flexProgress = progressPercent.clamp(1, 99);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryRed.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.greenGradient,
                ),
                child: CircleAvatar(
                  radius: 46,
                  backgroundImage: NetworkImage(avatarUrl),
                ),
              ),
              Positioned(
                bottom: -12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.darkGreen,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.surface, width: 2),
                  ),
                  child: Text(
                    rankTitle,
                    style: GoogleFonts.outfit(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppColors.surface,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Keep pushing,\nChampion!',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.1,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LVL $level',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.outfit(color: AppColors.textLight),
                  children: [
                    TextSpan(
                      text: formatXp(totalXp),
                      style: GoogleFonts.outfit(
                        color: AppColors.primaryRed,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: ' / ${formatXp(xpForNextLevel)} pts',
                      style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 12,
              color: AppColors.divider,
              child: Row(
                children: [
                  Expanded(
                    flex: flexProgress,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: AppColors.redGradient,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  Expanded(flex: 100 - flexProgress, child: const SizedBox()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildMetricsGrid(UserProfile? profile, List<CompletedChallenge> completions, int verifiedCount) {
    final streak = profile?.streak ?? 0;
    final bestStreak = profile?.bestStreak ?? 0;
    final totalXp = profile?.totalXp ?? 0;
    final verified = verifiedCount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  isPrimary: true,
                  title: '$streak Day',
                  subtitle: 'STREAK',
                  icon: Icons.local_fire_department_rounded,
                  iconColor: AppColors.surface,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricItem(
                  isPrimary: false,
                  title: '$bestStreak',
                  subtitle: 'BEST STREAK',
                  icon: Icons.emoji_events_rounded,
                  iconColor: AppColors.primaryRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  isPrimary: false,
                  title: formatXp(totalXp),
                  subtitle: 'TOTAL XP',
                  icon: Icons.stars_rounded,
                  iconColor: AppColors.darkRed,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricItem(
                  isPrimary: false,
                  title: '$verified',
                  subtitle: 'VERIFIED',
                  icon: Icons.verified_rounded,
                  iconColor: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required bool isPrimary,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.primaryRed : AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (!isPrimary)
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          if (isPrimary)
            BoxShadow(
              color: AppColors.primaryRed.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isPrimary ? AppColors.surface : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              color: isPrimary ? AppColors.surface.withValues(alpha: 0.7) : AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactBreakdown(List<ImpactBreakdownEntry> entries) {
    final displayEntries = entries
        .map((e) => ImpactBreakdownEntry(
            category: e.category.toUpperCase(),
            count: e.count,
            percentage: e.percentage,
          ))
        .toList();

    if (displayEntries.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          children: [
            Text(
              'Impact Breakdown',
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 24),
            Text(
              'Complete challenges to see your impact breakdown!',
              style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textLight),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Impact Breakdown',
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 24),
          for (int i = 0; i < displayEntries.length; i++) ...[
            _buildProgressRow(
              displayEntries[i].category,
              '${displayEntries[i].percentage.round()}%',
              categoryColor(displayEntries[i].category),
              displayEntries[i].percentage / 100,
            ),
            if (i < displayEntries.length - 1) const SizedBox(height: 18),
          ],
        ],
      ),
    );
  }



  Widget _buildProgressRow(String label, String percentStr, Color color, double percent) {
    final flexValue = (percent * 100).toInt().clamp(1, 99);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: AppColors.textSecondary),
            ),
            Text(
              percentStr,
              style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            height: 6,
            color: color.withValues(alpha: 0.15),
            child: Row(
              children: [
                Expanded(flex: flexValue, child: Container(color: color)),
                Expanded(flex: 100 - flexValue, child: const SizedBox()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContributionGrid(List<ContributionDay> heatmap) {
    final now = DateTime.now();
    final gridData = List<int>.generate(70, (_) => 0);

    if (heatmap.isNotEmpty) {
      for (final day in heatmap) {
        final diff = now.difference(day.day).inDays;
        if (diff >= 0 && diff < 70) {
          gridData[69 - diff] = day.level;
        }
      }
    } else {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          children: [
            Text(
              'Contribution Grid',
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 24),
            Text(
              'Complete challenges to build your contribution grid!',
              style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textLight),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contribution Grid',
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            child: GridView.builder(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 70,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 14,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
              ),
              itemBuilder: (context, index) {
                Color boxColor;
                switch (gridData[index]) {
                  case 1: boxColor = AppColors.heatmap1; break;
                  case 2: boxColor = AppColors.heatmap2; break;
                  case 3: boxColor = AppColors.heatmap3; break;
                  case 4: boxColor = AppColors.heatmap4; break;
                  default:  boxColor = AppColors.heatmap0;
                }
                return Container(
                  decoration: BoxDecoration(
                    color: boxColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LESS IMPACT',
                style: GoogleFonts.outfit(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.textLight, letterSpacing: 0.5),
              ),
              Row(
                children: [
                  _legendBox(AppColors.heatmap0),
                  const SizedBox(width: 4),
                  _legendBox(AppColors.heatmap1),
                  const SizedBox(width: 4),
                  _legendBox(AppColors.heatmap2),
                  const SizedBox(width: 4),
                  _legendBox(AppColors.heatmap3),
                  const SizedBox(width: 4),
                  _legendBox(AppColors.heatmap4),
                ],
              ),
              Text(
                'MORE IMPACT',
                style: GoogleFonts.outfit(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.textLight, letterSpacing: 0.5),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _legendBox(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildGlobalCommunityGoal(CommunityGoal goal) {
    final progressPercent = goal.progressPercent;
    final flexProgress = progressPercent.clamp(1, 99);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: AppColors.greenGradient,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Global\nCommunity\nGoal',
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.surface,
                    height: 1.1,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.darkGreen.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  'Join the\neffort!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    color: AppColors.surface,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            goal.title,
            style: GoogleFonts.outfit(
              color: AppColors.surface.withValues(alpha: 0.85),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Progress',
                style: GoogleFonts.outfit(
                  color: AppColors.surface,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${formatCount(goal.currentCount)} / ${formatCount(goal.targetCount)}',
                style: GoogleFonts.outfit(
                  color: AppColors.surface,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 14,
              color: AppColors.surface.withValues(alpha: 0.2),
              child: Row(
                children: [
                  Expanded(
                    flex: flexProgress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$progressPercent%',
                        style: GoogleFonts.outfit(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ),
                  Expanded(flex: 100 - flexProgress, child: const SizedBox()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildAchievements(List<UserAchievement> achievements) {
    final unlocked = achievements.where((a) => a.id.isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Achievements',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              Text(
                'View All',
                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryRed),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: unlocked.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Complete challenges to unlock achievements!',
                      style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textLight),
                    ),
                  ),
                )
              : ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: unlocked.take(5).map((ua) {
                    final ach = ua.achievement;
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: _buildAchievementCard(
                        iconFromName(ach?.iconName ?? 'star'),
                        colorFromHex(ach?.colorHex ?? '#FF9800'),
                        ach?.title ?? 'Badge',
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }


  Widget _buildAchievementCard(IconData icon, Color color, String title) {
    // Map any achievement color to red/green/white palette
    final mappedColor = AppColors.mapToRedGreen(color);

    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: mappedColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: mappedColor, size: 28),
          ),
          const Spacer(),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(List<CompletedChallenge> completions) {
    if (completions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          'No recent activity yet. Complete a challenge to get started!',
          style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textLight),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Recent Activity',
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 16),
        for (int i = 0; i < completions.take(3).length; i++) ...[
          _buildActivityCardFromCompletion(completions[i]),
          if (i < 2 && i < completions.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildActivityCardFromCompletion(CompletedChallenge completion) {
    final challenge = completion.challenge;
    final catColor = categoryColor(challenge?.category.name ?? 'ENVIRONMENTAL');
    final icon = categoryIcon(challenge?.category.name ?? 'ENVIRONMENTAL');
    final timeLabel = formatTimeLabel(completion.verifiedAt);
    final taskTitle = challenge?.title ?? 'Challenge';
    final points = '+${completion.pointsEarned} pts';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: catColor, width: 4)),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: catColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      timeLabel,
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textLight,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      taskTitle,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                points,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: catColor,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

/// Loads all data needed by the ImpactPage from Supabase via DI repositories.
class _ImpactDataLoader extends StatefulWidget {
  final Widget Function(
    UserProfile?,
    List<UserAchievement>,
    List<CompletedChallenge>,
    List<ImpactBreakdownEntry>,
    List<ContributionDay>,
    List<CommunityGoal>,
    int,
    Future<void> Function(),
  ) builder;

  const _ImpactDataLoader({required this.builder});

  @override
  State<_ImpactDataLoader> createState() => _ImpactDataLoaderState();
}

class _ImpactDataLoaderState extends State<_ImpactDataLoader> {
  UserProfile? _profile;
  List<UserAchievement> _achievements = [];
  List<CompletedChallenge> _completions = [];
  List<ImpactBreakdownEntry> _breakdown = [];
  List<ContributionDay> _heatmap = [];
  List<CommunityGoal> _communityGoals = [];
  int _verifiedCount = 0;
  bool _isLoading = true; // Only true on first load
  bool _isInitialLoad = true;
  bool _isRefreshing = false; // Guards against concurrent refreshes
  int _lastRefreshCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Listen for tab-switch refreshes from AppRefreshNotifier
    getIt<AppRefreshNotifier>().addListener(_onRefreshNotification);
  }

  @override
  void dispose() {
    getIt<AppRefreshNotifier>().removeListener(_onRefreshNotification);
    super.dispose();
  }

  void _onRefreshNotification() {
    final currentCount = getIt<AppRefreshNotifier>().refreshCount;
    // Only refresh if this is a new notification (not the one that triggered our own load)
    if (currentCount != _lastRefreshCount && !_isLoading) {
      _lastRefreshCount = currentCount;
      _loadData();
    }
  }

  Future<void> _loadData() async {
    if (!mounted || _isRefreshing) return;
    _isRefreshing = true;
    // Only show full-screen spinner on the very first load;
    // subsequent refreshes update data silently in the background.
    if (_isInitialLoad) {
      setState(() => _isLoading = true);
    }

    try {
      final profileRepo = getIt<ProfileRepository>();
      final achievementRepo = getIt<AchievementRepository>();
      final completedRepo = getIt<CompletedChallengeRepository>();
      final impactRepo = getIt<ImpactRepository>();

      final results = await Future.wait([
        profileRepo.getCurrentUserProfile(),
        achievementRepo.getAllWithStatus(),
        completedRepo.getUserCompletions(limit: 10),
        impactRepo.getImpactBreakdown(),
        impactRepo.getContributionHeatmap(days: 70),
        impactRepo.getActiveCommunityGoals(),
        completedRepo.getCompletionsCount(),
      ]);

      if (mounted) {
        setState(() {
          _profile = results[0] as UserProfile?;
          _achievements = results[1] as List<UserAchievement>;
          _completions = results[2] as List<CompletedChallenge>;
          _breakdown = results[3] as List<ImpactBreakdownEntry>;
          _heatmap = results[4] as List<ContributionDay>;
          _communityGoals = results[5] as List<CommunityGoal>;
          _verifiedCount = results[6] as int;
          _isLoading = false;
          _isInitialLoad = false;
        });
      }
    } catch (e) {
      debugPrint('ImpactPage data load error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isInitialLoad = false;
        });
      }
    } finally {
      _isRefreshing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return widget.builder(
      _profile, _achievements, _completions, _breakdown,
      _heatmap, _communityGoals, _verifiedCount, _loadData,
    );
  }
}
