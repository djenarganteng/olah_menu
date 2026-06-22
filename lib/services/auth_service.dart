import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  SupabaseClient get _supabase => Supabase.instance.client;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );

    final user = response.user;
    if (user != null && response.session != null) {
      await _upsertProfile(user.id, fullName);
      await _supabase.auth.signOut();
    }

    return response;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: 'olahmenu://reset-password',
    );
  }

  Future<void> signOut() {
    return _supabase.auth.signOut();
  }

  Future<void> updateDisplayName({
    required String userId,
    required String fullName,
  }) async {
    await _supabase.from('profiles').upsert({
      'id': userId,
      'full_name': fullName,
    });
    await _supabase.auth.updateUser(
      UserAttributes(data: {'full_name': fullName}),
    );
  }

  Future<void> updatePassword(String password) async {
    await _supabase.auth.updateUser(UserAttributes(password: password));
  }

  Future<void> reauthenticate({
    required String email,
    required String password,
  }) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<String> updateAvatar({
    required String userId,
    required Uint8List bytes,
    required String extension,
  }) async {
    final safeExtension = extension.toLowerCase().replaceAll('.', '');
    final path =
        '$userId/avatar-${DateTime.now().millisecondsSinceEpoch}.$safeExtension';
    final contentType = switch (safeExtension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };

    await _supabase.storage
        .from('profile-avatars')
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType, upsert: true),
        );

    final avatarUrl = _supabase.storage
        .from('profile-avatars')
        .getPublicUrl(path);

    await _supabase.from('profiles').upsert({
      'id': userId,
      'avatar_url': avatarUrl,
    });
    await _supabase.auth.updateUser(
      UserAttributes(data: {'avatar_url': avatarUrl}),
    );

    return avatarUrl;
  }

  Future<void> _upsertProfile(String userId, String fullName) async {
    await _supabase.from('profiles').upsert({
      'id': userId,
      'full_name': fullName,
    });
  }
}
