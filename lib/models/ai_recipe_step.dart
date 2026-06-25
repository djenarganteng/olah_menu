class AiRecipeStep {
  const AiRecipeStep({
    required this.step,
    required this.title,
    required this.description,
  });

  final int step;
  final String title;
  final String description;

  factory AiRecipeStep.fromMap(Map<String, dynamic> map, {int fallbackStep = 0}) {
    return AiRecipeStep(
      step: _toInt(map['step'], fallback: fallbackStep),
      title: _stringOrFallback(
        map['title'] ?? map['judul'],
        fallback: fallbackStep > 0 ? 'Langkah $fallbackStep' : 'Langkah',
      ),
      description: _stringOrFallback(
        map['description'] ?? map['deskripsi'],
        fallback: '',
      ),
    );
  }

  factory AiRecipeStep.fromText(String value, {int fallbackStep = 0}) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return AiRecipeStep(
        step: fallbackStep,
        title: fallbackStep > 0 ? 'Langkah $fallbackStep' : 'Langkah',
        description: '',
      );
    }

    final match = RegExp(r'^(?:Langkah\s*)?(\d+)[\.:\-]\s*(.+)$',
            caseSensitive: false)
        .firstMatch(normalized);
    if (match != null) {
      final body = match.group(2)?.trim() ?? normalized;
      final parts = _splitTitleAndDescription(body);
      return AiRecipeStep(
        step: _toInt(match.group(1), fallback: fallbackStep),
        title: parts.$1,
        description: parts.$2,
      );
    }

    final parts = _splitTitleAndDescription(normalized);
    return AiRecipeStep(
      step: fallbackStep,
      title: parts.$1,
      description: parts.$2,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'step': step,
      'title': title,
      'description': description,
    };
  }

  String toDisplayText() {
    final normalizedTitle = title.trim();
    final normalizedDescription = description.trim();

    if (normalizedTitle.isEmpty) {
      return normalizedDescription;
    }
    if (normalizedDescription.isEmpty) {
      return normalizedTitle;
    }
    return '$normalizedTitle: $normalizedDescription';
  }

  static int _toInt(dynamic value, {required int fallback}) {
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  static String _stringOrFallback(dynamic value, {required String fallback}) {
    if (value is! String) {
      return fallback;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? fallback : trimmed;
  }

  static (String, String) _splitTitleAndDescription(String text) {
    final normalized = text.trim();
    if (normalized.isEmpty) {
      return ('', '');
    }

    final separators = [': ', ' - ', ' — ', ' · '];
    for (final separator in separators) {
      final index = normalized.indexOf(separator);
      if (index > 0) {
        final title = normalized.substring(0, index).trim();
        final description = normalized.substring(index + separator.length).trim();
        if (title.isNotEmpty && description.isNotEmpty) {
          return (title, description);
        }
      }
    }

    if (normalized.length > 80) {
      return ('Langkah', normalized);
    }

    return (normalized, '');
  }
}
