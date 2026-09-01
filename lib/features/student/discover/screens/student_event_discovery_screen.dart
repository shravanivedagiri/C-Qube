import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:c_qube/core/constants/app_colors.dart';
import 'package:c_qube/core/constants/app_constants.dart';
import 'package:c_qube/shared/widgets/event_card.dart';
import 'package:c_qube/shared/widgets/custom_text_field.dart';
import 'package:c_qube/shared/widgets/tag_chip.dart';
import 'package:c_qube/shared/widgets/empty_state_view.dart';
import 'package:c_qube/state/auth_state.dart';
import 'package:c_qube/state/student_state.dart';
import 'package:c_qube/features/student/events/screens/event_detail_screen.dart';

class StudentEventDiscoveryScreen extends StatefulWidget {
  const StudentEventDiscoveryScreen({super.key});

  @override
  State<StudentEventDiscoveryScreen> createState() => _StudentEventDiscoveryScreenState();
}

class _StudentEventDiscoveryScreenState extends State<StudentEventDiscoveryScreen> {
  final _searchController = TextEditingController();
  EventCategory? _selectedCategory;
  bool _onlineOnly = false;
  bool _beginnerOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentState = Provider.of<StudentState>(context);
    final authState = Provider.of<AuthState>(context);
    final studentId = authState.currentStudent?.id ?? '';

    final filteredEvents = studentState.allEvents.where((event) {
      if (_searchController.text.trim().isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        final matchTitle = event.title.toLowerCase().contains(query);
        final matchDesc = event.description.toLowerCase().contains(query);
        final matchClub = event.clubName.toLowerCase().contains(query);
        if (!matchTitle && !matchDesc && !matchClub) return false;
      }
      if (_selectedCategory != null && event.category != _selectedCategory) {
        return false;
      }
      if (_onlineOnly && !event.isOnline) {
        return false;
      }
      if (_beginnerOnly && !event.isBeginnerFriendly) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Events & Hackathons'),
      ),
      body: Column(
        children: [
          // Search & Filter Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  hintText: 'Search events, hackathons, workshops...',
                  controller: _searchController,
                  prefixIcon: Icons.search_rounded,
                  onChanged: (v) => setState(() {}),
                ),
                const SizedBox(height: 12),

                // Category Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      TagChip(
                        label: 'ALL EVENTS',
                        isSelected: _selectedCategory == null,
                        color: AppColors.primary,
                        onTap: () => setState(() => _selectedCategory = null),
                      ),
                      const SizedBox(width: 8),
                      ...EventCategory.values.map(
                        (cat) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: TagChip(
                            label: cat.name.toUpperCase(),
                            isSelected: _selectedCategory == cat,
                            color: AppColors.secondary,
                            onTap: () => setState(() {
                              _selectedCategory = _selectedCategory == cat ? null : cat;
                            }),
                          ),
                        ),
                      ),
                      TagChip(
                        label: 'ONLINE ONLY',
                        isSelected: _onlineOnly,
                        color: AppColors.accent,
                        icon: Icons.videocam_outlined,
                        onTap: () => setState(() => _onlineOnly = !_onlineOnly),
                      ),
                      const SizedBox(width: 8),
                      TagChip(
                        label: 'BEGINNER FRIENDLY',
                        isSelected: _beginnerOnly,
                        color: AppColors.success,
                        onTap: () => setState(() => _beginnerOnly = !_beginnerOnly),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Events List
          Expanded(
            child: filteredEvents.isEmpty
                ? const EmptyStateView(
                    icon: Icons.event_busy_rounded,
                    title: 'No Matching Events',
                    description: 'No events match your criteria. Try clearing some filters or searching for other terms.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredEvents.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final event = filteredEvents[index];
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
