import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';

class NotificationState extends ChangeNotifier {
  final NotificationRepository _notificationRepository;

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;

  NotificationState({NotificationRepository? notificationRepository})
      : _notificationRepository = notificationRepository ?? MockNotificationRepository();

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  Future<void> loadNotifications(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _notifications = await _notificationRepository.getUserNotifications(userId);
      _unreadCount = await _notificationRepository.getUnreadCount(userId);
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId, String userId) async {
    await _notificationRepository.markAsRead(notificationId);
    _notifications = await _notificationRepository.getUserNotifications(userId);
    _unreadCount = await _notificationRepository.getUnreadCount(userId);
    notifyListeners();
  }

  Future<void> markAllAsRead(String userId) async {
    await _notificationRepository.markAllAsRead(userId);
    _notifications = await _notificationRepository.getUserNotifications(userId);
    _unreadCount = 0;
    notifyListeners();
  }
}
