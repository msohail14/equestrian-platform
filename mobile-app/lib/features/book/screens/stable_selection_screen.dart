import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../core/services/booking_service.dart';
import 'coach_selection_screen.dart';

class StableSelectionScreen extends StatefulWidget {
  const StableSelectionScreen({super.key});

  @override
  State<StableSelectionScreen> createState() => _StableSelectionScreenState();
}

class _StableSelectionScreenState extends State<StableSelectionScreen> {
  List<dynamic> _stables = [];
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
      final stables = await BookingService().getBookingStables();
      if (mounted) {
        setState(() {
          _stables = stables;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load stables';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Select Stable')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const LoadingState(message: 'Loading stables...');
    if (_error != null) return ErrorState(message: _error!, onRetry: _loadData);
    if (_stables.isEmpty) {
      return const EmptyState(
        message: 'No stables available',
        icon: Icons.home_work_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: _stables.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final stable = _stables[index];
          return _StableCard(
            stable: stable,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CoachSelectionScreen(
                    stableId: stable['id'],
                    stableName: stable['name'] ?? 'Stable',
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

class _StableCard extends StatelessWidget {
  final Map<String, dynamic> stable;
  final VoidCallback onTap;

  const _StableCard({required this.stable, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = stable['name'] ?? 'Unknown Stable';
    final city = stable['city'] ?? stable['location'] ?? '';
    final rating = stable['average_rating'] ?? stable['rating'];
    final minPrice = stable['min_lesson_price'] ?? stable['lesson_price_min'];
    final maxPrice = stable['max_lesson_price'] ?? stable['lesson_price_max'];
    final logoUrl = stable['logo_url'] ?? stable['logo'];

    String priceRange = '';
    if (minPrice != null && maxPrice != null) {
      priceRange = '€$minPrice – €$maxPrice';
    } else if (minPrice != null) {
      priceRange = 'From €$minPrice';
    }

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
            children: [
              _buildLogo(logoUrl),
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
                    if (city.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(city, style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
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
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                        ],
                        if (priceRange.isNotEmpty)
                          Text(
                            priceRange,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(String? url) {
    if (url != null && url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: CachedNetworkImage(
          imageUrl: url,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          placeholder: (_, __) => _logoFallback(),
          errorWidget: (_, __, ___) => _logoFallback(),
        ),
      );
    }
    return _logoFallback();
  }

  Widget _logoFallback() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: const Icon(
        Icons.home_work_outlined,
        color: AppColors.primary,
        size: 28,
      ),
    );
  }
}
