import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/services/booking_service.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final int coachId;
  final int stableId;
  final String date;
  final String startTime;
  final String endTime;
  final int horseId;
  final String horseName;

  const BookingConfirmationScreen({
    super.key,
    required this.coachId,
    required this.stableId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.horseId,
    required this.horseName,
  });

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  bool _isSubmitting = false;

  String get _formattedDate {
    try {
      final parsed = DateTime.parse(widget.date);
      return DateFormat('EEEE, MMMM d, yyyy').format(parsed);
    } catch (_) {
      return widget.date;
    }
  }

  Future<void> _confirmBooking() async {
    setState(() => _isSubmitting = true);
    try {
      await BookingService().createBooking({
        'coach_id': widget.coachId,
        'stable_id': widget.stableId,
        'booking_date': widget.date,
        'start_time': widget.startTime,
        'end_time': widget.endTime,
        'horse_id': widget.horseId,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking confirmed!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Review Booking')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Booking Summary', style: AppTextStyles.h2),
                  const SizedBox(height: AppSpacing.lg),
                  _buildSummaryCard(),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _summaryRow(Icons.calendar_today, 'Date', _formattedDate),
          const Divider(height: AppSpacing.lg),
          _summaryRow(
            Icons.access_time,
            'Time',
            '${widget.startTime} – ${widget.endTime}',
          ),
          const Divider(height: AppSpacing.lg),
          _summaryRow(Icons.pets, 'Horse', widget.horseName),
        ],
      ),
    );
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: PrimaryButton(
          label: 'Confirm & Pay',
          width: double.infinity,
          isLoading: _isSubmitting,
          onPressed: _isSubmitting ? null : _confirmBooking,
        ),
      ),
    );
  }
}
