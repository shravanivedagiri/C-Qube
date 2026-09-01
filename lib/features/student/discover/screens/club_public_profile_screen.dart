import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:c_qube/core/constants/app_colors.dart';
import 'package:c_qube/core/constants/app_constants.dart';
import 'package:c_qube/core/constants/app_typography.dart';
import 'package:c_qube/core/utils/date_formatter.dart';
import 'package:c_qube/models/club_model.dart';
import 'package:c_qube/models/club_join_request_model.dart';
import 'package:c_qube/models/notification_model.dart';
import 'package:c_qube/models/post_model.dart';
import 'package:c_qube/models/recruitment_model.dart';
import 'package:c_qube/repositories/recruitment_repository.dart';
import 'package:c_qube/shared/widgets/tag_chip.dart';
import 'package:c_qube/shared/widgets/event_card.dart';
import 'package:c_qube/shared/widgets/empty_state_view.dart';
import 'package:c_qube/shared/widgets/custom_button.dart';
import 'package:c_qube/state/auth_state.dart';
import 'package:c_qube/state/student_state.dart';
import 'package:c_qube/services/mock_data_store.dart';
import 'package:c_qube/features/student/events/screens/event_detail_screen.dart';

class ClubPublicProfileScreen extends StatefulWidget {
  final ClubModel club;

  const ClubPublicProfileScreen({super.key, required this.club});

  @override
  State<ClubPublicProfileScreen> createState() => _ClubPublicProfileScreenState();
}

class _ClubPublicProfileScreenState extends State<ClubPublicProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ClubModel _club;

  @override
  void initState() {
    super.initState();
    _club = widget.club;
    _tabController = TabController(length: 4, vsync: this);
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
    final studentState = Provider.of<StudentState>(context);
    final student = authState.currentStudent;
    final isMember = student?.joinedClubIds.contains(_club.id) ?? false;
    final isFollowing = _club.followerStudentIds.contains(student?.id ?? '');

    final store = MockDataStore();
    final clubPosts = store.posts.where((p) => p.clubId == _club.id).toList();
    final clubDrives = store.recruitmentDrives.where((d) => d.clubId == _club.id).toList();
    final clubGallery = store.galleryItems.where((g) => g.clubId == _club.id).toList();
    final clubEvents = store.events.where((e) => e.clubId == _club.id).toList();

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                _club.bannerUrl.isNotEmpty
                    ? _club.bannerUrl
                    : 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&w=1200&q=80',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? AppColors.darkBg : AppColors.lightBg,
                            width: 3,
                          ),
                          image: DecorationImage(
                            image: NetworkImage(
                              _club.logoUrl.isNotEmpty
                                  ? _club.logoUrl
                                  : 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?auto=format&fit=crop&w=200&q=80',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const Spacer(),
                      OutlinedButton(
                        onPressed: () {
                          if (student != null) {
                            studentState.toggleFollowClub(_club.id, student.id);
                            setState(() {});
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(isFollowing ? 'Following' : '+ Follow'),
                      ),
                      const SizedBox(width: 8),
                      Builder(
                        builder: (context) {
                          if (isMember) {
                            return const TagChip(
                              label: 'Member ✓',
                              color: AppColors.success,
                            );
                          }
                          final hasClaim = store.clubJoinRequests.any(
                            (r) => r.clubId == _club.id && r.studentId == (student?.id ?? '') && r.status == ClubJoinRequestStatus.pending,
                          );
                          if (hasClaim) {
                            return const TagChip(
                              label: 'Claim Pending ⏳',
                              color: AppColors.warning,
                            );
                          }
                          return ElevatedButton.icon(
                            onPressed: () {
                              if (student == null) return;
                              final claim = ClubJoinRequest(
                                id: 'req_${DateTime.now().millisecondsSinceEpoch}',
                                clubId: _club.id,
                                clubName: _club.name,
                                studentId: student.id,
                                studentName: student.name,
                                studentEmail: student.email,
                                studentDepartment: student.department,
                                status: ClubJoinRequestStatus.pending,
                              );
                              store.clubJoinRequests.add(claim);
                              store.notifications.insert(0, NotificationModel(
                                id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
                                userId: _club.id,
                                type: NotificationType.club,
                                title: 'New Membership Claim',
                                body: '${student.name} claimed membership in ${_club.name}.',
                                referenceId: claim.id,
                                createdAt: DateTime.now(),
                              ));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Membership claim sent to Club Head for approval!'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                              setState(() {});
                            },
                            icon: const Icon(Icons.verified_user_outlined, size: 14),
                            label: const Text('Claim Membership'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              textStyle: AppTypography.labelSmall,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _club.name,
                          style: AppTypography.displaySmall.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                      ),
                      const Icon(Icons.verified, color: AppColors.primaryLight, size: 20),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _club.department,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      TagChip(
                        label: _club.category.name.toUpperCase(),
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 8),
                      TagChip(
                        label: '${_club.memberCount} Members',
                        color: AppColors.primaryLight,
                      ),
                      const SizedBox(width: 8),
                      if (_club.isBeginnerFriendly)
                        const TagChip(
                          label: 'Beginner Friendly',
                          color: AppColors.success,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(
                    _club.about,
                    style: AppTypography.bodyLarge.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_club.contactInfo.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _club.contactInfo,
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary,
                labelColor: isDark ? Colors.white : AppColors.primary,
                unselectedLabelColor: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                tabs: const [
                  Tab(text: 'Activity'),
                  Tab(text: 'Recruitment'),
                  Tab(text: 'Events'),
                  Tab(text: 'Gallery'),
                ],
              ),
              isDark: isDark,
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            clubPosts.isEmpty
                ? const EmptyStateView(
                    icon: Icons.article_outlined,
                    title: 'No Club Activity Yet',
                    description: 'This club has not posted any announcements recently.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: clubPosts.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final post = clubPosts[index];
                      return _buildPostCard(post, isDark, student?.id ?? '');
                    },
                  ),

            // Tab 2: Recruitment Drives
            clubDrives.isEmpty
                ? const EmptyStateView(
                    icon: Icons.campaign_outlined,
                    title: 'No Open Recruitment Drives',
                    description: 'This club does not currently have active recruitment drives.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: clubDrives.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final drive = clubDrives[index];
                      final hasApplied = store.recruitmentApplications.any(
                        (a) => a.recruitmentId == drive.id && a.studentId == (student?.id ?? ''),
                      );

                      return Container(
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
                                  label: drive.isOpen ? 'OPEN DRIVE' : 'CLOSED',
                                  color: drive.isOpen ? AppColors.success : AppColors.error,
                                ),
                                const Spacer(),
                                Text(
                                  'Deadline: ${DateFormatter.formatShortDate(drive.deadline)}',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              drive.title,
                              style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              drive.description,
                              style: AppTypography.bodyMedium.copyWith(
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: drive.openPositions
                                  .map((pos) => TagChip(label: pos, color: AppColors.secondary))
                                  .toList(),
                            ),
                            const SizedBox(height: 16),
                            CustomButton(
                              text: hasApplied
                                  ? 'Application Submitted ✓'
                                  : (drive.isOpen ? 'Apply for Recruitment Drive' : 'Drive Closed'),
                              variant: hasApplied ? ButtonVariant.success : ButtonVariant.primary,
                              onPressed: (hasApplied || !drive.isOpen || student == null)
                                  ? null
                                  : () {
                                      _showApplyModal(context, drive, student);
                                    },
                            ),
                          ],
                        ),
                      );
                    },
                  ),

            clubEvents.isEmpty
                ? const EmptyStateView(
                    icon: Icons.event_busy_outlined,
                    title: 'No Events Hosted Yet',
                    description: 'Check back soon for new workshops and competitions.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: clubEvents.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final event = clubEvents[index];
                      final isReg = event.isRegisteredBy(student?.id ?? '');
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
                          if (student != null) {
                            studentState.toggleEventRegistration(event.id, student.id);
                            setState(() {});
                          }
                        },
                      );
                    },
                  ),

            clubGallery.isEmpty
                ? const EmptyStateView(
                    icon: Icons.photo_library_outlined,
                    title: 'No Gallery Media Yet',
                    description: 'Photos and event recordings will appear here.',
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemCount: clubGallery.length,
                    itemBuilder: (context, index) {
                      final item = clubGallery[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              item.mediaUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: isDark ? AppColors.darkSurface : Colors.grey.shade200,
                                child: const Icon(Icons.image_outlined, color: AppColors.primary),
                              ),
                            ),
                            if (item.mediaType == MediaType.video)
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(PostModel post, bool isDark, String studentId) {
    return Container(
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
                label: post.type.name.toUpperCase(),
                color: AppColors.primaryLight,
              ),
              const Spacer(),
              Text(
                DateFormatter.formatRelative(post.createdAt),
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            post.title,
            style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            post.content,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              height: 1.45,
            ),
          ),
          if (post.imageUrl.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                post.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  child: const Icon(Icons.image_outlined, color: AppColors.primary),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showApplyModal(BuildContext context, RecruitmentDrive drive, dynamic student) {
    String selectedPosition = drive.openPositions.isNotEmpty ? drive.openPositions.first : 'Member';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        final isDarkModal = Theme.of(modalContext).brightness == Brightness.dark;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: isDarkModal ? AppColors.darkSurface : AppColors.lightBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Apply — ${drive.title}',
                            style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(modalContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Text('Select Position', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: selectedPosition,
                      items: drive.openPositions
                          .map((pos) => DropdownMenuItem(value: pos, child: Text(pos)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setModalState(() => selectedPosition = v);
                      },
                    ),
                    const SizedBox(height: 24),

                    CustomButton(
                      text: 'Submit Application',
                      variant: ButtonVariant.primary,
                      onPressed: () async {
                        final repo = MockRecruitmentRepository();
                        await repo.submitApplication(
                          RecruitmentApplication(
                            id: 'app_${DateTime.now().millisecondsSinceEpoch}',
                            recruitmentId: drive.id,
                            recruitmentTitle: drive.title,
                            clubId: drive.clubId,
                            clubName: drive.clubName,
                            studentId: student.id,
                            studentName: student.name,
                            studentEmail: student.email,
                            studentDepartment: student.department,
                            studentYear: student.year,
                            positionApplied: selectedPosition,
                          ),
                        );

                        if (context.mounted) {
                          Navigator.pop(modalContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Application submitted! Club coordinators will review your application.'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                          setState(() {});
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final bool isDark;

  _SliverTabBarDelegate(this._tabBar, {required this.isDark});

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
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}
