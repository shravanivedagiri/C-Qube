import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../models/club_join_request_model.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../state/auth_state.dart';
import '../../../../state/club_state.dart';

class ClubJoinRequestsScreen extends StatefulWidget {
  const ClubJoinRequestsScreen({super.key});

  @override
  State<ClubJoinRequestsScreen> createState() => _ClubJoinRequestsScreenState();
}

class _ClubJoinRequestsScreenState extends State<ClubJoinRequestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = Provider.of<AuthState>(context, listen: false);
      final clubState = Provider.of<ClubState>(context, listen: false);
      final club = authState.currentClub ?? clubState.currentClub;
      if (club != null) {
        clubState.loadClubData(club.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final clubState = Provider.of<ClubState>(context);
    final requests = clubState.joinRequests;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Club Join Requests'),
      ),
      body: requests.isEmpty
          ? const EmptyStateView(
              icon: Icons.how_to_reg_outlined,
              title: 'No Join Requests',
              message: 'There are currently no student requests to join this club.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final req = requests[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                            child: Text(
                              req.studentName.isNotEmpty ? req.studentName[0] : 'S',
                              style: AppTypography.headlineSmall.copyWith(color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  req.studentName,
                                  style: AppTypography.headlineSmall.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  req.studentEmail,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildStatusBadge(req.status),
                        ],
                      ),
                      if (req.studentDepartment.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Department: ${req.studentDepartment}',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      if (req.status == ClubJoinRequestStatus.pending) ...[
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.close_rounded, size: 18),
                                label: const Text('Reject'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  side: const BorderSide(color: AppColors.error),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () async {
                                  await clubState.respondToJoinRequest(req.id, false);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Request rejected.'),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                                label: const Text('Approve'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () async {
                                  await clubState.respondToJoinRequest(req.id, true);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${req.studentName} is now a club member!'),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildStatusBadge(ClubJoinRequestStatus status) {
    Color color;
    String text;
    switch (status) {
      case ClubJoinRequestStatus.approved:
        color = AppColors.success;
        text = 'APPROVED';
        break;
      case ClubJoinRequestStatus.rejected:
        color = AppColors.error;
        text = 'REJECTED';
        break;
      case ClubJoinRequestStatus.pending:
      default:
        color = AppColors.warning;
        text = 'PENDING';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
