import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:c_qube/core/constants/app_colors.dart';
import 'package:c_qube/core/constants/app_typography.dart';
import 'package:c_qube/shared/widgets/tag_chip.dart';
import 'package:c_qube/state/auth_state.dart';
import 'package:c_qube/state/club_state.dart';
import 'package:c_qube/features/club/dashboard/widgets/club_drawer.dart';
import 'package:c_qube/features/club/activity/screens/club_activity_tab.dart';
import 'package:c_qube/features/club/gallery/screens/club_gallery_screen.dart';
import 'package:c_qube/features/club/profile/screens/edit_club_profile_screen.dart';
import 'package:c_qube/features/student/calendar/screens/student_calendar_screen.dart';

class ClubDashboardScreen extends StatefulWidget {
  const ClubDashboardScreen({super.key});

  @override
  State<ClubDashboardScreen> createState() => _ClubDashboardScreenState();
}

class _ClubDashboardScreenState extends State<ClubDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
    final authState = Provider.of<AuthState>(context);
    final clubState = Provider.of<ClubState>(context);
    final club = authState.currentClub ?? clubState.currentClub;

    if (club == null) {
      return const Scaffold(
        body: Center(child: Text('No active club session')),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: ClubDrawer(
        club: club,
        onDashboardSelected: () {
          _tabController.animateTo(0);
        },
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundImage: NetworkImage(
                club.logoUrl.isNotEmpty
                    ? club.logoUrl
                    : 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?auto=format&fit=crop&w=200&q=80',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                club.name,
                style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            tooltip: 'Global Campus Calendar',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StudentCalendarScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Club Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditClubProfileScreen(club: club)),
              );
            },
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Large Club Banner with Edit Button Overlay
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AspectRatio(
                          aspectRatio: 16 / 7,
                          child: Image.network(
                            club.bannerUrl.isNotEmpty
                                ? club.bannerUrl
                                : 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&w=1200&q=80',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => EditClubProfileScreen(club: club)),
                            );
                          },
                          icon: const Icon(Icons.edit, size: 14),
                          label: const Text('Edit Banner'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black.withValues(alpha: 0.75),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            textStyle: AppTypography.labelSmall,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Club Info Summary Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            TagChip(
                              label: club.category.name.toUpperCase(),
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: 8),
                            TagChip(
                              label: '${club.memberCount} Members',
                              color: AppColors.primaryLight,
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => EditClubProfileScreen(club: club)),
                                );
                              },
                              tooltip: 'Edit About',
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'About ${club.name}',
                          style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          club.about,
                          style: AppTypography.bodyMedium.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _DashboardTabBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.secondary,
                labelColor: isDark ? Colors.white : AppColors.secondary,
                unselectedLabelColor: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                tabs: const [
                  Tab(icon: Icon(Icons.article_outlined), text: 'Activity & Feed'),
                  Tab(icon: Icon(Icons.photo_library_outlined), text: 'Gallery & Media'),
                ],
              ),
              isDark: isDark,
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            const ClubActivityTab(),
            const ClubGalleryScreen(),
          ],
        ),
      ),
    );
  }
}

class _DashboardTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final bool isDark;

  _DashboardTabBarDelegate(this._tabBar, {required this.isDark});

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: isDark ? AppColors.darkBg : AppColors.lightBg,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_DashboardTabBarDelegate oldDelegate) => false;
}
