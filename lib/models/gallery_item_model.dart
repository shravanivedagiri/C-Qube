import '../core/constants/app_constants.dart';

class GalleryItemModel {
  final String id;
  final String clubId;
  final String title;
  final String mediaUrl;
  final MediaType mediaType;
  final String thumbnailUrl;
  final DateTime createdAt;

  GalleryItemModel({
    required this.id,
    required this.clubId,
    this.title = '',
    required this.mediaUrl,
    required this.mediaType,
    this.thumbnailUrl = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  GalleryItemModel copyWith({
    String? id,
    String? clubId,
    String? title,
    String? mediaUrl,
    MediaType? mediaType,
    String? thumbnailUrl,
    DateTime? createdAt,
  }) {
    return GalleryItemModel(
      id: id ?? this.id,
      clubId: clubId ?? this.clubId,
      title: title ?? this.title,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
