import 'package:flutter/material.dart';
import 'app_strings.dart';

/// AppLocalizations provides reactive 4-language switching throughout the widget tree.
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  String translate(String key, {Map<String, String>? params}) {
    return AppStrings.tr(key, langCode: locale.languageCode, params: params);
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'hi', 'mr', 'gu'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension LocalizationExtension on BuildContext {
  String tr(String key, {Map<String, String>? params}) {
    final loc = AppLocalizations.of(this);
    if (loc != null) {
      return loc.translate(key, params: params);
    }
    return AppStrings.tr(key, params: params);
  }
}
