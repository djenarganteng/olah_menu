import 'package:flutter_test/flutter_test.dart';
import 'package:olah_menu/config/ai_recipe_placeholders.dart';
import 'package:olah_menu/models/ai_recipe.dart';

void main() {
  test('AiRecipe.fromMap supports legacy payloads', () {
    final recipe = AiRecipe.fromMap({
      'id': 'legacy-1',
      'title': 'Nasi Goreng Kampung',
      'description': 'Resep lama yang masih valid.',
      'cooking_time': 25,
      'servings': 2,
      'ingredients': ['nasi', 'telur', 'bawang putih'],
      'steps': ['Tumis bumbu', 'Masukkan nasi'],
      'source': 'cache',
    });

    expect(recipe.id, 'legacy-1');
    expect(recipe.title, 'Nasi Goreng Kampung');
    expect(recipe.estimatedTime, '25 menit');
    expect(recipe.difficulty, 'Mudah');
    expect(recipe.mainIngredients, isEmpty);
    expect(recipe.ingredients, ['nasi', 'telur', 'bawang putih']);
    expect(recipe.stepDetails, hasLength(2));
    expect(recipe.stepDetails.first.title, 'Tumis bumbu');
    expect(recipe.imageSource, 'placeholder');
    expect(recipe.sourceBadgeLabel, '⚡ Dari Cache');
  });

  test('AiRecipe.fromMap supports enriched payloads', () {
    final recipe = AiRecipe.fromMap({
      'id': 'rich-1',
      'nama_masakan': 'Ayam Bakar Bumbu Meresap',
      'deskripsi': 'Ayam bakar juicy dengan bumbu meresap.',
      'cooking_time': 45,
      'estimasi_waktu': '45 menit',
      'tingkat_kesulitan': 'Sedang',
      'jumlah_porsi': 4,
      'tips_memasak': ['Gunakan api kecil', 'Balik ayam beberapa kali'],
      'bahan_utama': ['ayam', 'bawang merah'],
      'bumbu_dan_pelengkap': ['kecap manis', 'garam'],
      'step_details': [
        {'step': 1, 'title': 'Marinasi', 'description': 'Lumuri ayam.'},
        {'step': 2, 'title': 'Bakar', 'description': 'Bakar sampai matang.'},
      ],
      'image_source': 'placeholder',
    });

    expect(recipe.title, 'Ayam Bakar Bumbu Meresap');
    expect(recipe.estimatedTime, '45 menit');
    expect(recipe.difficulty, 'Sedang');
    expect(recipe.servings, 4);
    expect(recipe.tips, hasLength(2));
    expect(recipe.mainIngredients, ['ayam', 'bawang merah']);
    expect(recipe.seasonings, ['kecap manis', 'garam']);
    expect(recipe.steps, ['Marinasi: Lumuri ayam.', 'Bakar: Bakar sampai matang.']);
    expect(recipe.imageSource, 'placeholder');
  });

  test('placeholder spec follows recipe keywords', () {
    final spec = aiRecipePlaceholderFor('Sup Ayam Wortel');

    expect(spec.assetPath, 'assets/recipes/sup_ayam_wortel.jpg');
    expect(spec.label, 'Ayam');
  });
}
