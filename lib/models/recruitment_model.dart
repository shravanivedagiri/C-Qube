import '../core/constants/app_constants.dart';

class RecruitmentDrive {
  final String id;
  final String clubId;
  final String clubName;
  final String title;
  final String description;
  final List<String> openPositions;
  final String eligibility;
  final List<String> skillsRequired;
  final DateTime deadline;
  final List<String> questions;
  final String bannerUrl;
  final bool isOpen;
  final int applicantCount;
  final DateTime createdAt;

  RecruitmentDrive({
    required this.id,
    required this.clubId,
    required this.clubName,
    required this.title,
    required this.description,
    required this.openPositions,
    this.eligibility = 'Open to all years',
    this.skillsRequired = const [],
    required this.deadline,
    this.questions = const [],
    this.bannerUrl = '',
    this.isOpen = true,
    this.applicantCount = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isExpired => DateTime.now().isAfter(deadline);

  RecruitmentDrive copyWith({
    String? id,
    String? clubId,
    String? clubName,
    String? title,
    String? description,
    List<String>? openPositions,
    String? eligibility,
    List<String>? skillsRequired,
    DateTime? deadline,
    List<String>? questions,
    String? bannerUrl,
    bool? isOpen,
    int? applicantCount,
    DateTime? createdAt,
  }) {
    return RecruitmentDrive(
      id: id ?? this.id,
      clubId: clubId ?? this.clubId,
      clubName: clubName ?? this.clubName,
      title: title ?? this.title,
      description: description ?? this.description,
      openPositions: openPositions ?? this.openPositions,
      eligibility: eligibility ?? this.eligibility,
      skillsRequired: skillsRequired ?? this.skillsRequired,
      deadline: deadline ?? this.deadline,
      questions: questions ?? this.questions,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      isOpen: isOpen ?? this.isOpen,
      applicantCount: applicantCount ?? this.applicantCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class RecruitmentApplication {
  final String id;
  final String recruitmentId;
  final String recruitmentTitle;
  final String clubId;
  final String clubName;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final String studentDepartment;
  final String studentYear;
  final String positionApplied;
  final Map<String, String> answers;
  final ApplicationStatus status;
  final String notes;
  final DateTime submittedAt;

  RecruitmentApplication({
    required this.id,
    required this.recruitmentId,
    required this.recruitmentTitle,
    required this.clubId,
    required this.clubName,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.studentDepartment,
    required this.studentYear,
    required this.positionApplied,
    required this.answers,
    this.status = ApplicationStatus.applied,
    this.notes = '',
    DateTime? submittedAt,
  }) : submittedAt = submittedAt ?? DateTime.now();

  RecruitmentApplication copyWith({
    String? id,
    String? recruitmentId,
    String? recruitmentTitle,
    String? clubId,
    String? clubName,
    String? studentId,
    String? studentName,
    String? studentEmail,
    String? studentDepartment,
    String? studentYear,
    String? positionApplied,
    Map<String, String>? answers,
    ApplicationStatus? status,
    String? notes,
    DateTime? submittedAt,
  }) {
    return RecruitmentApplication(
      id: id ?? this.id,
      recruitmentId: recruitmentId ?? this.recruitmentId,
      recruitmentTitle: recruitmentTitle ?? this.recruitmentTitle,
      clubId: clubId ?? this.clubId,
      clubName: clubName ?? this.clubName,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentEmail: studentEmail ?? this.studentEmail,
      studentDepartment: studentDepartment ?? this.studentDepartment,
      studentYear: studentYear ?? this.studentYear,
      positionApplied: positionApplied ?? this.positionApplied,
      answers: answers ?? this.answers,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      submittedAt: submittedAt ?? this.submittedAt,
    );
  }
}
