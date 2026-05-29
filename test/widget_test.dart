import 'package:flutter_test/flutter_test.dart';

import 'package:olah_menu/app.dart';

void main() {
  testWidgets('shows configuration helper when Supabase is missing', (
    tester,
  ) async {
    await tester.pumpWidget(
      const OlahMenuApp(
        initializationError: 'SUPABASE_URL dan SUPABASE_ANON_KEY kosong',
      ),
    );

    expect(find.text('Konfigurasi Supabase Belum Lengkap'), findsOneWidget);
    expect(find.textContaining('--dart-define=SUPABASE_URL'), findsOneWidget);
  });
}
