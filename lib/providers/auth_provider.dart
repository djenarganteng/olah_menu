import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthProvider({required this.authService}) {
    _restoreSession();
    _subscription = authService.authStateChanges.listen((state) {
      _user = state.session?.user;
      _status = _user == null
          ? AuthStatus.unauthenticated
          : AuthStatus.authenticated;
      notifyListeners();
    });
  }

  final AuthService authService;

  AuthStatus _status = AuthStatus.loading;
  User? _user;
  StreamSubscription<AuthState>? _subscription;

  AuthStatus get status => _status;
  User? get user => _user;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<AuthResponse> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    return authService.signUp(
      email: email,
      password: password,
      fullName: fullName,
    );
  }

  Future<void> login({required String email, required String password}) async {
    await authService.signIn(email: email, password: password);
  }

  Future<void> logout() async {
    await authService.signOut();
  }

  Future<void> updateAvatar({
    required Uint8List bytes,
    required String extension,
  }) async {
    final currentUser = _user;
    if (currentUser == null) {
      return;
    }

    await authService.updateAvatar(
      userId: currentUser.id,
      bytes: bytes,
      extension: extension,
    );
    _user = authService.getCurrentUser();
    notifyListeners();
  }

  Future<void> updateDisplayName(String fullName) async {
    final currentUser = _user;
    if (currentUser == null) {
      return;
    }

    await authService.updateDisplayName(
      userId: currentUser.id,
      fullName: fullName,
    );
    _user = authService.getCurrentUser();
    notifyListeners();
  }

  Future<void> updatePassword(String password) async {
    await authService.updatePassword(password);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final currentUser = _user;
    final email = currentUser?.email;
    if (currentUser == null || email == null || email.isEmpty) {
      return;
    }

    await authService.reauthenticate(email: email, password: currentPassword);
    await authService.updatePassword(newPassword);
  }

  void _restoreSession() {
    _user = authService.getCurrentUser();
    _status = _user == null
        ? AuthStatus.unauthenticated
        : AuthStatus.authenticated;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
