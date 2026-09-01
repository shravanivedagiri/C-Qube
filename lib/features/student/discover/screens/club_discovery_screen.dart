import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:c_qube/core/constants/app_colors.dart';
import 'package:c_qube/core/constants/app_constants.dart';
import 'package:c_qube/shared/widgets/club_card.dart';
import 'package:c_qube/shared/widgets/custom_text_field.dart';
import 'package:c_qube/shared/widgets/tag_chip.dart';
import 'package:c_qube/shared/widgets/empty_state_view.dart';
import 'package:c_qube/state/auth_state.dart';
import 'package:c_qube/state/student_state.dart';
import 'club_public_profile_screen.dart';

class ClubDiscoveryScreen extends StatefulWidget {
  const ClubDiscoveryScreen({super.key});

  @override
  State<ClubDiscoveryScreen> createState() => _ClubDiscoveryScreenState();
}

class _ClubDiscoveryScreenState extends State<ClubDiscoveryScreen> {
  final _searchController = TextEditingController();
  ClubCategory? _selectedCategory;


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentState = Provider.of<StudentState>(context);
    final authState = Provider.of<AuthState>(context);
    final student = authState.currentStudent;

    final filteredClubs = studentState.allClubs.where((club) {
      if (_searchController.text.trim().isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        final matchName = club.name.toLowerCase().contains(query);
        final matchDesc = club.about.toLowerCase().contains(query);
        if (!matchName && !matchDesc) return false;
      }
      if (_selectedCategory != null && club.category != _selectedCategory) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Clubs & Societies'),
      ),
      body: Column(
        children: [
          // Search & Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  hintText: 'Search by club name or keyword...',
                  controller: _searchController,
                  prefixIcon: Icons.search_rounded,
                  onChanged: (v) => setState(() {}),
                ),
                const SizedBox(height: 12),

                // Horizontal Category Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      TagChip(
                        label: 'ALL CLUBS',
                        isSelected: _selectedCategory == null,
                        color: AppColors.primary,
                        onTap: () => setState(() => _selectedCategory = null),
                      ),
                      const SizedBox(width: 8),
                      ...ClubCategory.values.map(
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
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Club Grid / List
          Expanded(
            child: filteredClubs.isEmpty
                ? const EmptyStateView(
                    icon: Icons.search_off_rounded,
                    title: 'No Clubs Found',
                    description: 'Try adjusting your search keyword or clearing selected categories.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredClubs.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final club = filteredClubs[index];
                      final isJoined = student?.joinedClubIds.contains(club.id) ?? false;

                      return ClubCard(
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
                        onJoinToggle: () {
                          if (student != null) {
                            studentState.toggleJoinClub(club.id, student);
                          }
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
