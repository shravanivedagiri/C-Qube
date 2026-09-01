import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../models/club_model.dart';
import 'tag_chip.dart';

class ClubCard extends StatelessWidget {
  final ClubModel club;
  final bool isMember;
  final bool isFollowing;
  final VoidCallback? onTap;
  final VoidCallback? onJoinToggle;
  final VoidCallback? onFollowToggle;

  const ClubCard({
    super.key,
    required this.club,
    this.isMember = false,
    this.isFollowing = false,
    this.onTap,
    this.onJoinToggle,
    this.onFollowToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Avatar, Name, Category
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 52,
                    height: 52,
                    color: AppColors.primary.withValues(alpha: 0.1),
                    child: Image.network(
                      club.logoUrl.isNotEmpty
                          ? club.logoUrl
                          : 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?auto=format&fit=crop&w=200&q=80',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.groups, color: AppColors.primary, size: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              club.name,
                              style: AppTypography.headlineSmall.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.verified, size: 16, color: AppColors.primaryLight),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        club.department,
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description Snippet
            Text(
              club.about,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Tags & Action Row
            Row(
              children: [
                TagChip(
                  label: club.category.name.toUpperCase(),
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 6),
                if (club.isBeginnerFriendly)
                  const TagChip(
                    label: 'BEGINNER FRIENDLY',
                    color: AppColors.success,
                  ),
                const Spacer(),
                Text(
                  '${club.memberCount} members',
                  style: AppTypography.labelSmall.copyWith(
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
                if (onJoinToggle != null) ...[
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      onPressed: onJoinToggle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isMember
                            ? AppColors.success.withValues(alpha: 0.15)
                            : AppColors.primary,
                        foregroundColor: isMember ? AppColors.success : Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: isMember
                              ? const BorderSide(color: AppColors.success, width: 1)
                              : BorderSide.none,
                        ),
                      ),
                      child: Text(
                        isMember ? 'Joined ✓' : 'Join',
                        style: AppTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isMember ? AppColors.success : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
