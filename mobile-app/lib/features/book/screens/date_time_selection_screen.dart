import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/services/booking_service.dart';
import 'horse_request_screen.dart';

class DateTimeSelectionScreen extends StatefulWidget {
  final int coachId;
  final String coachName;
  final int stableId;

  const DateTimeSelectionScreen({
    super.key,
    required this.coachId,
    required this.coachName,
    required this.stableId,
  });

  @override
  State<DateTimeSelectionScreen> createState() =>
      _DateTimeSelectionScreenState();
}

class _DateTimeSelectionScreenState extends State<DateTimeSelectionScreen> {
  late List<DateTime> _availableDays;
  DateTime? _selectedDate;
  List<dynamic> _slots = [];
  Map<String, dynamic>? _selectedSlot;
  bool _isSlotsLoading = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _availableDays = List.generate(
      14,
      (i) => DateTime(now.year, now.month, now.day).add(Duration(days: i)),
    );
  }

  Future<void> _loadSlots(DateTime date) async {
    setState(() {
      _isSlotsLoading = true;
      _slots = [];
      _selectedSlot = null;
    });
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final slots =
          await BookingService().getCoachSlots(widget.coachId, dateStr);
      if (mounted) {
        setState(() {
          _slots = slots;
          _isSlotsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _slots = [];
          _isSlotsLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: Text('Book with ${widget.coachName}')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select Date', style: AppTextStyles.h3),
                  const SizedBox(height: AppSpacing.md),
                  _buildDateChips(),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Available Slots', style: AppTextStyles.h3),
                  const SizedBox(height: AppSpacing.md),
                  _buildSlots(),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildDateChips() {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _availableDays.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final day = _availableDays[index];
          final isSelected = _selectedDate != null &&
              _selectedDate!.year == day.year &&
              _selectedDate!.month == day.month &&
              _selectedDate!.day == day.day;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedDate = day);
              _loadSlots(day);
            },
            child: Container(
              width: 56,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(day).toUpperCase(),
                    style: AppTextStyles.caption.copyWith(
                      color: isSelected
                          ? AppColors.textInverse
                          : AppColors.textTertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${day.day}',
                    style: AppTextStyles.h3.copyWith(
                      color: isSelected
                          ? AppColors.textInverse
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    DateFormat('MMM').format(day),
                    style: AppTextStyles.caption.copyWith(
                      color: isSelected
                          ? AppColors.textInverse.withOpacity(0.8)
                          : AppColors.textTertiary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSlots() {
    if (_selectedDate == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Center(
          child: Text(
            'Pick a date to see available time slots',
            style: AppTextStyles.bodyMedium,
          ),
        ),
      );
    }

    if (_isSlotsLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_slots.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: EmptyState(
          message: 'No available slots for this date',
          icon: Icons.event_busy_outlined,
        ),
      );
    }

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: _slots.map((slot) {
        final startTime = slot['start_time'] ?? slot['start'] ?? '';
        final endTime = slot['end_time'] ?? slot['end'] ?? '';
        final isSelected = _selectedSlot == slot;
        final label = endTime.isNotEmpty ? '$startTime – $endTime' : startTime;

        return GestureDetector(
          onTap: () => setState(() => _selectedSlot = slot),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color:
                    isSelected ? AppColors.textInverse : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
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
          label: 'Continue',
          width: double.infinity,
          onPressed: _selectedSlot != null
              ? () {
                  final dateStr =
                      DateFormat('yyyy-MM-dd').format(_selectedDate!);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HorseRequestScreen(
                        coachId: widget.coachId,
                        stableId: widget.stableId,
                        date: dateStr,
                        startTime: _selectedSlot!['start_time'] ??
                            _selectedSlot!['start'] ??
                            '',
                        endTime: _selectedSlot!['end_time'] ??
                            _selectedSlot!['end'] ??
                            '',
                      ),
                    ),
                  );
                }
              : null,
        ),
      ),
    );
  }
}
