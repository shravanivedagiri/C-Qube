import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:c_qube/core/constants/app_colors.dart';
import 'package:c_qube/core/constants/app_constants.dart';
import 'package:c_qube/core/constants/app_typography.dart';
import 'package:c_qube/models/user_model.dart';
import 'package:c_qube/shared/widgets/custom_button.dart';
import 'package:c_qube/shared/widgets/custom_text_field.dart';
import 'package:c_qube/shared/widgets/tag_chip.dart';
import 'package:c_qube/state/auth_state.dart';

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

  late List<String> _selectedInterests;
  late List<String> _selectedSkills;
  late bool _showJoinedClubs;
  late bool _showRegisteredEvents;
  late bool _showPoints;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student.name);
    _bioController = TextEditingController(text: widget.student.bio);
    _goalsController = TextEditingController(text: widget.student.goals);
    _selectedInterests = List<String>.from(widget.student.interests);
    _selectedSkills = List<String>.from(widget.student.skills);
    _showJoinedClubs = widget.student.privacySettings.showJoinedClubs;
    _showRegisteredEvents = widget.student.privacySettings.showRegisteredEvents;
    _showPoints = widget.student.privacySettings.showPoints;
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              // Avatar
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundImage: widget.student.avatarUrl.isNotEmpty
                          ? NetworkImage(widget.student.avatarUrl)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                      ),
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
                    SwitchListTile(
                      title: const Text('Show Campus Points & Achievements'),
                      value: _showPoints,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (v) => setState(() => _showPoints = v),
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
