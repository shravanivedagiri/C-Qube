import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/validator_utils.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../state/auth_state.dart';
import '../../../state/club_state.dart';
import '../../club/dashboard/screens/club_dashboard_screen.dart';
import '../widgets/auth_header.dart';
import 'club_request_screen.dart';
import 'club_first_time_setup_screen.dart';

class ClubLoginScreen extends StatefulWidget {
  const ClubLoginScreen({super.key});

  @override
  State<ClubLoginScreen> createState() => _ClubLoginScreenState();
}

class _ClubLoginScreenState extends State<ClubLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'gdsc@campus.edu');
  final _passwordController = TextEditingController(text: 'clubpass123');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = Provider.of<AuthState>(context, listen: false);
    final clubState = Provider.of<ClubState>(context, listen: false);

    final club = await authState.loginClub(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    if (club == null) {
      // Club not registered in approved database -> Show dedicated Unregistered explanation
      _showUnregisteredDialog();
    } else {
      clubState.setCurrentClub(club);
      if (!club.isProfileCompleted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ClubFirstTimeSetupScreen(club: club),
          ),
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ClubDashboardScreen()),
          (route) => false,
        );
      }
    }
  }

  void _showUnregisteredDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.info_outline_rounded, color: AppColors.warning),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Club Not Registered',
                style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your club is not registered with C-QUBE yet.',
              style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Club accounts are provisioned exclusively after college administration approval. If you are a coordinator, submit a registration request for review.',
              style: AppTypography.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ClubRequestScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Request Club Registration'),
          ),
        ],
      ),
    );
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
                  title: 'Club Portal Login',
                  subtitle: 'Sign in with your approved club account to manage activities, events and recruitments.',
                  icon: Icons.groups_rounded,
                ),
                const SizedBox(height: 32),

                // Club Email / Identifier
                CustomTextField(
                  label: 'Club Official Email ID',
                  hintText: 'e.g. gdsc@campus.edu',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.business_outlined,
                  validator: ValidatorUtils.validateEmail,
                ),
                const SizedBox(height: 18),

                // Password
                CustomTextField(
                  label: 'Password',
                  hintText: '••••••••',
                  controller: _passwordController,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline_rounded,
                  validator: ValidatorUtils.validatePassword,
                ),
                const SizedBox(height: 28),

                // Login Button
                CustomButton(
                  text: 'Sign In to Club Dashboard',
                  isLoading: authState.isLoading,
                  onPressed: _handleLogin,
                  variant: ButtonVariant.secondary,
                ),
                const SizedBox(height: 24),

                // Quick Demo Accounts Box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.verified_user_outlined, size: 18, color: AppColors.secondary),
                          const SizedBox(width: 8),
                          Text(
                            'Approved Demo Clubs:',
                            style: AppTypography.labelSmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• gdsc@campus.edu (GDSC)\n• airs@campus.edu (AIRS Robotics)\n• lumiere@campus.edu (Photography)\n• ecell@campus.edu (E-Cell)',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Request registration action
                Center(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ClubRequestScreen()),
                      );
                    },
                    icon: const Icon(Icons.add_business_outlined, size: 18),
                    label: const Text('Request Club Registration'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondary,
                      side: const BorderSide(color: AppColors.secondary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
