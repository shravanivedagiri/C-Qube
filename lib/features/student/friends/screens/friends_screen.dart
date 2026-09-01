import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:c_qube/core/constants/app_colors.dart';
import 'package:c_qube/core/constants/app_typography.dart';
import 'package:c_qube/shared/widgets/custom_text_field.dart';
import 'package:c_qube/shared/widgets/empty_state_view.dart';
import 'package:c_qube/state/auth_state.dart';
import 'package:c_qube/state/student_state.dart';
import 'friend_profile_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final studentState = Provider.of<StudentState>(context);
    final authState = Provider.of<AuthState>(context);
    final currentStudent = authState.currentStudent;

    final myFriends = studentState.friends;
    final pendingRequests = studentState.pendingRequests;
    final campusStudents = studentState.allStudents
        .where((s) => s.id != currentStudent?.id)
        .where((s) {
      if (_searchController.text.trim().isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        final matchName = s.name.toLowerCase().contains(query);
        final matchDept = s.department.toLowerCase().contains(query);
        return matchName || matchDept;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Friends & Network'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: isDark ? Colors.white : AppColors.primary,
          unselectedLabelColor: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
          tabs: [
            Tab(text: 'My Friends (${myFriends.length})'),
            Tab(text: 'Find Students (${campusStudents.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: My Friends & Incoming Requests
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (pendingRequests.isNotEmpty) ...[
                  Text(
                    'Pending Requests (${pendingRequests.length})',
                    style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: pendingRequests.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final req = pendingRequests[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: req.avatarUrl.isNotEmpty ? NetworkImage(req.avatarUrl) : null,
                              child: req.avatarUrl.isEmpty ? Text(req.name[0]) : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(req.name, style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700)),
                                  Text('${req.department} • ${req.year}', style: AppTypography.labelSmall),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.check_circle_rounded, color: AppColors.success),
                              onPressed: () {
                                if (currentStudent != null) {
                                  studentState.acceptFriendRequest(req.id, currentStudent.id);
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel_rounded, color: AppColors.error),
                              onPressed: () {
                                if (currentStudent != null) {
                                  studentState.rejectFriendRequest(req.id, currentStudent.id);
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],

                Text(
                  'Connected Friends',
                  style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                myFriends.isEmpty
                    ? const EmptyStateView(
                        icon: Icons.people_outline_rounded,
                        title: 'No Connected Friends Yet',
                        description: 'Use the "Find Students" tab to connect with peers in your department.',
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: myFriends.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final friend = myFriends[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            tileColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            ),
                            leading: CircleAvatar(
                              radius: 22,
                              backgroundImage: friend.avatarUrl.isNotEmpty ? NetworkImage(friend.avatarUrl) : null,
                              child: friend.avatarUrl.isEmpty ? Text(friend.name[0]) : null,
                            ),
                            title: Text(friend.name, style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700)),
                            subtitle: Text('${friend.department} • ${friend.points} pts'),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => FriendProfileScreen(student: friend)),
                              );
                            },
                          );
                        },
                      ),
              ],
            ),
          ),

          // Tab 2: Find & Connect with Campus Students
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: CustomTextField(
                  hintText: 'Search by student name or branch...',
                  controller: _searchController,
                  prefixIcon: Icons.search_rounded,
                  onChanged: (v) => setState(() {}),
                ),
              ),
              Expanded(
                child: campusStudents.isEmpty
                    ? const EmptyStateView(
                        icon: Icons.person_search_outlined,
                        title: 'No Students Found',
                        description: 'Try typing a different name or department keyword.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: campusStudents.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final student = campusStudents[index];
                          final isAlreadyFriend = myFriends.any((f) => f.id == student.id);
                          final isPending = studentState.hasPendingRequestWith(student.id);

                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCard : AppColors.lightCard,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundImage: student.avatarUrl.isNotEmpty ? NetworkImage(student.avatarUrl) : null,
                                  child: student.avatarUrl.isEmpty ? Text(student.name[0]) : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(student.name, style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700)),
                                      Text('${student.department} • ${student.year}', style: AppTypography.labelSmall),
                                    ],
                                  ),
                                ),
                                if (isAlreadyFriend)
                                  Chip(
                                    label: const Text('Friend ✓'),
                                    backgroundColor: AppColors.success.withValues(alpha: 0.15),
                                    labelStyle: AppTypography.labelSmall.copyWith(color: AppColors.success),
                                  )
                                else if (isPending)
                                  Chip(
                                    label: const Text('Requested'),
                                    backgroundColor: AppColors.warning.withValues(alpha: 0.15),
                                    labelStyle: AppTypography.labelSmall.copyWith(color: AppColors.warning),
                                  )
                                else
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      if (currentStudent != null) {
                                        studentState.sendFriendRequest(currentStudent.id, student.id);
                                      }
                                    },
                                    icon: const Icon(Icons.person_add_rounded, size: 14),
                                    label: const Text('Add'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      textStyle: AppTypography.labelSmall,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
