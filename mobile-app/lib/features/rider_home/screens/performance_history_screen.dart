import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../core/services/session_feedback_service.dart';

class PerformanceHistoryScreen extends StatefulWidget {
  final int riderId;

  const PerformanceHistoryScreen({super.key, required this.riderId});

  @override
  State<PerformanceHistoryScreen> createState() =>
      _PerformanceHistoryScreenState();
}

class _PerformanceHistoryScreenState extends State<PerformanceHistoryScreen> {
  Map<String, dynamic> _performance = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final data =
          await SessionFeedbackService().getRiderPerformance(widget.riderId);
      if (mounted) {
        setState(() {
          _performance = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load performance data';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Performance')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingState(message: 'Loading performance...');
    }
    if (_error != null) return ErrorState(message: _error!, onRetry: _loadData);
    if (_performance.isEmpty) {
      return const EmptyState(
        message: 'No performance data yet',
        icon: Icons.insights_outlined,
      );
    }

    final avgRating = _performance['average_rating'];
    final totalSessions = _performance['total_sessions'] ?? 0;
    final feedbackList =
        (_performance['feedbacks'] ?? _performance['feedback'] ?? []) as List;
    final areasToImprove =
        (_performance['areas_to_improve'] ?? []) as List;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewCards(avgRating, totalSessions),
            if (areasToImprove.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              _buildAreasToImprove(areasToImprove),
            ],
            if (feedbackList.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Text('Session Feedback', style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.md),
              ...feedbackList.map((fb) => _FeedbackCard(feedback: fb)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards(dynamic avgRating, int totalSessions) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.star_rounded,
            iconColor: AppColors.secondary,
            label: 'Avg Rating',
            value: avgRating != null
                ? double.tryParse('$avgRating')?.toStringAsFixed(1) ?? '-'
                : '-',
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            icon: Icons.event_available,
            iconColor: AppColors.primary,
            label: 'Sessions',
            value: '$totalSessions',
          ),
        ),
      ],
    );
  }

  Widget _buildAreasToImprove(List areas) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, size: 18, color: AppColors.warning),
              const SizedBox(width: 8),
              Text(
                'Areas to Improve',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...areas.map(
            (area) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  ', style: TextStyle(color: AppColors.textSecondary)),
                  Expanded(
                    child: Text(
                      '$area',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final dynamic feedback;

  const _FeedbackCard({required this.feedback});

  @override
  Widget build(BuildContext context) {
    if (feedback is! Map) return const SizedBox.shrink();

    final rating = feedback['rating'];
    final comment = feedback['comments'] ?? feedback['comment'] ?? '';
    final coachName = feedback['coach_name'] ??
        '${feedback['coach']?['first_name'] ?? ''} ${feedback['coach']?['last_name'] ?? ''}'
            .trim();
    final date = feedback['session_date'] ?? feedback['created_at'] ?? '';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (coachName.isNotEmpty)
                Expanded(
                  child: Text(
                    coachName,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              if (rating != null) ...[
                const Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '$rating',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ],
          ),
          if (date.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(date, style: AppTextStyles.caption),
          ],
          if (comment.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              comment,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
