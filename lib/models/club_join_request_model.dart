enum ClubJoinRequestStatus { pending, approved, rejected }

class ClubJoinRequest {
  final String id;
  final String clubId;
  final String clubName;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final String studentDepartment;
  final ClubJoinRequestStatus status;
  final DateTime createdAt;

  ClubJoinRequest({
    required this.id,
    required this.clubId,
    required this.clubName,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    this.studentDepartment = '',
    this.status = ClubJoinRequestStatus.pending,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  ClubJoinRequest copyWith({
    String? id,
    String? clubId,
    String? clubName,
    String? studentId,
    String? studentName,
    String? studentEmail,
    String? studentDepartment,
    ClubJoinRequestStatus? status,
    DateTime? createdAt,
  }) {
    return ClubJoinRequest(
      id: id ?? this.id,
      clubId: clubId ?? this.clubId,
      clubName: clubName ?? this.clubName,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentEmail: studentEmail ?? this.studentEmail,
      studentDepartment: studentDepartment ?? this.studentDepartment,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
