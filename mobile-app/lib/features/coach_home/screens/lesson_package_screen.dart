import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/lesson_package_service.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../auth/providers/auth_provider.dart';

class LessonPackageScreen extends StatefulWidget {
  const LessonPackageScreen({super.key});

  @override
  State<LessonPackageScreen> createState() => _LessonPackageScreenState();
}

class _LessonPackageScreenState extends State<LessonPackageScreen> {
  List<dynamic> _packages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final auth = context.read<AuthProvider>();
      final coachId = auth.user?['id'] as int? ?? 0;
      final packages =
          await LessonPackageService().getCoachPackages(coachId);
      if (mounted) {
        setState(() {
          _packages = packages;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showCreateDialog() async {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final lessonCountCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final validityCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        title: Text('New Lesson Package', style: AppTextStyles.h3),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(titleCtrl, 'Title', 'Package title'),
                const SizedBox(height: AppSpacing.sm),
                _dialogField(descCtrl, 'Description', 'Short description',
                    maxLines: 2),
                const SizedBox(height: AppSpacing.sm),
                _dialogField(
                    lessonCountCtrl, 'Lesson Count', '10',
                    keyboardType: TextInputType.number),
                const SizedBox(height: AppSpacing.sm),
                _dialogField(priceCtrl, 'Price', '99.99',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true)),
                const SizedBox(height: AppSpacing.sm),
                _dialogField(validityCtrl, 'Validity (days)', '30',
                    keyboardType: TextInputType.number),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: AppTextStyles.button
                    .copyWith(color: AppColors.textSecondary)),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              try {
                await ApiService().post('/packages', data: {
                  'title': titleCtrl.text.trim(),
                  'description': descCtrl.text.trim(),
                  'lesson_count': int.tryParse(lessonCountCtrl.text) ?? 1,
                  'price': double.tryParse(priceCtrl.text) ?? 0,
                  'validity_days': int.tryParse(validityCtrl.text) ?? 30,
                });
                if (ctx.mounted) Navigator.pop(ctx, true);
              } catch (_) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to create package'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text('Create',
                style: AppTextStyles.button
                    .copyWith(color: AppColors.textInverse)),
          ),
        ],
      ),
    );

    titleCtrl.dispose();
    descCtrl.dispose();
    lessonCountCtrl.dispose();
    priceCtrl.dispose();
    validityCtrl.dispose();

    if (created == true) _loadData();
  }

  Widget _dialogField(
    TextEditingController controller,
    String label,
    String hint, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle:
            AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        hintStyle:
            AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
        filled: true,
        fillColor: AppColors.surfaceWarm,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      ),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? '$label is required' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text('Lesson Packages', style: AppTextStyles.h3),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.textInverse),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: _isLoading
            ? const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primary))
            : _packages.isEmpty
                ? ListView(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.inventory_2_outlined,
                                  size: 64, color: AppColors.textTertiary),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'No packages yet',
                                style: AppTextStyles.bodyLarge.copyWith(
                                    color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Tap + to create your first lesson package',
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: _packages.length,
                    itemBuilder: (context, index) {
                      final pkg =
                          _packages[index] as Map<String, dynamic>;
                      return _PackageCard(pkg: pkg);
                    },
                  ),
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final Map<String, dynamic> pkg;

  const _PackageCard({required this.pkg});

  @override
  Widget build(BuildContext context) {
    final status = pkg['status'] ?? 'active';
    final isActive = status == 'active';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  pkg['title'] ?? 'Untitled',
                  style: AppTextStyles.label
                      .copyWith(color: AppColors.textPrimary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 2),
                decoration: BoxDecoration(
                  color: (isActive ? AppColors.success : AppColors.textTertiary)
                      .withAlpha(25),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Text(
                  status,
                  style: AppTextStyles.caption.copyWith(
                    color:
                        isActive ? AppColors.success : AppColors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _infoChip(Icons.book_outlined,
                  '${pkg['lesson_count'] ?? 0} lessons'),
              const SizedBox(width: AppSpacing.md),
              _infoChip(Icons.attach_money,
                  '\$${pkg['price'] ?? '0.00'}'),
              const SizedBox(width: AppSpacing.md),
              _infoChip(Icons.timelapse,
                  '${pkg['validity_days'] ?? 30} days'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(text, style: AppTextStyles.bodySmall),
      ],
    );
  }
}
