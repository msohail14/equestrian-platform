class Session {
  final int id;
  final int? courseId;
  final String? title;
  final DateTime? sessionDate;
  final String? startTime;
  final String? endTime;
  final String status;
  final String? notes;
  final int? horseId;
  final int? arenaId;
  final int? courseTemplateId;

  Session({
    required this.id,
    this.courseId,
    this.title,
    this.sessionDate,
    this.startTime,
    this.endTime,
    this.status = 'scheduled',
    this.notes,
    this.horseId,
    this.arenaId,
    this.courseTemplateId,
  });

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        id: json['id'] as int,
        courseId: json['course_id'] as int?,
        title: json['title'] as String?,
        sessionDate: json['session_date'] != null
            ? DateTime.tryParse(json['session_date'] as String)
            : null,
        startTime: json['start_time'] as String?,
        endTime: json['end_time'] as String?,
        status: json['status'] as String? ?? 'scheduled',
        notes: json['notes'] as String?,
        horseId: json['horse_id'] as int?,
        arenaId: json['arena_id'] as int?,
        courseTemplateId: json['course_template_id'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'course_id': courseId,
        'title': title,
        'session_date': sessionDate?.toIso8601String(),
        'start_time': startTime,
        'end_time': endTime,
        'status': status,
        'notes': notes,
        'horse_id': horseId,
        'arena_id': arenaId,
        'course_template_id': courseTemplateId,
      };
}
