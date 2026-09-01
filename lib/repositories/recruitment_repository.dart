import '../core/constants/app_constants.dart';
import '../models/recruitment_model.dart';
import '../services/mock_data_store.dart';

abstract class RecruitmentRepository {
  Future<List<RecruitmentDrive>> getAllOpenDrives();
  Future<List<RecruitmentDrive>> getClubDrives(String clubId);
  Future<RecruitmentDrive> createDrive(RecruitmentDrive drive);
  Future<List<RecruitmentApplication>> getDriveApplications(String recruitmentId);
  Future<List<RecruitmentApplication>> getClubApplications(String clubId);
  Future<RecruitmentApplication> submitApplication(RecruitmentApplication application);
  Future<void> updateApplicationStatus(String applicationId, ApplicationStatus newStatus, {String? notes});
}

class MockRecruitmentRepository implements RecruitmentRepository {
  final MockDataStore _store = MockDataStore();

  @override
  Future<List<RecruitmentDrive>> getAllOpenDrives() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _store.recruitmentDrives.where((d) => d.isOpen && !d.isExpired).toList();
  }

  @override
  Future<List<RecruitmentDrive>> getClubDrives(String clubId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _store.recruitmentDrives.where((d) => d.clubId == clubId).toList();
  }

  @override
  Future<RecruitmentDrive> createDrive(RecruitmentDrive drive) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _store.recruitmentDrives.insert(0, drive);
    return drive;
  }

  @override
  Future<List<RecruitmentApplication>> getDriveApplications(String recruitmentId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _store.recruitmentApplications.where((a) => a.recruitmentId == recruitmentId).toList();
  }

  @override
  Future<List<RecruitmentApplication>> getClubApplications(String clubId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _store.recruitmentApplications.where((a) => a.clubId == clubId).toList();
  }

  @override
  Future<RecruitmentApplication> submitApplication(RecruitmentApplication application) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _store.recruitmentApplications.insert(0, application);
    final driveIndex = _store.recruitmentDrives.indexWhere((d) => d.id == application.recruitmentId);
    if (driveIndex != -1) {
      final drive = _store.recruitmentDrives[driveIndex];
      _store.recruitmentDrives[driveIndex] = drive.copyWith(applicantCount: drive.applicantCount + 1);
    }
    return application;
  }

  @override
  Future<void> updateApplicationStatus(String applicationId, ApplicationStatus newStatus, {String? notes}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _store.recruitmentApplications.indexWhere((a) => a.id == applicationId);
    if (index != -1) {
      final app = _store.recruitmentApplications[index];
      _store.recruitmentApplications[index] = app.copyWith(
        status: newStatus,
        notes: notes ?? app.notes,
      );
    }
  }
}
