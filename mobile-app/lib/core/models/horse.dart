class Horse {
  final int id;
  final String name;
  final String? breed;
  final int? age;
  final String? gender;
  final String status;
  final String? color;
  final int? stableId;
  final String? profileImageUrl;
  final String? trainingLevel;
  final String? temperament;
  final String? injuryNotes;
  final String? riderSuitability;
  final String? feiPedigreeLink;
  final int maxDailySessions;

  Horse({
    required this.id,
    required this.name,
    this.breed,
    this.age,
    this.gender,
    this.status = 'available',
    this.color,
    this.stableId,
    this.profileImageUrl,
    this.trainingLevel,
    this.temperament,
    this.injuryNotes,
    this.riderSuitability,
    this.feiPedigreeLink,
    this.maxDailySessions = 3,
  });

  factory Horse.fromJson(Map<String, dynamic> json) => Horse(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        breed: json['breed'] as String?,
        age: json['age'] as int?,
        gender: json['gender'] as String?,
        status: json['status'] as String? ?? 'available',
        color: json['color'] as String?,
        stableId: json['stable_id'] as int?,
        profileImageUrl: json['profile_image_url'] as String?,
        trainingLevel: json['training_level'] as String?,
        temperament: json['temperament'] as String?,
        injuryNotes: json['injury_notes'] as String?,
        riderSuitability: json['rider_suitability'] as String?,
        feiPedigreeLink: json['fei_pedigree_link'] as String?,
        maxDailySessions: json['max_daily_sessions'] as int? ?? 3,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'breed': breed,
        'age': age,
        'gender': gender,
        'status': status,
        'color': color,
        'stable_id': stableId,
        'profile_image_url': profileImageUrl,
        'training_level': trainingLevel,
        'temperament': temperament,
        'injury_notes': injuryNotes,
        'rider_suitability': riderSuitability,
        'fei_pedigree_link': feiPedigreeLink,
        'max_daily_sessions': maxDailySessions,
      };
}
