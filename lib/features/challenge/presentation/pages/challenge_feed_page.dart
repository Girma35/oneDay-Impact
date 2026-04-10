import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:one_day/features/challenge/data/repositories/mock_challenge_repository.dart';
import 'package:one_day/features/challenge/domain/entities/challenge.dart';
import 'package:one_day/features/challenge/presentation/pages/challenge_details_page.dart';
import 'package:one_day/features/challenge/presentation/widgets/challenge_card.dart';

class ChallengeFeedPage extends StatelessWidget {
  const ChallengeFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = MockChallengeRepository();

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: true,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                'Today\'s Challenges',
                style: GoogleFonts.outfit(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none, color: Colors.black87),
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
