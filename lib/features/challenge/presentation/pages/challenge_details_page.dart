import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_day/core/di/di.dart';
import 'package:one_day/core/theme/app_colors.dart';
import 'package:one_day/core/utils/responsive_utils.dart';
import 'package:one_day/features/challenge/presentation/bloc/verification_bloc.dart';
import 'package:one_day/features/challenge/domain/entities/challenge.dart';
import 'package:one_day/features/challenge/domain/repositories/verification_repository.dart';
import 'package:one_day/features/challenge/domain/repositories/completed_challenge_repository.dart';

class ChallengeDetailsPage extends StatelessWidget {
  final Challenge challenge;

  const ChallengeDetailsPage({super.key, required this.challenge});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VerificationBloc(
        repository: getIt<VerificationRepository>(),
        completedRepo: getIt<CompletedChallengeRepository>(),
      ),
      child: BlocConsumer<VerificationBloc, VerificationState>(
        listener: (context, state) {
          if (state is VerificationSuccess) {
            _showResultDialog(context, state.isVerified);
          } else if (state is VerificationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: AppColors.primaryRed,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              _buildScaffold(context),
              // Full-screen loading overlay while AI is working
              if (state is VerificationLoading)
                Container(
                  color: AppColors.textPrimary.withValues(alpha: 0.55),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(color: AppColors.primaryRed),
                          const SizedBox(height: 20),
                          Text(
                            'AI is verifying\nyour action…',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Powered by Hugging Face',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: challenge.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: AppColors.divider),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.divider,
                  child: const Icon(Icons.broken_image, size: 48),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: responsiveMaxWidth(
              child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildCategoryBadge(challenge.category),
                      const Spacer(),
                      Text(
                        '+${challenge.impactPoints} pts',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryRed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    challenge.title,
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    challenge.description,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: 24),
                  Text(
                    'Verification Method',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.paleGreen,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.lightGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.auto_awesome, color: AppColors.primaryGreen),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Image Verification',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                'AI will analyse your photo to confirm you completed the challenge.',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton.icon(
                    onPressed: () => _showVerificationBottomSheet(context),
                    icon: const Text('🔥', style: TextStyle(fontSize: 20)),
                    label: const Text('Complete & Verify'),
                  ),
                ],
              ),
            ),
            ),
          ),
        ],
      ),
    );
  }

  void _showVerificationBottomSheet(BuildContext context) {
    final bloc = context.read<VerificationBloc>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Verify Your Action',
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Take or choose a photo as proof',
                  style: GoogleFonts.outfit(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Camera is not supported on web or desktop — only show on mobile
                    if (!kIsWeb &&
                        ![TargetPlatform.linux, TargetPlatform.macOS, TargetPlatform.windows]
                            .contains(defaultTargetPlatform))
                      _VerificationOption(
                        icon: Icons.camera_alt_rounded,
                        label: 'Camera',
                        onTap: () => _pickAndVerify(
                            sheetContext, ImageSource.camera, bloc),
                      ),
                    _VerificationOption(
                      icon: Icons.photo_library_rounded,
                      label: kIsWeb ? 'Choose Photo' : 'Gallery',
                      onTap: () => _pickAndVerify(
                          sheetContext, ImageSource.gallery, bloc),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAndVerify(
    BuildContext context,
    ImageSource source,
    VerificationBloc bloc,
  ) async {
    Navigator.pop(context); // Close bottom sheet first
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: source,
      imageQuality: 85, // Compress slightly for faster upload
    );

    if (image != null) {
      bloc.add(VerifyChallengeStarted(
        challengeId: challenge.id,
        challengeDescription: challenge.description,
        verificationKeywords: challenge.verificationKeywords,
        image: image, // XFile works on all platforms including web
      ));
    }
  }

  void _showResultDialog(BuildContext context, bool success) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          success ? '🎉 Challenge Verified!' : '❌ Not Verified',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: Text(
          success
              ? 'Amazing work! You earned ${challenge.impactPoints} impact points.'
              : 'AI couldn\'t confirm the challenge from this photo. '
                'Try again with a clearer image showing your action.',
          style: GoogleFonts.outfit(height: 1.5),
        ),
        actions: [
          if (!success)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showVerificationBottomSheet(context);
              },
              child: const Text('Try Again'),
            ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              Navigator.pop(context); // Close dialog
              if (success) Navigator.pop(context); // Go back to feed
            },
            child: Text(success ? 'Awesome!' : 'OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(ChallengeCategory category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
      ),
      child: Text(
        category.name.toUpperCase(),
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.darkGreen,
        ),
      ),
    );
  }
}

class _VerificationOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _VerificationOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.paleGreen,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: AppColors.primaryGreen),
            const SizedBox(height: 10),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w600,
                color: AppColors.darkGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
