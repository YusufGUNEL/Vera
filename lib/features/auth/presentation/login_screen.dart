import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_tokens.dart';
import '../state/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _signIn() {
    final l10n = context.l10n;
    final name = _nameController.text.trim().isEmpty
        ? l10n.defaultUserName
        : _nameController.text.trim();
    final email = _emailController.text.trim().isEmpty
        ? l10n.loginEmailHint
        : _emailController.text.trim();
    ref.read(authControllerProvider.notifier).signInDemo(
          displayName: name,
          email: email,
        );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(-0.4, -0.4),
                    colors: [t.umaLight, t.uma],
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                l10n.loginTitle,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: t.ink,
                  letterSpacing: -0.9,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.loginSubtitle,
                style: TextStyle(fontSize: 14, color: t.muted, height: 1.5),
              ),
              const SizedBox(height: 24),
              _Field(
                label: l10n.loginDisplayName,
                controller: _nameController,
                hint: l10n.loginDisplayNameHint,
              ),
              const SizedBox(height: 14),
              _Field(
                label: l10n.emailField,
                controller: _emailController,
                hint: l10n.loginEmailHint,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: t.brand,
                    foregroundColor: t.brandFG,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(l10n.continueWithDemo),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.loginFooter,
                style: TextStyle(fontSize: 12, color: t.muted, height: 1.45),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: t.ink,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: t.muted),
            filled: true,
            fillColor: t.card,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: t.line),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: t.line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: t.uma, width: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}
