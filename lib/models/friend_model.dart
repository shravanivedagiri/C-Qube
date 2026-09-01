class Friendship {
  final String id;
  final String senderId;
  final String receiverId;
  final String status; // 'pending', 'accepted', 'rejected'
  final DateTime createdAt;

  Friendship({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.status = 'pending',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Friendship copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? status,
    DateTime? createdAt,
  }) {
    return Friendship(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class FriendActivityItem {
  final String id;
  final String studentId;
  final String studentName;
  final String studentAvatarUrl;
  final String activityText;
  final String targetName;
  final String activityType; // 'joined_club', 'registered_event', 'achievement', 'points'
  final DateTime timestamp;

  FriendActivityItem({
    required this.id,
    required this.studentId,
    required this.studentName,
    this.studentAvatarUrl = '',
    required this.activityText,
    required this.targetName,
    required this.activityType,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
