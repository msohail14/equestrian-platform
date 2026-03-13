import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/course_template_service.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/utils/smooth_page_route.dart';
import 'course_layout_editor_screen.dart';

class CourseBuilderScreen extends StatefulWidget {
  const CourseBuilderScreen({super.key});

  @override
  State<CourseBuilderScreen> createState() => _CourseBuilderScreenState();
}

class _CourseBuilderScreenState extends State<CourseBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _obstaclesController = TextEditingController();
  final _notesController = TextEditingController();
  String _difficulty = 'beginner';
  bool _isSaving = false;
  bool _hasLayout = false;
  Map<String, dynamic>? _layoutResult;

  static const _difficulties = ['beginner', 'intermediate', 'advanced'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _obstaclesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _addLayout() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      SmoothPageRoute(page: const CourseLayoutEditorScreen()),
    );
    if (result != null && mounted) {
      setState(() {
        _hasLayout = true;
        _layoutResult = result;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final payload = <String, dynamic>{
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'difficulty': _difficulty,
        'obstacles': _obstaclesController.text.trim(),
        'notes': _notesController.text.trim(),
      };

      if (_layoutResult != null) {
        payload['layout_data'] = _layoutResult;
      }

      await CourseTemplateService().createTemplate(payload);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course template created'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create template'),
            backgroundColor: AppColors.error,
          ),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle:
            AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
        filled: true,
        fillColor: AppColors.surfaceWarm,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.md),
      );

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text('Course Builder', style: AppTextStyles.h3),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Title', style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration('Course title'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Description', style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: _inputDecoration('Describe the course...'),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Difficulty', style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String>(
                value: _difficulty,
                decoration: _inputDecoration(''),
                items: _difficulties
                    .map((d) => DropdownMenuItem(
                          value: d,
                          child: Text(
                            d[0].toUpperCase() + d.substring(1),
                            style: AppTextStyles.bodyMedium,
                          ),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _difficulty = v);
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Obstacles', style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _obstaclesController,
                decoration:
                    _inputDecoration('List obstacles (comma-separated)'),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Notes', style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: _inputDecoration('Additional notes...'),
              ),
              const SizedBox(height: AppSpacing.xl),
              GestureDetector(
                onTap: _addLayout,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: _hasLayout
                        ? AppColors.primary.withAlpha(15)
                        : AppColors.surfaceWarm,
                    borderRadius: BorderRadius.circular(AppRadii.card),
                    border: Border.all(
                      color:
                          _hasLayout ? AppColors.primary : AppColors.border,
                      style: _hasLayout
                          ? BorderStyle.solid
                          : BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _hasLayout ? Icons.check_circle : Icons.add_photo_alternate_outlined,
                        size: 40,
                        color: _hasLayout
                            ? AppColors.primary
                            : AppColors.textTertiary,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _hasLayout ? 'Layout Added' : 'Add Course Layout',
                        style: AppTextStyles.label.copyWith(
                          color: _hasLayout
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                      if (!_hasLayout)
                        Text(
                          'Draw or upload a course diagram',
                          style: AppTextStyles.bodySmall,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Create Course Template',
                  onPressed: _isSaving ? null : _save,
                  isLoading: _isSaving,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
