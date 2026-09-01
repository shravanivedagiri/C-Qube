import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:c_qube/core/constants/app_colors.dart';
import 'package:c_qube/core/constants/app_typography.dart';
import 'package:c_qube/core/utils/date_formatter.dart';
import 'package:c_qube/models/post_model.dart';
import 'package:c_qube/models/friend_model.dart';
import 'package:c_qube/shared/widgets/club_card.dart';
import 'package:c_qube/shared/widgets/event_card.dart';
import 'package:c_qube/shared/widgets/tag_chip.dart';
import 'package:c_qube/shared/widgets/empty_state_view.dart';
import 'package:c_qube/shared/widgets/skeleton_loader.dart';
import 'package:c_qube/state/auth_state.dart';
import 'package:c_qube/state/student_state.dart';
import 'package:c_qube/state/notification_state.dart';
import 'package:c_qube/features/student/discover/screens/club_public_profile_screen.dart';
import 'package:c_qube/features/student/events/screens/event_detail_screen.dart';
import 'package:c_qube/features/student/notifications/screens/notifications_screen.dart';
import 'package:c_qube/features/student/discover/screens/club_discovery_screen.dart';
import 'package:c_qube/features/student/discover/screens/student_event_discovery_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = Provider.of<AuthState>(context);
    final studentState = Provider.of<StudentState>(context);
    final notificationState = Provider.of<NotificationState>(context);
    final student = authState.currentStudent;

    if (student == null) {
      return const Scaffold(body: Center(child: Text('User session not found')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${student.name.split(' ').first} 👋',
              style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              '${student.department} • ${student.year}',
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, size: 26),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                  );
                },
              ),
              if (notificationState.unreadCount > 0)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${notificationState.unreadCount}',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await studentState.loadDashboardData(student);
        },
        child: studentState.isLoading
            ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SkeletonLoader(height: 140, width: double.infinity),
                    SizedBox(height: 16),
                    SkeletonLoader(height: 200, width: double.infinity),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Section 1: Recommended Clubs
                    _buildSectionHeader(
                      title: 'Recommended Clubs for You',
                      actionText: 'Explore All',
                      onAction: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ClubDiscoveryScreen()),
                        );
                      },
                    ),
                    SizedBox(
                      height: 230,
                      child: studentState.recommendedClubs.isEmpty
                          ? const Center(child: Text('No club recommendations found.'))
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              scrollDirection: Axis.horizontal,
                              itemCount: studentState.recommendedClubs.length,
                              separatorBuilder: (context, index) => const SizedBox(width: 14),
                              itemBuilder: (context, index) {
                                final club = studentState.recommendedClubs[index];
                                final isJoined = student.joinedClubIds.contains(club.id);

                                return SizedBox(
                                  width: 280,
                                  child: ClubCard(
                                    club: club,
                                    isMember: isJoined,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ClubPublicProfileScreen(club: club),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 24),

                    // Section 2: Upcoming Events & Hackathons Carousel
                    _buildSectionHeader(
                      title: 'Upcoming Events & Hackathons',
                      actionText: 'View All',
                      onAction: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const StudentEventDiscoveryScreen()),
                        );
                      },
                    ),
                    studentState.upcomingEvents.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: EmptyStateView(
                              icon: Icons.event_busy_outlined,
                              title: 'No Upcoming Events',
                              description: 'No campus events are scheduled right now.',
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: studentState.upcomingEvents.take(3).length,
                            separatorBuilder: (context, index) => const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final event = studentState.upcomingEvents[index];
                              final isReg = event.isRegisteredBy(student.id);

                              return EventCard(
                                event: event,
                                isRegistered: isReg,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EventDetailScreen(event: event),
                                    ),
                                  );
                                },
                                onRegisterToggle: () {
                                  studentState.toggleEventRegistration(event.id, student.id);
                                },
                              );
                            },
                          ),
                    const SizedBox(height: 24),

                    // Section 3: Friend Activity Feed
                    _buildSectionHeader(
                      title: 'Friend Activities',
                      actionText: null,
                      onAction: null,
                    ),
                    studentState.friendActivities.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                              ),
                              child: Text(
                                'No recent friend activities yet. Connect with campus peers!',
                                style: AppTypography.bodySmall,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: studentState.friendActivities.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final activity = studentState.friendActivities[index];
                              return _buildFriendActivityCard(activity, isDark);
                            },
                          ),
                    const SizedBox(height: 24),

                    // Section 4: Club Feed / Announcements
                    _buildSectionHeader(
                      title: 'Campus Feed & Announcements',
                      actionText: null,
                      onAction: null,
                    ),
                    studentState.feedPosts.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: EmptyStateView(
                              icon: Icons.article_outlined,
                              title: 'No Feed Posts',
                              description: 'Posts from your joined clubs will appear here.',
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: studentState.feedPosts.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final post = studentState.feedPosts[index];
                              return _buildPostCard(post, isDark, student.id, studentState);
                            },
                          ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String? actionText,
    required VoidCallback? onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
          ),
          if (actionText != null && onAction != null)
            TextButton(
              onPressed: onAction,
              child: Text(
                actionText,
                style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFriendActivityCard(FriendActivityItem activity, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
            backgroundImage: activity.studentAvatarUrl.isNotEmpty
                ? NetworkImage(activity.studentAvatarUrl)
                : null,
            child: activity.studentAvatarUrl.isEmpty
                ? Text(activity.studentName[0], style: AppTypography.labelSmall)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                    children: [
                      TextSpan(
                        text: activity.studentName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: ' ${activity.activityText} '),
                      TextSpan(
                        text: activity.targetName,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormatter.formatRelative(activity.timestamp),
                  style: AppTypography.labelSmall.copyWith(
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(PostModel post, bool isDark, String studentId, StudentState studentState) {
    final isLiked = post.isLikedBy(studentId);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: post.clubLogoUrl.isNotEmpty ? NetworkImage(post.clubLogoUrl) : null,
                child: post.clubLogoUrl.isEmpty ? const Icon(Icons.groups, size: 14) : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.clubName, style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700)),
                    Text(
                      DateFormatter.formatRelative(post.createdAt),
                      style: AppTypography.labelSmall.copyWith(
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
              TagChip(label: post.type.name.toUpperCase(), color: AppColors.secondary),
            ],
          ),
          const SizedBox(height: 12),
          Text(post.title, style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(post.content, style: AppTypography.bodyMedium),
          if (post.imageUrl.isNotEmpty) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(post.imageUrl, height: 160, width: double.infinity, fit: BoxFit.cover),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              InkWell(
                onTap: () {
                  studentState.toggleLikePost(post.id, studentId);
                },
                child: Row(
                  children: [
                    Icon(
                      isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      size: 18,
                      color: isLiked ? AppColors.error : (isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary),
                    ),
                    const SizedBox(width: 6),
                    Text('${post.likesCount}', style: AppTypography.labelSmall),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Row(
                children: [
                  const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: AppColors.secondary),
                  const SizedBox(width: 6),
                  Text('${post.commentsCount}', style: AppTypography.labelSmall),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
