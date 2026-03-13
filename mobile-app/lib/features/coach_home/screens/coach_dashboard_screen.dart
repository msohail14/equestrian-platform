import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/api_service.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/coach_bottom_nav.dart';
import '../../../core/models/user_role.dart';
import '../../../core/navigation/app_navigator.dart';
import '../../../core/utils/smooth_page_route.dart';
import 'coach_earnings_screen.dart';
import 'session_feedback_screen.dart';

class CoachDashboardScreen extends StatefulWidget {
  const CoachDashboardScreen({super.key});

  @override
  State<CoachDashboardScreen> createState() => _CoachDashboardScreenState();
}

class _CoachDashboardScreenState extends State<CoachDashboardScreen> {
  Map<String, dynamic> _dashboardData = {};
  List<dynamic> _todaySessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final response = await ApiService().get('/coach-dashboard');
      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      if (mounted) {
        setState(() {
          _dashboardData = data;
          _todaySessions =
              data['today_sessions'] is List ? data['today_sessions'] : [];
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userName = auth.user != null
        ? '${auth.user!['first_name'] ?? ''} ${auth.user!['last_name'] ?? ''}'
            .trim()
        : 'Coach';
    final dateText =
        DateFormat('EEEE, MMMM d').format(DateTime.now()).toUpperCase();

    return AppScaffold(
      bottomNavigationBar: CoachBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) return;
          AppNavigator.navigateToTab(context, index, UserRole.coach);
        },
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: _isLoading
            ? const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primary))
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateText,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Welcome back,',
                      style: AppTextStyles.h2.copyWith(
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      userName.isEmpty ? 'Coach' : userName,
                      style: AppTextStyles.h2
                          .copyWith(color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      childAspectRatio: 1.4,
                      children: [
                        _StatCard(
                          icon: Icons.calendar_today,
                          value:
                              '${_dashboardData['upcoming_sessions_count'] ?? 0}',
                          label: 'Upcoming Sessions',
                          color: AppColors.primary,
                        ),
                        _StatCard(
                          icon: Icons.attach_money,
                          value:
                              '\$${_dashboardData['total_earnings'] ?? '0.00'}',
                          label: 'Total Earnings',
                          color: AppColors.success,
                          onTap: () => Navigator.push(
                            context,
                            SmoothPageRoute(
                                page: const CoachEarningsScreen()),
                          ),
                        ),
                        _StatCard(
                          icon: Icons.pending_actions,
                          value:
                              '\$${_dashboardData['pending_payouts'] ?? '0.00'}',
                          label: 'Pending Payouts',
                          color: AppColors.warning,
                        ),
                        _StatCard(
                          icon: Icons.people,
                          value:
                              '${_dashboardData['total_riders'] ?? 0}',
                          label: 'Total Riders',
                          color: AppColors.secondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text("Today's Sessions", style: AppTextStyles.h3),
                    const SizedBox(height: AppSpacing.md),
                    if (_todaySessions.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWarm,
                          borderRadius:
                              BorderRadius.circular(AppRadii.card),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.event_available,
                                size: 48,
                                color: AppColors.textTertiary),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'No sessions today',
                              style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      )
                    else
                      ...List.generate(_todaySessions.length, (i) {
                        final session =
                            _todaySessions[i] as Map<String, dynamic>;
                        return _SessionTile(
                          session: session,
                          onFeedbackTap: () => Navigator.push(
                            context,
                            SmoothPageRoute(
                              page: SessionFeedbackScreen(
                                sessionId: session['id'] as int? ?? 0,
                              ),
                            ),
                          ),
                        );
                      }),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(value,
                style: AppTextStyles.h3
                    .copyWith(color: AppColors.textPrimary)),
            Text(label,
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final Map<String, dynamic> session;
  final VoidCallback? onFeedbackTap;

  const _SessionTile({required this.session, this.onFeedbackTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session['title'] ??
                      session['course']?['title'] ??
                      'Session',
                  style: AppTextStyles.label,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${session['start_time'] ?? ''} • ${session['rider']?['first_name'] ?? 'Rider'} ${session['rider']?['last_name'] ?? ''}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onFeedbackTap,
            icon: const Icon(Icons.rate_review_outlined, size: 20),
            color: AppColors.primary,
            tooltip: 'Add Feedback',
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withAlpha(25),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Text(
              session['status'] ?? 'scheduled',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
