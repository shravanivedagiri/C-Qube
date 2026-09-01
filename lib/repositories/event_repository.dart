import '../core/constants/app_constants.dart';
import '../models/event_model.dart';
import '../models/user_model.dart';
import '../services/mock_data_store.dart';

abstract class EventRepository {
  Future<List<EventModel>> getAllEvents({
    String? searchQuery,
    EventCategory? category,
    String? clubId,
    String? department,
    bool? isOnline,
    bool? isBeginnerFriendly,
    DateTime? filterDate,
  });
  Future<List<EventModel>> getUpcomingEvents({int limit = 10});
  Future<List<EventModel>> getRegisteredEventsForStudent(String studentId);
  Future<List<EventModel>> getClubEvents(String clubId);
  Future<EventModel?> getEventById(String eventId);
  Future<EventModel> createEvent(EventModel event);
  Future<void> updateEvent(EventModel event);
  Future<void> deleteEvent(String eventId);
  Future<bool> toggleEventRegistration(String eventId, String studentId);
  Future<List<UserModel>> getEventParticipants(String eventId);
}

class MockEventRepository implements EventRepository {
  final MockDataStore _store = MockDataStore();

  @override
  Future<List<EventModel>> getAllEvents({
    String? searchQuery,
    EventCategory? category,
    String? clubId,
    String? department,
    bool? isOnline,
    bool? isBeginnerFriendly,
    DateTime? filterDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _store.events.where((e) {
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final matchesTitle = e.title.toLowerCase().contains(q);
        final matchesDesc = e.description.toLowerCase().contains(q);
        final matchesClub = e.clubName.toLowerCase().contains(q);
        if (!matchesTitle && !matchesDesc && !matchesClub) return false;
      }
      if (category != null && e.category != category) return false;
      if (clubId != null && e.clubId != clubId) return false;
      if (department != null &&
          department != 'All' &&
          e.department != department &&
          e.department != 'All Departments') {
        return false;
      }
      if (isOnline != null && e.isOnline != isOnline) return false;
      if (isBeginnerFriendly == true && !e.isBeginnerFriendly) return false;
      if (filterDate != null) {
        final sameDay = e.date.year == filterDate.year &&
            e.date.month == filterDate.month &&
            e.date.day == filterDate.day;
        if (!sameDay) return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<List<EventModel>> getUpcomingEvents({int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final now = DateTime.now();
    final upcoming = _store.events.where((e) => e.date.isAfter(now.subtract(const Duration(days: 1)))).toList();
    upcoming.sort((a, b) => a.date.compareTo(b.date));
    return upcoming.take(limit).toList();
  }

  @override
  Future<List<EventModel>> getRegisteredEventsForStudent(String studentId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _store.events.where((e) => e.registeredStudentIds.contains(studentId)).toList();
  }

  @override
  Future<List<EventModel>> getClubEvents(String clubId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _store.events.where((e) => e.clubId == clubId).toList();
  }

  @override
  Future<EventModel?> getEventById(String eventId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _store.events.firstWhere(
      (e) => e.id == eventId,
      orElse: () => _store.events.first,
    );
  }

  @override
  Future<EventModel> createEvent(EventModel event) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _store.events.insert(0, event);
    return event;
  }

  @override
  Future<void> updateEvent(EventModel event) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final index = _store.events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      _store.events[index] = event;
    }
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _store.events.removeWhere((e) => e.id == eventId);
  }

  @override
  Future<bool> toggleEventRegistration(String eventId, String studentId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final index = _store.events.indexWhere((e) => e.id == eventId);
    if (index == -1) return false;

    final event = _store.events[index];
    final isRegistered = event.registeredStudentIds.contains(studentId);
    final updatedList = List<String>.from(event.registeredStudentIds);

    if (isRegistered) {
      updatedList.remove(studentId);
    } else {
      if (event.isFull) return false;
      updatedList.add(studentId);
    }

    _store.events[index] = event.copyWith(registeredStudentIds: updatedList);

    // Sync student model
    final studentIndex = _store.students.indexWhere((s) => s.id == studentId);
    if (studentIndex != -1) {
      final student = _store.students[studentIndex];
      final registered = List<String>.from(student.registeredEventIds);
      if (isRegistered) {
        registered.remove(eventId);
      } else {
        registered.add(eventId);
      }
      _store.students[studentIndex] = student.copyWith(
        registeredEventIds: registered,
        points: isRegistered ? student.points : student.points + 75, // +75 pts for registering
      );
      if (_store.currentUser?.id == studentId) {
        _store.currentUser = _store.students[studentIndex];
      }
    }

    return !isRegistered;
  }

  @override
  Future<List<UserModel>> getEventParticipants(String eventId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final event = _store.events.firstWhere((e) => e.id == eventId, orElse: () => _store.events.first);
    return _store.students.where((s) => event.registeredStudentIds.contains(s.id)).toList();
  }
}
