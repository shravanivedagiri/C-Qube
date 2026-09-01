import '../core/constants/app_constants.dart';
import '../models/club_model.dart';
import '../models/user_model.dart';
import '../models/club_join_request_model.dart';
import '../services/mock_data_store.dart';

abstract class ClubRepository {
  Future<List<ClubModel>> getAllClubs({
    String? searchQuery,
    ClubCategory? category,
    String? department,
    bool? beginnerFriendlyOnly,
  });
  Future<ClubModel?> getClubById(String clubId);
  Future<List<ClubModel>> getRecommendedClubs(UserModel student);
  Future<void> updateClubProfile(ClubModel club);
  Future<void> toggleJoinClub(String clubId, String studentId);
  Future<void> toggleFollowClub(String clubId, String studentId);
  Future<void> submitJoinRequest({
    required String clubId,
    required String clubName,
    required String studentId,
    required String studentName,
    required String studentEmail,
    String studentDepartment,
  });
  Future<List<ClubJoinRequest>> getClubJoinRequests(String clubId);
  Future<List<ClubJoinRequest>> getStudentJoinRequests(String studentId);
  Future<void> respondToJoinRequest(String requestId, bool approve);
}

class MockClubRepository implements ClubRepository {
  final MockDataStore _store = MockDataStore();

  @override
  Future<List<ClubModel>> getAllClubs({
    String? searchQuery,
    ClubCategory? category,
    String? department,
    bool? beginnerFriendlyOnly,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _store.clubs.where((c) {
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final matchesName = c.name.toLowerCase().contains(q);
        final matchesAbout = c.about.toLowerCase().contains(q);
        final matchesDept = c.department.toLowerCase().contains(q);
        if (!matchesName && !matchesAbout && !matchesDept) return false;
      }
      if (category != null && c.category != category) return false;
      if (department != null &&
          department != 'All' &&
          c.department != department &&
          c.department != 'All Departments') {
        return false;
      }
      if (beginnerFriendlyOnly == true && !c.isBeginnerFriendly) return false;
      return true;
    }).toList();
  }

  @override
  Future<ClubModel?> getClubById(String clubId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _store.clubs.firstWhere(
      (c) => c.id == clubId,
      orElse: () => _store.clubs.first,
    );
  }

  @override
  Future<List<ClubModel>> getRecommendedClubs(UserModel student) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Score based on student interests and department
    final list = List<ClubModel>.from(_store.clubs);
    list.sort((a, b) {
      int scoreA = 0;
      int scoreB = 0;

      if (a.department == student.department) scoreA += 2;
      if (b.department == student.department) scoreB += 2;

      for (final interest in student.interests) {
        if (a.about.toLowerCase().contains(interest.toLowerCase())) scoreA += 3;
        if (b.about.toLowerCase().contains(interest.toLowerCase())) scoreB += 3;
      }

      return scoreB.compareTo(scoreA);
    });
    return list;
  }

  @override
  Future<void> updateClubProfile(ClubModel updatedClub) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final index = _store.clubs.indexWhere((c) => c.id == updatedClub.id);
    if (index != -1) {
      _store.clubs[index] = updatedClub;
      if (_store.currentClub?.id == updatedClub.id) {
        _store.currentClub = updatedClub;
      }
    }
  }

  @override
  Future<void> toggleJoinClub(String clubId, String studentId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _store.clubs.indexWhere((c) => c.id == clubId);
    if (index != -1) {
      final club = _store.clubs[index];
      final isMember = club.memberStudentIds.contains(studentId);
      final updatedMembers = List<String>.from(club.memberStudentIds);
      final updatedFollowers = List<String>.from(club.followerStudentIds);

      if (isMember) {
        updatedMembers.remove(studentId);
      } else {
        updatedMembers.add(studentId);
        if (!updatedFollowers.contains(studentId)) updatedFollowers.add(studentId);
      }

      _store.clubs[index] = club.copyWith(
        memberStudentIds: updatedMembers,
        followerStudentIds: updatedFollowers,
        memberCount: isMember ? club.memberCount - 1 : club.memberCount + 1,
      );

      // Update current student joined clubs list
      final studentIndex = _store.students.indexWhere((s) => s.id == studentId);
      if (studentIndex != -1) {
        final st = _store.students[studentIndex];
        final joined = List<String>.from(st.joinedClubIds);
        if (isMember) {
          joined.remove(clubId);
        } else {
          joined.add(clubId);
        }
        _store.students[studentIndex] = st.copyWith(
          joinedClubIds: joined,
          points: isMember ? st.points : st.points + 50, // +50 points for joining club
        );
        if (_store.currentUser?.id == studentId) {
          _store.currentUser = _store.students[studentIndex];
        }
      }
    }
  }

  @override
  Future<void> toggleFollowClub(String clubId, String studentId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _store.clubs.indexWhere((c) => c.id == clubId);
    if (index != -1) {
      final club = _store.clubs[index];
      final isFollowing = club.followerStudentIds.contains(studentId);
      final updatedFollowers = List<String>.from(club.followerStudentIds);

      if (isFollowing) {
        updatedFollowers.remove(studentId);
      } else {
        updatedFollowers.add(studentId);
      }

      _store.clubs[index] = club.copyWith(followerStudentIds: updatedFollowers);
    }
  }

  @override
  Future<void> submitJoinRequest({
    required String clubId,
    required String clubName,
    required String studentId,
    required String studentName,
    required String studentEmail,
    String studentDepartment = '',
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Supabase Storage / DB Placeholder:
    // await supabase.from('club_join_requests').insert({
    //   'club_id': clubId,
    //   'student_id': studentId,
    //   'status': 'pending',
    // });

    final exists = _store.clubJoinRequests.any(
      (r) => r.clubId == clubId && r.studentId == studentId && r.status == ClubJoinRequestStatus.pending,
    );
    if (exists) return;

    final request = ClubJoinRequest(
      id: 'req_${DateTime.now().millisecondsSinceEpoch}',
      clubId: clubId,
      clubName: clubName,
      studentId: studentId,
      studentName: studentName,
      studentEmail: studentEmail,
      studentDepartment: studentDepartment,
      status: ClubJoinRequestStatus.pending,
    );
    _store.clubJoinRequests.add(request);
  }

  @override
  Future<List<ClubJoinRequest>> getClubJoinRequests(String clubId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _store.clubJoinRequests.where((r) => r.clubId == clubId).toList();
  }

  @override
  Future<List<ClubJoinRequest>> getStudentJoinRequests(String studentId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _store.clubJoinRequests.where((r) => r.studentId == studentId).toList();
  }

  @override
  Future<void> respondToJoinRequest(String requestId, bool approve) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _store.clubJoinRequests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      final req = _store.clubJoinRequests[index];
      final newStatus = approve ? ClubJoinRequestStatus.approved : ClubJoinRequestStatus.rejected;
      _store.clubJoinRequests[index] = req.copyWith(status: newStatus);

      if (approve) {
        // Add student to club members
        final clubIndex = _store.clubs.indexWhere((c) => c.id == req.clubId);
        if (clubIndex != -1) {
          final club = _store.clubs[clubIndex];
          if (!club.memberStudentIds.contains(req.studentId)) {
            final members = List<String>.from(club.memberStudentIds)..add(req.studentId);
            _store.clubs[clubIndex] = club.copyWith(
              memberStudentIds: members,
              memberCount: club.memberCount + 1,
            );
            if (_store.currentClub?.id == club.id) {
              _store.currentClub = _store.clubs[clubIndex];
            }
          }
        }

        // Add club to student's joinedClubIds
        final studentIndex = _store.students.indexWhere((s) => s.id == req.studentId);
        if (studentIndex != -1) {
          final student = _store.students[studentIndex];
          if (!student.joinedClubIds.contains(req.clubId)) {
            final joined = List<String>.from(student.joinedClubIds)..add(req.clubId);
            _store.students[studentIndex] = student.copyWith(joinedClubIds: joined);
            if (_store.currentUser?.id == student.id) {
              _store.currentUser = _store.students[studentIndex];
            }
          }
        }
      }
    }
  }
}
