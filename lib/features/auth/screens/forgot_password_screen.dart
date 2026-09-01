import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/validator_utils.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../widgets/auth_header.dart';

import 'package:provider/provider.dart';
import '../../../state/auth_state.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    final authState = Provider.of<AuthState>(context, listen: false);
    await authState.resetPassword(_emailController.text.trim());
    if (mounted) {
      setState(() => _submitted = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: _submitted
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mark_email_read_outlined, size: 48, color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Password Reset Email Sent',
                      style: AppTypography.headlineMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'We have sent a secure password reset link to ${_emailController.text}. Please follow the instructions in the email.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: 'Back to Login',
                      onPressed: () => Navigator.pop(context),
                      variant: ButtonVariant.primary,
                    ),
                  ],
                )
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AuthHeader(
                        title: 'Reset Password',
                        subtitle: 'Enter your registered college email and we will send you a reset link.',
                        icon: Icons.lock_reset_rounded,
                      ),
                      const SizedBox(height: 32),
                      CustomTextField(
                        label: 'Registered Email ID',
                        hintText: 'e.g. rahul@campus.edu',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: ValidatorUtils.validateEmail,
                      ),
                      const SizedBox(height: 28),
                      CustomButton(
                        text: 'Send Reset Link',
                        onPressed: _handleSubmit,
                        variant: ButtonVariant.primary,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
