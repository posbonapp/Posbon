export type Locale = 'ru' | 'en' | 'fr'

export const DEFAULT_LOCALE: Locale = 'ru'

export function normalizeLocale(value: unknown): Locale {
  if (value === 'en' || value === 'fr' || value === 'ru') return value
  return DEFAULT_LOCALE
}

/// Picks the translated string for `locale` out of a jsonb
/// `{"ru": "...", "en": "...", "fr": "..."}` column (e.g. requests.title_i18n),
/// falling back when there's no translation yet (row not processed by
/// translate-request, or field was empty).
export function pickI18nField(i18n: unknown, locale: Locale, fallback: string): string {
  if (i18n && typeof i18n === 'object' && !Array.isArray(i18n)) {
    const value = (i18n as Record<string, unknown>)[locale]
    if (typeof value === 'string' && value) return value
  }
  return fallback
}

type MessageBuilder = (params: Record<string, string>) => { title: string; body: string }

const MESSAGES: Record<string, Record<Locale, MessageBuilder>> = {
  task_new: {
    ru: (p) => ({ title: p.urgent === '1' ? 'Срочная задача' : 'Новая задача', body: p.title }),
    en: (p) => ({ title: p.urgent === '1' ? 'Urgent task' : 'New task', body: p.title }),
    fr: (p) => ({ title: p.urgent === '1' ? 'Tâche urgente' : 'Nouvelle tâche', body: p.title }),
  },
  task_redo: {
    ru: (p) => ({ title: 'Задачу вернули на переделку', body: p.title }),
    en: (p) => ({ title: 'Task sent back for rework', body: p.title }),
    fr: (p) => ({ title: 'Tâche renvoyée à refaire', body: p.title }),
  },
  task_done: {
    ru: (p) => ({ title: 'Работа выполнена', body: p.title }),
    en: (p) => ({ title: 'Work completed', body: p.title }),
    fr: (p) => ({ title: 'Travail terminé', body: p.title }),
  },
  request_new: {
    ru: (p) => ({
      title: `Новая заявка${p.apartment ? ` — кв. ${p.apartment}` : ''}`,
      body: p.title,
    }),
    en: (p) => ({
      title: `New request${p.apartment ? ` — apt. ${p.apartment}` : ''}`,
      body: p.title,
    }),
    fr: (p) => ({
      title: `Nouvelle demande${p.apartment ? ` — appt. ${p.apartment}` : ''}`,
      body: p.title,
    }),
  },
  announcement_new: {
    ru: (p) => ({ title: `Объявление: ${p.title}`, body: p.body }),
    en: (p) => ({ title: `Announcement: ${p.title}`, body: p.body }),
    fr: (p) => ({ title: `Annonce : ${p.title}`, body: p.body }),
  },
}

export function localize(
  key: keyof typeof MESSAGES,
  locale: Locale,
  params: Record<string, string>
): { title: string; body: string } {
  return MESSAGES[key][locale](params)
}
