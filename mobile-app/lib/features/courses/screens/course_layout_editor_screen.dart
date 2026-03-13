import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/api_service.dart';
import '../../../core/widgets/app_scaffold.dart';

class DrawingStroke {
  final Color color;
  final double strokeWidth;
  final List<Offset> points;
  final bool isEraser;

  DrawingStroke({
    required this.color,
    required this.strokeWidth,
    required this.points,
    this.isEraser = false,
  });

  Map<String, dynamic> toJson() => {
        'color': color.value,
        'strokeWidth': strokeWidth,
        'points': points.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
        'isEraser': isEraser,
      };

  factory DrawingStroke.fromJson(Map<String, dynamic> json) => DrawingStroke(
        color: Color(json['color'] as int),
        strokeWidth: (json['strokeWidth'] as num).toDouble(),
        points: (json['points'] as List)
            .map((p) => Offset(
                (p['x'] as num).toDouble(), (p['y'] as num).toDouble()))
            .toList(),
        isEraser: json['isEraser'] as bool? ?? false,
      );
}

class _DrawingPainter extends CustomPainter {
  final List<DrawingStroke> strokes;
  _DrawingPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      final paint = Paint()
        ..color = stroke.isEraser ? Colors.white : stroke.color
        ..strokeWidth = stroke.strokeWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      if (stroke.points.length < 2) continue;
      final path = Path()
        ..moveTo(stroke.points.first.dx, stroke.points.first.dy);
      for (int i = 1; i < stroke.points.length; i++) {
        path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter old) => true;
}

class CourseLayoutEditorScreen extends StatefulWidget {
  const CourseLayoutEditorScreen({super.key});

  @override
  State<CourseLayoutEditorScreen> createState() =>
      _CourseLayoutEditorScreenState();
}

class _CourseLayoutEditorScreenState extends State<CourseLayoutEditorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey _canvasKey = GlobalKey();

  final List<DrawingStroke> _strokes = [];
  final List<DrawingStroke> _redoStack = [];
  DrawingStroke? _currentStroke;

  bool _isEraser = false;
  Color _selectedColor = Colors.black;
  double _selectedWidth = 3.0;
  bool _isSaving = false;

  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  static const List<Color> _palette = [
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
  ];

  static const List<double> _widths = [2.0, 5.0, 10.0];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    final point = details.localPosition;
    _currentStroke = DrawingStroke(
      color: _isEraser ? Colors.white : _selectedColor,
      strokeWidth: _isEraser ? 20.0 : _selectedWidth,
      points: [point],
      isEraser: _isEraser,
    );
    setState(() {});
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_currentStroke == null) return;
    _currentStroke!.points.add(details.localPosition);
    setState(() {});
  }

  void _onPanEnd(DragEndDetails details) {
    if (_currentStroke == null) return;
    _strokes.add(_currentStroke!);
    _redoStack.clear();
    _currentStroke = null;
    setState(() {});
  }

  void _undo() {
    if (_strokes.isEmpty) return;
    _redoStack.add(_strokes.removeLast());
    setState(() {});
  }

  void _redo() {
    if (_redoStack.isEmpty) return;
    _strokes.add(_redoStack.removeLast());
    setState(() {});
  }

  void _clear() {
    _strokes.clear();
    _redoStack.clear();
    _currentStroke = null;
    setState(() {});
  }

  Future<void> _pickImage(ImageSource source) async {
    final xFile = await _picker.pickImage(source: source, imageQuality: 85);
    if (xFile != null && mounted) {
      setState(() => _selectedImage = xFile);
    }
  }

  Future<List<int>?> _captureCanvas() async {
    final boundary =
        _canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Future<void> _save() async {
    if (_tabController.index == 0) {
      if (_strokes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Draw something before saving')),
        );
        return;
      }

      setState(() => _isSaving = true);
      try {
        final pngBytes = await _captureCanvas();
        if (pngBytes == null) {
          if (mounted) setState(() => _isSaving = false);
          return;
        }

        final tempFile = File(
            '${Directory.systemTemp.path}/course_layout_${DateTime.now().millisecondsSinceEpoch}.png');
        await tempFile.writeAsBytes(pngBytes);

        final strokeJson =
            jsonEncode(_strokes.map((s) => s.toJson()).toList());

        await ApiService().uploadFile(
          '/course-templates/layout',
          filePath: tempFile.path,
          fieldName: 'layout_image',
          extraFields: {'stroke_data': strokeJson},
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Layout saved'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, {
            'success': true,
            'mode': 'draw',
            'stroke_data': strokeJson,
          });
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save layout'),
              backgroundColor: AppColors.error,
            ),
          );
          setState(() => _isSaving = false);
        }
      }
    } else {
      if (_selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select an image first')),
        );
        return;
      }

      setState(() => _isSaving = true);
      try {
        await ApiService().uploadFile(
          '/course-templates/layout',
          filePath: _selectedImage!.path,
          fieldName: 'layout_image',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Layout uploaded'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, {'success': true, 'mode': 'upload'});
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to upload layout'),
              backgroundColor: AppColors.error,
            ),
          );
          setState(() => _isSaving = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text('Course Layout', style: AppTextStyles.h3),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary),
                  ),
                )
              : TextButton(
                  onPressed: _save,
                  child: Text('Save',
                      style: AppTextStyles.button
                          .copyWith(color: AppColors.primary)),
                ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textTertiary,
          indicatorColor: AppColors.primary,
          labelStyle: AppTextStyles.label,
          unselectedLabelStyle: AppTextStyles.bodyMedium,
          tabs: const [
            Tab(text: 'Draw'),
            Tab(text: 'Upload'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildDrawTab(),
          _buildUploadTab(),
        ],
      ),
    );
  }

  Widget _buildDrawTab() {
    final allStrokes = [
      ..._strokes,
      if (_currentStroke != null) _currentStroke!,
    ];

    return Column(
      children: [
        Expanded(
          child: RepaintBoundary(
            key: _canvasKey,
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: Container(
                width: double.infinity,
                color: AppColors.surface,
                child: CustomPaint(
                  painter: _DrawingPainter(allStrokes),
                  size: Size.infinite,
                ),
              ),
            ),
          ),
        ),
        _buildToolbar(),
      ],
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _toolButton(
                  icon: Icons.edit,
                  label: 'Pen',
                  isActive: !_isEraser,
                  onTap: () => setState(() => _isEraser = false),
                ),
                _toolButton(
                  icon: Icons.auto_fix_high,
                  label: 'Eraser',
                  isActive: _isEraser,
                  onTap: () => setState(() => _isEraser = true),
                ),
                _toolButton(
                  icon: Icons.undo,
                  label: 'Undo',
                  isActive: false,
                  enabled: _strokes.isNotEmpty,
                  onTap: _undo,
                ),
                _toolButton(
                  icon: Icons.redo,
                  label: 'Redo',
                  isActive: false,
                  enabled: _redoStack.isNotEmpty,
                  onTap: _redo,
                ),
                _toolButton(
                  icon: Icons.delete_outline,
                  label: 'Clear',
                  isActive: false,
                  enabled: _strokes.isNotEmpty,
                  onTap: _clear,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                ..._palette.map((c) => GestureDetector(
                      onTap: () => setState(() {
                        _selectedColor = c;
                        _isEraser = false;
                      }),
                      child: Container(
                        width: 32,
                        height: 32,
                        margin: const EdgeInsets.only(right: AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedColor == c && !_isEraser
                                ? AppColors.primary
                                : AppColors.border,
                            width:
                                _selectedColor == c && !_isEraser ? 3 : 1,
                          ),
                        ),
                      ),
                    )),
                const Spacer(),
                ..._widths.map((w) {
                  final widthLabel =
                      w == 2.0 ? 'S' : (w == 5.0 ? 'M' : 'L');
                  return GestureDetector(
                    onTap: () => setState(() => _selectedWidth = w),
                    child: Container(
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.only(left: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: _selectedWidth == w
                            ? AppColors.primary.withAlpha(25)
                            : AppColors.surfaceWarm,
                        borderRadius:
                            BorderRadius.circular(AppRadii.sm),
                        border: Border.all(
                          color: _selectedWidth == w
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widthLabel,
                        style: AppTextStyles.caption.copyWith(
                          color: _selectedWidth == w
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary.withAlpha(25)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Icon(
              icon,
              size: 22,
              color: !enabled
                  ? AppColors.textTertiary.withAlpha(100)
                  : isActive
                      ? AppColors.primary
                      : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontSize: 10,
              color: !enabled
                  ? AppColors.textTertiary.withAlpha(100)
                  : isActive
                      ? AppColors.primary
                      : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadTab() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Expanded(
            child: _selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.card),
                    child: Image.file(
                      File(_selectedImage!.path),
                      fit: BoxFit.contain,
                      width: double.infinity,
                    ),
                  )
                : Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWarm,
                      borderRadius: BorderRadius.circular(AppRadii.card),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.image_outlined,
                            size: 64, color: AppColors.textTertiary),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'No image selected',
                          style: AppTextStyles.bodyLarge
                              .copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Choose from gallery or take a photo',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Gallery'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.button),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Camera'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.button),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
