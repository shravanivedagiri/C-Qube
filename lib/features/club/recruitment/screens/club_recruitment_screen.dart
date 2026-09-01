import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:c_qube/core/constants/app_colors.dart';
import 'package:c_qube/core/constants/app_constants.dart';
import 'package:c_qube/core/constants/app_typography.dart';
import 'package:c_qube/core/utils/date_formatter.dart';
import 'package:c_qube/shared/widgets/empty_state_view.dart';
import 'package:c_qube/shared/widgets/tag_chip.dart';
import 'package:c_qube/state/club_state.dart';
import 'create_recruitment_screen.dart';
import 'applicant_detail_screen.dart';

class ClubRecruitmentScreen extends StatefulWidget {
  const ClubRecruitmentScreen({super.key});

  @override
  State<ClubRecruitmentScreen> createState() => _ClubRecruitmentScreenState();
}

class _ClubRecruitmentScreenState extends State<ClubRecruitmentScreen>
    with SingleTickerProviderStateMixin {
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
    final drives = clubState.clubDrives;
    final applications = clubState.clubApplications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Club Recruitment Hub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Open Recruitment Drive',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateRecruitmentScreen()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.secondary,
          labelColor: isDark ? Colors.white : AppColors.secondary,
          unselectedLabelColor: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
          tabs: [
            Tab(text: 'Applicants (${applications.length})'),
            Tab(text: 'Drives (${drives.length})'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateRecruitmentScreen()),
          );
        },
        backgroundColor: AppColors.secondary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Open Drive', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Applicants List
          applications.isEmpty
              ? EmptyStateView(
                  icon: Icons.people_outline_rounded,
                  title: 'No Applications Received Yet',
                  description: 'When students apply for your open positions, their resumes and questionnaire responses will appear here.',
                  actionText: 'Open Recruitment Drive',
                  onAction: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateRecruitmentScreen()),
                    );
                  },
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: applications.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final app = applications[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ApplicantDetailScreen(application: app),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : AppColors.lightCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.secondary.withValues(alpha: 0.12),
                              child: Text(
                                app.studentName[0],
                                style: AppTypography.headlineSmall.copyWith(color: AppColors.secondary),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          app.studentName,
                                          style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      _buildStatusBadge(app.status),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Role: ${app.positionApplied}',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.primaryLight,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${app.studentDepartment} • ${app.studentYear}',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
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

          // Tab 2: Active Recruitment Drives
          drives.isEmpty
              ? EmptyStateView(
                  icon: Icons.campaign_outlined,
                  title: 'No Active Recruitment Drives',
                  description: 'Launch a recruitment drive to recruit coordinators and team leads for your club.',
                  actionText: 'Launch Drive',
                  onAction: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateRecruitmentScreen()),
                    );
                  },
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: drives.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final drive = drives[index];
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
                              TagChip(
                                label: drive.isOpen ? 'ACTIVE DRIVE' : 'CLOSED',
                                color: drive.isOpen ? AppColors.success : AppColors.error,
                              ),
                              const Spacer(),
                              Text(
                                'Deadline: ${DateFormatter.formatShortDate(drive.deadline)}',
                                style: AppTypography.labelSmall.copyWith(color: AppColors.secondary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(drive.title, style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          Text(drive.description, style: AppTypography.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: drive.openPositions
                                .map((pos) => TagChip(label: pos, color: AppColors.primaryLight))
                                .toList(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ApplicationStatus status) {
    Color color;
    String label;

    switch (status) {
      case ApplicationStatus.applied:
        color = AppColors.info;
        label = 'Applied';
        break;
      case ApplicationStatus.underReview:
        color = AppColors.warning;
        label = 'Under Review';
        break;
      case ApplicationStatus.shortlisted:
        color = AppColors.secondary;
        label = 'Shortlisted';
        break;
      case ApplicationStatus.selected:
        color = AppColors.success;
        label = 'Selected ✓';
        break;
      case ApplicationStatus.rejected:
        color = AppColors.error;
        label = 'Rejected';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(color: color, fontWeight: FontWeight.w700, fontSize: 10),
      ),
    );
  }
}
