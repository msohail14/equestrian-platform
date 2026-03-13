class Booking {
  final int id;
  final int? riderId;
  final int? coachId;
  final int? stableId;
  final int? arenaId;
  final int? horseId;
  final int? sessionId;
  final DateTime? bookingDate;
  final String? startTime;
  final String? endTime;
  final String? lessonType;
  final String status;
  final int? paymentId;
  final double? price;
  final String? notes;
  final DateTime? createdAt;

  Booking({
    required this.id,
    this.riderId,
    this.coachId,
    this.stableId,
    this.arenaId,
    this.horseId,
    this.sessionId,
    this.bookingDate,
    this.startTime,
    this.endTime,
    this.lessonType,
    this.status = 'pending',
    this.paymentId,
    this.price,
    this.notes,
    this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json['id'] as int,
        riderId: json['rider_id'] as int?,
        coachId: json['coach_id'] as int?,
        stableId: json['stable_id'] as int?,
        arenaId: json['arena_id'] as int?,
        horseId: json['horse_id'] as int?,
        sessionId: json['session_id'] as int?,
        bookingDate: json['booking_date'] != null
            ? DateTime.tryParse(json['booking_date'] as String)
            : null,
        startTime: json['start_time'] as String?,
        endTime: json['end_time'] as String?,
        lessonType: json['lesson_type'] as String?,
        status: json['status'] as String? ?? 'pending',
        paymentId: json['payment_id'] as int?,
        price: (json['price'] as num?)?.toDouble(),
        notes: json['notes'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'rider_id': riderId,
        'coach_id': coachId,
        'stable_id': stableId,
        'arena_id': arenaId,
        'horse_id': horseId,
        'session_id': sessionId,
        'booking_date': bookingDate?.toIso8601String(),
        'start_time': startTime,
        'end_time': endTime,
        'lesson_type': lessonType,
        'status': status,
        'payment_id': paymentId,
        'price': price,
        'notes': notes,
        'created_at': createdAt?.toIso8601String(),
      };
}
