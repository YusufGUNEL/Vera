import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/firebase/firebase_bootstrap.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/responsive.dart';
import 'auth_error_messages.dart';
import '../state/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static const _demoEmail = 'a';
  static const _demoPassword = 'b';

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final l10n = context.l10n;
    final firebase = ref.read(firebaseBootstrapProvider);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = l10n.loginEmailPasswordRequired);
      return;
    }

    if (email == _demoEmail && password == _demoPassword) {
      setState(() {
        _busy = true;
        _error = null;
      });
      try {
        await ref.read(authControllerProvider.notifier).signInDemo(
              displayName: l10n.demoUser,
              email: email,
            );
      } catch (error) {
        setState(() => _error = l10n.loginGenericError);
      } finally {
        if (mounted) setState(() => _busy = false);
      }
      return;
    }

    if (!firebase.ready) {
      setState(() => _error = l10n.loginFooter);
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await ref.read(authControllerProvider.notifier).signInWithEmail(
            email: email,
            password: password,
          );
    } on FirebaseAuthException catch (error) {
      setState(() {
        _error = l10n.loginFirebaseError(error.code);
      });
    } catch (error) {
      setState(() => _error = l10n.loginGenericError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final firebase = ref.read(firebaseBootstrapProvider);

    if (!firebase.ready) {
      messenger?.showSnackBar(
        SnackBar(content: Text(l10n.googleSignInUnavailable)),
      );
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await ref.read(authControllerProvider.notifier).signInWithGoogle();
    } on FirebaseAuthException catch (error) {
      setState(() {
        _error = l10n.loginFirebaseError(error.code);
      });
    } on PlatformException catch (error) {
      setState(() {
        _error = googleSignInErrorMessage(
          l10n: l10n,
          error: error,
          fallback: l10n.loginFirebaseError(error.code),
        );
      });
    } catch (error) {
      setState(() => _error = l10n.loginGenericError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    final firebase = ref.watch(firebaseBootstrapProvider);

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final responsive = context.responsive;
            final outerPadding = EdgeInsets.fromLTRB(
              responsive.pageGutter,
              responsive.isDesktop ? 28 : 20,
              responsive.pageGutter,
              24,
            );
            return SingleChildScrollView(
              padding: outerPadding,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - outerPadding.vertical,
                    maxWidth: responsive.authMaxWidth,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(responsive.isDesktop ? 28 : 0),
                    decoration: responsive.isDesktop
                        ? BoxDecoration(
                            color: t.card,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: t.line),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          )
                        : null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 12),
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
                          style: TextStyle(
                              fontSize: 14, color: t.muted, height: 1.5),
                        ),
                        const SizedBox(height: 14),
                        _AuthStatusBanner(
                          message: firebase.ready
                              ? l10n.loginFirebaseReadyFooter
                              : '${l10n.loginFooter}\n${l10n.loginDemoHint(_demoEmail, _demoPassword)}',
                          isWarning: !firebase.ready,
                        ),
                        const SizedBox(height: 24),
                        _Field(
                          label: l10n.emailField,
                          controller: _emailController,
                          hint: l10n.loginEmailHint,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 14),
                        _Field(
                          label: l10n.passwordField,
                          controller: _passwordController,
                          hint: '********',
                          obscure: true,
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _busy ? null : _signIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: t.brand,
                              foregroundColor: t.brandFG,
                              padding: const EdgeInsets.symmetric(vertical: 15),
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
                                : Text(l10n.loginContinueEmail),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _busy ? null : _signInWithGoogle,
                            icon: Icon(
                              Icons.g_mobiledata_rounded,
                              color: t.brand,
                              size: 22,
                            ),
                            label: Text(l10n.continueWithGoogle),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: t.brand,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: t.line),
                            ),
                          ),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _error!,
                            style: TextStyle(
                              color: t.red,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                                child: Divider(color: t.line, thickness: 1)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                l10n.dividerOr,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: t.muted,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                            Expanded(
                                child: Divider(color: t.line, thickness: 1)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: _busy
                                ? null
                                : () => context.push(Routes.signup),
                            icon: Icon(
                              Icons.person_add_alt_1_outlined,
                              size: 18,
                              color: t.brand,
                            ),
                            label: Text(
                              l10n.loginCreateAccount,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: t.brand,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: t.brand, width: 1.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AuthStatusBanner extends StatelessWidget {
  const _AuthStatusBanner({
    required this.message,
    required this.isWarning,
  });

  final String message;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final accent = isWarning ? t.gold : t.brand;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isWarning ? Icons.warning_amber_rounded : Icons.verified_outlined,
            size: 18,
            color: accent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12.5,
                color: t.ink,
                height: 1.45,
              ),
            ),
          ),
        ],
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
    this.obscure = false,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscure;

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
          obscureText: obscure,
          cursorColor: t.uma,
          style: TextStyle(
            fontSize: 15,
            color: t.ink,
            fontWeight: FontWeight.w500,
            height: 1.2,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: t.muted, fontSize: 14),
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
