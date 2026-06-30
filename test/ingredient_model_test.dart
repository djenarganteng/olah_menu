import 'package:flutter_test/flutter_test.dart';
import 'package:olah_menu/models/ingredient.dart';

void main() {
  test('Ingredient.fromMap supports user-created metadata', () {
    final ingredient = Ingredient.fromMap({
      'id': 7,
      'name': 'Mozzarella',
      'category': 'Susu & Olahan',
      'sort_order': 9999,
      'image_url': null,
      'created_at': '2026-06-29T00:00:00Z',
      'created_by': '00000000-0000-0000-0000-000000000001',
      'is_user_created': true,
    });

    expect(ingredient.id, 7);
    expect(ingredient.name, 'Mozzarella');
    expect(ingredient.category, 'Susu & Olahan');
    expect(ingredient.createdBy, '00000000-0000-0000-0000-000000000001');
    expect(ingredient.isUserCreated, isTrue);
    expect(ingredient.createdAt, DateTime.parse('2026-06-29T00:00:00Z'));
  });

  test('Ingredient normalization trims and title-cases input', () {
    expect(Ingredient.normalizeText('  mozzarella   cheese  '), 'mozzarella cheese');
    expect(Ingredient.toTitleCase('  mozzarella   cheese  '), 'Mozzarella Cheese');
    expect(Ingredient.normalizeKey('  MOZZARELLA   Cheese  '), 'mozzarella cheese');
  });
}
