import '../models/notification_model.dart';
import '../services/mock_data_store.dart';

abstract class NotificationRepository {
  Future<List<NotificationModel>> getUserNotifications(String userId);
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead(String userId);
  Future<int> getUnreadCount(String userId);
}

class MockNotificationRepository implements NotificationRepository {
  final MockDataStore _store = MockDataStore();

  @override
  Future<List<NotificationModel>> getUserNotifications(String userId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final list = _store.notifications.where((n) => n.userId == userId).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final index = _store.notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _store.notifications[index] = _store.notifications[index].copyWith(isRead: true);
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    for (int i = 0; i < _store.notifications.length; i++) {
      if (_store.notifications[i].userId == userId) {
        _store.notifications[i] = _store.notifications[i].copyWith(isRead: true);
      }
    }
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    return _store.notifications.where((n) => n.userId == userId && !n.isRead).length;
  }
}
