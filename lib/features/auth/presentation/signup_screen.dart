import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
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
    final l10n = context.l10n;
    final firebase = ref.read(firebaseBootstrapProvider);
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (name.isEmpty) {
      setState(() => _error = l10n.signupErrorNameRequired);
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _error = l10n.signupErrorInvalidEmail);
      return;
    }
    if (password.length < 6) {
      setState(() => _error = l10n.signupErrorShortPassword);
      return;
    }
    if (password != confirm) {
      setState(() => _error = l10n.signupErrorPasswordMismatch);
      return;
    }
    if (!_accepted) {
      setState(() => _error = l10n.signupErrorAcceptTerms);
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      if (firebase.ready) {
        await ref.read(authControllerProvider.notifier).signUpWithEmail(
              displayName: name,
              email: email,
              password: password,
            );
      } else {
        await Future<void>.delayed(const Duration(milliseconds: 600));
        await ref.read(authControllerProvider.notifier).signInDemo(
              displayName: name,
              email: email,
            );
      }
    } on FirebaseAuthException catch (error) {
      setState(() {
        _error = l10n.signupFailedTemplate(error.code);
      });
    } catch (error) {
      setState(() => _error = l10n.signupGenericError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    final l10n = context.l10n;
    final firebase = ref.read(firebaseBootstrapProvider);

    if (!firebase.ready) {
      setState(() => _error = l10n.googleSignInUnavailable);
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
        _error = l10n.signupFailedTemplate(error.code);
      });
    } on PlatformException catch (error) {
      setState(() {
        _error = googleSignInErrorMessage(
          l10n: l10n,
          error: error,
          fallback: l10n.signupFailedTemplate(error.code),
        );
      });
    } catch (error) {
      setState(() => _error = l10n.signupGenericError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
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

  String _strengthLabel(double value, AppStrings l10n) {
    if (value < 0.4) return l10n.signupStrengthWeak;
    if (value < 0.7) return l10n.signupStrengthMedium;
    return l10n.signupStrengthStrong;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    final firebase = ref.watch(firebaseBootstrapProvider);
    final password = _passwordController.text;
    final strength = _strength(password);
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
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.login),
          icon: Icon(Icons.arrow_back, color: t.ink),
          tooltip: l10n.signupSignIn,
        ),
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final responsive = context.responsive;
            final outerPadding = EdgeInsets.fromLTRB(
              responsive.pageGutter,
              4,
              responsive.pageGutter,
              28,
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
                      children: [
                        Container(
                          width: 52,
                          height: 52,
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
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.signupTitle,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: t.ink,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          firebase.ready
                              ? l10n.signupSubtitleFirebase
                              : l10n.signupSubtitleLocal,
                          style: TextStyle(
                              fontSize: 13.5, color: t.muted, height: 1.5),
                        ),
                        if (!firebase.ready) ...[
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: t.gold.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: t.gold.withValues(alpha: 0.35)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  size: 18,
                                  color: t.gold,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    l10n.loginDemoHint('a', 'b'),
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: t.ink,
                                      height: 1.45,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),

                        // ── Form fields ──────────────────────────────────────────
                        AuthField(
                          label: l10n.signupFieldFullName,
                          controller: _nameController,
                          hintText: l10n.signupFieldFullName,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 14),
                        AuthField(
                          label: l10n.signupFieldEmail,
                          controller: _emailController,
                          hintText: l10n.signupHintEmail,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.mail_outline,
                          autofillHints: const [AutofillHints.email],
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 14),
                        AuthField(
                          label: l10n.signupFieldPassword,
                          controller: _passwordController,
                          hintText: l10n.signupHintPassword,
                          obscure: _obscure,
                          prefixIcon: Icons.lock_outline,
                          autofillHints: const [AutofillHints.newPassword],
                          textInputAction: TextInputAction.next,
                          suffix: IconButton(
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 20,
                              color: t.muted,
                            ),
                          ),
                        ),
                        // Strength meter — only when the user has typed something.
                        AnimatedSize(
                          duration: const Duration(milliseconds: 160),
                          curve: Curves.easeOut,
                          alignment: Alignment.topCenter,
                          child: password.isEmpty
                              ? const SizedBox(
                                  width: double.infinity, height: 0)
                              : Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(999),
                                          child: LinearProgressIndicator(
                                            value: strength,
                                            minHeight: 5,
                                            backgroundColor: t.bgSoft,
                                            valueColor: AlwaysStoppedAnimation(
                                                strengthColor),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        _strengthLabel(strength, l10n),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: strengthColor,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                        const SizedBox(height: 14),
                        AuthField(
                          label: l10n.signupFieldConfirmPassword,
                          controller: _confirmController,
                          hintText: l10n.signupHintConfirmPassword,
                          obscure: _obscure,
                          prefixIcon: Icons.lock_outline,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _busy ? null : _signUp(),
                        ),
                        const SizedBox(height: 18),

                        // ── Terms ────────────────────────────────────────────────
                        _TermsRow(
                          accepted: _accepted,
                          onToggle: () =>
                              setState(() => _accepted = !_accepted),
                          onOpenTerms: () => _openPolicySheet(
                            title: l10n.signupTermsTitle,
                            body: l10n.signupTermsBody,
                          ),
                          onOpenPolicy: () => _openPolicySheet(
                            title: l10n.signupPolicyTitle,
                            body: l10n.signupPolicyBody,
                          ),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          _ErrorBanner(message: _error!),
                        ],
                        const SizedBox(height: 22),

                        // ── Primary CTA ──────────────────────────────────────────
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _busy ? null : _signUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: t.brand,
                              foregroundColor: t.brandFG,
                              disabledBackgroundColor:
                                  t.brand.withValues(alpha: 0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: _busy
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: t.brandFG,
                                    ),
                                  )
                                : Text(
                                    firebase.ready
                                        ? l10n.signupCtaCreate
                                        : l10n.signupCtaContinueLocal,
                                    style: const TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: _busy ? null : _signInWithGoogle,
                            icon: Icon(
                              Icons.g_mobiledata_rounded,
                              size: 24,
                              color: t.brand,
                            ),
                            label: Text(
                              l10n.continueWithGoogle,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: t.brand,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: t.line),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // ── "Already have an account? Sign in" ───────────────────
                        Center(
                          child: TextButton(
                            onPressed: () => context.canPop()
                                ? context.pop()
                                : context.go(Routes.login),
                            style: TextButton.styleFrom(
                              foregroundColor: t.brand,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                            ),
                            child: Text.rich(
                              TextSpan(
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: t.muted,
                                  height: 1.4,
                                ),
                                children: [
                                  TextSpan(text: l10n.signupAlreadyHaveAccount),
                                  TextSpan(
                                    text: l10n.signupSignIn,
                                    style: TextStyle(
                                      color: t.brand,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
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

  Future<void> _openPolicySheet({
    required String title,
    required String body,
  }) {
    final t = context.tokens;
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: t.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: t.line,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: t.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 13,
                    color: t.ink2,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: t.brand,
                      foregroundColor: t.brandFG,
                    ),
                    child: Text(context.l10n.close),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TermsRow extends StatelessWidget {
  const _TermsRow({
    required this.accepted,
    required this.onToggle,
    required this.onOpenTerms,
    required this.onOpenPolicy,
  });

  final bool accepted;
  final VoidCallback onToggle;
  final VoidCallback onOpenTerms;
  final VoidCallback onOpenPolicy;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(top: 1),
              decoration: BoxDecoration(
                color: accepted ? t.brand : Colors.transparent,
                border: Border.all(
                  color: accepted ? t.brand : t.line,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(7),
              ),
              alignment: Alignment.center,
              child: accepted
                  ? Icon(Icons.check, color: t.brandFG, size: 15)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontSize: 12.5,
                    color: t.ink2,
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(text: context.l10n.signupTermsPrefix),
                    TextSpan(
                      text: context.l10n.signupTermsVera,
                      style: TextStyle(
                        color: t.brand,
                        fontWeight: FontWeight.w700,
                      ),
                      recognizer: TapGestureRecognizer()..onTap = onOpenTerms,
                    ),
                    TextSpan(text: context.l10n.signupTermsAnd),
                    TextSpan(
                      text: context.l10n.signupTermsPolicy,
                      style: TextStyle(
                        color: t.brand,
                        fontWeight: FontWeight.w700,
                      ),
                      recognizer: TapGestureRecognizer()..onTap = onOpenPolicy,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: t.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.red.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 16, color: t.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 12, color: t.red, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
