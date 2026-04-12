import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB), // Soft off-white background from image
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
            ),
            const SizedBox(width: 12),
            Text(
              'Bishoftu',
              style: GoogleFonts.caveat(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFB91C1C),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.grey),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 32),
              _buildMetricsGrid(),
              const SizedBox(height: 32),
              _buildAchievementWardrobe(),
              const SizedBox(height: 32),
              _buildAccountSettings(),
              const SizedBox(height: 40),
              _buildSignOutButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFFFFEDD5), Color(0xFFFDBA74)],
                  center: Alignment.topCenter,
                  radius: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.15),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage('https://i.pravatar.cc/150?img=11'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF166534), // Dark green
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.eco, color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'ECO-WARRIOR',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Alex Rivers',
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFEE2E2), // Light red
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'LEVEL 24 • IMPACT LEADER',
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF991B1B), // Dark red
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.1,
      children: [
        _buildMetricCard(
          title: 'TOTAL XP',
          valueWidget: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '12.4',
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
              Text(
                'K',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
          bgColor: Colors.white,
          titleColor: Colors.grey.shade600,
        ),
        _buildMetricCard(
          title: 'VERIFIED',
          valueWidget: Text(
            '84',
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF6D28D9),
            ),
          ),
          subtext: 'Challenges Completed',
          bgColor: const Color(0xFFF3E8FF), // Light purple
          titleColor: const Color(0xFF6D28D9),
        ),
        _buildMetricCard(
          title: 'STREAK',
          valueWidget: Row(
            children: [
              const Icon(Icons.flash_on, color: Colors.white, size: 28),
              const SizedBox(width: 4),
              Text(
                '12',
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'DAYS',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
          bgColor: const Color(0xFFB91C1C), // Deep red/orange
          titleColor: Colors.white70,
        ),
        _buildMetricCard(
          title: 'GLOBAL RANK',
          valueWidget: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '15',
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF166534),
                ),
              ),
              Text(
                '%',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF166534),
                ),
              ),
            ],
          ),
          subtext: 'Top Tier Impact',
          subtextColor: const Color(0xFF166534),
          bgColor: const Color(0xFFDCFCE7), // Light green
          titleColor: const Color(0xFF166534),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required Widget valueWidget,
    String? subtext,
    required Color bgColor,
    required Color titleColor,
    Color? subtextColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: bgColor == Colors.white
            ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 8),
          valueWidget,
          if (subtext != null) ...[
            const SizedBox(height: 4),
            Text(
              subtext,
              style: GoogleFonts.outfit(
                fontSize: 10,
                color: subtextColor ?? titleColor.withOpacity(0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAchievementWardrobe() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'Achievement Wardrobe',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
            ),
            Text(
              'VIEW ALL',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFDC2626),
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            children: [
              _buildBadgeItem(
                icon: Icons.wb_sunny_rounded,
                iconColor: const Color(0xFFC2410C),
                bgColor: const Color(0xFFFFEDD5),
                label: 'EARLY BIRD',
              ),
              const SizedBox(width: 16),
              _buildBadgeItem(
                icon: Icons.fitness_center_rounded,
                iconColor: const Color(0xFF6D28D9),
                bgColor: const Color(0xFFF3E8FF),
                label: 'WEEKEND WARRIOR',
              ),
              const SizedBox(width: 16),
              _buildBadgeItem(
                icon: Icons.eco_rounded,
                iconColor: const Color(0xFF15803D),
                bgColor: const Color(0xFFDCFCE7),
                label: 'GREEN THUMB',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.outfit(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: const Color(0xFF4B5563),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Settings',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSettingsRow(icon: Icons.person_outline, label: 'Personal Information'),
              _buildSettingsRow(icon: Icons.notifications_none, label: 'Notification Preferences'),
              _buildSettingsRow(icon: Icons.shield_outlined, label: 'Privacy & Security'),
              _buildSettingsRow(icon: Icons.help_outline, label: 'Help & Support', isLast: true),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSettingsRow({required IconData icon, required String label, bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFF4B5563), size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 64,
            color: Colors.grey[100],
          ),
      ],
    );
  }

  Widget _buildSignOutButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFFFBE8E8), // Very very light red/pink
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: () {},
        child: Text(
          'SIGN OUT',
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: const Color(0xFFB91C1C),
          ),
        ),
      ),
    );
  }
}
