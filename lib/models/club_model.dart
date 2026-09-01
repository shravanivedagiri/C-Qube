import '../core/constants/app_constants.dart';

class ClubModel {
  final String id;
  final String name;
  final String email;
  final String logoUrl;
  final String bannerUrl;
  final String about;
  final ClubCategory category;
  final String department;
  final bool isApproved;
  final bool isProfileCompleted;
  final String coordinatorName;
  final String coordinatorEmail;
  final String contactInfo;
  final Map<String, String> socialLinks;
  final int memberCount;
  final bool isBeginnerFriendly;
  final List<String> followerStudentIds;
  final List<String> memberStudentIds;
  final DateTime createdAt;

  ClubModel({
    required this.id,
    required this.name,
    required this.email,
    this.logoUrl = '',
    this.bannerUrl = '',
    this.about = '',
    required this.category,
    this.department = 'All Departments',
    this.isApproved = true,
    this.isProfileCompleted = true,
    this.coordinatorName = '',
    this.coordinatorEmail = '',
    this.contactInfo = '',
    this.socialLinks = const {},
    this.memberCount = 0,
    this.isBeginnerFriendly = true,
    this.followerStudentIds = const [],
    this.memberStudentIds = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  ClubModel copyWith({
    String? id,
    String? name,
    String? email,
    String? logoUrl,
    String? bannerUrl,
    String? about,
    ClubCategory? category,
    String? department,
    bool? isApproved,
    bool? isProfileCompleted,
    String? coordinatorName,
    String? coordinatorEmail,
    String? contactInfo,
    Map<String, String>? socialLinks,
    int? memberCount,
    bool? isBeginnerFriendly,
    List<String>? followerStudentIds,
    List<String>? memberStudentIds,
    DateTime? createdAt,
  }) {
    return ClubModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      logoUrl: logoUrl ?? this.logoUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      about: about ?? this.about,
      category: category ?? this.category,
      department: department ?? this.department,
      isApproved: isApproved ?? this.isApproved,
      isProfileCompleted: isProfileCompleted ?? this.isProfileCompleted,
      coordinatorName: coordinatorName ?? this.coordinatorName,
      coordinatorEmail: coordinatorEmail ?? this.coordinatorEmail,
      contactInfo: contactInfo ?? this.contactInfo,
      socialLinks: socialLinks ?? this.socialLinks,
      memberCount: memberCount ?? this.memberCount,
      isBeginnerFriendly: isBeginnerFriendly ?? this.isBeginnerFriendly,
      followerStudentIds: followerStudentIds ?? this.followerStudentIds,
      memberStudentIds: memberStudentIds ?? this.memberStudentIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ClubRegistrationRequest {
  final String id;
  final String clubName;
  final String clubEmail;
  final String coordinatorName;
  final String coordinatorEmail;
  final String department;
  final String description;
  final String reason;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime createdAt;

  ClubRegistrationRequest({
    required this.id,
    required this.clubName,
    required this.clubEmail,
    required this.coordinatorName,
    required this.coordinatorEmail,
    required this.department,
    required this.description,
    required this.reason,
    this.status = 'pending',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
