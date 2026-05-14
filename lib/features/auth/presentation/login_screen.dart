import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_tokens.dart';
import '../state/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Mert Aksoy');
    _emailController = TextEditingController(text: 'mert@aksoy.com');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

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
                'Sign in to Vera',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: t.ink,
                  letterSpacing: -0.9,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Demo session, profile preferences, and AI actions stay on this device until you sign out.',
                style: TextStyle(fontSize: 14, color: t.muted, height: 1.5),
              ),
              const SizedBox(height: 24),
              _Field(
                label: 'Display name',
                controller: _nameController,
              ),
              const SizedBox(height: 14),
              _Field(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      ref.read(authControllerProvider.notifier).signInDemo(
                            displayName: _nameController.text.trim().isEmpty
                                ? 'Mert Aksoy'
                                : _nameController.text.trim(),
                            email: _emailController.text.trim().isEmpty
                                ? 'mert@aksoy.com'
                                : _emailController.text.trim(),
                          ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: t.brand,
                    foregroundColor: t.brandFG,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text('Continue with demo account'),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Next step: real auth, secure session storage, connected bank identity, and biometric relock.',
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
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
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
