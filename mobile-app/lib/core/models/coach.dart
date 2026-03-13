class Coach {
  final int id;
  final String? firstName;
  final String? lastName;
  final String email;
  final String? mobileNumber;
  final String? profilePictureUrl;
  final double averageRating;
  final int totalReviews;
  final String? bio;
  final List<String> specialties;
  final bool isVerified;
  final bool isActive;

  Coach({
    required this.id,
    this.firstName,
    this.lastName,
    required this.email,
    this.mobileNumber,
    this.profilePictureUrl,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.bio,
    this.specialties = const [],
    this.isVerified = false,
    this.isActive = true,
  });

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();

  factory Coach.fromJson(Map<String, dynamic> json) => Coach(
        id: json['id'] as int,
        firstName: json['first_name'] as String?,
        lastName: json['last_name'] as String?,
        email: json['email'] as String? ?? '',
        mobileNumber: json['mobile_number'] as String?,
        profilePictureUrl: json['profile_picture_url'] as String?,
        averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
        totalReviews: json['total_reviews'] as int? ?? 0,
        bio: json['bio'] as String?,
        specialties: json['specialties'] is List
            ? List<String>.from(json['specialties'])
            : [],
        isVerified: json['is_verified'] as bool? ?? false,
        isActive: json['is_active'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'mobile_number': mobileNumber,
        'profile_picture_url': profilePictureUrl,
        'average_rating': averageRating,
        'total_reviews': totalReviews,
        'bio': bio,
        'specialties': specialties,
        'is_verified': isVerified,
        'is_active': isActive,
      };
}
