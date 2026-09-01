class ClubAnalyticsModel {
  final String clubId;
  final int profileViews;
  final int postEngagement;
  final int eventRegistrations;
  final int eventAttendance;
  final int recruitmentApplications;
  final int activeMembers;
  final int galleryViews;
  final List<MonthlyMetricPoint> viewsTrend;
  final List<MonthlyMetricPoint> registrationsTrend;
  final Map<String, int> studentInterestsDistribution;
  final Map<String, int> departmentDistribution;

  ClubAnalyticsModel({
    required this.clubId,
    this.profileViews = 1420,
    this.postEngagement = 870,
    this.eventRegistrations = 312,
    this.eventAttendance = 285,
    this.recruitmentApplications = 78,
    this.activeMembers = 64,
    this.galleryViews = 950,
    this.viewsTrend = const [],
    this.registrationsTrend = const [],
    this.studentInterestsDistribution = const {},
    this.departmentDistribution = const {},
  });

  double get attendanceRate =>
      eventRegistrations == 0 ? 0 : (eventAttendance / eventRegistrations) * 100;
}

class MonthlyMetricPoint {
  final String month;
  final double value;

  MonthlyMetricPoint({required this.month, required this.value});
}
