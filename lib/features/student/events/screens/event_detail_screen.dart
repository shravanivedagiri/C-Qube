import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:c_qube/core/constants/app_colors.dart';
import 'package:c_qube/core/constants/app_typography.dart';
import 'package:c_qube/core/utils/date_formatter.dart';
import 'package:c_qube/models/event_model.dart';
import 'package:c_qube/shared/widgets/tag_chip.dart';
import 'package:c_qube/shared/widgets/custom_button.dart';
import 'package:c_qube/state/auth_state.dart';
import 'package:c_qube/state/student_state.dart';

class EventDetailScreen extends StatefulWidget {
  final EventModel event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late EventModel _event;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final studentState = Provider.of<StudentState>(context);
    final authState = Provider.of<AuthState>(context);
    final student = authState.currentStudent;
    final isRegistered = student != null && _event.isRegisteredBy(student.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Banner Image & App Bar
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _event.bannerUrl.isNotEmpty
                        ? _event.bannerUrl
                        : 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?auto=format&fit=crop&w=1200&q=80',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black45,
                          Colors.transparent,
                          Colors.black87,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Row(
                      children: [
                        TagChip(
                          label: _event.category.name.toUpperCase(),
                          color: AppColors.primaryLight,
                        ),
                        const SizedBox(width: 8),
                        if (_event.isOnline)
                          const TagChip(
                            label: 'ONLINE EVENT',
                            color: AppColors.accent,
                            icon: Icons.videocam_outlined,
                          ),
                        if (_event.isBeginnerFriendly) ...[
                          const SizedBox(width: 8),
                          const TagChip(
                            label: 'BEGINNER FRIENDLY',
                            color: AppColors.success,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Event Info & Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Title
                  Text(
                    _event.title,
                    style: AppTypography.displaySmall.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Host Club Info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                        backgroundImage: _event.clubLogoUrl.isNotEmpty
                            ? NetworkImage(_event.clubLogoUrl)
                            : null,
                        child: _event.clubLogoUrl.isEmpty
                            ? const Icon(Icons.groups, size: 18, color: AppColors.primary)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Organized by',
                            style: AppTypography.labelSmall.copyWith(
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            ),
                          ),
                          Text(
                            _event.clubName,
                            style: AppTypography.labelMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Date, Time & Venue Cards
                  _buildDetailTile(
                    icon: Icons.calendar_month_rounded,
                    title: DateFormatter.formatShortDate(_event.date),
                    subtitle: '${DateFormatter.formatTime(_event.startTime)} - ${DateFormatter.formatTime(_event.endTime)}',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  _buildDetailTile(
                    icon: Icons.location_on_rounded,
                    title: _event.location,
                    subtitle: _event.isOnline ? 'Access link shared upon registration' : 'Physical On-Campus Venue',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  _buildDetailTile(
                    icon: Icons.stars_rounded,
                    title: '+50 Campus Activity Points',
                    subtitle: 'Earned automatically upon attendance confirmation',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 24),

                  // Seat Availability Counter Bar
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Seat Availability',
                              style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              '${_event.registeredCount} / ${_event.capacity} Filled',
                              style: AppTypography.labelMedium.copyWith(
                                color: _event.isFull ? AppColors.error : AppColors.success,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: (_event.capacity == 0)
                                ? 0
                                : (_event.registeredCount / _event.capacity).clamp(0.0, 1.0),
                            backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _event.isFull ? AppColors.error : AppColors.primary,
                            ),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Registration Closes: ${DateFormatter.formatShortDate(_event.registrationDeadline)}',
                          style: AppTypography.labelSmall.copyWith(
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'About this Event',
                    style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _event.description,
                    style: AppTypography.bodyLarge.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: isRegistered ? 'Registered ✓' : 'Register Now',
                          variant: isRegistered ? ButtonVariant.success : ButtonVariant.primary,
                          icon: isRegistered ? Icons.check_circle_rounded : Icons.how_to_reg_rounded,
                          onPressed: () async {
                            if (student != null) {
                              await studentState.toggleEventRegistration(_event.id, student.id);
                              setState(() {
                                final updatedStoreEvent = studentState.allEvents.firstWhere((e) => e.id == _event.id);
                                _event = updatedStoreEvent;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
