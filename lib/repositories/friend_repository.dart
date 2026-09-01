import '../models/user_model.dart';
import '../models/friend_model.dart';
import '../models/notification_model.dart';
import '../core/constants/app_constants.dart';
import '../services/mock_data_store.dart';

abstract class FriendRepository {
  Future<List<UserModel>> getFriendsForStudent(String studentId);
  Future<List<FriendActivityItem>> getFriendActivityFeed(String studentId);
  Future<List<UserModel>> searchStudents(String query, String currentStudentId);
  Future<void> sendFriendRequest(String senderId, String receiverId);
  Future<void> respondFriendRequest(String senderId, String receiverId, bool accept);
  Future<String> getFriendshipStatus(String student1Id, String student2Id);
}

class MockFriendRepository implements FriendRepository {
  final MockDataStore _store = MockDataStore();

  @override
  Future<List<UserModel>> getFriendsForStudent(String studentId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final student = _store.students.firstWhere(
      (s) => s.id == studentId,
      orElse: () => _store.students.first,
    );
    return _store.students.where((s) => student.friendIds.contains(s.id)).toList();
  }

  @override
  Future<List<FriendActivityItem>> getFriendActivityFeed(String studentId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final student = _store.students.firstWhere(
      (s) => s.id == studentId,
      orElse: () => _store.students.first,
    );
    // Filter activities from friends whose privacy settings allow it
    return _store.friendActivities.where((a) {
      if (a.studentId == studentId) return true;
      if (!student.friendIds.contains(a.studentId)) return false;
      final friendUser = _store.students.firstWhere((s) => s.id == a.studentId, orElse: () => student);
      if (a.activityType == 'joined_club' && !friendUser.privacySettings.showJoinedClubs) return false;
      if (a.activityType == 'registered_event' && !friendUser.privacySettings.showRegisteredEvents) return false;
      if (a.activityType == 'achievement' && !friendUser.privacySettings.showPoints) return false;
      return true;
    }).toList();
  }

  @override
  Future<List<UserModel>> searchStudents(String query, String currentStudentId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final q = query.toLowerCase();
    return _store.students.where((s) {
      if (s.id == currentStudentId) return false;
      if (query.trim().isEmpty) return true;
      return s.name.toLowerCase().contains(q) ||
          s.department.toLowerCase().contains(q) ||
          s.interests.any((i) => i.toLowerCase().contains(q));
    }).toList();
  }

  @override
  Future<void> sendFriendRequest(String senderId, String receiverId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final friendship = Friendship(
      id: 'fr_${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      receiverId: receiverId,
      status: 'pending',
    );
    _store.friendships.add(friendship);

    final sender = _store.students.firstWhere((s) => s.id == senderId, orElse: () => _store.students.first);

    // Send notification to receiver
    _store.notifications.insert(
      0,
      NotificationModel(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
        userId: receiverId,
        type: NotificationType.friend,
        title: 'Friend Request',
        body: '${sender.name} sent you a friend request.',
        referenceId: senderId,
        isRead: false,
        actionStatus: 'pending',
      ),
    );
  }

  @override
  Future<void> respondFriendRequest(String senderId, String receiverId, bool accept) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _store.friendships.indexWhere(
      (f) => (f.senderId == senderId && f.receiverId == receiverId) ||
          (f.senderId == receiverId && f.receiverId == senderId),
    );

    if (index != -1) {
      _store.friendships[index] = _store.friendships[index].copyWith(
        status: accept ? 'accepted' : 'rejected',
      );
    }

    if (accept) {
      // Add each other to friends lists
      final senderIdx = _store.students.indexWhere((s) => s.id == senderId);
      final receiverIdx = _store.students.indexWhere((s) => s.id == receiverId);

      if (senderIdx != -1) {
        final s = _store.students[senderIdx];
        final f = List<String>.from(s.friendIds);
        if (!f.contains(receiverId)) f.add(receiverId);
        _store.students[senderIdx] = s.copyWith(friendIds: f);
        if (_store.currentUser?.id == senderId) _store.currentUser = _store.students[senderIdx];
      }

      if (receiverIdx != -1) {
        final r = _store.students[receiverIdx];
        final f = List<String>.from(r.friendIds);
        if (!f.contains(senderId)) f.add(senderId);
        _store.students[receiverIdx] = r.copyWith(friendIds: f);
        if (_store.currentUser?.id == receiverId) _store.currentUser = _store.students[receiverIdx];
      }
    }
  }

  @override
  Future<String> getFriendshipStatus(String student1Id, String student2Id) async {
    if (student1Id == student2Id) return 'self';
    final existing = _store.friendships.firstWhere(
      (f) => (f.senderId == student1Id && f.receiverId == student2Id) ||
          (f.senderId == student2Id && f.receiverId == student1Id),
      orElse: () => Friendship(id: '', senderId: '', receiverId: '', status: 'none'),
    );
    return existing.status;
  }
}
