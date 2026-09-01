import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:c_qube/core/constants/app_colors.dart';
import 'package:c_qube/core/constants/app_constants.dart';
import 'package:c_qube/core/constants/app_typography.dart';
import 'package:c_qube/models/user_model.dart';
import 'package:c_qube/models/club_model.dart';
import 'package:c_qube/models/club_join_request_model.dart';
import 'package:c_qube/shared/widgets/custom_button.dart';
import 'package:c_qube/shared/widgets/custom_text_field.dart';
import 'package:c_qube/shared/widgets/tag_chip.dart';
import 'package:c_qube/state/auth_state.dart';
import 'package:c_qube/state/student_state.dart';

class EditStudentProfileScreen extends StatefulWidget {
  final UserModel student;

  const EditStudentProfileScreen({super.key, required this.student});

  @override
  State<EditStudentProfileScreen> createState() => _EditStudentProfileScreenState();
}

class _EditStudentProfileScreenState extends State<EditStudentProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _goalsController;

  late String _avatarUrl;
  late List<String> _selectedInterests;
  late List<String> _selectedSkills;
  late bool _showJoinedClubs;
  late bool _showRegisteredEvents;
  late bool _showPoints;

  @override
  void initState() {
    super.initState();
    _avatarUrl = widget.student.avatarUrl;
    _nameController = TextEditingController(text: widget.student.name);
    _bioController = TextEditingController(text: widget.student.bio);
    _goalsController = TextEditingController(text: widget.student.goals);
    _selectedInterests = List<String>.from(widget.student.interests);
    _selectedSkills = List<String>.from(widget.student.skills);
    _showJoinedClubs = widget.student.privacySettings.showJoinedClubs;
    _showRegisteredEvents = widget.student.privacySettings.showRegisteredEvents;
    _showPoints = widget.student.privacySettings.showPoints;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final studentState = Provider.of<StudentState>(context, listen: false);
      studentState.loadMyJoinRequests(widget.student.id);
      studentState.refreshClubs(widget.student);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _goalsController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    final authState = Provider.of<AuthState>(context, listen: false);
    final updated = widget.student.copyWith(
      name: _nameController.text.trim(),
      avatarUrl: _avatarUrl,
      bio: _bioController.text.trim(),
      goals: _goalsController.text.trim(),
      interests: _selectedInterests,
      skills: _selectedSkills,
      privacySettings: StudentPrivacySettings(
        showJoinedClubs: _showJoinedClubs,
        showRegisteredEvents: _showRegisteredEvents,
        showPoints: _showPoints,
      ),
    );

    authState.updateCurrentStudent(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: AppColors.success),
    );
    Navigator.pop(context);
  }

  void _showAvatarPickerModal() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final urlController = TextEditingController(text: _avatarUrl);

    final presetAvatars = [
      'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=400&q=80',
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=400&q=80',
      'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=400&q=80',
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80',
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=400&q=80',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Change Profile Picture',
                style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a picture from presets or paste an image URL:',
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 70,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: presetAvatars.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    final avatar = presetAvatars[i];
                    final isSelected = _avatarUrl == avatar;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _avatarUrl = avatar);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(avatar),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Image URL / Device Photo Path',
                hintText: 'https://example.com/photo.jpg',
                controller: urlController,
                prefixIcon: Icons.link_rounded,
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Select & Update Avatar',
                onPressed: () {
                  final text = urlController.text.trim();
                  if (text.isNotEmpty) {
                    setState(() => _avatarUrl = text);
                  }
                  Navigator.pop(ctx);
                },
                variant: ButtonVariant.primary,
              ),
              // Supabase Storage Upload Placeholder Interface:
              // await supabase.storage.from('avatars').upload('student_${student.id}.png', imageFile);
            ],
          ),
        );
      },
    );
  }

  void _showJoinClubModal(StudentState studentState) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final availableClubs = studentState.allClubs.where((club) {
      final isMember = widget.student.joinedClubIds.contains(club.id);
      final hasPendingReq = studentState.myJoinRequests.any(
        (r) => r.clubId == club.id && r.status == ClubJoinRequestStatus.pending,
      );
      return !isMember && !hasPendingReq;
    }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Request to Join Club',
                style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Submitting a join request requires review & approval from the club coordinator before membership is granted.',
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: availableClubs.isEmpty
                    ? const Center(
                        child: Text('No available clubs to request join.'),
                      )
                    : ListView.builder(
                        itemCount: availableClubs.length,
                        itemBuilder: (context, index) {
                          final club = availableClubs[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            elevation: 0,
                            color: isDark ? AppColors.darkCard : AppColors.lightCard,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: club.logoUrl.isNotEmpty ? NetworkImage(club.logoUrl) : null,
                                child: club.logoUrl.isEmpty ? Text(club.name[0]) : null,
                              ),
                              title: Text(club.name, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700)),
                              subtitle: Text(club.department, style: AppTypography.bodySmall),
                              trailing: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () async {
                                  Navigator.pop(ctx);
                                  await studentState.submitClubJoinRequest(
                                    clubId: club.id,
                                    clubName: club.name,
                                    student: widget.student,
                                  );
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Join request submitted to ${club.name} coordinator.'),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                  }
                                },
                                child: const Text('Request'),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final studentState = Provider.of<StudentState>(context);
    final myRequests = studentState.myJoinRequests;
    final joinedClubs = studentState.allClubs
        .where((c) => widget.student.joinedClubIds.contains(c.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Student Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar with Edit Button
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundImage: _avatarUrl.isNotEmpty ? NetworkImage(_avatarUrl) : null,
                          child: _avatarUrl.isEmpty
                              ? Text(
                                  widget.student.name.isNotEmpty ? widget.student.name[0] : 'S',
                                  style: AppTypography.displaySmall.copyWith(color: AppColors.primary),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _showAvatarPickerModal,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _showAvatarPickerModal,
                      icon: const Icon(Icons.photo_library_outlined, size: 16),
                      label: const Text('Change Profile Picture'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              CustomTextField(
                label: 'Full Name',
                hintText: 'Your full name',
                controller: _nameController,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Bio',
                hintText: 'Short description about yourself',
                controller: _bioController,
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Campus Goals',
                hintText: 'What are your goals this academic year?',
                controller: _goalsController,
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // Club Membership & Approval Join Request Section
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Club Memberships',
                          style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showJoinClubModal(studentState),
                          icon: const Icon(Icons.add_rounded, size: 16),
                          label: const Text('Request to Join Club'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            textStyle: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (joinedClubs.isNotEmpty) ...[
                      Text('Approved Joined Clubs:', style: AppTypography.labelSmall.copyWith(color: AppColors.primaryLight)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: joinedClubs.map((club) {
                          return Chip(
                            avatar: CircleAvatar(
                              backgroundImage: club.logoUrl.isNotEmpty ? NetworkImage(club.logoUrl) : null,
                              child: club.logoUrl.isEmpty ? Text(club.name[0]) : null,
                            ),
                            label: Text(club.name, style: AppTypography.bodySmall),
                            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                    ],

                    if (myRequests.isNotEmpty) ...[
                      Text('Submitted Join Requests:', style: AppTypography.labelSmall.copyWith(color: AppColors.secondary)),
                      const SizedBox(height: 6),
                      Column(
                        children: myRequests.map((req) {
                          Color badgeColor;
                          String badgeText;
                          switch (req.status) {
                            case ClubJoinRequestStatus.approved:
                              badgeColor = AppColors.success;
                              badgeText = 'Approved';
                              break;
                            case ClubJoinRequestStatus.rejected:
                              badgeColor = AppColors.error;
                              badgeText = 'Rejected';
                              break;
                            case ClubJoinRequestStatus.pending:
                            default:
                              badgeColor = AppColors.warning;
                              badgeText = 'Pending Approval';
                              break;
                          }
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Icon(Icons.shield_outlined, size: 16, color: badgeColor),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(req.clubName, style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: badgeColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    badgeText,
                                    style: AppTypography.labelSmall.copyWith(color: badgeColor, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    if (joinedClubs.isEmpty && myRequests.isEmpty)
                      Text(
                        'No club memberships yet. Tap "Request to Join Club" to apply.',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Interests
              Text('Your Interests', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.allInterests.map((interest) {
                  final isSelected = _selectedInterests.contains(interest);
                  return TagChip(
                    label: interest,
                    isSelected: isSelected,
                    color: AppColors.primary,
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedInterests.remove(interest);
                        } else {
                          _selectedInterests.add(interest);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Skills
              Text('Your Skills', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.allSkills.map((skill) {
                  final isSelected = _selectedSkills.contains(skill);
                  return TagChip(
                    label: skill,
                    isSelected: isSelected,
                    color: AppColors.secondary,
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedSkills.remove(skill);
                        } else {
                          _selectedSkills.add(skill);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // Privacy Settings Group
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Friend Privacy Settings',
                      style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Show Joined Clubs to Friends'),
                      value: _showJoinedClubs,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (v) => setState(() => _showJoinedClubs = v),
                    ),
                    SwitchListTile(
                      title: const Text('Show Registered Events to Friends'),
                      value: _showRegisteredEvents,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (v) => setState(() => _showRegisteredEvents = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              CustomButton(
                text: 'Save Profile Changes',
                onPressed: _handleSave,
                variant: ButtonVariant.primary,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
