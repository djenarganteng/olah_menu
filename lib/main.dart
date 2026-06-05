import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'config/supabase_config.dart';
import 'widgets/local_favorites_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? initializationError;

  try {
    if (SupabaseConfig.url.isEmpty || SupabaseConfig.anonKey.isEmpty) {
      throw const FormatException(
        'SUPABASE_URL dan SUPABASE_ANON_KEY wajib diisi lewat --dart-define.',
      );
    }

    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  } catch (error) {
    initializationError = error.toString();
  }

  await LocalFavoritesStore.init();

  runApp(OlahMenuApp(initializationError: initializationError));
}
