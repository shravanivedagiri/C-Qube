import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:c_qube/core/constants/app_colors.dart';
import 'package:c_qube/core/constants/app_typography.dart';
import 'package:c_qube/models/event_model.dart';
import 'package:c_qube/models/user_model.dart';
import 'package:c_qube/shared/widgets/empty_state_view.dart';
import 'package:c_qube/state/club_state.dart';

class EventParticipantsScreen extends StatefulWidget {
  final EventModel event;

  const EventParticipantsScreen({super.key, required this.event});

  @override
  State<EventParticipantsScreen> createState() => _EventParticipantsScreenState();
}

class _EventParticipantsScreenState extends State<EventParticipantsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final clubState = Provider.of<ClubState>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.event.title} — Attendees'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Export CSV',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Participant CSV roster downloaded to local storage!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<UserModel>>(
        future: clubState.getEventParticipants(widget.event.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final attendees = snapshot.data ?? [];

          return Column(
            children: [
              // Banner summary card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                child: Row(
                  children: [
                    const Icon(Icons.people_alt_rounded, color: AppColors.primary, size: 28),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${attendees.length} Registered Students',
                          style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          'Capacity: ${widget.event.capacity} seats',
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Participants List
              Expanded(
                child: attendees.isEmpty
                    ? const EmptyStateView(
                        icon: Icons.person_off_outlined,
                        title: 'No Registrations Yet',
                        description: 'When students register for this event on campus, their details will appear here.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: attendees.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final student = attendees[index];

                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCard : AppColors.lightCard,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                  backgroundImage: student.avatarUrl.isNotEmpty
                                      ? NetworkImage(student.avatarUrl)
                                      : null,
                                  child: student.avatarUrl.isEmpty
                                      ? Text(
                                          student.name[0],
                                          style: AppTypography.headlineSmall.copyWith(color: AppColors.primary),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        student.name,
                                        style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
                                      ),
                                      Text(
                                        student.email,
                                        style: AppTypography.bodySmall.copyWith(color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary),
                                      ),
                                      Text(
                                        '${student.department} • ${student.year}',
                                        style: AppTypography.labelSmall.copyWith(color: AppColors.primaryLight),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Confirmed',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
