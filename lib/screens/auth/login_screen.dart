import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 26,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _AuthIcon(icon: Icons.lock_rounded),
                      const SizedBox(height: 20),
                      Text(
                        'Masuk ke OlahMenu',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Lanjutkan untuk menyimpan resep dan bahan favoritmu.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSoft,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.mail_outline_rounded),
                        ),
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                            ),
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Password wajib diisi.'
                            : null,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _submit,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.6,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Masuk'),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => const RegisterScreen(),
                                    ),
                                  );
                                },
                          child: const Text('Belum punya akun? Daftar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      await context.read<AuthProvider>().login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_authErrorMessage(error))));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Email wajib diisi.';
    }
    final isValid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    return isValid ? null : 'Format email belum valid.';
  }
}

class _AuthIcon extends StatelessWidget {
  const _AuthIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(icon, color: AppColors.primary, size: 30),
    );
  }
}

String _authErrorMessage(Object error) {
  final rawMessage = error is AuthException ? error.message : error.toString();
  final message = rawMessage.toLowerCase();
  if (message.contains('email not confirmed') ||
      message.contains('not confirmed')) {
    return 'Email belum dikonfirmasi. Cek inbox atau spam email kamu.';
  }
  if (message.contains('invalid login credentials')) {
    return 'Email atau password salah.';
  }
  if (message.contains('too many') || message.contains('rate limit')) {
    return 'Terlalu banyak percobaan login. Tunggu sebentar lalu coba lagi.';
  }
  if (message.contains('email')) {
    return 'Login gagal. Periksa email kamu.';
  }
  if (message.contains('network') ||
      message.contains('socket') ||
      message.contains('failed host lookup') ||
      message.contains('connection')) {
    return 'Koneksi internet bermasalah. Silakan coba lagi.';
  }
  return 'Login gagal. Silakan coba lagi.';
}
