import 'package:flutter/services.dart';

import '../../../core/localization/app_strings.dart';

String googleSignInErrorMessage({
  required AppStrings l10n,
  required PlatformException error,
  required String fallback,
}) {
  if (error.code == 'sign_in_failed') {
    return l10n.googleSignInConfigMissing;
  }
  final message = error.message?.trim();
  if (message != null && message.isNotEmpty) return message;
  return fallback;
}
