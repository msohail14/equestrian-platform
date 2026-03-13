import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../core/services/horse_service.dart';
import '../../../core/providers/booking_provider.dart';
import '../widgets/booking_step_header.dart';
import '../widgets/horse_card.dart';
import 'choose_coach_screen.dart';
import '../../rider_home/widgets/home_bottom_nav.dart';

class SelectHorseScreen extends StatefulWidget {
  const SelectHorseScreen({super.key});

  @override
  State<SelectHorseScreen> createState() => _SelectHorseScreenState();
}

class _SelectHorseScreenState extends State<SelectHorseScreen> {
  String? _selectedHorse;
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

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );

    return AppScaffold(
      appBar: null,
      bottomNavigationBar: HomeBottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) Navigator.pop(context);
        },
      ),
      body: Column(
        children: [
          const BookingStepHeader(currentStep: 2),
          Expanded(
            child: _isLoading
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
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Select your horse',
                                  style: AppTextStyles.h1.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: AppSpacing.md,
                                        mainAxisSpacing: AppSpacing.md,
                                        childAspectRatio: 0.75,
                                      ),
                                  itemCount: _horses.length,
                                  itemBuilder: (context, index) {
                                    final horse = _horses[index];
                                    final name = horse['name'] ?? 'Unknown';
                                    final discipline = horse['discipline'] ?? '';
                                    final imageUrl = horse['profile_image_url'] ?? '';
                                    final isSelected = _selectedHorse == name;

                                    return HorseCard(
                                      name: name,
                                      discipline: discipline,
                                      imageUrl: imageUrl,
                                      isSelected: isSelected,
                                      onTap: () {
                                        setState(() {
                                          _selectedHorse = name;
                                        });

                                        bookingProvider.setHorse(name, imageUrl);

                                        Future.delayed(
                                          const Duration(milliseconds: 300),
                                          () {
                                            if (mounted) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const ChooseCoachScreen(),
                                                ),
                                              );
                                            }
                                          },
                                        );
                                      },
                                    );
                                  },
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
