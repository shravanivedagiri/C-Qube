import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:c_qube/core/constants/app_colors.dart';
import 'package:c_qube/core/constants/app_typography.dart';
import 'package:c_qube/core/utils/date_formatter.dart';
import 'package:c_qube/shared/widgets/empty_state_view.dart';
import 'package:c_qube/shared/widgets/tag_chip.dart';
import 'package:c_qube/state/club_state.dart';
import 'create_announcement_screen.dart';
import 'create_post_screen.dart';
import 'package:c_qube/features/club/events/screens/host_event_screen.dart';
import 'package:c_qube/features/club/recruitment/screens/create_recruitment_screen.dart';

class ClubActivityTab extends StatelessWidget {
  const ClubActivityTab({super.key});

  void _showCreateActivityModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Activity',
                style: AppTypography.displaySmall.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'Select an action to publish to your club and campus feeds:',
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // Option 1: Create Announcement
              _buildModalOption(
                ctx,
                icon: Icons.campaign_rounded,
                color: AppColors.secondary,
                title: 'Create Announcement',
                subtitle: 'Broadcast official alerts and updates to students',
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateAnnouncementScreen()));
                },
                isDark: isDark,
              ),
              const SizedBox(height: 10),

              // Option 2: Create Post
              _buildModalOption(
                ctx,
                icon: Icons.article_rounded,
                color: AppColors.primary,
                title: 'Create Post / Achievement',
                subtitle: 'Share milestones, photos, and team recognitions',
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePostScreen()));
                },
                isDark: isDark,
              ),
              const SizedBox(height: 10),

              // Option 3: Host Event
              _buildModalOption(
                ctx,
                icon: Icons.event_available_rounded,
                color: AppColors.success,
                title: 'Host Event / Workshop',
                subtitle: 'Publish hackathons, seminars, and calendar entries',
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const HostEventScreen()));
                },
                isDark: isDark,
              ),
              const SizedBox(height: 10),

              // Option 4: Open Recruitment
              _buildModalOption(
                ctx,
                icon: Icons.badge_rounded,
                color: AppColors.warning,
                title: 'Open Recruitment Drive',
                subtitle: 'Accept student applications for domain leads',
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateRecruitmentScreen()));
                },
                isDark: isDark,
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalOption(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700)),
                  Text(subtitle, style: AppTypography.bodySmall.copyWith(color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.secondary),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final clubState = Provider.of<ClubState>(context);
    final posts = clubState.clubPosts;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateActivityModal(context),
        backgroundColor: AppColors.secondary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Create Activity', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: posts.isEmpty
          ? EmptyStateView(
              icon: Icons.article_outlined,
              title: 'This club hasn\'t posted anything yet',
              description: 'Publish your first announcement, achievement, or event to engage with campus students.',
              actionText: 'Create Activity',
              onAction: () => _showCreateActivityModal(context),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: posts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final post = posts[index];

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          TagChip(
                            label: post.type.name.toUpperCase(),
                            color: AppColors.secondary,
                          ),
                          const Spacer(),
                          Text(
                            DateFormatter.formatRelative(post.createdAt),
                            style: AppTypography.labelSmall.copyWith(
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        post.title,
                        style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        post.content,
                        style: AppTypography.bodyMedium.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          height: 1.45,
                        ),
                      ),
                      if (post.imageUrl.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image.network(
                              post.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                child: const Icon(Icons.image_outlined, color: AppColors.primary),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}
