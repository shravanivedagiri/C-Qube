import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:c_qube/core/constants/app_colors.dart';
import 'package:c_qube/core/constants/app_typography.dart';
import 'package:c_qube/core/utils/validator_utils.dart';
import 'package:c_qube/models/recruitment_model.dart';
import 'package:c_qube/shared/widgets/custom_button.dart';
import 'package:c_qube/shared/widgets/custom_text_field.dart';
import 'package:c_qube/state/auth_state.dart';
import 'package:c_qube/state/club_state.dart';

class CreateRecruitmentScreen extends StatefulWidget {
  const CreateRecruitmentScreen({super.key});

  @override
  State<CreateRecruitmentScreen> createState() => _CreateRecruitmentScreenState();
}

class _CreateRecruitmentScreenState extends State<CreateRecruitmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _positionsController = TextEditingController(text: 'App Dev Lead, UI/UX Lead, PR Coordinator');
  final _eligibilityController = TextEditingController(text: 'Open to 1st, 2nd, and 3rd Year Students');
  final _skillsController = TextEditingController(text: 'Flutter, Figma, Leadership, Communication');

  DateTime _deadline = DateTime.now().add(const Duration(days: 14));
  final String _bannerUrl = 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&w=800&q=80';

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _positionsController.dispose();
    _eligibilityController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Future<void> _handlePublish() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = Provider.of<AuthState>(context, listen: false);
    final clubState = Provider.of<ClubState>(context, listen: false);
    final club = authState.currentClub;

    if (club == null) return;

    final openPositions = _positionsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final skillsRequired = _skillsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final newDrive = RecruitmentDrive(
      id: 'rec_${DateTime.now().millisecondsSinceEpoch}',
      clubId: club.id,
      clubName: club.name,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      openPositions: openPositions,
      eligibility: _eligibilityController.text.trim(),
      skillsRequired: skillsRequired,
      deadline: _deadline,
      bannerUrl: _bannerUrl,
    );

    await clubState.createRecruitmentDrive(newDrive);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Recruitment drive "${newDrive.title}" is now live!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Open Recruitment Drive'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                label: 'Drive Title',
                hintText: 'e.g. Core Team Leadership Recruitment 2026-27',
                controller: _titleController,
                validator: (v) => ValidatorUtils.validateRequired(v, 'Drive title'),
              ),
              const SizedBox(height: 18),

              CustomTextField(
                label: 'Description & Induction Process',
                hintText: 'Describe open domains, selection rounds and responsibilities...',
                controller: _descController,
                maxLines: 4,
                validator: (v) => ValidatorUtils.validateRequired(v, 'Description'),
              ),
              const SizedBox(height: 18),

              CustomTextField(
                label: 'Open Positions (comma separated)',
                hintText: 'e.g. Flutter Lead, Web Lead, Video Editor',
                controller: _positionsController,
                validator: (v) => ValidatorUtils.validateRequired(v, 'Positions'),
              ),
              const SizedBox(height: 18),

              CustomTextField(
                label: 'Eligibility Criteria',
                hintText: 'e.g. Open to 1st, 2nd, and 3rd year students from any branch',
                controller: _eligibilityController,
              ),
              const SizedBox(height: 18),

              CustomTextField(
                label: 'Skills Required (comma separated)',
                hintText: 'e.g. Flutter, React, Figma, Public Speaking',
                controller: _skillsController,
              ),
              const SizedBox(height: 18),

              // Application Deadline
              Text('Application Deadline', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _deadline,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (picked != null) setState(() => _deadline = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 18, color: AppColors.secondary),
                      const SizedBox(width: 8),
                      Text(DateFormat('MMM d, yyyy').format(_deadline), style: AppTypography.bodyMedium),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              CustomButton(
                text: 'Launch Recruitment Drive',
                onPressed: _handlePublish,
                variant: ButtonVariant.secondary,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
