import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:c_qube/core/constants/app_colors.dart';
import 'package:c_qube/core/constants/app_constants.dart';
import 'package:c_qube/core/constants/app_typography.dart';
import 'package:c_qube/core/utils/date_formatter.dart';
import 'package:c_qube/shared/widgets/empty_state_view.dart';
import 'package:c_qube/state/notification_state.dart';
import 'package:c_qube/state/auth_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notificationState = Provider.of<NotificationState>(context);
    final authState = Provider.of<AuthState>(context);
    final studentId = authState.currentStudent?.id ?? '';
    final notifications = notificationState.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications Center'),
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () {
                notificationState.markAllAsRead(studentId);
              },
              child: Text(
                'Mark All Read',
                style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
              ),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? const EmptyStateView(
              icon: Icons.notifications_off_outlined,
              title: 'No Notifications Yet',
              description: 'Updates on event registrations, friend requests, and club announcements will appear here.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = notifications[index];

                return InkWell(
                  onTap: () {
                    notificationState.markAsRead(item.id, studentId);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: item.isRead
                          ? (isDark ? AppColors.darkCard : AppColors.lightCard)
                          : AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: item.isRead
                            ? (isDark ? AppColors.darkBorder : AppColors.lightBorder)
                            : AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTypeIcon(item.type),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: AppTypography.labelMedium.copyWith(
                                        fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  if (!item.isRead)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.body,
                                style: AppTypography.bodySmall.copyWith(
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                DateFormatter.formatRelative(item.createdAt),
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
                  ),
                );
              },
            ),
    );
  }

  Widget _buildTypeIcon(NotificationType type) {
    IconData icon = Icons.notifications_rounded;
    Color color = AppColors.accent;

    switch (type) {
      case NotificationType.event:
        icon = Icons.event_available_rounded;
        color = AppColors.primary;
        break;
      case NotificationType.friend:
        icon = Icons.person_add_rounded;
        color = AppColors.success;
        break;
      case NotificationType.club:
        icon = Icons.campaign_rounded;
        color = AppColors.warning;
        break;
      case NotificationType.friendActivity:
        icon = Icons.notifications_rounded;
        color = AppColors.accent;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
