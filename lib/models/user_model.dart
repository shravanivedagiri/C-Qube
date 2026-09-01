import '../core/constants/app_constants.dart';

class StudentPrivacySettings {
  final bool showJoinedClubs;
  final bool showRegisteredEvents;
  final bool showPoints;
  final bool showActivityTimeline;

  StudentPrivacySettings({
    this.showJoinedClubs = true,
    this.showRegisteredEvents = true,
    this.showPoints = true,
    this.showActivityTimeline = true,
  });

  StudentPrivacySettings copyWith({
    bool? showJoinedClubs,
    bool? showRegisteredEvents,
    bool? showPoints,
    bool? showActivityTimeline,
  }) {
    return StudentPrivacySettings(
      showJoinedClubs: showJoinedClubs ?? this.showJoinedClubs,
      showRegisteredEvents: showRegisteredEvents ?? this.showRegisteredEvents,
      showPoints: showPoints ?? this.showPoints,
      showActivityTimeline: showActivityTimeline ?? this.showActivityTimeline,
    );
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final UserRole role;
  final String department;
  final String year;
  final String bio;
  final List<String> interests;
  final List<String> skills;
  final String goals;
  final int points;
  final List<String> joinedClubIds;
  final List<String> registeredEventIds;
  final List<String> friendIds;
  final StudentPrivacySettings privacySettings;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl = '',
    required this.role,
    this.department = '',
    this.year = '',
    this.bio = '',
    this.interests = const [],
    this.skills = const [],
    this.goals = '',
    this.points = 0,
    this.joinedClubIds = const [],
    this.registeredEventIds = const [],
    this.friendIds = const [],
    StudentPrivacySettings? privacySettings,
    DateTime? createdAt,
  })  : privacySettings = privacySettings ?? StudentPrivacySettings(),
        createdAt = createdAt ?? DateTime.now();

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    UserRole? role,
    String? department,
    String? year,
    String? bio,
    List<String>? interests,
    List<String>? skills,
    String? goals,
    int? points,
    List<String>? joinedClubIds,
    List<String>? registeredEventIds,
    List<String>? friendIds,
    StudentPrivacySettings? privacySettings,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      department: department ?? this.department,
      year: year ?? this.year,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      skills: skills ?? this.skills,
      goals: goals ?? this.goals,
      points: points ?? this.points,
      joinedClubIds: joinedClubIds ?? this.joinedClubIds,
      registeredEventIds: registeredEventIds ?? this.registeredEventIds,
      friendIds: friendIds ?? this.friendIds,
      privacySettings: privacySettings ?? this.privacySettings,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
