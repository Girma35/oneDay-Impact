import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ImpactPage extends StatelessWidget {
  const ImpactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB), // Very light soft grey background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar().animate().fadeIn().slideY(begin: -0.1),
              const SizedBox(height: 16),
              _buildHeroLevelCard().animate().fadeIn(delay: 50.ms).slideY(begin: 0.1),
              const SizedBox(height: 24),
              _buildMetricsGrid().animate().fadeIn(delay: 150.ms),
              const SizedBox(height: 24),
              _buildImpactBreakdown().animate().fadeIn(delay: 250.ms).slideX(begin: -0.05),
              const SizedBox(height: 24),
              _buildContributionGrid().animate().fadeIn(delay: 350.ms).slideX(begin: 0.05),
              const SizedBox(height: 24),
              _buildGlobalCommunityGoal().animate().fadeIn(delay: 450.ms).slideY(begin: 0.1),
              const SizedBox(height: 32),
              _buildAchievements().animate().fadeIn(delay: 550.ms),
              const SizedBox(height: 32),
              _buildRecentActivity().animate().fadeIn(delay: 650.ms).slideY(begin: 0.1),
              const SizedBox(height: 100), // Bottom padding for overlap
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.black,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
              ),
              const SizedBox(width: 12),
              Text(
                'Bishoftu',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFFC02A24),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const Icon(Icons.notifications_rounded, color: Color(0xFF2E3A59), size: 28),
        ],
      ),
    );
  }

  Widget _buildHeroLevelCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
                  gradient: LinearGradient(
                    colors: [Colors.purpleAccent, Colors.orangeAccent, Colors.yellowAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const CircleAvatar(
                  radius: 46,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=60'),
                ),
              ),
              Positioned(
                bottom: -12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF196127),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text(
                    'ECO-WARRIOR',
                    style: GoogleFonts.outfit(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
              color: const Color(0xFF1E2022),
              height: 1.1,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LVL 24',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.outfit(color: Colors.grey[500]),
                  children: [
                    TextSpan(
                      text: '1,240',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFC02A24),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: ' / 2,000 pts',
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
              color: Colors.grey[200],
              child: Row(
                children: [
                  Expanded(
                    flex: 62,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFC02A24), Color(0xFFFFA07A)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const Expanded(flex: 38, child: SizedBox()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  isPrimary: true,
                  title: '12 Day',
                  subtitle: 'STREAK',
                  icon: Icons.local_fire_department_rounded,
                  iconColor: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricItem(
                  isPrimary: false,
                  title: '45',
                  subtitle: 'BEST STREAK',
                  icon: Icons.emoji_events_rounded,
                  iconColor: const Color(0xFFC02A24),
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
                  title: '12.4K',
                  subtitle: 'TOTAL XP',
                  icon: Icons.stars_rounded,
                  iconColor: const Color(0xFF6A1B9A),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricItem(
                  isPrimary: false,
                  title: '84',
                  subtitle: 'VERIFIED',
                  icon: Icons.verified_rounded,
                  iconColor: const Color(0xFF28853D),
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
        color: isPrimary ? const Color(0xFFB32A15) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (!isPrimary)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          if (isPrimary)
            BoxShadow(
              color: const Color(0xFFB32A15).withOpacity(0.4),
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
              color: isPrimary ? Colors.white : const Color(0xFF1E2022),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              color: isPrimary ? Colors.white70 : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactBreakdown() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E2022)),
          ),
          const SizedBox(height: 24),
          _buildProgressRow('ENVIRONMENTAL', '40%', const Color(0xFF28853D), 0.4),
          const SizedBox(height: 18),
          _buildProgressRow('SOCIAL', '25%', const Color(0xFF7B3AF2), 0.25),
          const SizedBox(height: 18),
          _buildProgressRow('SELF-CARE', '15%', const Color(0xFFE56A54), 0.15),
          const SizedBox(height: 18),
          _buildProgressRow('CIVIC', '10%', Colors.grey[600]!, 0.1),
        ],
      ),
    );
  }

  Widget _buildProgressRow(String label, String percentStr, Color color, double percent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: const Color(0xFF4A4E54)),
            ),
            Text(
              percentStr,
              style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            height: 6,
            color: color.withOpacity(0.15),
            child: Row(
              children: [
                Expanded(flex: (percent * 100).toInt(), child: Container(color: color)),
                Expanded(flex: 100 - (percent * 100).toInt(), child: const SizedBox()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContributionGrid() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E2022)),
          ),
          const SizedBox(height: 20),
          // Heatmap grid placeholder
          ClipRRect(
            child: GridView.builder(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 5 * 14, // 5 rows to make it look nicely matched
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 14,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
              ),
              itemBuilder: (context, index) {
                int pattern = [1, 2, 0, 3, 4, 1, 0, 2, 3, 0, 1, 4, 2, 0, 0, 2, 4, 1, 3, 2, 0, 4, 1, 0, 2, 3, 1, 0, 4, 1, 2, 0, 3, 2, 1, 4, 0, 2, 3, 1, 0, 1, 4][index % 43];
                Color boxColor;
                switch (pattern) {
                  case 0: boxColor = Colors.grey[200]!; break;
                  case 1: boxColor = const Color(0xFFA5D6A7); break;
                  case 2: boxColor = const Color(0xFF66BB6A); break;
                  case 3: boxColor = const Color(0xFF43A047); break;
                  case 4: boxColor = const Color(0xFF1B5E20); break;
                  default: boxColor = Colors.grey[200]!;
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
                style: GoogleFonts.outfit(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 0.5),
              ),
              Row(
                children: [
                  _legendBox(Colors.grey[200]!),
                  const SizedBox(width: 4),
                  _legendBox(const Color(0xFFA5D6A7)),
                  const SizedBox(width: 4),
                  _legendBox(const Color(0xFF66BB6A)),
                  const SizedBox(width: 4),
                  _legendBox(const Color(0xFF43A047)),
                  const SizedBox(width: 4),
                  _legendBox(const Color(0xFF1B5E20)),
                ],
              ),
              Text(
                'MORE IMPACT',
                style: GoogleFonts.outfit(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 0.5),
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

  Widget _buildGlobalCommunityGoal() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF7B3AF2), // Rich purple gradient base
        gradient: const LinearGradient(
          colors: [Color(0xFF8B47FA), Color(0xFF6A24E3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7B3AF2).withOpacity(0.4),
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
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF4C10A8).withOpacity(0.6),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  'You\ncontributed\n1.5%!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Join thousands in our\n10,000 task target',
            style: GoogleFonts.outfit(
              color: Colors.white.withOpacity(0.85),
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
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '7,200 / 10,000',
                style: GoogleFonts.outfit(
                  color: Colors.white,
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
              color: Colors.white.withOpacity(0.2),
              child: Row(
                children: [
                  Expanded(
                    flex: 72,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '72%',
                        style: GoogleFonts.outfit(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF7B3AF2),
                        ),
                      ),
                    ),
                  ),
                  const Expanded(flex: 28, child: SizedBox()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
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
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E2022)),
              ),
              Text(
                'View All',
                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFFC02A24)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              _buildAchievementCard(Icons.wb_sunny_rounded, Colors.orange, 'Early Bird'),
              const SizedBox(width: 16),
              _buildAchievementCard(Icons.fitness_center_rounded, const Color(0xFF28853D), 'Weekend\nWarrior'),
              const SizedBox(width: 16),
              _buildAchievementCard(Icons.local_florist_rounded, Colors.teal, 'Green\nThumb'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(IconData icon, Color color, String title) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const Spacer(),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: const Color(0xFF1E2022),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Recent Activity',
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E2022)),
          ),
        ),
        const SizedBox(height: 16),
        _buildActivityCard(
          borderThemeColor: const Color(0xFF28853D),
          icon: Icons.energy_savings_leaf_rounded,
          timeLabel: 'TODAY',
          taskTitle: 'Cleaned local\nstreet',
          points: '+50\npts',
        ),
        const SizedBox(height: 16),
        _buildActivityCard(
          borderThemeColor: const Color(0xFF7B3AF2),
          icon: Icons.volunteer_activism_rounded,
          timeLabel: 'YESTERDAY',
          taskTitle: 'Donated books',
          points: '+80 pts',
        ),
      ],
    );
  }

  Widget _buildActivityCard({
    required Color borderThemeColor,
    required IconData icon,
    required String timeLabel,
    required String taskTitle,
    required String points,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: borderThemeColor, width: 4)),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: borderThemeColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: borderThemeColor, size: 24),
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
                        color: Colors.grey[500],
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
                        color: const Color(0xFF1E2022),
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
                  color: borderThemeColor,
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
