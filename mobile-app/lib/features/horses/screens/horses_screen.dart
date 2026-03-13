import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../core/services/horse_service.dart';
import '../../rider_home/widgets/home_bottom_nav.dart';
import '../../../core/models/user_role.dart';
import '../../../core/navigation/app_navigator.dart';
import '../../coach_home/widgets/coach_bottom_nav.dart';

class HorsesScreen extends StatefulWidget {
  final UserRole userRole;

  const HorsesScreen({super.key, required this.userRole});

  @override
  State<HorsesScreen> createState() => _HorsesScreenState();
}

class _HorsesScreenState extends State<HorsesScreen> {
  List<dynamic> _horses = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHorses();
  }

  Future<void> _loadHorses() async {
    try {
      final horses = await HorseService().getHorses();
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

  Map<String, List<dynamic>> _groupByStable(List<dynamic> horses) {
    final grouped = <String, List<dynamic>>{};
    for (final horse in horses) {
      final stable = (horse['stable'] ?? horse['stable_name'] ?? 'Unknown Stable').toString();
      grouped.putIfAbsent(stable, () => []).add(horse);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: null,
      bottomNavigationBar: widget.userRole == UserRole.rider
          ? HomeBottomNavBar(
              currentIndex: 2,
              onTap: (index) {
                if (index == 2) return;
                AppNavigator.navigateToTab(context, index, widget.userRole);
              },
            )
          : CoachBottomNavBar(
              currentIndex: 2,
              onTap: (index) {
                if (index == 2) return;
                AppNavigator.navigateToTab(context, index, widget.userRole);
              },
            ),
      body: _isLoading
          ? const LoadingState(message: 'Loading horses...')
          : _error != null
              ? ErrorState(message: _error!, onRetry: () {
                  setState(() { _isLoading = true; _error = null; });
                  _loadHorses();
                })
              : _horses.isEmpty
                  ? const EmptyState(
                      message: 'No horses available',
                      icon: Icons.pets,
                    )
                  : _buildContent(),
    );
  }

  Widget _buildContent() {
    final grouped = _groupByStable(_horses);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'Stables',
                style: AppTextStyles.h1.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 32,
                ),
              ),
            ),
          ),
          ...grouped.entries.map((entry) => _buildStableSection(
                entry.key,
                entry.value.length,
                entry.value,
              )),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildStableSection(String name, int horseCount, List<dynamic> horses) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            '$horseCount ${horseCount == 1 ? 'horse' : 'horses'}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 0.85,
            children: horses
                .map((horse) => _buildHorseCard(
                      horse['name'] ?? 'Unknown',
                      horse['discipline'] ?? '',
                      horse['profile_image_url'] ?? '',
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHorseCard(String name, String discipline, String imagePath) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Stack(
          fit: StackFit.expand,
          children: [
            imagePath.startsWith('http')
                ? Image.network(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.background,
                      child: Icon(Icons.pets, size: 48, color: AppColors.textSecondary),
                    ),
                  )
                : imagePath.isNotEmpty
                    ? Image.asset(imagePath, fit: BoxFit.cover)
                    : Container(
                        color: AppColors.background,
                        child: Icon(Icons.pets, size: 48, color: AppColors.textSecondary),
                      ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.h3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    discipline,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
