import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:c_qube/core/constants/app_colors.dart';
import 'package:c_qube/core/constants/app_typography.dart';
import 'package:c_qube/models/analytics_model.dart';
import 'package:c_qube/state/club_state.dart';

class ClubAnalyticsScreen extends StatelessWidget {
  const ClubAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final clubState = Provider.of<ClubState>(context);
    final analytics = clubState.analytics ??
        ClubAnalyticsModel(
          clubId: clubState.currentClub?.id ?? '',
          profileViews: 1840,
          postEngagement: 920,
          eventRegistrations: 312,
          eventAttendance: 285,
          recruitmentApplications: 34,
          activeMembers: 68,
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Club Performance Analytics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Databricks telemetry banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.insights_rounded, color: AppColors.secondary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Databricks Campus Analytics Engine',
                          style: AppTypography.labelMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Aggregated telemetry on student engagement, registration trends, and club visibility.',
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Top Metric Summary Cards (2x3 Grid)
            Row(
              children: [
                _buildStatCard('Profile Views', '${analytics.profileViews}', Icons.visibility_outlined, AppColors.primary, isDark, '+24% this month'),
                const SizedBox(width: 12),
                _buildStatCard('Post Reach', '${analytics.postEngagement}', Icons.thumb_up_alt_outlined, AppColors.secondary, isDark, '+18% vs last wk'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatCard('Registrations', '${analytics.eventRegistrations}', Icons.how_to_reg_rounded, AppColors.success, isDark, '91.3% attendance'),
                const SizedBox(width: 12),
                _buildStatCard('Applicants', '${analytics.recruitmentApplications}', Icons.badge_outlined, AppColors.warning, isDark, 'Active Drive'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatCard('Active Members', '${analytics.activeMembers}', Icons.groups_rounded, AppColors.accent, isDark, 'Core + Leads'),
                const SizedBox(width: 12),
                _buildStatCard('Attendance Rate', '${analytics.attendanceRate.toStringAsFixed(1)}%', Icons.check_circle_outline, AppColors.success, isDark, 'High engagement'),
              ],
            ),
            const SizedBox(height: 28),

            // Chart 1: Growth & Registration Trend (FL Chart)
            Text('Event Registrations Growth', style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Container(
              height: 220,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May'];
                          if (value.toInt() >= 0 && value.toInt() < months.length) {
                            return Text(months[value.toInt()], style: AppTypography.labelSmall);
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 45),
                        FlSpot(1, 90),
                        FlSpot(2, 160),
                        FlSpot(3, 230),
                        FlSpot(4, 312),
                      ],
                      isCurved: true,
                      color: AppColors.secondary,
                      barWidth: 3.5,
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.secondary.withValues(alpha: 0.15),
                      ),
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Distribution Breakdown
            Text('Student Interests Distribution', style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Column(
                children: [
                  _buildDistributionBar('AI & Machine Learning', 0.38, '38%', AppColors.primary, isDark),
                  const SizedBox(height: 12),
                  _buildDistributionBar('Mobile & App Dev', 0.28, '28%', AppColors.secondary, isDark),
                  const SizedBox(height: 12),
                  _buildDistributionBar('Web Development', 0.18, '18%', AppColors.accent, isDark),
                  const SizedBox(height: 12),
                  _buildDistributionBar('UI/UX Design', 0.10, '10%', AppColors.warning, isDark),
                  const SizedBox(height: 12),
                  _buildDistributionBar('Others', 0.06, '6%', AppColors.success, isDark),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDark, String subtitle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 10),
            Text(value, style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(title, style: AppTypography.labelSmall.copyWith(color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary)),
            const SizedBox(height: 4),
            Text(subtitle, style: AppTypography.labelSmall.copyWith(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionBar(String label, double fraction, String pct, Color color, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
            Text(pct, style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w700, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
