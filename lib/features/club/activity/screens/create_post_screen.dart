import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:c_qube/core/constants/app_colors.dart';
import 'package:c_qube/core/constants/app_constants.dart';
import 'package:c_qube/core/constants/app_typography.dart';
import 'package:c_qube/core/utils/validator_utils.dart';
import 'package:c_qube/models/post_model.dart';
import 'package:c_qube/shared/widgets/custom_button.dart';
import 'package:c_qube/shared/widgets/custom_text_field.dart';
import 'package:c_qube/state/auth_state.dart';
import 'package:c_qube/state/club_state.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _imageUrlController = TextEditingController(
    text: 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?auto=format&fit=crop&w=800&q=80',
  );
  PostType _selectedType = PostType.achievement;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _handlePublish() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = Provider.of<AuthState>(context, listen: false);
    final clubState = Provider.of<ClubState>(context, listen: false);
    final club = authState.currentClub;

    if (club == null) return;

    final post = PostModel(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}',
      clubId: club.id,
      clubName: club.name,
      clubLogoUrl: club.logoUrl,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      imageUrl: _imageUrlController.text.trim(),
      type: _selectedType,
      createdAt: DateTime.now(),
    );

    await clubState.createPost(post);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post published to club feed!'), backgroundColor: AppColors.success),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Club Post'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                label: 'Post Title',
                hintText: 'e.g. GDSC Wins 1st Place at National Smart India Hackathon',
                controller: _titleController,
                validator: (v) => ValidatorUtils.validateRequired(v, 'Post title'),
              ),
              const SizedBox(height: 18),

              Text('Post Category', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              DropdownButtonFormField<PostType>(
                value: _selectedType,
                items: PostType.values
                    .map((t) => DropdownMenuItem(value: t, child: Text(t.name.toUpperCase(), style: AppTypography.bodyMedium)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedType = v);
                },
              ),
              const SizedBox(height: 18),

              CustomTextField(
                label: 'Content / Highlights',
                hintText: 'Share stories, achievements, photos, and team appreciation...',
                controller: _contentController,
                maxLines: 4,
                validator: (v) => ValidatorUtils.validateRequired(v, 'Content'),
              ),
              const SizedBox(height: 18),

              CustomTextField(
                label: 'Photo Image URL',
                hintText: 'https://...',
                controller: _imageUrlController,
              ),
              const SizedBox(height: 32),

              CustomButton(
                text: 'Publish Post',
                onPressed: _handlePublish,
                variant: ButtonVariant.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
