import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:c_qube/core/constants/app_colors.dart';
import 'package:c_qube/core/constants/app_constants.dart';
import 'package:c_qube/core/constants/app_typography.dart';
import 'package:c_qube/core/utils/date_formatter.dart';
import 'package:c_qube/models/event_model.dart';
import 'package:c_qube/shared/widgets/empty_state_view.dart';
import 'package:c_qube/shared/widgets/event_card.dart';
import 'package:c_qube/state/auth_state.dart';
import 'package:c_qube/state/student_state.dart';
import 'package:c_qube/features/student/events/screens/event_detail_screen.dart';

class StudentCalendarScreen extends StatefulWidget {
  final bool isClubView;

  const StudentCalendarScreen({
    super.key,
    this.isClubView = false,
  });

  @override
  State<StudentCalendarScreen> createState() => _StudentCalendarScreenState();
}

class _StudentCalendarScreenState extends State<StudentCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  bool _filterMyRegistrations = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final studentState = Provider.of<StudentState>(context);
    final authState = Provider.of<AuthState>(context);
    final studentId = authState.currentStudent?.id ?? '';
    final isClub = widget.isClubView || authState.activeRole == UserRole.club;

    final baseEvents = (!isClub && _filterMyRegistrations)
        ? studentState.myRegisteredEvents
        : studentState.allEvents;

    final selectedDayEvents = baseEvents.where((e) {
      if (_selectedDay == null) return false;
      return isSameDay(e.date, _selectedDay!);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(isClub ? 'Club Campus Events Calendar' : 'Campus Events Calendar'),
      ),
      body: Column(
        children: [
          // Filter Toggle: All Events vs My Registrations (Only shown for Students)
          if (!isClub)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: FilterChip(
                      selected: !_filterMyRegistrations,
                      label: Text(
                        'All Campus Events (${studentState.allEvents.length})',
                        style: AppTypography.labelSmall.copyWith(
                          fontWeight: !_filterMyRegistrations ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      onSelected: (v) => setState(() => _filterMyRegistrations = false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilterChip(
                      selected: _filterMyRegistrations,
                      label: Text(
                        'My Registrations (${studentState.myRegisteredEvents.length})',
                        style: AppTypography.labelSmall.copyWith(
                          fontWeight: _filterMyRegistrations ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      onSelected: (v) => setState(() => _filterMyRegistrations = true),
                    ),
                  ),
                ],
              ),
            ),

          // TableCalendar Widget
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: TableCalendar<EventModel>(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: (day) {
                return baseEvents.where((e) => isSameDay(e.date, day)).toList();
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() => _calendarFormat = format);
              },
              calendarStyle: CalendarStyle(
                markerDecoration: const BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Date Header for Selected Day
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                Text(
                  _selectedDay != null
                      ? DateFormatter.formatShortDate(_selectedDay!)
                      : 'Selected Date',
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${selectedDayEvents.length} Events',
                  style: AppTypography.labelSmall.copyWith(
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),

          // Events list for selected date
          Expanded(
            child: selectedDayEvents.isEmpty
                ? EmptyStateView(
                    icon: Icons.calendar_today_outlined,
                    title: 'No Events on this Date',
                    description: _filterMyRegistrations
                        ? 'You have not registered for any events on this date.'
                        : 'No campus workshops or hackathons scheduled on this date.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: selectedDayEvents.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final event = selectedDayEvents[index];
                      final isReg = event.isRegisteredBy(studentId);

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
                          studentState.toggleEventRegistration(event.id, studentId);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
