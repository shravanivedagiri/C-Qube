import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/club_model.dart';
import '../models/event_model.dart';
import '../models/post_model.dart';
import '../models/gallery_item_model.dart';
import '../models/recruitment_model.dart';
import '../models/analytics_model.dart';
import '../models/user_model.dart';
import '../models/club_join_request_model.dart';
import '../repositories/club_repository.dart';
import '../repositories/event_repository.dart';
import '../repositories/post_repository.dart';
import '../repositories/gallery_repository.dart';
import '../repositories/recruitment_repository.dart';
import '../repositories/analytics_repository.dart';

class ClubState extends ChangeNotifier {
  final ClubRepository _clubRepository;
  final EventRepository _eventRepository;
  final PostRepository _postRepository;
  final GalleryRepository _galleryRepository;
  final RecruitmentRepository _recruitmentRepository;
  final AnalyticsRepository _analyticsRepository;

  ClubModel? _currentClub;
  List<EventModel> _clubEvents = [];
  List<PostModel> _clubPosts = [];
  List<GalleryItemModel> _clubGallery = [];
  List<RecruitmentDrive> _clubDrives = [];
  List<RecruitmentApplication> _clubApplications = [];
  List<ClubJoinRequest> _joinRequests = [];
  ClubAnalyticsModel? _analytics;
  bool _isLoading = false;

  ClubState({
    ClubRepository? clubRepository,
    EventRepository? eventRepository,
    PostRepository? postRepository,
    GalleryRepository? galleryRepository,
    RecruitmentRepository? recruitmentRepository,
    AnalyticsRepository? analyticsRepository,
  })  : _clubRepository = clubRepository ?? MockClubRepository(),
        _eventRepository = eventRepository ?? MockEventRepository(),
        _postRepository = postRepository ?? MockPostRepository(),
        _galleryRepository = galleryRepository ?? MockGalleryRepository(),
        _recruitmentRepository = recruitmentRepository ?? MockRecruitmentRepository(),
        _analyticsRepository = analyticsRepository ?? MockAnalyticsRepository();

  ClubModel? get currentClub => _currentClub;
  List<EventModel> get clubEvents => _clubEvents;
  List<PostModel> get clubPosts => _clubPosts;
  List<GalleryItemModel> get clubGallery => _clubGallery;
  List<RecruitmentDrive> get clubDrives => _clubDrives;
  List<RecruitmentApplication> get clubApplications => _clubApplications;
  List<ClubJoinRequest> get joinRequests => _joinRequests;
  ClubAnalyticsModel? get analytics => _analytics;
  bool get isLoading => _isLoading;

  void setCurrentClub(ClubModel club) {
    _currentClub = club;
    loadClubData(club.id);
  }

  Future<void> loadClubData(String clubId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _eventRepository.getClubEvents(clubId),
        _postRepository.getClubPosts(clubId),
        _galleryRepository.getClubGallery(clubId),
        _recruitmentRepository.getClubDrives(clubId),
        _recruitmentRepository.getClubApplications(clubId),
        _analyticsRepository.getClubAnalytics(clubId),
      ]);

      _clubEvents = results[0] as List<EventModel>;
      _clubPosts = results[1] as List<PostModel>;
      _clubGallery = results[2] as List<GalleryItemModel>;
      _clubDrives = results[3] as List<RecruitmentDrive>;
      _clubApplications = results[4] as List<RecruitmentApplication>;
      _analytics = results[5] as ClubAnalyticsModel;
      _joinRequests = await _clubRepository.getClubJoinRequests(clubId);
    } catch (e) {
      debugPrint('Error loading club data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createEvent(EventModel event) async {
    await _eventRepository.createEvent(event);
    if (_currentClub != null) {
      _clubEvents = await _eventRepository.getClubEvents(_currentClub!.id);
      notifyListeners();
    }
  }

  Future<void> createPost(PostModel post) async {
    await _postRepository.createPost(post);
    if (_currentClub != null) {
      _clubPosts = await _postRepository.getClubPosts(_currentClub!.id);
      notifyListeners();
    }
  }

  Future<void> createRecruitmentDrive(RecruitmentDrive drive) async {
    await _recruitmentRepository.createDrive(drive);
    if (_currentClub != null) {
      _clubDrives = await _recruitmentRepository.getClubDrives(_currentClub!.id);
      notifyListeners();
    }
  }

  Future<void> uploadGalleryItem(GalleryItemModel item) async {
    await _galleryRepository.uploadMediaItem(item);
    if (_currentClub != null) {
      _clubGallery = await _galleryRepository.getClubGallery(_currentClub!.id);
      notifyListeners();
    }
  }

  Future<void> updateApplicationStatus(String applicationId, ApplicationStatus newStatus, {String? notes}) async {
    await _recruitmentRepository.updateApplicationStatus(applicationId, newStatus, notes: notes);
    if (_currentClub != null) {
      _clubApplications = await _recruitmentRepository.getClubApplications(_currentClub!.id);
      notifyListeners();
    }
  }

  Future<void> updateClubProfile(ClubModel updated) async {
    await _clubRepository.updateClubProfile(updated);
    _currentClub = updated;
    notifyListeners();
  }

  Future<List<UserModel>> getEventParticipants(String eventId) async {
    return await _eventRepository.getEventParticipants(eventId);
  }

  Future<void> respondToJoinRequest(String requestId, bool approve) async {
    await _clubRepository.respondToJoinRequest(requestId, approve);
    if (_currentClub != null) {
      _joinRequests = await _clubRepository.getClubJoinRequests(_currentClub!.id);
      _currentClub = await _clubRepository.getClubById(_currentClub!.id);
      notifyListeners();
    }
  }
}
