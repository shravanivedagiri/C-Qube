import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:c_qube/core/constants/app_colors.dart';
import 'package:c_qube/core/constants/app_constants.dart';
import 'package:c_qube/core/constants/app_typography.dart';
import 'package:c_qube/models/gallery_item_model.dart';
import 'package:c_qube/shared/widgets/empty_state_view.dart';
import 'package:c_qube/shared/widgets/custom_text_field.dart';
import 'package:c_qube/state/auth_state.dart';
import 'package:c_qube/state/club_state.dart';

class ClubGalleryScreen extends StatefulWidget {
  const ClubGalleryScreen({super.key});

  @override
  State<ClubGalleryScreen> createState() => _ClubGalleryScreenState();
}

class _ClubGalleryScreenState extends State<ClubGalleryScreen> {
  void _showUploadDialog() {
    final titleController = TextEditingController();
    MediaType mediaType = MediaType.photo;
    String sampleUrl = 'https://images.unsplash.com/photo-1511578314322-379afb476865?auto=format&fit=crop&w=800&q=80';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {


          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              'Upload Club Media',
              style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    label: 'Media Caption / Title',
                    hintText: 'e.g. Hackathon Demo Day 2026',
                    controller: titleController,
                  ),
                  const SizedBox(height: 16),
                  Text('Media Type', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('📷 Photo'),
                        selected: mediaType == MediaType.photo,
                        onSelected: (v) => setModalState(() {
                          mediaType = MediaType.photo;
                          sampleUrl = 'https://images.unsplash.com/photo-1511578314322-379afb476865?auto=format&fit=crop&w=800&q=80';
                        }),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('🎬 Video Highlight'),
                        selected: mediaType == MediaType.video,
                        onSelected: (v) => setModalState(() {
                          mediaType = MediaType.video;
                          sampleUrl = 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?auto=format&fit=crop&w=800&q=80';
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(sampleUrl, height: 120, width: double.infinity, fit: BoxFit.cover),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final authState = Provider.of<AuthState>(context, listen: false);
                  final clubState = Provider.of<ClubState>(context, listen: false);
                  final club = authState.currentClub;

                  if (club != null) {
                    final item = GalleryItemModel(
                      id: 'gal_${DateTime.now().millisecondsSinceEpoch}',
                      clubId: club.id,
                      title: titleController.text.trim().isNotEmpty
                          ? titleController.text.trim()
                          : 'Club Memory',
                      mediaUrl: sampleUrl,
                      mediaType: mediaType,
                      thumbnailUrl: sampleUrl,
                    );
                    await clubState.uploadGalleryItem(item);
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: Colors.white),
                child: const Text('Upload to Storage'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final clubState = Provider.of<ClubState>(context);
    final gallery = clubState.clubGallery;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Club Gallery & Media'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_rounded),
            tooltip: 'Upload Media',
            onPressed: _showUploadDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showUploadDialog,
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: gallery.isEmpty
          ? EmptyStateView(
              icon: Icons.photo_library_outlined,
              title: 'No photos or videos yet',
              description: 'Upload workshop photos, award snapshots, and aftermovies to showcase your club milestones.',
              actionText: 'Upload Photo or Video',
              onAction: _showUploadDialog,
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: gallery.length,
              itemBuilder: (context, index) {
                final item = gallery[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        item.mediaUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: isDark ? AppColors.darkSurface : Colors.grey.shade200,
                          child: const Icon(Icons.image_outlined, color: AppColors.secondary),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black87, Colors.transparent],
                            ),
                          ),
                          child: Text(
                            item.title,
                            style: AppTypography.labelSmall.copyWith(color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      if (item.mediaType == MediaType.video)
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
