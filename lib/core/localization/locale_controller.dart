import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_locale.dart';
import 'app_strings.dart';

const _kLocaleKey = 'app.locale';

class LocaleController extends StateNotifier<AppLocale> {
  LocaleController() : super(AppLocale.tr) {
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppLocale.fromCode(prefs.getString(_kLocaleKey));
  }

  Future<void> setLocale(AppLocale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocaleKey, locale.code);
  }
}

final localeControllerProvider =
    StateNotifierProvider<LocaleController, AppLocale>(
  (ref) => LocaleController(),
);

final stringsProvider = Provider<AppStrings>((ref) {
  final locale = ref.watch(localeControllerProvider);
  return AppStrings(locale);
});
