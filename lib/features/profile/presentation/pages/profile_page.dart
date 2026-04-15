import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:one_day/core/di/di.dart';
import 'package:one_day/core/theme/app_colors.dart';
import 'package:one_day/core/utils/responsive_utils.dart';
import 'package:one_day/core/utils/app_refresh_notifier.dart';
import 'package:one_day/core/utils/icon_utils.dart';
import 'package:one_day/core/utils/location_service.dart';
import 'package:one_day/features/profile/domain/entities/user_profile.dart';
import 'package:one_day/features/profile/domain/entities/achievement.dart';
import 'package:one_day/features/profile/domain/repositories/profile_repository.dart';
import 'package:one_day/features/profile/domain/repositories/achievement_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final locationService = getIt<LocationService>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.location_on, color: AppColors.primaryRed, size: 20),
            const SizedBox(width: 4),
            ListenableBuilder(
              listenable: locationService,
              builder: (context, _) {
                return Text(
                  locationService.cityName,
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                    color: AppColors.primaryRed,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.textSecondary),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _ProfileDataLoader(
        profileBuilder: (profile, achievements, globalRank, verifiedCount, onRefresh) {
          return RefreshIndicator(
            onRefresh: onRefresh,
            color: AppColors.primaryRed,
            child: responsiveMaxWidth(
              child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildProfileHeader(context, profile),
                    const SizedBox(height: 32),
                    _buildMetricsGrid(profile, globalRank, verifiedCount),
                    const SizedBox(height: 32),
                    _buildAchievementWardrobe(achievements),
                    const SizedBox(height: 32),
                    _buildAccountSettings(),
                    const SizedBox(height: 40),
                    _buildSignOutButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProfile? profile) {
    final avatarUrl = profile?.avatarUrl ?? 'https://i.pravatar.cc/150?img=11';
    final fullName = profile?.fullName ?? 'Loading...';
    final level = profile?.level ?? 1;
    final rankTitle = profile?.displayRankTitle ?? 'BEGINNER';

    return Column(
      children: [
        GestureDetector(
          onTap: () => _pickAndUploadAvatar(context, profile),
          child: Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.lightGreen, AppColors.primaryGreen],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.15),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(avatarUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              // Camera icon overlay for avatar upload
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt, color: AppColors.surface, size: 16),
                ),
              ),
              Positioned(
                bottom: -12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.darkGreen,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.surface, width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.eco, color: AppColors.surface, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        rankTitle,
                        style: GoogleFonts.outfit(
                          color: AppColors.surface,
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
        ),
        const SizedBox(height: 24),
        Text(
          fullName,
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.lightRed,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'LEVEL $level • $rankTitle',
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.darkRed,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  /// Pick an avatar image and upload to Supabase Storage, then update profile.
  Future<void> _pickAndUploadAvatar(BuildContext context, UserProfile? profile) async {
    final picker = ImagePicker();
    final messenger = ScaffoldMessenger.of(context);
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 512,
      maxHeight: 512,
    );

    if (image == null || profile == null) return;

    try {
      // Show loading
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Uploading avatar...'),
          backgroundColor: AppColors.primaryGreen,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 30),
        ),
      );

      final supabase = Supabase.instance.client;
      final userId = profile.id;
      final fileBytes = await image.readAsBytes();
      final fileExt = image.name.contains('.')
          ? image.name.split('.').last
          : 'jpg';
      final storagePath = 'avatars/$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      // Upload to Supabase Storage (requires 'avatars' bucket to exist in Supabase)
      await supabase.storage.from('avatars').uploadBinary(
        storagePath,
        fileBytes,
      );

      // Get public URL
      final publicUrl = supabase.storage.from('avatars').getPublicUrl(storagePath);
      // Add cache-busting query param to force image refresh
      final cacheBustUrl = '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';

      // Update profile with new avatar URL
      await getIt<ProfileRepository>().updateProfile(avatarUrl: cacheBustUrl);

      // Refresh all pages
      getIt<AppRefreshNotifier>().refresh();

      if (!context.mounted) return;
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Avatar updated!'),
          backgroundColor: AppColors.primaryGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint('Avatar upload error: $e');
      if (context.mounted) {
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: Text('Failed to upload avatar: $e'),
            backgroundColor: AppColors.primaryRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildMetricsGrid(UserProfile? profile, int globalRank, int verifiedCount) {
    final totalXp = profile?.totalXp ?? 0;
    final streak = profile?.streak ?? 0;

    String xpDisplay;
    String xpSuffix;
    if (totalXp >= 10000) {
      final k = totalXp / 1000;
      xpDisplay = k.toStringAsFixed(k % 1 == 0 ? 0 : 1);
      xpSuffix = 'K';
    } else {
      xpDisplay = totalXp.toString();
      xpSuffix = '';
    }

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
                xpDisplay,
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              if (xpSuffix.isNotEmpty)
                Text(
                  xpSuffix,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryRed,
                  ),
                ),
            ],
          ),
          bgColor: AppColors.surface,
          titleColor: AppColors.textSecondary,
        ),
        _buildMetricCard(
          title: 'VERIFIED',
          valueWidget: Text(
            '$verifiedCount',
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryGreen,
            ),
          ),
          subtext: 'Challenges Completed',
          bgColor: AppColors.paleGreen,
          titleColor: AppColors.primaryGreen,
        ),
        _buildMetricCard(
          title: 'STREAK',
          valueWidget: Row(
            children: [
              const Icon(Icons.flash_on, color: AppColors.surface, size: 28),
              const SizedBox(width: 4),
              Text(
                '$streak',
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.surface,
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
                    color: AppColors.surface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          bgColor: AppColors.primaryRed,
          titleColor: AppColors.surface.withValues(alpha: 0.7),
        ),
        _buildMetricCard(
          title: 'GLOBAL RANK',
          valueWidget: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$globalRank',
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkGreen,
                ),
              ),
              Text(
                '%',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkGreen,
                ),
              ),
            ],
          ),
          subtext: 'Top Tier Impact',
          subtextColor: AppColors.darkGreen,
          bgColor: AppColors.lightGreen,
          titleColor: AppColors.darkGreen,
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
        boxShadow: bgColor == AppColors.surface
            ? [BoxShadow(color: AppColors.textPrimary.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))]
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
                color: subtextColor ?? titleColor.withValues(alpha: 0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAchievementWardrobe(List<UserAchievement> achievements) {
    final unlocked = achievements.where((a) => a.id.isNotEmpty).toList();

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
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'VIEW ALL',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryRed,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: unlocked.isEmpty
              ? Center(
                  child: Text(
                    'Complete challenges to earn badges!',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: AppColors.textLight,
                    ),
                  ),
                )
              : ListView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  children: unlocked.take(5).map((ua) {
                    final ach = ua.achievement;
                    // Map to red/green palette
                    final iconColor = AppColors.mapToRedGreen(colorFromHex(ach?.colorHex ?? '#FF9800'));
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: _buildBadgeItem(
                        icon: iconFromName(ach?.iconName ?? 'star'),
                        iconColor: iconColor,
                        bgColor: iconColor.withValues(alpha: 0.12),
                        label: ach?.title ?? 'Badge',
                      ),
                    );
                  }).toList(),
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
            color: AppColors.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withValues(alpha: 0.04),
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
        SizedBox(
          width: 80,
          child: Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: AppColors.textSecondary,
            ),
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
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withValues(alpha: 0.03),
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
                  color: AppColors.background,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.textSecondary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.textLight, size: 20),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 64,
            color: AppColors.divider,
          ),
      ],
    );
  }

  Widget _buildSignOutButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: AppColors.paleRed,
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
            color: AppColors.primaryRed,
          ),
        ),
      ),
    );
  }
}

/// Helper widget that loads profile data, achievements, global rank, and verified count
/// and passes them to a builder. Shows a loading indicator while fetching.
class _ProfileDataLoader extends StatefulWidget {
  final Widget Function(UserProfile?, List<UserAchievement>, int, int, Future<void> Function()) profileBuilder;

  const _ProfileDataLoader({required this.profileBuilder});

  @override
  State<_ProfileDataLoader> createState() => _ProfileDataLoaderState();
}

class _ProfileDataLoaderState extends State<_ProfileDataLoader> {
  UserProfile? _profile;
  List<UserAchievement> _achievements = [];
  int _globalRank = 0;
  int _verifiedCount = 0;
  bool _isLoading = true; // Only true on first load
  bool _isInitialLoad = true;
  bool _isRefreshing = false; // Guards against concurrent refreshes
  int _lastRefreshCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    getIt<AppRefreshNotifier>().addListener(_onRefreshNotification);
  }

  @override
  void dispose() {
    getIt<AppRefreshNotifier>().removeListener(_onRefreshNotification);
    super.dispose();
  }

  void _onRefreshNotification() {
    final currentCount = getIt<AppRefreshNotifier>().refreshCount;
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

      final results = await Future.wait([
        profileRepo.getCurrentUserProfile(),
        achievementRepo.getAllWithStatus(),
        profileRepo.getGlobalRank(),
        profileRepo.getVerifiedCount(),
      ]);

      if (mounted) {
        setState(() {
          _profile = results[0] as UserProfile?;
          _achievements = results[1] as List<UserAchievement>;
          _globalRank = results[2] as int;
          _verifiedCount = results[3] as int;
          _isLoading = false;
          _isInitialLoad = false;
        });
      }
    } catch (e) {
      debugPrint('ProfilePage data load error: $e');
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
      return const Padding(
        padding: EdgeInsets.only(top: 60),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return widget.profileBuilder(_profile, _achievements, _globalRank, _verifiedCount, _loadData);
  }
}
