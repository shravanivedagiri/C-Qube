import '../models/analytics_model.dart';
import '../services/mock_data_store.dart';

abstract class AnalyticsRepository {
  Future<ClubAnalyticsModel> getClubAnalytics(String clubId);
}

class MockAnalyticsRepository implements AnalyticsRepository {
  final MockDataStore _store = MockDataStore();

  @override
  Future<ClubAnalyticsModel> getClubAnalytics(String clubId) async {
    await Future.delayed(const Duration(milliseconds: 250));

    final clubEvents = _store.events.where((e) => e.clubId == clubId).toList();
    int totalRegistrations = 0;
    for (final e in clubEvents) {
      totalRegistrations += e.registeredCount;
    }

    final clubApps = _store.recruitmentApplications.where((a) => a.clubId == clubId).toList();

    return ClubAnalyticsModel(
      clubId: clubId,
      profileViews: 1840,
      postEngagement: 920,
      eventRegistrations: totalRegistrations > 0 ? totalRegistrations : 312,
      eventAttendance: 285,
      recruitmentApplications: clubApps.isNotEmpty ? clubApps.length : 34,
      activeMembers: 68,
      galleryViews: 1140,
      viewsTrend: [
        MonthlyMetricPoint(month: 'Jan', value: 420),
        MonthlyMetricPoint(month: 'Feb', value: 680),
        MonthlyMetricPoint(month: 'Mar', value: 950),
        MonthlyMetricPoint(month: 'Apr', value: 1320),
        MonthlyMetricPoint(month: 'May', value: 1840),
      ],
      registrationsTrend: [
        MonthlyMetricPoint(month: 'Jan', value: 45),
        MonthlyMetricPoint(month: 'Feb', value: 90),
        MonthlyMetricPoint(month: 'Mar', value: 160),
        MonthlyMetricPoint(month: 'Apr', value: 230),
        MonthlyMetricPoint(month: 'May', value: 312),
      ],
      studentInterestsDistribution: {
        'AI/ML': 38,
        'App Dev': 28,
        'Web Dev': 18,
        'Design': 10,
        'Others': 6,
      },
      departmentDistribution: {
        'CSE': 45,
        'IT': 25,
        'ECE': 18,
        'Others': 12,
      },
    );
  }
}
