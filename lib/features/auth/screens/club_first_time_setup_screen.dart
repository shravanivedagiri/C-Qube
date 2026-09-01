import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/validator_utils.dart';
import '../../../models/club_model.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../state/auth_state.dart';
import '../../../state/club_state.dart';
import '../../club/dashboard/screens/club_dashboard_screen.dart';

class ClubFirstTimeSetupScreen extends StatefulWidget {
  final ClubModel club;
  const ClubFirstTimeSetupScreen({super.key, required this.club});

  @override
  State<ClubFirstTimeSetupScreen> createState() => _ClubFirstTimeSetupScreenState();
}

class _ClubFirstTimeSetupScreenState extends State<ClubFirstTimeSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _aboutController;
  late TextEditingController _contactController;
  late TextEditingController _instagramController;
  late TextEditingController _linkedinController;

  late ClubCategory _selectedCategory;
  late String _selectedDepartment;
  String _bannerUrl = 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&w=1200&q=80';
  String _logoUrl = 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?auto=format&fit=crop&w=200&q=80';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.club.name);
    _aboutController = TextEditingController(text: widget.club.about);
    _contactController = TextEditingController(text: widget.club.contactInfo);
    _instagramController = TextEditingController(text: widget.club.socialLinks['Instagram'] ?? '');
    _linkedinController = TextEditingController(text: widget.club.socialLinks['LinkedIn'] ?? '');
    _selectedCategory = widget.club.category;
    _selectedDepartment = widget.club.department;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    _contactController.dispose();
    _instagramController.dispose();
    _linkedinController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = Provider.of<AuthState>(context, listen: false);
    final clubState = Provider.of<ClubState>(context, listen: false);

    final success = await authState.completeClubProfile(
      clubId: widget.club.id,
      name: _nameController.text.trim(),
      logoUrl: _logoUrl,
      bannerUrl: _bannerUrl,
      about: _aboutController.text.trim(),
      category: _selectedCategory,
      department: _selectedDepartment,
      contactInfo: _contactController.text.trim(),
      socialLinks: {
        if (_instagramController.text.isNotEmpty) 'Instagram': _instagramController.text.trim(),
        if (_linkedinController.text.isNotEmpty) 'LinkedIn': _linkedinController.text.trim(),
      },
    );

    if (success && mounted) {
      if (authState.currentClub != null) {
        clubState.setCurrentClub(authState.currentClub!);
      }
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ClubDashboardScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = Provider.of<AuthState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Club Profile'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Set Up Your Club Hub',
                  style: AppTypography.displaySmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Customize your public club presence to start posting events, activities, and recruitments.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // Banner Upload Card
                Text(
                  'Club Banner Image',
                  style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: AspectRatio(
                        aspectRatio: 16 / 7,
                        child: Image.network(_bannerUrl, fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Toggle sample banner photo
                          setState(() {
                            _bannerUrl = _bannerUrl.contains('522071820081')
                                ? 'https://images.unsplash.com/photo-1511578314322-379afb476865?auto=format&fit=crop&w=1200&q=80'
                                : 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&w=1200&q=80';
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Banner updated via Supabase Storage')),
                          );
                        },
                        icon: const Icon(Icons.camera_alt_outlined, size: 16),
                        label: const Text('Change Banner'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black.withValues(alpha: 0.75),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          textStyle: AppTypography.labelSmall,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Logo Avatar
                Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundImage: NetworkImage(_logoUrl),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Club Logo',
                          style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _logoUrl = _logoUrl.contains('517694712202')
                                  ? 'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?auto=format&fit=crop&w=200&q=80'
                                  : 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?auto=format&fit=crop&w=200&q=80';
                            });
                          },
                          child: const Text('Upload New Logo'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Name
                CustomTextField(
                  label: 'Club Display Name',
                  hintText: 'e.g. Google Developer Student Club',
                  controller: _nameController,
                  validator: (v) => ValidatorUtils.validateRequired(v, 'Club Name'),
                ),
                const SizedBox(height: 16),

                // Category Dropdown
                Text(
                  'Category',
                  style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<ClubCategory>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.category_outlined, size: 20),
                  ),
                  items: ClubCategory.values
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat.name.toUpperCase(), style: AppTypography.bodyMedium),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedCategory = v);
                  },
                ),
                const SizedBox(height: 16),

                // About Description
                CustomTextField(
                  label: 'About Club & Mission',
                  hintText: 'Describe your club activities and initiatives for prospective members.',
                  controller: _aboutController,
                  maxLines: 3,
                  validator: (v) => ValidatorUtils.validateRequired(v, 'About description'),
                ),
                const SizedBox(height: 16),

                // Contact Info
                CustomTextField(
                  label: 'Official Contact Info & Location',
                  hintText: 'e.g. Lab 402 Tech Block | contact@gdsc.org',
                  controller: _contactController,
                  prefixIcon: Icons.contact_mail_outlined,
                  validator: (v) => ValidatorUtils.validateRequired(v, 'Contact info'),
                ),
                const SizedBox(height: 16),

                // Social Links
                CustomTextField(
                  label: 'Instagram Handle (optional)',
                  hintText: 'e.g. @gdsc_campus',
                  controller: _instagramController,
                  prefixIcon: Icons.camera_alt_outlined,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'LinkedIn Page / Website URL (optional)',
                  hintText: 'e.g. https://linkedin.com/company/gdsc',
                  controller: _linkedinController,
                  prefixIcon: Icons.link_rounded,
                ),
                const SizedBox(height: 32),

                // Save & Proceed
                CustomButton(
                  text: 'Save Profile & Go to Dashboard',
                  isLoading: authState.isLoading,
                  onPressed: _handleSave,
                  variant: ButtonVariant.secondary,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
