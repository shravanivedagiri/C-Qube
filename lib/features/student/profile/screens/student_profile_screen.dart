import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:c_qube/core/constants/app_colors.dart';
import 'package:c_qube/core/constants/app_typography.dart';
import 'package:c_qube/core/theme/theme_provider.dart';
import 'package:c_qube/shared/widgets/tag_chip.dart';
import 'package:c_qube/shared/widgets/custom_button.dart';
import 'package:c_qube/state/auth_state.dart';
import 'package:c_qube/state/student_state.dart';
import 'package:c_qube/features/welcome/screens/role_selection_screen.dart';
import 'edit_student_profile_screen.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authState = Provider.of<AuthState>(context);
    final studentState = Provider.of<StudentState>(context);
    final student = authState.currentStudent;

    if (student == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Campus Profile'),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: 'Toggle Dark Mode',
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditStudentProfileScreen(student: student),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Profile Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [AppColors.darkCard, AppColors.darkSurface]
                      : [AppColors.primary.withValues(alpha: 0.08), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundImage: student.avatarUrl.isNotEmpty
                            ? NetworkImage(student.avatarUrl)
                            : null,
                        child: student.avatarUrl.isEmpty
                            ? Text(
                                student.name[0],
                                style: AppTypography.displaySmall.copyWith(color: AppColors.primary),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.name,
                              style: AppTypography.headlineMedium.copyWith(
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              student.email,
                              style: AppTypography.bodySmall.copyWith(
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${student.department} • ${student.year}',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.primaryLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Stats Summary Cards
            Row(
              children: [
                _buildStatBox('Clubs Joined', '${student.joinedClubIds.length}', Icons.groups_rounded, AppColors.primary, isDark),
                const SizedBox(width: 12),
                _buildStatBox('Events Registered', '${studentState.myRegisteredEvents.length}', Icons.event_available_rounded, AppColors.secondary, isDark),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatBox('Campus Friends', '${studentState.friends.length}', Icons.people_alt_rounded, AppColors.success, isDark),
              ],
            ),
            const SizedBox(height: 24),

            // Official Approved Joined Clubs Section
            if (student.joinedClubIds.isNotEmpty) ...[
              Text('Joined Campus Clubs', style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: studentState.allClubs
                    .where((c) => student.joinedClubIds.contains(c.id))
                    .map((club) => Chip(
                          avatar: CircleAvatar(
                            backgroundImage: club.logoUrl.isNotEmpty ? NetworkImage(club.logoUrl) : null,
                            child: club.logoUrl.isEmpty ? Text(club.name[0]) : null,
                          ),
                          label: Text(club.name, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),
            ],

            // Bio & Goals
            if (student.bio.isNotEmpty) ...[
              Text('About Me', style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(
                student.bio,
                style: AppTypography.bodyLarge.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
            ],

            if (student.goals.isNotEmpty) ...[
              Text('Campus Goals', style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(
                student.goals,
                style: AppTypography.bodyLarge.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Interests
            Text('Interests', style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: student.interests.map((i) => TagChip(label: i, color: AppColors.primary)).toList(),
            ),
            const SizedBox(height: 20),

            // Skills
            Text('Skills & Strengths', style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: student.skills.map((s) => TagChip(label: s, color: AppColors.secondary)).toList(),
            ),
            const SizedBox(height: 28),

            // Logout Button
            CustomButton(
              text: 'Log Out of C-QUBE',
              variant: ButtonVariant.danger,
              icon: Icons.logout_rounded,
              onPressed: () async {
                await authState.logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                    (route) => false,
                  );
                }
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    label,
                    style: AppTypography.labelSmall.copyWith(
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
