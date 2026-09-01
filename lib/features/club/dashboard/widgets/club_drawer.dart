import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:c_qube/core/constants/app_colors.dart';
import 'package:c_qube/core/constants/app_typography.dart';
import 'package:c_qube/core/theme/theme_provider.dart';
import 'package:c_qube/models/club_model.dart';
import 'package:c_qube/state/auth_state.dart';
import 'package:c_qube/features/welcome/screens/role_selection_screen.dart';
import 'package:c_qube/features/club/events/screens/club_events_screen.dart';
import 'package:c_qube/features/club/gallery/screens/club_gallery_screen.dart';
import 'package:c_qube/features/club/recruitment/screens/club_recruitment_screen.dart';
import 'package:c_qube/features/club/analytics/screens/club_analytics_screen.dart';
import 'package:c_qube/features/club/profile/screens/edit_club_profile_screen.dart';

class ClubDrawer extends StatelessWidget {
  final ClubModel club;
  final VoidCallback? onDashboardSelected;

  const ClubDrawer({
    super.key,
    required this.club,
    this.onDashboardSelected,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authState = Provider.of<AuthState>(context, listen: false);

    return Drawer(
      child: Column(
        children: [
          // Club Header
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3B50DF), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(
                club.logoUrl.isNotEmpty
                    ? club.logoUrl
                    : 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?auto=format&fit=crop&w=200&q=80',
              ),
            ),
            accountName: Text(
              club.name,
              style: AppTypography.headlineSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
            ),
            accountEmail: Text(
              club.email,
              style: AppTypography.bodySmall.copyWith(color: Colors.white70),
            ),
          ),

          // Drawer Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.dashboard_rounded, color: AppColors.secondary),
                  title: const Text('Dashboard'),
                  onTap: () {
                    Navigator.pop(context);
                    if (onDashboardSelected != null) onDashboardSelected!();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.event_note_rounded, color: AppColors.primary),
                  title: const Text('Events & Hackathons'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ClubEventsScreen()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded, color: AppColors.accent),
                  title: const Text('Gallery & Media'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ClubGalleryScreen()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.badge_rounded, color: AppColors.warning),
                  title: const Text('Recruitment Hub'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ClubRecruitmentScreen()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.insights_rounded, color: AppColors.success),
                  title: const Text('Databricks Analytics'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ClubAnalyticsScreen()));
                  },
                ),
                const Divider(),

                // Theme Toggle
                ListTile(
                  leading: Icon(
                    themeProvider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  ),
                  title: Text(themeProvider.isDarkMode ? 'Light Theme' : 'Dark Theme'),
                  onTap: () => themeProvider.toggleTheme(),
                ),

                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Edit Club Profile'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => EditClubProfileScreen(club: club)),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                  title: const Text('Logout', style: TextStyle(color: AppColors.error)),
                  onTap: () async {
                    await authState.logout();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                        (route) => false,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
