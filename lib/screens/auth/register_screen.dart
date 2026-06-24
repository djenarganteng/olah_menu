import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF9E8),
      body: _RegisterBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isVeryCompact = constraints.maxHeight < 640;
              final isCompact = constraints.maxHeight < 760;
              final horizontalPadding = constraints.maxWidth < 390
                  ? 20.0
                  : 30.0;
              final topPadding = isVeryCompact
                  ? 56.0
                  : isCompact
                  ? 74.0
                  : 92.0;
              final cardHorizontalPadding = constraints.maxWidth < 390
                  ? 22.0
                  : 34.0;

              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      topPadding,
                      horizontalPadding,
                      32,
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 620),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(19),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0F000000),
                                blurRadius: 24,
                                offset: Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              cardHorizontalPadding,
                              isVeryCompact
                                  ? 20
                                  : isCompact
                                  ? 28
                                  : 34,
                              cardHorizontalPadding,
                              isVeryCompact
                                  ? 20
                                  : isCompact
                                  ? 28
                                  : 34,
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (!isVeryCompact) ...[
                                    Center(
                                      child: _BrandLogo(
                                        size: isCompact ? 74 : 88,
                                      ),
                                    ),
                                    SizedBox(height: isCompact ? 12 : 14),
                                  ],
                                  Text(
                                    'Buat akun',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFF222222),
                                      fontSize: isVeryCompact ? 26 : 30,
                                      fontWeight: FontWeight.w800,
                                      height: 1.12,
                                    ),
                                  ),
                                  if (!isVeryCompact) ...[
                                    SizedBox(height: isCompact ? 10 : 12),
                                    Text(
                                      'Daftar untuk mulai memakai\n'
                                      'OlahMenu dengan aman.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xFF111111),
                                        fontSize: isCompact ? 15 : 16,
                                        fontWeight: FontWeight.w400,
                                        height: 1.28,
                                      ),
                                    ),
                                  ],
                                  SizedBox(
                                    height: isVeryCompact
                                        ? 14
                                        : isCompact
                                        ? 22
                                        : 26,
                                  ),
                                  TextFormField(
                                    controller: _nameController,
                                    textInputAction: TextInputAction.next,
                                    style: _authFieldTextStyle,
                                    decoration: _authInputDecoration(
                                      hintText: 'Nama Lengkap',
                                      icon: Icons.person_outline_rounded,
                                      isDense: isVeryCompact,
                                    ),
                                    validator: (value) {
                                      if ((value?.trim() ?? '').length < 2) {
                                        return 'Nama lengkap wajib diisi.';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(
                                    height: isVeryCompact
                                        ? 8
                                        : isCompact
                                        ? 12
                                        : 14,
                                  ),
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    style: _authFieldTextStyle,
                                    decoration: _authInputDecoration(
                                      hintText: 'Email',
                                      icon: Icons.mail_outline_rounded,
                                      isDense: isVeryCompact,
                                    ),
                                    validator: _validateEmail,
                                  ),
                                  SizedBox(
                                    height: isVeryCompact
                                        ? 8
                                        : isCompact
                                        ? 12
                                        : 14,
                                  ),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.next,
                                    style: _authFieldTextStyle,
                                    decoration: _authInputDecoration(
                                      hintText: 'Password',
                                      icon: Icons.lock_outline_rounded,
                                      isDense: isVeryCompact,
                                      suffixIcon: IconButton(
                                        onPressed: () => setState(
                                          () => _obscurePassword =
                                              !_obscurePassword,
                                        ),
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if ((value ?? '').length < 8) {
                                        return 'Password minimal 8 karakter.';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(
                                    height: isVeryCompact
                                        ? 8
                                        : isCompact
                                        ? 12
                                        : 14,
                                  ),
                                  TextFormField(
                                    controller: _confirmPasswordController,
                                    obscureText: _obscureConfirmPassword,
                                    textInputAction: TextInputAction.done,
                                    style: _authFieldTextStyle,
                                    decoration: _authInputDecoration(
                                      hintText: 'Konfirmasi Password',
                                      icon: Icons.lock_outline_rounded,
                                      isDense: isVeryCompact,
                                      suffixIcon: IconButton(
                                        onPressed: () => setState(
                                          () => _obscureConfirmPassword =
                                              !_obscureConfirmPassword,
                                        ),
                                        icon: Icon(
                                          _obscureConfirmPassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value != _passwordController.text) {
                                        return 'Konfirmasi password harus sama.';
                                      }
                                      return null;
                                    },
                                    onFieldSubmitted: (_) => _submit(),
                                  ),
                                  SizedBox(
                                    height: isVeryCompact
                                        ? 14
                                        : isCompact
                                        ? 22
                                        : 26,
                                  ),
                                  FilledButton(
                                    style: isVeryCompact
                                        ? _authCompactPrimaryButtonStyle
                                        : _authPrimaryButtonStyle,
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
                                        : const Text('Daftar'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: horizontalPadding,
                    top: 16,
                    child: IconButton(
                      onPressed: _isLoading ? null : _goBackToLogin,
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: const Color(0xFF5D6264),
                      iconSize: 32,
                      style: IconButton.styleFrom(
                        disabledForegroundColor: const Color(0xFFB2B8B5),
                        minimumSize: const Size.square(44),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _goBackToLogin() {
    Navigator.of(context).pop();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await context.read<AuthProvider>().register(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) {
        return;
      }

      final message = response.session == null
          ? 'Registrasi berhasil. Cek email untuk konfirmasi akun.'
          : 'Registrasi berhasil. Silakan masuk.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_registerErrorMessage(error))));
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

class _RegisterBackground extends StatelessWidget {
  const _RegisterBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/backgrounds/leaf_background.png',
            fit: BoxFit.cover,
          ),
        ),
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xF7F5FBF1),
                  Color(0xF0E5F9E8),
                  Color(0xF5F3FBF1),
                ],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _BrandLogo extends StatelessWidget {
  const _BrandLogo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.9,
      height: size,
      child: Image.asset(
        'assets/branding/olah_menu_logo.png',
        fit: BoxFit.contain,
      ),
    );
  }
}

const TextStyle _authFieldTextStyle = TextStyle(
  color: Color(0xFF4C5052),
  fontSize: 17,
  fontWeight: FontWeight.w400,
);

final ButtonStyle _authPrimaryButtonStyle = FilledButton.styleFrom(
  backgroundColor: const Color(0xFF05B94F),
  disabledBackgroundColor: const Color(0xFF9BDDAD),
  foregroundColor: Colors.white,
  minimumSize: const Size.fromHeight(56),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(34)),
  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
);

final ButtonStyle _authCompactPrimaryButtonStyle = FilledButton.styleFrom(
  backgroundColor: const Color(0xFF05B94F),
  disabledBackgroundColor: const Color(0xFF9BDDAD),
  foregroundColor: Colors.white,
  minimumSize: const Size.fromHeight(48),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
  textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
);

InputDecoration _authInputDecoration({
  required String hintText,
  required IconData icon,
  bool isDense = false,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hintText,
    isDense: isDense,
    filled: true,
    fillColor: const Color(0xFFF3F5F6),
    prefixIcon: Icon(icon, size: 26),
    prefixIconColor: const Color(0xFF73777A),
    suffixIcon: suffixIcon,
    suffixIconColor: const Color(0xFF73777A),
    contentPadding: EdgeInsets.symmetric(
      horizontal: 18,
      vertical: isDense ? 12 : 16,
    ),
    hintStyle: const TextStyle(
      color: Color(0xFF575B5F),
      fontSize: 17,
      fontWeight: FontWeight.w400,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF05B94F), width: 1.4),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFD96441)),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFD96441), width: 1.4),
    ),
  );
}

String _registerErrorMessage(Object error) {
  final rawMessage = error is AuthException ? error.message : error.toString();
  final message = rawMessage.toLowerCase();
  if (message.contains('already') ||
      message.contains('registered') ||
      message.contains('user already exists')) {
    return 'Email sudah digunakan.';
  }
  if (message.contains('invalid email')) {
    return 'Format email belum valid.';
  }
  if (message.contains('password')) {
    return 'Password belum memenuhi syarat.';
  }
  if (message.contains('too many') || message.contains('rate limit')) {
    return 'Terlalu banyak percobaan daftar. Tunggu sebentar lalu coba lagi.';
  }
  if (message.contains('network') ||
      message.contains('socket') ||
      message.contains('failed host lookup') ||
      message.contains('connection')) {
    return 'Koneksi internet bermasalah. Silakan coba lagi.';
  }
  return 'Register gagal. Silakan coba lagi.';
}
