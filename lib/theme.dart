import 'package:flutter/material.dart';

/// Colors that flip between light and dark instead of staying fixed like the
/// brand/semantic accents (kAccent, kRed, kBlue, kAmber in admin_tasks_screen.dart),
/// which are intentionally the same in both themes.
class AppPalette extends ThemeExtension<AppPalette> {
  final Color card;
  final Color line;
  final Color muted;

  const AppPalette({required this.card, required this.line, required this.muted});

  @override
  AppPalette copyWith({Color? card, Color? line, Color? muted}) => AppPalette(
        card: card ?? this.card,
        line: line ?? this.line,
        muted: muted ?? this.muted,
      );

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      card: Color.lerp(card, other.card, t)!,
      line: Color.lerp(line, other.line, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
    );
  }
}

/// Shorthand for `Theme.of(context).extension<AppPalette>()!`.
AppPalette palette(BuildContext context) => Theme.of(context).extension<AppPalette>()!;

const _lightLine = Color(0xFFE6E1D6);
const _darkBg = Color(0xFF0B1220);
const _darkSurface = Color(0xFF141B2E);
const _darkLine = Color(0xFF243049);
const _darkAccent = Color(0xFF2E7CF6);

final ThemeData lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF2F7D6B),
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: const Color(0xFFF4F1EA),
  useMaterial3: true,
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _lightLine),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _lightLine),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  extensions: const [
    AppPalette(card: Colors.white, line: _lightLine, muted: Colors.grey),
  ],
);

final ThemeData darkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: _darkAccent,
    brightness: Brightness.dark,
    surface: _darkSurface,
  ),
  scaffoldBackgroundColor: _darkBg,
  useMaterial3: true,
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: _darkSurface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _darkLine),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _darkLine),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  extensions: const [
    AppPalette(card: _darkSurface, line: _darkLine, muted: Color(0xFF8B95AB)),
  ],
);
