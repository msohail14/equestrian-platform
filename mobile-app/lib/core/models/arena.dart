class Arena {
  final int id;
  final String name;
  final int? stableId;
  final String? surfaceType;
  final String? dimensions;
  final List<String> features;
  final String? imageUrl;
  final bool isActive;

  Arena({
    required this.id,
    required this.name,
    this.stableId,
    this.surfaceType,
    this.dimensions,
    this.features = const [],
    this.imageUrl,
    this.isActive = true,
  });

  factory Arena.fromJson(Map<String, dynamic> json) => Arena(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        stableId: json['stable_id'] as int?,
        surfaceType: json['surface_type'] as String?,
        dimensions: json['dimensions'] as String?,
        features: json['features'] is List
            ? List<String>.from(json['features'])
            : [],
        imageUrl: json['image_url'] as String?,
        isActive: json['is_active'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'stable_id': stableId,
        'surface_type': surfaceType,
        'dimensions': dimensions,
        'features': features,
        'image_url': imageUrl,
        'is_active': isActive,
      };
}
