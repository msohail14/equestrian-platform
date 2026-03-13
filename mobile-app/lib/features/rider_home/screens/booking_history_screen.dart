import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../core/services/booking_service.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  List<dynamic> _bookings = [];
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
      final bookings = await BookingService().getMyBookings();
      if (mounted) {
        setState(() {
          _bookings = bookings;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load bookings';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const LoadingState(message: 'Loading bookings...');
    if (_error != null) return ErrorState(message: _error!, onRetry: _loadData);
    if (_bookings.isEmpty) {
      return const EmptyState(
        message: 'No bookings yet',
        icon: Icons.event_note_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: _bookings.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) => _BookingCard(booking: _bookings[index]),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final status = (booking['status'] ?? 'pending').toString().toLowerCase();
    final dateRaw = booking['booking_date'] ?? booking['date'] ?? '';
    final coachFirst = booking['coach']?['first_name'] ?? '';
    final coachLast = booking['coach']?['last_name'] ?? '';
    final coachName = '$coachFirst $coachLast'.trim();
    final stableName = booking['stable']?['name'] ?? '';
    final startTime = booking['start_time'] ?? '';
    final endTime = booking['end_time'] ?? '';
    final price = booking['total_price'] ?? booking['price'];

    String formattedDate = dateRaw;
    try {
      if (dateRaw.isNotEmpty) {
        formattedDate = DateFormat('MMM d, yyyy').format(DateTime.parse(dateRaw));
      }
    } catch (_) {}

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    formattedDate,
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _StatusBadge(status: status),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (coachName.isNotEmpty)
              _infoRow(Icons.person_outline, coachName),
            if (stableName.isNotEmpty)
              _infoRow(Icons.home_work_outlined, stableName),
            if (startTime.isNotEmpty)
              _infoRow(Icons.access_time, '$startTime – $endTime'),
            if (price != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                '€$price',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textTertiary),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppTextStyles.bodySmall)),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (status) {
      case 'confirmed':
        bg = AppColors.success.withOpacity(0.12);
        fg = AppColors.success;
        break;
      case 'cancelled':
        bg = AppColors.error.withOpacity(0.12);
        fg = AppColors.error;
        break;
      case 'completed':
        bg = AppColors.primary.withOpacity(0.12);
        fg = AppColors.primary;
        break;
      default:
        bg = AppColors.warning.withOpacity(0.12);
        fg = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: AppTextStyles.caption.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
