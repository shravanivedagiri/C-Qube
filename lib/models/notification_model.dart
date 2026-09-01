import '../core/constants/app_constants.dart';

class NotificationModel {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final String referenceId;
  final bool isRead;
  final String? actionStatus; // 'pending', 'accepted', 'rejected'
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.referenceId = '',
    this.isRead = false,
    this.actionStatus,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  NotificationModel copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? body,
    String? referenceId,
    bool? isRead,
    String? actionStatus,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      referenceId: referenceId ?? this.referenceId,
      isRead: isRead ?? this.isRead,
      actionStatus: actionStatus ?? this.actionStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
