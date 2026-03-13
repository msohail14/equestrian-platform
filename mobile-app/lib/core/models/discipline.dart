class Discipline {
  final int id;
  final String name;
  final String? description;
  final String? iconImageUrl;
  final bool isActive;

  Discipline({
    required this.id,
    required this.name,
    this.description,
    this.iconImageUrl,
    this.isActive = true,
  });

  factory Discipline.fromJson(Map<String, dynamic> json) => Discipline(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        description: json['description'] as String?,
        iconImageUrl: json['icon_image_url'] as String?,
        isActive: json['is_active'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'icon_image_url': iconImageUrl,
        'is_active': isActive,
      };
}
