import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kSupportedLocaleCodes = ['ru', 'en', 'fr'];

class LocaleProvider extends ChangeNotifier {
  Locale? _locale;
  Locale? get locale => _locale;

  /// Код языка, который реально нужно использовать: явный выбор пользователя,
  /// иначе язык устройства (если он поддерживается), иначе 'ru'.
  String get effectiveCode {
    final chosen = _locale?.languageCode;
    if (chosen != null && kSupportedLocaleCodes.contains(chosen)) return chosen;
    final device = PlatformDispatcher.instance.locale.languageCode;
    if (kSupportedLocaleCodes.contains(device)) return device;
    return 'ru';
  }

  static const _key = 'app_locale';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code != null) _locale = Locale(code);
    notifyListeners();
  }

  Future<void> set(Locale? locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, locale.languageCode);
    }
    notifyListeners();
  }
}

final localeProvider = LocaleProvider();