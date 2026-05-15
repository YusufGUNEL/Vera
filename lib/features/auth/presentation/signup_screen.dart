import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_tokens.dart';
import '../state/auth_controller.dart';
import 'widgets/auth_field.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmController;
  bool _obscure = true;
  bool _accepted = false;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController()
      ..addListener(_onPasswordChanged);
    _confirmController = TextEditingController();
  }

  void _onPasswordChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (name.isEmpty) {
      setState(() => _error = 'Tam adını gir');
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _error = 'Geçerli bir e-posta adresi gir');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Şifre en az 6 karakter olmalı');
      return;
    }
    if (password != confirm) {
      setState(() => _error = 'Şifreler eşleşmiyor');
      return;
    }
    if (!_accepted) {
      setState(() => _error = 'Devam etmek için koşulları kabul et');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    await Future<void>.delayed(const Duration(milliseconds: 700));
    await ref.read(authControllerProvider.notifier).signInDemo(
          displayName: name,
          email: email,
        );
  }

  double _strength(String password) {
    if (password.isEmpty) return 0;
    var score = 0.0;
    if (password.length >= 6) score += 0.25;
    if (password.length >= 10) score += 0.25;
    if (password.contains(RegExp(r'[A-Z]'))) score += 0.15;
    if (password.contains(RegExp(r'[0-9]'))) score += 0.15;
    if (password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) score += 0.20;
    return score.clamp(0.0, 1.0);
  }

  String _strengthLabel(double s) {
    if (s == 0) return ' ';
    if (s < 0.4) return 'Zayıf';
    if (s < 0.7) return 'Orta';
    return 'Güçlü';
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final strength = _strength(_passwordController.text);
    final strengthColor = strength < 0.4
        ? t.red
        : strength < 0.7
            ? t.gold
            : t.green;

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back, color: t.ink),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hesabını oluştur',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: t.ink,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Vera\'ya katıl ve finansal yaşamını Uma yönetsin.',
                style: TextStyle(fontSize: 14, color: t.muted, height: 1.5),
              ),
              const SizedBox(height: 24),
              AuthField(
                label: 'Ad soyad',
                controller: _nameController,
                prefixIcon: Icons.person_outline,
                autofillHints: const [AutofillHints.name],
              ),
              const SizedBox(height: 14),
              AuthField(
                label: 'E-posta',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.mail_outline,
                autofillHints: const [AutofillHints.email],
              ),
              const SizedBox(height: 14),
              AuthField(
                label: 'Şifre',
                controller: _passwordController,
                obscure: _obscure,
                prefixIcon: Icons.lock_outline,
                autofillHints: const [AutofillHints.newPassword],
                suffix: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                    color: t.muted,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: strength,
                        minHeight: 4,
                        backgroundColor: t.bgSoft,
                        valueColor: AlwaysStoppedAnimation(strengthColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _strengthLabel(strength),
                    style: TextStyle(
                      fontSize: 11,
                      color: strengthColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              AuthField(
                label: 'Şifreyi tekrarla',
                controller: _confirmController,
                obscure: _obscure,
                prefixIcon: Icons.lock_outline,
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => setState(() => _accepted = !_accepted),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      margin: const EdgeInsets.only(top: 1),
                      decoration: BoxDecoration(
                        color: _accepted ? t.brand : Colors.transparent,
                        border: Border.all(
                          color: _accepted ? t.brand : t.line,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: _accepted
                          ? Icon(Icons.check, color: t.brandFG, size: 16)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Vera Kullanım Koşulları ve Gizlilik Politikası\'nı kabul ediyorum.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: t.ink2,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: t.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: t.red.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, size: 16, color: t.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(fontSize: 12, color: t.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _busy ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: t.brand,
                    foregroundColor: t.brandFG,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _busy
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: t.brandFG,
                          ),
                        )
                      : const Text(
                          'Hesap oluştur',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Zaten hesabın var mı? ',
                      style: TextStyle(fontSize: 13.5, color: t.muted),
                    ),
                    GestureDetector(
                      onTap: () => context.pop(),
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        'Giriş yap',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: t.brand,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
