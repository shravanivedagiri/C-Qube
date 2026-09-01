import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/validator_utils.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/tag_chip.dart';
import '../../../state/auth_state.dart';
import '../../../state/student_state.dart';
import '../../student/main_navigation.dart';
import '../widgets/auth_header.dart';
import 'student_login_screen.dart';

class StudentRegisterScreen extends StatefulWidget {
  const StudentRegisterScreen({super.key});

  @override
  State<StudentRegisterScreen> createState() => _StudentRegisterScreenState();
}

class _StudentRegisterScreenState extends State<StudentRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _goalsController = TextEditingController();
  final _bioController = TextEditingController();

  String _selectedDepartment = AppConstants.departments[0];
  String _selectedYear = AppConstants.years[0];
  final List<String> _selectedInterests = ['AI/ML', 'App Development'];
  final List<String> _selectedSkills = ['Flutter & Dart'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _goalsController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedInterests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least 1 interest to customize your recommendations.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final authState = Provider.of<AuthState>(context, listen: false);
    final studentState = Provider.of<StudentState>(context, listen: false);

    final success = await authState.registerStudent(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      department: _selectedDepartment,
      year: _selectedYear,
      interests: _selectedInterests,
      skills: _selectedSkills,
      goals: _goalsController.text.trim(),
      bio: _bioController.text.trim(),
    );

    if (success && mounted) {
      if (authState.currentStudent != null) {
        await studentState.loadDashboardData(authState.currentStudent!);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Welcome to C-QUBE! +100 Points awarded.'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const StudentMainNavigation()),
          (route) => false,
        );
      }
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AuthHeader(
                  title: 'Create Student Profile',
                  subtitle: 'Set up your campus profile to receive personalized club and event recommendations.',
                  icon: Icons.person_add_alt_1_rounded,
                ),
                const SizedBox(height: 28),

                // Full Name
                CustomTextField(
                  label: 'Full Name',
                  hintText: 'e.g. Rahul Sharma',
                  controller: _nameController,
                  prefixIcon: Icons.person_outline_rounded,
                  validator: (v) => ValidatorUtils.validateRequired(v, 'Name'),
                ),
                const SizedBox(height: 18),

                // Email
                CustomTextField(
                  label: 'College Email ID',
                  hintText: 'e.g. rahul@campus.edu',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: ValidatorUtils.validateEmail,
                ),
                const SizedBox(height: 18),

                // Password
                CustomTextField(
                  label: 'Password',
                  hintText: 'Create a strong password',
                  controller: _passwordController,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline_rounded,
                  validator: ValidatorUtils.validatePassword,
                ),
                const SizedBox(height: 18),

                // Department Dropdown
                Text(
                  'Department',
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
                const SizedBox(height: 18),

                // Year Dropdown
                Text(
                  'Academic Year',
                  style: AppTypography.labelMedium.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedYear,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.school_outlined, size: 20),
                  ),
                  items: AppConstants.years
                      .map((yr) => DropdownMenuItem(
                            value: yr,
                            child: Text(yr, style: AppTypography.bodyMedium),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedYear = v);
                  },
                ),
                const SizedBox(height: 24),

                // Interests Tag Selector
                Text(
                  'Your Interests (Select all that apply)',
                  style: AppTypography.labelMedium.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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

                // Skills Tag Selector
                Text(
                  'Your Skills & Strengths',
                  style: AppTypography.labelMedium.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
                const SizedBox(height: 20),

                // Bio
                CustomTextField(
                  label: 'Short Bio',
                  hintText: 'e.g. Passionate about AI, hackathons and mobile design.',
                  controller: _bioController,
                  maxLines: 2,
                ),
                const SizedBox(height: 18),

                // Goals
                CustomTextField(
                  label: 'Campus Goals & Aspirations',
                  hintText: 'e.g. Lead a technical project or organize a national symposium.',
                  controller: _goalsController,
                  maxLines: 2,
                ),
                const SizedBox(height: 32),

                // Register Button
                CustomButton(
                  text: 'Complete Registration (+100 Pts)',
                  isLoading: authState.isLoading,
                  onPressed: _handleRegister,
                  variant: ButtonVariant.primary,
                ),
                const SizedBox(height: 20),

                // Back to login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already registered?',
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const StudentLoginScreen()),
                        );
                      },
                      child: Text(
                        'Login',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
