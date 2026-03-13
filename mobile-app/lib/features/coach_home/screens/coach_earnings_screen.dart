import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/api_service.dart';
import '../../../core/widgets/app_scaffold.dart';

class CoachEarningsScreen extends StatefulWidget {
  const CoachEarningsScreen({super.key});

  @override
  State<CoachEarningsScreen> createState() => _CoachEarningsScreenState();
}

class _CoachEarningsScreenState extends State<CoachEarningsScreen> {
  Map<String, dynamic> _earningsData = {};
  List<dynamic> _monthlyEarnings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final response = await ApiService().get('/coach-dashboard/earnings');
      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      if (mounted) {
        setState(() {
          _earningsData = data;
          _monthlyEarnings = data['monthly_earnings'] is List
              ? data['monthly_earnings']
              : [];
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text('Earnings', style: AppTextStyles.h3),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
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
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            label: 'Paid',
                            value:
                                '\$${_earningsData['total_paid'] ?? '0.00'}',
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _SummaryCard(
                            label: 'Pending',
                            value:
                                '\$${_earningsData['total_pending'] ?? '0.00'}',
                            color: AppColors.warning,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _SummaryCard(
                            label: 'Processing',
                            value:
                                '\$${_earningsData['total_processing'] ?? '0.00'}',
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text('Monthly Breakdown', style: AppTextStyles.h3),
                    const SizedBox(height: AppSpacing.md),
                    if (_monthlyEarnings.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWarm,
                          borderRadius:
                              BorderRadius.circular(AppRadii.card),
                        ),
                        child: Text(
                          'No earnings data yet',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      )
                    else
                      ...List.generate(_monthlyEarnings.length, (i) {
                        final entry = _monthlyEarnings[i]
                            as Map<String, dynamic>;
                        return _MonthlyEarningTile(entry: entry);
                      }),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(value,
              style:
                  AppTextStyles.h3.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: AppSpacing.xs),
          Text(label,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _MonthlyEarningTile extends StatelessWidget {
  final Map<String, dynamic> entry;

  const _MonthlyEarningTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final month = entry['month'] ?? '';
    final amount = entry['amount'] ?? entry['total'] ?? '0.00';
    final status = entry['status'] ?? 'paid';
    final statusColor = status == 'paid'
        ? AppColors.success
        : status == 'pending'
            ? AppColors.warning
            : AppColors.primaryLight;

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
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: const Icon(Icons.calendar_month,
                size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$month', style: AppTextStyles.label),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${entry['sessions_count'] ?? 0} sessions',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$$amount',
                  style: AppTextStyles.h3
                      .copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Text(
                  status,
                  style:
                      AppTextStyles.caption.copyWith(color: statusColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
