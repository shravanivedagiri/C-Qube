class GenieMessageModel {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? relatedClubId;
  final String? relatedEventId;
  final List<String> quickReplies;

  GenieMessageModel({
    required this.id,
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.relatedClubId,
    this.relatedEventId,
    this.quickReplies = const [],
  }) : timestamp = timestamp ?? DateTime.now();
}
