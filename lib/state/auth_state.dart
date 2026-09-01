import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/club_model.dart';
import '../repositories/auth_repository.dart';

class AuthState extends ChangeNotifier {
  final AuthRepository _authRepository;

  UserModel? _currentStudent;
  ClubModel? _currentClub;
  UserRole? _activeRole;
  bool _isLoading = false;
  String? _errorMessage;

  AuthState({AuthRepository? authRepository})
      : _authRepository = authRepository ?? MockAuthRepository() {
    _initSession();
  }

  Future<void> _initSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final roleStr = prefs.getString('auth_role');
      if (roleStr == 'student') {
        _currentStudent = _authRepository.getCurrentStudent();
        _activeRole = UserRole.student;
      } else if (roleStr == 'club') {
        _currentClub = _authRepository.getCurrentClub();
        _activeRole = UserRole.club;
      } else {
        _currentStudent = _authRepository.getCurrentStudent();
        if (_currentStudent != null) _activeRole = UserRole.student;
      }
    } catch (_) {
      _currentStudent = _authRepository.getCurrentStudent();
      _currentClub = _authRepository.getCurrentClub();
      if (_currentStudent != null) _activeRole = UserRole.student;
    }
    notifyListeners();
  }

  UserModel? get currentStudent => _currentStudent;
  ClubModel? get currentClub => _currentClub;
  UserRole? get activeRole => _activeRole;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated =>
      (_activeRole == UserRole.student && _currentStudent != null) ||
      (_activeRole == UserRole.club && _currentClub != null);

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> loginStudent(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentStudent = await _authRepository.loginStudent(email, password);
      _activeRole = UserRole.student;
      _isLoading = false;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_role', 'student');
      await prefs.setString('auth_user_id', _currentStudent?.id ?? '');
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerStudent({
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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentStudent = await _authRepository.registerStudent(
        name: name,
        email: email,
        password: password,
        department: department,
        year: year,
        interests: interests,
        skills: skills,
        goals: goals,
        bio: bio,
      );
      _activeRole = UserRole.student;
      _isLoading = false;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_role', 'student');
      await prefs.setString('auth_user_id', _currentStudent?.id ?? '');
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<ClubModel?> loginClub(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final club = await _authRepository.loginClub(email, password);
      if (club != null) {
        _currentClub = club;
        _activeRole = UserRole.club;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_role', 'club');
        await prefs.setString('auth_club_id', club.id);
      }
      _isLoading = false;
      notifyListeners();
      return club;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> requestClubRegistration({
    required String clubName,
    required String clubEmail,
    required String coordinatorName,
    required String coordinatorEmail,
    required String department,
    required String description,
    required String reason,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.requestClubRegistration(
        clubName: clubName,
        clubEmail: clubEmail,
        coordinatorName: coordinatorName,
        coordinatorEmail: coordinatorEmail,
        department: department,
        description: description,
        reason: reason,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> completeClubProfile({
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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentClub = await _authRepository.completeClubProfile(
        clubId: clubId,
        name: name,
        logoUrl: logoUrl,
        bannerUrl: bannerUrl,
        about: about,
        category: category,
        department: department,
        contactInfo: contactInfo,
        socialLinks: socialLinks,
      );
      _activeRole = UserRole.club;
      _isLoading = false;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_role', 'club');
      await prefs.setString('auth_club_id', _currentClub?.id ?? '');
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.resetPassword(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void updateCurrentStudent(UserModel student) {
    _currentStudent = student;
    notifyListeners();
  }

  void updateCurrentClub(ClubModel club) {
    _currentClub = club;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _currentStudent = null;
    _currentClub = null;
    _activeRole = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_role');
    await prefs.remove('auth_user_id');
    await prefs.remove('auth_club_id');
    notifyListeners();
  }
}
