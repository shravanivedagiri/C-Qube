import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:c_qube/core/constants/app_colors.dart';
import 'package:c_qube/core/constants/app_constants.dart';
import 'package:c_qube/core/constants/app_typography.dart';
import 'package:c_qube/models/recruitment_model.dart';
import 'package:c_qube/shared/widgets/tag_chip.dart';
import 'package:c_qube/shared/widgets/custom_button.dart';
import 'package:c_qube/shared/widgets/custom_text_field.dart';
import 'package:c_qube/state/club_state.dart';

class ApplicantDetailScreen extends StatefulWidget {
  final RecruitmentApplication application;

  const ApplicantDetailScreen({super.key, required this.application});

  @override
  State<ApplicantDetailScreen> createState() => _ApplicantDetailScreenState();
}

class _ApplicantDetailScreenState extends State<ApplicantDetailScreen> {
  late ApplicationStatus _status;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _status = widget.application.status;
    _notesController = TextEditingController(text: widget.application.notes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveStatus() async {
    final clubState = Provider.of<ClubState>(context, listen: false);
    await clubState.updateApplicationStatus(
      widget.application.id,
      _status,
      notes: _notesController.text.trim(),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Applicant status and evaluation notes updated!'),
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
        title: Text('${widget.application.studentName} — Review'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Applicant Header Card
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
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                        child: Text(
                          widget.application.studentName[0],
                          style: AppTypography.headlineSmall.copyWith(color: AppColors.secondary),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.application.studentName,
                              style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w800),
                            ),
                            Text(
                              widget.application.studentEmail,
                              style: AppTypography.bodySmall.copyWith(color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary),
                            ),
                            Text(
                              '${widget.application.studentDepartment} • ${widget.application.studentYear}',
                              style: AppTypography.labelSmall.copyWith(color: AppColors.primaryLight),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Position Applied For:', style: AppTypography.bodySmall),
                      TagChip(
                        label: widget.application.positionApplied,
                        color: AppColors.secondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Application Questionnaire Answers
            Text('Application Questionnaire', style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...widget.application.answers.entries.map((entry) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Q: ${entry.key}',
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      entry.value,
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),

            // Application Status Selector
            Text('Update Application Status', style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            DropdownButtonFormField<ApplicationStatus>(
              value: _status,
              items: const [
                DropdownMenuItem(value: ApplicationStatus.applied, child: Text('Applied (New)')),
                DropdownMenuItem(value: ApplicationStatus.underReview, child: Text('🔍 Under Review')),
                DropdownMenuItem(value: ApplicationStatus.shortlisted, child: Text('⭐ Shortlisted for Interview')),
                DropdownMenuItem(value: ApplicationStatus.selected, child: Text('🎉 Selected / Inducted')),
                DropdownMenuItem(value: ApplicationStatus.rejected, child: Text('❌ Rejected')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _status = v);
              },
            ),
            const SizedBox(height: 16),

            // Internal Coordinator Notes
            CustomTextField(
              label: 'Internal Coordinator Notes',
              hintText: 'Add evaluation feedback or interview schedule notes...',
              controller: _notesController,
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            // Save Action
            CustomButton(
              text: 'Save Evaluation Status',
              onPressed: _handleSaveStatus,
              variant: ButtonVariant.secondary,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
