import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:c_qube/core/constants/app_colors.dart';
import 'package:c_qube/core/constants/app_constants.dart';
import 'package:c_qube/core/constants/app_typography.dart';
import 'package:c_qube/core/utils/validator_utils.dart';
import 'package:c_qube/models/club_model.dart';
import 'package:c_qube/shared/widgets/custom_button.dart';
import 'package:c_qube/shared/widgets/custom_text_field.dart';
import 'package:c_qube/state/auth_state.dart';
import 'package:c_qube/state/club_state.dart';

class EditClubProfileScreen extends StatefulWidget {
  final ClubModel club;

  const EditClubProfileScreen({super.key, required this.club});

  @override
  State<EditClubProfileScreen> createState() => _EditClubProfileScreenState();
}

class _EditClubProfileScreenState extends State<EditClubProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _aboutController;
  late TextEditingController _contactController;
  late TextEditingController _instagramController;
  late TextEditingController _linkedinController;

  late ClubCategory _selectedCategory;
  late String _bannerUrl;
  late String _logoUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.club.name);
    _aboutController = TextEditingController(text: widget.club.about);
    _contactController = TextEditingController(text: widget.club.contactInfo);
    _instagramController = TextEditingController(text: widget.club.socialLinks['Instagram'] ?? '');
    _linkedinController = TextEditingController(text: widget.club.socialLinks['LinkedIn'] ?? '');
    _selectedCategory = widget.club.category;
    _bannerUrl = widget.club.bannerUrl;
    _logoUrl = widget.club.logoUrl;
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

    final updated = widget.club.copyWith(
      name: _nameController.text.trim(),
      about: _aboutController.text.trim(),
      contactInfo: _contactController.text.trim(),
      category: _selectedCategory,
      bannerUrl: _bannerUrl,
      logoUrl: _logoUrl,
      socialLinks: {
        if (_instagramController.text.isNotEmpty) 'Instagram': _instagramController.text.trim(),
        if (_linkedinController.text.isNotEmpty) 'LinkedIn': _linkedinController.text.trim(),
      },
    );

    await clubState.updateClubProfile(updated);
    authState.updateCurrentClub(updated);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Club profile updated!'), backgroundColor: AppColors.success),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Club Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Club Banner', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
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
                        setState(() {
                          _bannerUrl = _bannerUrl.contains('522071820081')
                              ? 'https://images.unsplash.com/photo-1511578314322-379afb476865?auto=format&fit=crop&w=1200&q=80'
                              : 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&w=1200&q=80';
                        });
                      },
                      icon: const Icon(Icons.camera_alt_outlined, size: 16),
                      label: const Text('Change Banner'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black87, foregroundColor: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              CustomTextField(
                label: 'Club Name',
                hintText: 'Enter official club name',
                controller: _nameController,
                validator: (v) => ValidatorUtils.validateRequired(v, 'Club Name'),
              ),
              const SizedBox(height: 16),

              Text('Club Category', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              DropdownButtonFormField<ClubCategory>(
                value: _selectedCategory,
                items: ClubCategory.values
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.name.toUpperCase(), style: AppTypography.bodyMedium)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedCategory = v);
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'About Club',
                hintText: 'Describe club mission and activities...',
                controller: _aboutController,
                maxLines: 3,
                validator: (v) => ValidatorUtils.validateRequired(v, 'About'),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Contact Info & Lab Location',
                hintText: 'e.g. Lab 402, CS Department',
                controller: _contactController,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Instagram Handle',
                hintText: '@club_handle',
                controller: _instagramController,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'LinkedIn Page / Website',
                hintText: 'https://linkedin.com/company/...',
                controller: _linkedinController,
              ),
              const SizedBox(height: 32),

              CustomButton(
                text: 'Save Changes',
                onPressed: _handleSave,
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
