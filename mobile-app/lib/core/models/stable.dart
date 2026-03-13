class Stable {
  final int id;
  final String name;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? description;
  final String? logoImageUrl;
  final bool isActive;
  final bool isApproved;
  final double? rating;
  final double? lessonPriceMin;
  final double? lessonPriceMax;

  Stable({
    required this.id,
    required this.name,
    this.address,
    this.city,
    this.state,
    this.country,
    this.description,
    this.logoImageUrl,
    this.isActive = true,
    this.isApproved = false,
    this.rating,
    this.lessonPriceMin,
    this.lessonPriceMax,
  });

  factory Stable.fromJson(Map<String, dynamic> json) => Stable(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        address: json['address'] as String?,
        city: json['city'] as String?,
        state: json['state'] as String?,
        country: json['country'] as String?,
        description: json['description'] as String?,
        logoImageUrl: json['logo_image_url'] as String?,
        isActive: json['is_active'] as bool? ?? true,
        isApproved: json['is_approved'] as bool? ?? false,
        rating: (json['rating'] as num?)?.toDouble(),
        lessonPriceMin: (json['lesson_price_min'] as num?)?.toDouble(),
        lessonPriceMax: (json['lesson_price_max'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'city': city,
        'state': state,
        'country': country,
        'description': description,
        'logo_image_url': logoImageUrl,
        'is_active': isActive,
        'is_approved': isApproved,
        'rating': rating,
        'lesson_price_min': lessonPriceMin,
        'lesson_price_max': lessonPriceMax,
      };
}
