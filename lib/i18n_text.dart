/// Picks the machine-translated string for [locale] out of a jsonb
/// `{"ru": "...", "en": "...", "fr": "..."}` column, falling back to the
/// original text when there's no translation yet (e.g. row not processed
/// by the translate-request edge function, or field was empty).
String pickTranslated(Object? i18n, String original, String locale) {
  if (i18n is! Map) return original;
  final value = i18n[locale];
  if (value is! String || value.isEmpty) return original;
  return value;
}

/// Whether a "show original / show translation" toggle makes sense for
/// this row — i.e. it was written in a different language than the viewer's.
bool hasTranslationFor(String? originalLocale, String viewerLocale) {
  return originalLocale != null && originalLocale != viewerLocale;
}
