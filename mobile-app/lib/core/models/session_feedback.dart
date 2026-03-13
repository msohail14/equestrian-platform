class SessionFeedback {
  final int id;
  final int? sessionId;
  final int? coachId;
  final int? riderId;
  final String? feedbackText;
  final int? performanceRating;
  final List<String> areasToImprove;
  final DateTime? createdAt;

  SessionFeedback({
    required this.id,
    this.sessionId,
    this.coachId,
    this.riderId,
    this.feedbackText,
    this.performanceRating,
    this.areasToImprove = const [],
    this.createdAt,
  });

  factory SessionFeedback.fromJson(Map<String, dynamic> json) =>
      SessionFeedback(
        id: json['id'] as int,
        sessionId: json['session_id'] as int?,
        coachId: json['coach_id'] as int?,
        riderId: json['rider_id'] as int?,
        feedbackText: json['feedback_text'] as String?,
        performanceRating: json['performance_rating'] as int?,
        areasToImprove: json['areas_to_improve'] is List
            ? List<String>.from(json['areas_to_improve'])
            : [],
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'session_id': sessionId,
        'coach_id': coachId,
        'rider_id': riderId,
        'feedback_text': feedbackText,
        'performance_rating': performanceRating,
        'areas_to_improve': areasToImprove,
        'created_at': createdAt?.toIso8601String(),
      };
}
