import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/club_model.dart';
import '../models/event_model.dart';
import '../models/post_model.dart';
import '../models/friend_model.dart';
import '../models/genie_message_model.dart';
import '../models/club_join_request_model.dart';
import '../repositories/club_repository.dart';
import '../repositories/event_repository.dart';
import '../repositories/post_repository.dart';
import '../repositories/friend_repository.dart';
import '../repositories/genie_repository.dart';
import '../services/mock_data_store.dart';

class StudentState extends ChangeNotifier {
  final ClubRepository _clubRepository;
  final EventRepository _eventRepository;
  final PostRepository _postRepository;
  final FriendRepository _friendRepository;
  final GenieRepository _genieRepository;

  List<ClubModel> _recommendedClubs = [];
  List<ClubModel> _allClubs = [];
  List<EventModel> _upcomingEvents = [];
  List<EventModel> _allEvents = [];
  List<EventModel> _myRegisteredEvents = [];
  List<PostModel> _feedPosts = [];
  List<UserModel> _friends = [];
  List<UserModel> _allStudents = [];
  List<UserModel> _pendingRequests = [];
  List<FriendActivityItem> _friendActivities = [];
  List<GenieMessageModel> _genieMessages = [];
  List<ClubJoinRequest> _myJoinRequests = [];
  bool _isLoading = false;

  StudentState({
    ClubRepository? clubRepository,
    EventRepository? eventRepository,
    PostRepository? postRepository,
    FriendRepository? friendRepository,
    GenieRepository? genieRepository,
  })  : _clubRepository = clubRepository ?? MockClubRepository(),
        _eventRepository = eventRepository ?? MockEventRepository(),
        _postRepository = postRepository ?? MockPostRepository(),
        _friendRepository = friendRepository ?? MockFriendRepository(),
        _genieRepository = genieRepository ?? MockGenieRepository() {
    _initGenie();
    _initStudents();
  }

  void _initGenie() async {
    _genieMessages = await _genieRepository.getConversationHistory();
    notifyListeners();
  }

  void _initStudents() {
    final store = MockDataStore();
    _allStudents = store.students;
  }

  List<ClubModel> get recommendedClubs => _recommendedClubs;
  List<ClubModel> get allClubs => _allClubs;
  List<EventModel> get upcomingEvents => _upcomingEvents;
  List<EventModel> get allEvents => _allEvents;
  List<EventModel> get myRegisteredEvents => _myRegisteredEvents;
  List<PostModel> get feedPosts => _feedPosts;
  List<UserModel> get friends => _friends;
  List<UserModel> get allStudents => _allStudents;
  List<UserModel> get pendingRequests => _pendingRequests;
  List<FriendActivityItem> get friendActivities => _friendActivities;
  List<GenieMessageModel> get genieMessages => _genieMessages;
  List<ClubJoinRequest> get myJoinRequests => _myJoinRequests;
  bool get isLoading => _isLoading;

  Future<void> loadDashboardData(UserModel student) async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _clubRepository.getRecommendedClubs(student),
        _clubRepository.getAllClubs(),
        _eventRepository.getUpcomingEvents(),
        _eventRepository.getAllEvents(),
        _eventRepository.getRegisteredEventsForStudent(student.id),
        _postRepository.getFeedPosts(),
        _friendRepository.getFriendsForStudent(student.id),
        _friendRepository.getFriendActivityFeed(student.id),
      ]);

      _recommendedClubs = results[0] as List<ClubModel>;
      _allClubs = results[1] as List<ClubModel>;
      _upcomingEvents = results[2] as List<EventModel>;
      _allEvents = results[3] as List<EventModel>;
      _myRegisteredEvents = results[4] as List<EventModel>;
      _feedPosts = results[5] as List<PostModel>;
      _friends = results[6] as List<UserModel>;
      _friendActivities = results[7] as List<FriendActivityItem>;
      _pendingRequests = _allStudents.where((s) => s.id == 'user_std_002').toList();
      _myJoinRequests = await _clubRepository.getStudentJoinRequests(student.id);
    } catch (e) {
      debugPrint('Error loading student dashboard: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshEvents(String studentId) async {
    _allEvents = await _eventRepository.getAllEvents();
    _upcomingEvents = await _eventRepository.getUpcomingEvents();
    _myRegisteredEvents = await _eventRepository.getRegisteredEventsForStudent(studentId);
    notifyListeners();
  }

  Future<void> refreshClubs(UserModel student) async {
    _allClubs = await _clubRepository.getAllClubs();
    _recommendedClubs = await _clubRepository.getRecommendedClubs(student);
    notifyListeners();
  }

  Future<bool> toggleEventRegistration(String eventId, String studentId) async {
    final success = await _eventRepository.toggleEventRegistration(eventId, studentId);
    await refreshEvents(studentId);
    return success;
  }

  Future<void> toggleJoinClub(String clubId, UserModel student) async {
    await _clubRepository.toggleJoinClub(clubId, student.id);
    await refreshClubs(student);
  }

  Future<void> loadAllEvents() async {
    _allEvents = await _eventRepository.getAllEvents();
    _upcomingEvents = await _eventRepository.getUpcomingEvents();
    notifyListeners();
  }

  Future<void> toggleFollowClub(String clubId, String studentId) async {
    await _clubRepository.toggleFollowClub(clubId, studentId);
    _allClubs = await _clubRepository.getAllClubs();
    notifyListeners();
  }

  Future<void> sendFriendRequest(String senderId, String receiverId) async {
    await _friendRepository.sendFriendRequest(senderId, receiverId);
    notifyListeners();
  }

  Future<void> acceptFriendRequest(String senderId, String receiverId) async {
    await _friendRepository.respondFriendRequest(senderId, receiverId, true);
    _pendingRequests.removeWhere((s) => s.id == senderId);
    _friends = await _friendRepository.getFriendsForStudent(receiverId);
    notifyListeners();
  }

  Future<void> rejectFriendRequest(String senderId, String receiverId) async {
    await _friendRepository.respondFriendRequest(senderId, receiverId, false);
    _pendingRequests.removeWhere((s) => s.id == senderId);
    notifyListeners();
  }

  bool hasPendingRequestWith(String studentId) {
    return _pendingRequests.any((s) => s.id == studentId);
  }

  Future<void> askGenie(String query) async {
    await _genieRepository.sendMessage(query);
    _genieMessages = await _genieRepository.getConversationHistory();
    notifyListeners();
  }

  Future<void> loadMyJoinRequests(String studentId) async {
    _myJoinRequests = await _clubRepository.getStudentJoinRequests(studentId);
    notifyListeners();
  }

  Future<void> submitClubJoinRequest({
    required String clubId,
    required String clubName,
    required UserModel student,
  }) async {
    await _clubRepository.submitJoinRequest(
      clubId: clubId,
      clubName: clubName,
      studentId: student.id,
      studentName: student.name,
      studentEmail: student.email,
      studentDepartment: student.department,
    );
    await loadMyJoinRequests(student.id);
  }
}
