import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../core/services/booking_service.dart';
import 'date_time_selection_screen.dart';

class CoachSelectionScreen extends StatefulWidget {
  final int stableId;
  final String stableName;

  const CoachSelectionScreen({
    super.key,
    required this.stableId,
    required this.stableName,
  });

  @override
  State<CoachSelectionScreen> createState() => _CoachSelectionScreenState();
}

class _CoachSelectionScreenState extends State<CoachSelectionScreen> {
  List<dynamic> _coaches = [];
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
      final coaches = await BookingService().getStableCoaches(widget.stableId);
      if (mounted) {
        setState(() {
          _coaches = coaches;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load coaches';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: Text(widget.stableName)),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const LoadingState(message: 'Loading coaches...');
    if (_error != null) return ErrorState(message: _error!, onRetry: _loadData);
    if (_coaches.isEmpty) {
      return const EmptyState(
        message: 'No coaches available at this stable',
        icon: Icons.person_search_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: _coaches.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final coach = _coaches[index];
          final firstName = coach['first_name'] ?? '';
          final lastName = coach['last_name'] ?? '';
          final fullName = '$firstName $lastName'.trim();

          return _CoachCard(
            coach: coach,
            fullName: fullName,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DateTimeSelectionScreen(
                    coachId: coach['id'],
                    coachName: fullName.isEmpty ? 'Coach' : fullName,
                    stableId: widget.stableId,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CoachCard extends StatelessWidget {
  final Map<String, dynamic> coach;
  final String fullName;
  final VoidCallback onTap;

  const _CoachCard({
    required this.coach,
    required this.fullName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bio = coach['bio'] ?? '';
    final rating = coach['average_rating'] ?? coach['rating'];
    final photoUrl = coach['photo_url'] ?? coach['profile_image'];
    final specialties = coach['specialties'] ?? coach['disciplines'] ?? [];
    final specialtyList = specialties is List
        ? specialties.map((s) => s is Map ? (s['name'] ?? '$s') : '$s').toList()
        : <String>[];

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(photoUrl),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            fullName.isEmpty ? 'Coach' : fullName,
                            style: AppTextStyles.h3.copyWith(
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
                            double.tryParse('$rating')?.toStringAsFixed(1) ??
                                '$rating',
                            style: AppTextStyles.label,
                          ),
                        ],
                      ],
                    ),
                    if (specialtyList.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: specialtyList.take(3).map((s) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(AppRadii.sm),
                            ),
                            child: Text(
                              '$s',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    if (bio.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        bio,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(Icons.chevron_right, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String? url) {
    if (url != null && url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: CachedNetworkImage(
          imageUrl: url,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          placeholder: (_, __) => _avatarFallback(),
          errorWidget: (_, __, ___) => _avatarFallback(),
        ),
      );
    }
    return _avatarFallback();
  }

  Widget _avatarFallback() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: const Icon(Icons.person, color: AppColors.primary, size: 28),
    );
  }
}
