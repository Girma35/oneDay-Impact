import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:one_day/core/di/di.dart';
import 'package:one_day/core/theme/app_colors.dart';
import 'package:one_day/core/utils/responsive_utils.dart';
import 'package:one_day/features/challenge/domain/entities/challenge.dart';
import 'package:one_day/features/challenge/domain/repositories/challenge_repository.dart';
import 'package:one_day/features/challenge/presentation/pages/challenge_details_page.dart';
import 'package:one_day/features/challenge/presentation/widgets/challenge_card.dart';

class ChallengeFeedPage extends StatelessWidget {
  const ChallengeFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = getIt<ChallengeRepository>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: true,
            pinned: true,
            backgroundColor: AppColors.surface,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                'Today\'s Challenges',
                style: GoogleFonts.outfit(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none, color: AppColors.textPrimary),
              ),
              const SizedBox(width: 8),
            ],
          ),
          FutureBuilder<List<Challenge>>(
            future: repository.getDailyChallenges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              
              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(child: Text('Error: ${snapshot.error}')),
                );
              }

              final challenges = snapshot.data ?? [];
              final columns = gridColumns(context);

              if (columns > 1) {
                // Multi-column grid for tablet/desktop
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.5,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return ChallengeCard(
                          challenge: challenges[index],
                          compact: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChallengeDetailsPage(challenge: challenges[index]),
                              ),
                            );
                          },
                        );
                      },
                      childCount: challenges.length,
                    ),
                  ),
                );
              }

              // Single-column list for phone
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return ChallengeCard(
                      challenge: challenges[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChallengeDetailsPage(challenge: challenges[index]),
                          ),
                        );
                      },
                    );
                  },
                  childCount: challenges.length,
                ),
              );
            },
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
        ],
      ),
    );
  }
}
