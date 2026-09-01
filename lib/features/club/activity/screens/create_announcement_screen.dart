import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:c_qube/core/constants/app_colors.dart';
import 'package:c_qube/core/constants/app_constants.dart';
import 'package:c_qube/core/constants/app_typography.dart';
import 'package:c_qube/core/utils/validator_utils.dart';
import 'package:c_qube/models/post_model.dart';
import 'package:c_qube/shared/widgets/custom_button.dart';
import 'package:c_qube/shared/widgets/custom_text_field.dart';
import 'package:c_qube/shared/widgets/tag_chip.dart';
import 'package:c_qube/state/auth_state.dart';
import 'package:c_qube/state/club_state.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  State<CreateAnnouncementScreen> createState() => _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _imageUrlController = TextEditingController(
    text: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?auto=format&fit=crop&w=800&q=80',
  );

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _showPreviewModal() {
    if (!_formKey.currentState!.validate()) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = Provider.of<AuthState>(context, listen: false);
    final club = authState.currentClub;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Announcement Preview', style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),

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
                          radius: 16,
                          backgroundImage: NetworkImage(club?.logoUrl ?? ''),
                        ),
                        const SizedBox(width: 10),
                        Text(club?.name ?? 'Club', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700)),
                        const Spacer(),
                        const TagChip(label: 'ANNOUNCEMENT', color: AppColors.secondary),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(_titleController.text.trim(), style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(_contentController.text.trim(), style: AppTypography.bodyMedium),
                    if (_imageUrlController.text.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(_imageUrlController.text.trim(), height: 160, width: double.infinity, fit: BoxFit.cover),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await _handlePublish();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: Colors.white),
                      child: const Text('Confirm & Publish'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handlePublish() async {
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
      type: PostType.announcement,
      createdAt: DateTime.now(),
    );

    await clubState.createPost(post);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Announcement broadcasted to student feeds!'), backgroundColor: AppColors.success),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Announcement'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                label: 'Announcement Headline',
                hintText: 'e.g. Mandatory Briefing for All Hackathon Participants',
                controller: _titleController,
                validator: (v) => ValidatorUtils.validateRequired(v, 'Headline'),
              ),
              const SizedBox(height: 18),

              CustomTextField(
                label: 'Announcement Details',
                hintText: 'Type your message for campus students...',
                controller: _contentController,
                maxLines: 5,
                validator: (v) => ValidatorUtils.validateRequired(v, 'Message details'),
              ),
              const SizedBox(height: 18),

              CustomTextField(
                label: 'Image / Poster URL (Optional)',
                hintText: 'https://...',
                controller: _imageUrlController,
              ),
              const SizedBox(height: 32),

              CustomButton(
                text: 'Preview & Broadcast',
                onPressed: _showPreviewModal,
                variant: ButtonVariant.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
