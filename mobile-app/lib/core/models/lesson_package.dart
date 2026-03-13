class LessonPackage {
  final int id;
  final int? coachId;
  final String title;
  final String? description;
  final int lessonCount;
  final double price;
  final String currency;
  final int validityDays;
  final bool isActive;

  LessonPackage({
    required this.id,
    this.coachId,
    required this.title,
    this.description,
    required this.lessonCount,
    required this.price,
    this.currency = 'USD',
    this.validityDays = 30,
    this.isActive = true,
  });

  factory LessonPackage.fromJson(Map<String, dynamic> json) => LessonPackage(
        id: json['id'] as int,
        coachId: json['coach_id'] as int?,
        title: json['title'] as String? ?? '',
        description: json['description'] as String?,
        lessonCount: json['lesson_count'] as int? ?? 0,
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        currency: json['currency'] as String? ?? 'USD',
        validityDays: json['validity_days'] as int? ?? 30,
        isActive: json['is_active'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'coach_id': coachId,
        'title': title,
        'description': description,
        'lesson_count': lessonCount,
        'price': price,
        'currency': currency,
        'validity_days': validityDays,
        'is_active': isActive,
      };
}
