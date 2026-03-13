import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../core/services/course_service.dart';
import '../../coach_home/widgets/coach_bottom_nav.dart';
import '../widgets/course_card.dart';
import '../../../core/models/user_role.dart';
import '../../../core/navigation/app_navigator.dart';

class CoursesScreen extends StatefulWidget {
  final UserRole userRole;

  const CoursesScreen({super.key, required this.userRole});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  List<dynamic> _courses = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    try {
      final courses = await CourseService().getCourses();
      if (mounted) {
        setState(() {
          _courses = courses;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load courses';
          _isLoading = false;
        });
      }
    }
  }

  Map<String, List<dynamic>> _groupByFocus(List<dynamic> courses) {
    final grouped = <String, List<dynamic>>{};
    for (final course in courses) {
      final focus = (course['focus'] ?? course['category'] ?? 'General').toString();
      grouped.putIfAbsent(focus, () => []).add(course);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: null,
      bottomNavigationBar: CoachBottomNavBar(
        currentIndex: 3,
        onTap: (index) {
          if (index == 3) return;
          AppNavigator.navigateToTab(context, index, widget.userRole);
        },
      ),
      body: _isLoading
          ? const LoadingState(message: 'Loading courses...')
          : _error != null
              ? ErrorState(message: _error!, onRetry: () {
                  setState(() { _isLoading = true; _error = null; });
                  _loadCourses();
                })
              : _courses.isEmpty
                  ? const EmptyState(
                      message: 'No courses available',
                      icon: Icons.school_outlined,
                    )
                  : _buildContent(),
    );
  }

  Widget _buildContent() {
    final grouped = _groupByFocus(_courses);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Courses',
                    style: AppTextStyles.h1.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 32,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add, color: Colors.white, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          'New',
                          style: AppTextStyles.button.copyWith(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (grouped.length > 1)
            ...grouped.entries.map((entry) => _buildSection(entry.key, entry.value))
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: _courses
                    .map((course) => _buildCourseCard(course))
                    .toList(),
              ),
            ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<dynamic> courses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            title,
            style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: courses.map((course) => _buildCourseCard(course)).toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget _buildCourseCard(dynamic course) {
    return CourseCard(
      category: course['discipline_name'] ?? course['category'] ?? '',
      level: course['level'] ?? '',
      title: course['title'] ?? course['name'] ?? '',
      description: course['description'] ?? '',
      duration: course['duration_weeks'] != null
          ? '${course['duration_weeks']} Weeks'
          : course['duration'] ?? '',
      participants: course['enrollment_count'] ?? course['participants'] ?? 0,
      onTap: () {},
    );
  }
}
