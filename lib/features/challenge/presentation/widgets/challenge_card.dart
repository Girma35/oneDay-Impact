import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:one_day/core/theme/app_colors.dart';
import 'package:one_day/features/challenge/domain/entities/challenge.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final VoidCallback onTap;
  final bool compact;

  const ChallengeCard({
    super.key,
    required this.challenge,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              // Challenge Image
              CachedNetworkImage(
                imageUrl: challenge.imageUrl,
                height: compact ? 160 : 220,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: compact ? 160 : 220,
                  color: AppColors.divider,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: compact ? 160 : 220,
                  color: AppColors.divider,
                  child: const Icon(Icons.error),
                ),
              ),
              
              // Gradient Overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.textPrimary.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Content
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildCategoryBadge(challenge.category),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryRed,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '+${challenge.impactPoints} pts',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.surface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      challenge.title,
                      style: GoogleFonts.outfit(
                        fontSize: compact ? 16 : 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.surface,
                      ),
                    ),
                    if (!compact)
                    Text(
                      challenge.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: AppColors.surface.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(ChallengeCategory category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        category.name.toUpperCase(),
        style: GoogleFonts.outfit(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.surface,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
