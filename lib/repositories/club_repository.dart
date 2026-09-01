import '../core/constants/app_constants.dart';
import '../models/club_model.dart';
import '../models/user_model.dart';
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
}
