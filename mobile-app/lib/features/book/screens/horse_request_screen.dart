import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/services/booking_service.dart';
import 'booking_confirmation_screen.dart';

class HorseRequestScreen extends StatefulWidget {
  final int coachId;
  final int stableId;
  final String date;
  final String startTime;
  final String endTime;

  const HorseRequestScreen({
    super.key,
    required this.coachId,
    required this.stableId,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  @override
  State<HorseRequestScreen> createState() => _HorseRequestScreenState();
}

class _HorseRequestScreenState extends State<HorseRequestScreen> {
  List<dynamic> _horses = [];
  bool _isLoading = true;
  String? _error;
  int? _selectedHorseId;

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
      final horses = await BookingService().getStableHorses(widget.stableId);
      if (mounted) {
        setState(() {
          _horses = horses;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load horses';
          _isLoading = false;
        });
      }
    }
  }

  Map<String, dynamic>? get _selectedHorse {
    if (_selectedHorseId == null) return null;
    try {
      return _horses.firstWhere((h) => h['id'] == _selectedHorseId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Choose a Horse')),
      body: Column(
        children: [
          Expanded(child: _buildBody()),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const LoadingState(message: 'Loading horses...');
    if (_error != null) return ErrorState(message: _error!, onRetry: _loadData);
    if (_horses.isEmpty) {
      return const EmptyState(
        message: 'No horses available at this stable',
        icon: Icons.pets_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: _horses.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final horse = _horses[index];
          final isSelected = horse['id'] == _selectedHorseId;

          return _HorseSelectionCard(
            horse: horse,
            isSelected: isSelected,
            onTap: () => setState(() => _selectedHorseId = horse['id']),
          );
        },
      ),
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
          label: 'Review Booking',
          width: double.infinity,
          onPressed: _selectedHorse != null
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingConfirmationScreen(
                        coachId: widget.coachId,
                        stableId: widget.stableId,
                        date: widget.date,
                        startTime: widget.startTime,
                        endTime: widget.endTime,
                        horseId: _selectedHorseId!,
                        horseName: _selectedHorse!['name'] ?? 'Horse',
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

class _HorseSelectionCard extends StatelessWidget {
  final Map<String, dynamic> horse;
  final bool isSelected;
  final VoidCallback onTap;

  const _HorseSelectionCard({
    required this.horse,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = horse['name'] ?? 'Unknown';
    final breed = horse['breed'] ?? '';
    final level = horse['level'] ?? horse['suitability_level'] ?? '';
    final discipline = horse['discipline'] ?? '';
    final photoUrl = horse['photo_url'] ?? horse['image_url'];

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: isSelected ? 2 : 0,
        ),
      ),
      elevation: isSelected ? 4 : 2,
      shadowColor: isSelected
          ? AppColors.primary.withOpacity(0.2)
          : AppColors.overlay.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              _buildPhoto(photoUrl),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (breed.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(breed, style: AppTextStyles.bodySmall),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        if (discipline.isNotEmpty)
                          _tag(discipline, AppColors.primaryLight),
                        if (level.isNotEmpty)
                          _tag(level, AppColors.secondaryLight),
                      ],
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tag(String text, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPhoto(String? url) {
    if (url != null && url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: CachedNetworkImage(
          imageUrl: url,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          placeholder: (_, __) => _photoFallback(),
          errorWidget: (_, __, ___) => _photoFallback(),
        ),
      );
    }
    return _photoFallback();
  }

  Widget _photoFallback() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.secondaryLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: const Icon(Icons.pets, color: AppColors.secondary, size: 28),
    );
  }
}
