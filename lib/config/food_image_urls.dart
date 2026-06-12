String ingredientPhotoUrlFor(String name, String category) {
  final value = '$name $category'.toLowerCase();

  if (value.contains('wortel')) {
    return _loremFlickrUrl('600', '600', 'carrot');
  }
  if (value.contains('tempe')) {
    return _loremFlickrUrl('600', '600', 'tofu');
  }
  if (value.contains('telur')) {
    return _loremFlickrUrl('600', '600', 'egg');
  }
  if (value.contains('sawi')) {
    return _loremFlickrUrl('600', '600', 'vegetable');
  }
  if (value.contains('minyak')) {
    return _loremFlickrUrl('600', '600', 'kitchen');
  }
  if (value.contains('nasi')) {
    return _loremFlickrUrl('600', '600', 'meal');
  }
  if (value.contains('kentang')) {
    return _loremFlickrUrl('600', '600', 'potato');
  }
  if (value.contains('ayam')) {
    return _loremFlickrUrl('600', '600', 'chicken');
  }
  if (value.contains('tahu')) {
    return _loremFlickrUrl('600', '600', 'tofu');
  }
  if (value.contains('brokoli')) {
    return _loremFlickrUrl('600', '600', 'broccoli');
  }
  if (value.contains('kol')) {
    return _loremFlickrUrl('600', '600', 'vegetable');
  }
  if (value.contains('mie')) {
    return _loremFlickrUrl('600', '600', 'noodle');
  }
  if (value.contains('kecap')) {
    return _loremFlickrUrl('600', '600', 'meal');
  }
  if (value.contains('garam')) {
    return _loremFlickrUrl('600', '600', 'kitchen');
  }
  if (value.contains('cabai')) {
    return _loremFlickrUrl('600', '600', 'chili');
  }
  if (value.contains('bawang putih')) {
    return _loremFlickrUrl('600', '600', 'garlic');
  }
  if (value.contains('bawang merah')) {
    return _loremFlickrUrl('600', '600', 'onion');
  }
  if (value.contains('bakso')) {
    return _loremFlickrUrl('600', '600', 'meal');
  }
  if (value.contains('daun bawang')) {
    return _loremFlickrUrl('600', '600', 'vegetable');
  }

  return _loremFlickrUrl('600', '600', 'food');
}

String recipePhotoUrlFor(String recipeName) {
  final value = recipeName.toLowerCase();

  if (value.contains('nasi')) {
    return _loremFlickrUrl('980', '654', 'meal');
  }
  if (value.contains('mie')) {
    return _loremFlickrUrl('980', '654', 'noodle');
  }
  if (value.contains('tahu')) {
    return _loremFlickrUrl('980', '654', 'tofu');
  }
  if (value.contains('tempe')) {
    return _loremFlickrUrl('980', '654', 'food');
  }
  if (value.contains('sup')) {
    return _loremFlickrUrl('980', '654', 'chicken');
  }
  if (value.contains('telur')) {
    return _loremFlickrUrl('980', '654', 'egg');
  }
  if (value.contains('ayam')) {
    return _loremFlickrUrl('980', '654', 'chicken');
  }

  return _loremFlickrUrl('980', '654', 'meal');
}

String _loremFlickrUrl(String width, String height, String query) {
  return 'https://loremflickr.com/$width/$height/${Uri.encodeComponent(query)}';
}
