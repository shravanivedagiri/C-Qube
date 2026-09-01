import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:c_qube/core/constants/app_colors.dart';
import 'package:c_qube/core/constants/app_typography.dart';
import 'package:c_qube/models/user_model.dart';
import 'package:c_qube/shared/widgets/tag_chip.dart';
import 'package:c_qube/shared/widgets/custom_button.dart';
import 'package:c_qube/state/auth_state.dart';
import 'package:c_qube/state/student_state.dart';
import 'package:c_qube/services/mock_data_store.dart';

class FriendProfileScreen extends StatefulWidget {
  final UserModel student;

  const FriendProfileScreen({super.key, required this.student});

  @override
  State<FriendProfileScreen> createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends State<FriendProfileScreen> {
  late UserModel _student;
  String _friendshipStatus = 'none';

  @override
  void initState() {
    super.initState();
    _student = widget.student;
    _checkStatus();
  }

  void _checkStatus() {
    final authState = Provider.of<AuthState>(context, listen: false);
    final myId = authState.currentStudent?.id ?? '';
    final isFriend = authState.currentStudent?.friendIds.contains(_student.id) ?? false;
    if (myId == _student.id) {
      _friendshipStatus = 'self';
    } else if (isFriend) {
      _friendshipStatus = 'friends';
    } else {
      _friendshipStatus = 'none';
    }
  }

  Future<void> _handleFriendAction() async {
    final authState = Provider.of<AuthState>(context, listen: false);
    final studentState = Provider.of<StudentState>(context, listen: false);
    final myId = authState.currentStudent?.id ?? '';

    if (_friendshipStatus == 'none') {
      await studentState.sendFriendRequest(myId, _student.id);
      setState(() => _friendshipStatus = 'pending');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Friend request sent to ${_student.name}!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final store = MockDataStore();
    final joinedClubs = store.clubs.where((c) => _student.joinedClubIds.contains(c.id)).toList();
    final registeredEvents = store.events.where((e) => _student.registeredEventIds.contains(e.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_student.name),
        actions: [
          if (_friendshipStatus != 'self')
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: CustomButton(
                  height: 36,
                  text: _friendshipStatus == 'friends'
                      ? 'Friends ✓'
                      : _friendshipStatus == 'pending'
                          ? 'Request Sent'
                          : 'Add Friend',
                  variant: _friendshipStatus == 'friends'
                      ? ButtonVariant.success
                      : _friendshipStatus == 'pending'
                          ? ButtonVariant.secondary
                          : ButtonVariant.primary,
                  onPressed: _friendshipStatus == 'none' ? _handleFriendAction : null,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar, Name, Dept
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  backgroundImage: _student.avatarUrl.isNotEmpty
                      ? NetworkImage(_student.avatarUrl)
                      : null,
                  child: _student.avatarUrl.isEmpty
                      ? Text(
                          _student.name.isNotEmpty ? _student.name[0] : 'S',
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
                        _student.name,
                        style: AppTypography.headlineMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_student.department} • ${_student.year}',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_student.privacySettings.showPoints)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.stars_rounded, size: 14, color: AppColors.warning),
                              const SizedBox(width: 4),
                              Text(
                                '${_student.points} Campus Points',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Bio
            if (_student.bio.isNotEmpty) ...[
              Text(
                'About',
                style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                _student.bio,
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Interests
            if (_student.interests.isNotEmpty) ...[
              Text(
                'Interests',
                style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _student.interests
                    .map((i) => TagChip(label: i, color: AppColors.primary))
                    .toList(),
              ),
              const SizedBox(height: 20),
            ],

            // Skills
            if (_student.skills.isNotEmpty) ...[
              Text(
                'Skills',
                style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _student.skills
                    .map((s) => TagChip(label: s, color: AppColors.secondary))
                    .toList(),
              ),
              const SizedBox(height: 20),
            ],

            // Joined Clubs (Privacy guarded)
            if (_student.privacySettings.showJoinedClubs && joinedClubs.isNotEmpty) ...[
              Text(
                'Joined Clubs (${joinedClubs.length})',
                style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ...joinedClubs.map(
                (c) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(c.logoUrl),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          c.name,
                          style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      TagChip(label: c.category.name.toUpperCase(), color: AppColors.primaryLight),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Registered Events (Privacy guarded)
            if (_student.privacySettings.showRegisteredEvents && registeredEvents.isNotEmpty) ...[
              Text(
                'Attending Events (${registeredEvents.length})',
                style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ...registeredEvents.map(
                (e) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_available_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.title,
                              style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              e.clubName,
                              style: AppTypography.bodySmall.copyWith(
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
