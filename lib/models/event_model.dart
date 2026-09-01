import '../core/constants/app_constants.dart';

class EventModel {
  final String id;
  final String clubId;
  final String clubName;
  final String clubLogoUrl;
  final String title;
  final String description;
  final String bannerUrl;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final int capacity;
  final List<String> registeredStudentIds;
  final DateTime registrationDeadline;
  final EventCategory category;
  final String department;
  final bool isOnline;
  final bool isBeginnerFriendly;
  final bool isDraft;
  final String organizerName;
  final DateTime createdAt;

  EventModel({
    required this.id,
    required this.clubId,
    required this.clubName,
    this.clubLogoUrl = '',
    required this.title,
    required this.description,
    this.bannerUrl = '',
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.location,
    this.capacity = 100,
    this.registeredStudentIds = const [],
    required this.registrationDeadline,
    required this.category,
    this.department = 'All Departments',
    this.isOnline = false,
    this.isBeginnerFriendly = true,
    this.isDraft = false,
    this.organizerName = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  int get registeredCount => registeredStudentIds.length;
  int get availableSeats => (capacity - registeredCount).clamp(0, capacity);
  bool get isFull => registeredCount >= capacity;
  bool get isRegistrationClosed => DateTime.now().isAfter(registrationDeadline) || isFull;
  bool isRegisteredBy(String studentId) => registeredStudentIds.contains(studentId);

  EventModel copyWith({
    String? id,
    String? clubId,
    String? clubName,
    String? clubLogoUrl,
    String? title,
    String? description,
    String? bannerUrl,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    int? capacity,
    List<String>? registeredStudentIds,
    DateTime? registrationDeadline,
    EventCategory? category,
    String? department,
    bool? isOnline,
    bool? isBeginnerFriendly,
    bool? isDraft,
    String? organizerName,
    DateTime? createdAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      clubId: clubId ?? this.clubId,
      clubName: clubName ?? this.clubName,
      clubLogoUrl: clubLogoUrl ?? this.clubLogoUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      capacity: capacity ?? this.capacity,
      registeredStudentIds: registeredStudentIds ?? this.registeredStudentIds,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      category: category ?? this.category,
      department: department ?? this.department,
      isOnline: isOnline ?? this.isOnline,
      isBeginnerFriendly: isBeginnerFriendly ?? this.isBeginnerFriendly,
      isDraft: isDraft ?? this.isDraft,
      organizerName: organizerName ?? this.organizerName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
