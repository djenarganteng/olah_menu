class Ingredient {
  const Ingredient({
    required this.id,
    required this.name,
    required this.category,
    required this.sortOrder,
    this.imageUrl,
    this.createdAt,
    this.createdBy,
    this.isUserCreated = false,
  });

  final int id;
  final String name;
  final String category;
  final int sortOrder;
  final String? imageUrl;
  final DateTime? createdAt;
  final String? createdBy;
  final bool isUserCreated;

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      id: (map['id'] as num).toInt(),
      name: map['name'] as String,
      category: map['category'] as String,
      sortOrder: ((map['sort_order'] as num?) ?? 9999).toInt(),
      imageUrl: map['image_url'] as String?,
      createdAt: _parseDateTime(map['created_at']),
      createdBy: map['created_by'] as String?,
      isUserCreated: map['is_user_created'] as bool? ?? false,
    );
  }

  static String normalizeText(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String normalizeKey(String value) {
    return normalizeText(value).toLowerCase().replaceAll('pakcoy', 'pokcoy');
  }

  static String toTitleCase(String value) {
    final normalized = normalizeText(value);
    if (normalized.isEmpty) {
      return normalized;
    }

    return normalized
        .split(' ')
        .map((word) {
          if (word.isEmpty) {
            return word;
          }

          return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
        })
        .join(' ');
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return DateTime.tryParse(value.toString());
  }
}
