import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/validator_utils.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../state/auth_state.dart';
import '../widgets/auth_header.dart';

class ClubRequestScreen extends StatefulWidget {
  const ClubRequestScreen({super.key});

  @override
  State<ClubRequestScreen> createState() => _ClubRequestScreenState();
}

class _ClubRequestScreenState extends State<ClubRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clubNameController = TextEditingController();
  final _clubEmailController = TextEditingController();
  final _coordinatorNameController = TextEditingController();
  final _coordinatorEmailController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _reasonController = TextEditingController();

  String _selectedDepartment = AppConstants.departments[0];
  bool _submitted = false;

  @override
  void dispose() {
    _clubNameController.dispose();
    _clubEmailController.dispose();
    _coordinatorNameController.dispose();
    _coordinatorEmailController.dispose();
    _descriptionController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = Provider.of<AuthState>(context, listen: false);

    final success = await authState.requestClubRegistration(
      clubName: _clubNameController.text.trim(),
      clubEmail: _clubEmailController.text.trim(),
      coordinatorName: _coordinatorNameController.text.trim(),
      coordinatorEmail: _coordinatorEmailController.text.trim(),
      department: _selectedDepartment,
      description: _descriptionController.text.trim(),
      reason: _reasonController.text.trim(),
    );

    if (success && mounted) {
      setState(() => _submitted = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = Provider.of<AuthState>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: _submitted
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle_rounded, size: 64, color: AppColors.success),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Request Submitted Successfully',
                      style: AppTypography.displaySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your request has been submitted. The college administration and Dean of Student Affairs will review your application. An onboarding credential email will be dispatched to ${_coordinatorEmailController.text} once approved.',
                      style: AppTypography.bodyLarge.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 36),
                    CustomButton(
                      text: 'Return to Login',
                      onPressed: () => Navigator.pop(context),
                      variant: ButtonVariant.secondary,
                    ),
                  ],
                )
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AuthHeader(
                        title: 'Request Club Registration',
                        subtitle: 'Apply for official club listing on C-QUBE. Submitted requests are reviewed by the college administration.',
                        icon: Icons.domain_add_rounded,
                      ),
                      const SizedBox(height: 28),

                      // Club Name
                      CustomTextField(
                        label: 'Club / Chapter Name',
                        hintText: 'e.g. CyberSecurity & Ethical Hacking Society',
                        controller: _clubNameController,
                        prefixIcon: Icons.groups_outlined,
                        validator: (v) => ValidatorUtils.validateRequired(v, 'Club name'),
                      ),
                      const SizedBox(height: 16),

                      // Club Email
                      CustomTextField(
                        label: 'Club Official Email ID',
                        hintText: 'e.g. cybersec@campus.edu',
                        controller: _clubEmailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: ValidatorUtils.validateEmail,
                      ),
                      const SizedBox(height: 16),

                      // Coordinator Name
                      CustomTextField(
                        label: 'Faculty / Student Coordinator Name',
                        hintText: 'e.g. Prof. R. Sharma / Aditi Roy',
                        controller: _coordinatorNameController,
                        prefixIcon: Icons.person_outline_rounded,
                        validator: (v) => ValidatorUtils.validateRequired(v, 'Coordinator name'),
                      ),
                      const SizedBox(height: 16),

                      // Coordinator Email
                      CustomTextField(
                        label: 'Coordinator Personal Email ID',
                        hintText: 'e.g. aditi.roy@campus.edu',
                        controller: _coordinatorEmailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.alternate_email_rounded,
                        validator: ValidatorUtils.validateEmail,
                      ),
                      const SizedBox(height: 16),

                      // Department
                      Text(
                        'Department Affiliation',
                        style: AppTypography.labelMedium.copyWith(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedDepartment,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.apartment_rounded, size: 20),
                        ),
                        items: AppConstants.departments
                            .map((dept) => DropdownMenuItem(
                                  value: dept,
                                  child: Text(dept, style: AppTypography.bodyMedium),
                                ))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedDepartment = v);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Short Description
                      CustomTextField(
                        label: 'Short Club Description',
                        hintText: 'What is the mission and vision of your club?',
                        controller: _descriptionController,
                        maxLines: 3,
                        validator: (v) => ValidatorUtils.validateRequired(v, 'Description'),
                      ),
                      const SizedBox(height: 16),

                      // Reason for requesting
                      CustomTextField(
                        label: 'Reason for Requesting Registration',
                        hintText: 'How will joining C-QUBE benefit the student body?',
                        controller: _reasonController,
                        maxLines: 2,
                        validator: (v) => ValidatorUtils.validateRequired(v, 'Reason'),
                      ),
                      const SizedBox(height: 28),

                      // Submit Button
                      CustomButton(
                        text: 'Submit Registration Application',
                        isLoading: authState.isLoading,
                        onPressed: _handleSubmit,
                        variant: ButtonVariant.secondary,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
