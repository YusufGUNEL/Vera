import 'package:flutter/material.dart';

enum AppLocale {
  tr('tr', 'TR', 'Türkçe'),
  en('en', 'EN', 'English'),
  de('de', 'DE', 'Deutsch'),
  ar('ar', 'AR', 'العربية'),
  ru('ru', 'RU', 'Русский'),
  zh('zh', 'ZH', '中文');

  const AppLocale(this.code, this.short, this.label);

  final String code;
  final String short;
  final String label;

  Locale toLocale() => Locale(code);

  bool get isRtl => this == AppLocale.ar;

  static AppLocale fromCode(String? code) {
    for (final l in AppLocale.values) {
      if (l.code == code) return l;
    }
    return AppLocale.tr;
  }
}
