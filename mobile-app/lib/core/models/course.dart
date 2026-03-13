class Course {
  final int id;
  final String title;
  final String? description;
  final int? coachId;
  final int? stableId;
  final int? disciplineId;
  final String? thumbnailImageUrl;
  final String? difficulty;
  final int? maxEnrollment;
  final double? price;
  final bool isActive;
  final String? layoutImageUrl;
  final String? layoutDrawingData;

  Course({
    required this.id,
    required this.title,
    this.description,
    this.coachId,
    this.stableId,
    this.disciplineId,
    this.thumbnailImageUrl,
    this.difficulty,
    this.maxEnrollment,
    this.price,
    this.isActive = true,
    this.layoutImageUrl,
    this.layoutDrawingData,
  });

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        description: json['description'] as String?,
        coachId: json['coach_id'] as int?,
        stableId: json['stable_id'] as int?,
        disciplineId: json['discipline_id'] as int?,
        thumbnailImageUrl: json['thumbnail_image_url'] as String?,
        difficulty: json['difficulty'] as String?,
        maxEnrollment: json['max_enrollment'] as int?,
        price: (json['price'] as num?)?.toDouble(),
        isActive: json['is_active'] as bool? ?? true,
        layoutImageUrl: json['layout_image_url'] as String?,
        layoutDrawingData: json['layout_drawing_data'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'coach_id': coachId,
        'stable_id': stableId,
        'discipline_id': disciplineId,
        'thumbnail_image_url': thumbnailImageUrl,
        'difficulty': difficulty,
        'max_enrollment': maxEnrollment,
        'price': price,
        'is_active': isActive,
        'layout_image_url': layoutImageUrl,
        'layout_drawing_data': layoutDrawingData,
      };
}
