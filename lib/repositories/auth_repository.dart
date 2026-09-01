import '../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/club_model.dart';
import '../services/mock_data_store.dart';

abstract class AuthRepository {
  Future<UserModel> loginStudent(String email, String password);
  Future<UserModel> registerStudent({
    required String name,
    required String email,
    required String password,
    required String department,
    required String year,
    required List<String> interests,
    required List<String> skills,
    required String goals,
    required String bio,
  });
  Future<ClubModel?> loginClub(String email, String password);
  Future<void> requestClubRegistration({
    required String clubName,
    required String clubEmail,
    required String coordinatorName,
    required String coordinatorEmail,
    required String department,
    required String description,
    required String reason,
  });
  Future<ClubModel> completeClubProfile({
    required String clubId,
    required String name,
    required String logoUrl,
    required String bannerUrl,
    required String about,
    required ClubCategory category,
    required String department,
    required String contactInfo,
    required Map<String, String> socialLinks,
  });
  Future<void> logout();
  UserModel? getCurrentStudent();
  ClubModel? getCurrentClub();
}

class MockAuthRepository implements AuthRepository {
  final MockDataStore _store = MockDataStore();

  @override
  Future<UserModel> loginStudent(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final student = _store.students.firstWhere(
      (s) => s.email.toLowerCase() == email.trim().toLowerCase(),
      orElse: () => _store.students.first,
    );
    _store.currentUser = student;
    return student;
  }

  @override
  Future<UserModel> registerStudent({
    required String name,
    required String email,
    required String password,
    required String department,
    required String year,
    required List<String> interests,
    required List<String> skills,
    required String goals,
    required String bio,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final newStudent = UserModel(
      id: 'student_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      role: UserRole.student,
      department: department,
      year: year,
      interests: interests,
      skills: skills,
      goals: goals,
      bio: bio,
      points: 0,
    );
    _store.students.add(newStudent);
    _store.currentUser = newStudent;
    return newStudent;
  }

  @override
  Future<ClubModel?> loginClub(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final matchingClubs = _store.clubs.where(
      (c) => c.email.toLowerCase() == email.trim().toLowerCase(),
    );

    if (matchingClubs.isEmpty) {
      // Club not found in approved database
      return null;
    }

    final club = matchingClubs.first;
    _store.currentClub = club;
    return club;
  }

  @override
  Future<void> requestClubRegistration({
    required String clubName,
    required String clubEmail,
    required String coordinatorName,
    required String coordinatorEmail,
    required String department,
    required String description,
    required String reason,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));
    final request = ClubRegistrationRequest(
      id: 'req_${DateTime.now().millisecondsSinceEpoch}',
      clubName: clubName,
      clubEmail: clubEmail,
      coordinatorName: coordinatorName,
      coordinatorEmail: coordinatorEmail,
      department: department,
      description: description,
      reason: reason,
      status: 'pending',
    );
    _store.clubRequests.add(request);
  }

  @override
  Future<ClubModel> completeClubProfile({
    required String clubId,
    required String name,
    required String logoUrl,
    required String bannerUrl,
    required String about,
    required ClubCategory category,
    required String department,
    required String contactInfo,
    required Map<String, String> socialLinks,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));
    final index = _store.clubs.indexWhere((c) => c.id == clubId);
    if (index != -1) {
      final updated = _store.clubs[index].copyWith(
        name: name,
        logoUrl: logoUrl,
        bannerUrl: bannerUrl,
        about: about,
        category: category,
        department: department,
        contactInfo: contactInfo,
        socialLinks: socialLinks,
        isProfileCompleted: true,
      );
      _store.clubs[index] = updated;
      _store.currentClub = updated;
      return updated;
    }
    throw Exception('Club not found');
  }

  @override
  Future<void> logout() async {
    _store.currentUser = null;
    _store.currentClub = null;
  }

  @override
  UserModel? getCurrentStudent() => _store.currentUser;

  @override
  ClubModel? getCurrentClub() => _store.currentClub;
}
