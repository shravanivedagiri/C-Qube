import '../core/constants/app_constants.dart';

class PostModel {
  final String id;
  final String clubId;
  final String clubName;
  final String clubLogoUrl;
  final PostType type;
  final String title;
  final String content;
  final String imageUrl;
  final String attachmentUrl;
  final String? eventReferenceId;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.clubId,
    required this.clubName,
    this.clubLogoUrl = '',
    required this.type,
    required this.title,
    required this.content,
    this.imageUrl = '',
    this.attachmentUrl = '',
    this.eventReferenceId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  PostModel copyWith({
    String? id,
    String? clubId,
    String? clubName,
    String? clubLogoUrl,
    PostType? type,
    String? title,
    String? content,
    String? imageUrl,
    String? attachmentUrl,
    String? eventReferenceId,
    DateTime? createdAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      clubId: clubId ?? this.clubId,
      clubName: clubName ?? this.clubName,
      clubLogoUrl: clubLogoUrl ?? this.clubLogoUrl,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      eventReferenceId: eventReferenceId ?? this.eventReferenceId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
