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
  bool _isSendingReset = false;
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
      backgroundColor: const Color(0xFFEAF9E8),
      body: _AuthBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
              final keyboardVisible = keyboardInset > 0;
              final isVeryCompact = constraints.maxHeight < 560;
              final isCompact = constraints.maxHeight < 760;
              final horizontalPadding = constraints.maxWidth < 390
                  ? 22.0
                  : 30.0;
              final topPadding = isVeryCompact
                  ? 18.0
                  : isCompact
                  ? 34.0
                  : 56.0;

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  0,
                  horizontalPadding,
                  32,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: keyboardVisible
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: keyboardVisible ? 0 : topPadding),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 620),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (!isVeryCompact) ...[
                                    Center(
                                      child: _BrandLogo(size: isCompact ? 118 : 142),
                                    ),
                                    SizedBox(height: isCompact ? 18 : 22),
                                  ],
                                  Text(
                                    'Masuk ke OlahMenu',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFF050505),
                                      fontFamily: 'serif',
                                      fontSize: isVeryCompact
                                          ? 26
                                          : isCompact
                                          ? 30
                                          : 34,
                                      fontWeight: FontWeight.w400,
                                      height: 1.08,
                                    ),
                                  ),
                                  if (!isVeryCompact) ...[
                                    SizedBox(height: isCompact ? 12 : 16),
                                    Text(
                                      'Lanjutkan untuk menyimpan resep\n'
                                      'dan bahan favoritmu.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xFF111111),
                                        fontSize: isCompact ? 16 : 18,
                                        fontWeight: FontWeight.w400,
                                        height: 1.32,
                                      ),
                                    ),
                                  ],
                                  SizedBox(
                                    height: isVeryCompact
                                        ? 14
                                        : isCompact
                                        ? 28
                                        : 34,
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
                                        ? 10
                                        : isCompact
                                        ? 14
                                        : 16,
                                  ),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.done,
                                    style: _authFieldTextStyle,
                                    decoration: _authInputDecoration(
                                      hintText: 'Password',
                                      icon: Icons.lock_outline_rounded,
                                      isDense: isVeryCompact,
                                      suffixIcon: IconButton(
                                        onPressed: () => setState(
                                          () => _obscurePassword = !_obscurePassword,
                                        ),
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                        ),
                                      ),
                                    ),
                                    validator: (value) => value == null || value.isEmpty
                                        ? 'Password wajib diisi.'
                                        : null,
                                    onFieldSubmitted: (_) => _submit(),
                                  ),
                                  SizedBox(height: isVeryCompact ? 2 : 6),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      style: _authLinkButtonStyle,
                                      onPressed: _isLoading || _isSendingReset
                                          ? null
                                          : _showPasswordResetDialog,
                                      child: _isSendingReset
                                          ? const Text('Mengirim...')
                                          : const Text('Lupa password?'),
                                    ),
                                  ),
                                  SizedBox(
                                    height: isVeryCompact
                                        ? 8
                                        : isCompact
                                        ? 18
                                        : 24,
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
                                        : const Text('Masuk'),
                                  ),
                                  SizedBox(
                                    height: isVeryCompact
                                        ? 4
                                        : isCompact
                                        ? 10
                                        : 14,
                                  ),
                                  Center(
                                    child: TextButton(
                                      style: _authLinkButtonStyle,
                                      onPressed: _isLoading
                                          ? null
                                          : () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute<void>(
                                                  builder: (_) =>
                                                      const RegisterScreen(),
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
                    ],
                  ),
                ),
              );
            },
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

  Future<void> _showPasswordResetDialog() async {
    final email = await showDialog<String>(
      context: context,
      builder: (context) => _PasswordResetDialog(
        initialEmail: _emailController.text.trim(),
        validateEmail: _validateEmail,
      ),
    );

    if (email == null || !mounted) {
      return;
    }

    await _sendPasswordReset(email);
  }

  Future<void> _sendPasswordReset(String email) async {
    setState(() => _isSendingReset = true);
    try {
      await context.read<AuthProvider>().sendPasswordResetEmail(email);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link reset password sudah dikirim ke email kamu.'),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_passwordResetErrorMessage(error))),
      );
    } finally {
      if (mounted) {
        setState(() => _isSendingReset = false);
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

class _AuthBackground extends StatelessWidget {
  const _AuthBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/backgrounds/auth_soft_leaf_bg.png',
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
                  Color(0x33F6FBF0),
                  Color(0x22EAF7E7),
                  Color(0x30F3F8EE),
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

final ButtonStyle _authLinkButtonStyle = TextButton.styleFrom(
  foregroundColor: const Color(0xFF2F7B37),
  disabledForegroundColor: const Color(0xFF8BA98E),
  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
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
    prefixIconColor: const Color(0xFF8C9094),
    suffixIcon: suffixIcon,
    suffixIconColor: const Color(0xFF8C9094),
    contentPadding: EdgeInsets.symmetric(
      horizontal: 18,
      vertical: isDense ? 12 : 16,
    ),
    hintStyle: const TextStyle(
      color: Color(0xFF8B8F94),
      fontSize: 17,
      fontWeight: FontWeight.w400,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(19),
      borderSide: const BorderSide(color: Color(0xFFD9DEE1)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(19),
      borderSide: const BorderSide(color: Color(0xFFD9DEE1)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(19),
      borderSide: const BorderSide(color: Color(0xFF05B94F), width: 1.4),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(19),
      borderSide: const BorderSide(color: Color(0xFFD96441)),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(19),
      borderSide: const BorderSide(color: Color(0xFFD96441), width: 1.4),
    ),
  );
}

class _PasswordResetDialog extends StatefulWidget {
  const _PasswordResetDialog({
    required this.initialEmail,
    required this.validateEmail,
  });

  final String initialEmail;
  final String? Function(String?) validateEmail;

  @override
  State<_PasswordResetDialog> createState() => _PasswordResetDialogState();
}

class _PasswordResetDialogState extends State<_PasswordResetDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reset Password'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _emailController,
              autofocus: _emailController.text.trim().isEmpty,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Alamat email',
                prefixIcon: Icon(Icons.mail_outline_rounded),
              ),
              validator: widget.validateEmail,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 54,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('Batal'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 54,
              child: FilledButton(
                onPressed: _submit,
                child: const Text('Kirim Link'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(_emailController.text.trim());
    }
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

String _passwordResetErrorMessage(Object error) {
  final rawMessage = error is AuthException ? error.message : error.toString();
  final message = rawMessage.toLowerCase();
  if (message.contains('rate limit') || message.contains('too many')) {
    return 'Terlalu banyak permintaan reset. Tunggu sebentar lalu coba lagi.';
  }
  if (message.contains('invalid email') || message.contains('email')) {
    return 'Reset gagal. Periksa email kamu.';
  }
  if (message.contains('network') ||
      message.contains('socket') ||
      message.contains('failed host lookup') ||
      message.contains('connection')) {
    return 'Koneksi internet bermasalah. Silakan coba lagi.';
  }
  return 'Gagal mengirim link reset password. Silakan coba lagi.';
}
