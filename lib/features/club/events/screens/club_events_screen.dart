import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:c_qube/core/constants/app_colors.dart';
import 'package:c_qube/shared/widgets/empty_state_view.dart';
import 'package:c_qube/shared/widgets/event_card.dart';
import 'package:c_qube/state/club_state.dart';
import 'host_event_screen.dart';
import 'event_participants_screen.dart';

class ClubEventsScreen extends StatefulWidget {
  const ClubEventsScreen({super.key});

  @override
  State<ClubEventsScreen> createState() => _ClubEventsScreenState();
}

class _ClubEventsScreenState extends State<ClubEventsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final clubState = Provider.of<ClubState>(context);
    final events = clubState.clubEvents;

    final upcomingEvents = events.where((e) => e.date.isAfter(DateTime.now())).toList();
    final pastEvents = events.where((e) => e.date.isBefore(DateTime.now())).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Club Events & Workshops'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Host Event',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HostEventScreen()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: isDark ? Colors.white : AppColors.primary,
          unselectedLabelColor: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
          tabs: [
            Tab(text: 'Upcoming (${upcomingEvents.length})'),
            Tab(text: 'Past (${pastEvents.length})'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HostEventScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Host Event', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Upcoming Events
          upcomingEvents.isEmpty
              ? EmptyStateView(
                  icon: Icons.event_available_outlined,
                  title: 'No Upcoming Events',
                  description: 'Host workshops, hackathons, or tech talks for campus students.',
                  actionText: 'Host New Event',
                  onAction: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HostEventScreen()),
                    );
                  },
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: upcomingEvents.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final event = upcomingEvents[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        EventCard(
                          event: event,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EventParticipantsScreen(event: event),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 6),
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EventParticipantsScreen(event: event),
                              ),
                            );
                          },
                          icon: const Icon(Icons.people_alt_outlined, size: 16),
                          label: Text('View Roster (${event.registeredCount} Registered)'),
                        ),
                      ],
                    );
                  },
                ),

          // Tab 2: Past Events
          pastEvents.isEmpty
              ? const EmptyStateView(
                  icon: Icons.history_toggle_off_rounded,
                  title: 'No Past Events Record',
                  description: 'Completed club events will be archived here.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: pastEvents.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final event = pastEvents[index];
                    return EventCard(
                      event: event,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EventParticipantsScreen(event: event),
                          ),
                        );
                      },
                    );
                  },
                ),
        ],
      ),
    );
  }
}
