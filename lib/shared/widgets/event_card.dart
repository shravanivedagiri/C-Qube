import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/event_model.dart';
import 'tag_chip.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final bool isRegistered;
  final VoidCallback? onTap;
  final VoidCallback? onRegisterToggle;

  const EventCard({
    super.key,
    required this.event,
    this.isRegistered = false,
    this.onTap,
    this.onRegisterToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
            // Banner Image & Date Tag
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      event.bannerUrl.isNotEmpty
                          ? event.bannerUrl
                          : 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?auto=format&fit=crop&w=800&q=80',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: isDark ? AppColors.darkSurface : Colors.grey.shade200,
                        child: const Center(
                          child: Icon(Icons.event_outlined, size: 40, color: AppColors.primary),
                        ),
                      ),
                    ),
                  ),
                ),
                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.2),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                  ),
                ),
                // Category & Online Tag
                Positioned(
                  top: 12,
                  left: 12,
                  child: Row(
                    children: [
                      TagChip(
                        label: event.category.name.toUpperCase(),
                        color: AppColors.primaryLight,
                      ),
                      const SizedBox(width: 6),
                      if (event.isOnline)
                        const TagChip(
                          label: 'ONLINE',
                          color: AppColors.accent,
                          icon: Icons.videocam_outlined,
                        ),
                    ],
                  ),
                ),
                // Date Badge on bottom right of banner
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 12, color: Colors.white),
                        const SizedBox(width: 5),
                        Text(
                          DateFormatter.formatShortDate(event.date),
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Content Body
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Club organizer info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                        backgroundImage: event.clubLogoUrl.isNotEmpty
                            ? NetworkImage(event.clubLogoUrl)
                            : null,
                        child: event.clubLogoUrl.isEmpty
                            ? const Icon(Icons.groups, size: 12, color: AppColors.primary)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.clubName,
                          style: AppTypography.labelSmall.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Event Title
                  Text(
                    event.title,
                    style: AppTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),

                  // Time & Location
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 14,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary),
                      const SizedBox(width: 5),
                      Text(
                        DateFormatter.formatTime(event.startTime),
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.location_on_outlined,
                          size: 14,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Seat capacity bar and register action
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${event.registeredCount} / ${event.capacity} seats filled',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: (event.capacity == 0)
                                    ? 0
                                    : (event.registeredCount / event.capacity).clamp(0.0, 1.0),
                                backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  event.isFull ? AppColors.error : AppColors.primary,
                                ),
                                minHeight: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (onRegisterToggle != null) ...[
                        const SizedBox(width: 14),
                        SizedBox(
                          height: 34,
                          child: ElevatedButton(
                            onPressed: onRegisterToggle,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isRegistered
                                  ? AppColors.success.withValues(alpha: 0.15)
                                  : AppColors.primary,
                              foregroundColor: isRegistered ? AppColors.success : Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: isRegistered
                                    ? const BorderSide(color: AppColors.success, width: 1)
                                    : BorderSide.none,
                              ),
                            ),
                            child: Text(
                              isRegistered ? 'Registered ✓' : 'Register',
                              style: AppTypography.labelSmall.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isRegistered ? AppColors.success : Colors.white,
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
          ],
        ),
      ),
    );
  }
}
