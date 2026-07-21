export const TARGETS = ['ru', 'en', 'fr'] as const
export type Target = typeof TARGETS[number]

// Google Translate v2 always HTML-escapes its output (even with format=text it
// still returns entities like &#39; or &amp; for punctuation), so decode before
// storing — otherwise raw entities like "d&#x27;installation" leak to the UI.
const NAMED_ENTITIES: Record<string, string> = {
  amp: '&',
  lt: '<',
  gt: '>',
  quot: '"',
  apos: "'",
  nbsp: ' ',
}

function decodeHtmlEntities(text: string): string {
  return text.replace(/&(#x[0-9a-fA-F]+|#\d+|[a-zA-Z]+);/g, (match, entity: string) => {
    if (entity[0] === '#') {
      const code = entity[1] === 'x' || entity[1] === 'X'
        ? parseInt(entity.slice(2), 16)
        : parseInt(entity.slice(1), 10)
      return Number.isNaN(code) ? match : String.fromCodePoint(code)
    }
    return NAMED_ENTITIES[entity] ?? match
  })
}

async function translateBatch(
  texts: string[],
  target: Target,
  apiKey: string
): Promise<{ translated: string[]; detected: string[] }> {
  const res = await fetch(
    `https://translation.googleapis.com/language/translate/v2?key=${apiKey}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ q: texts, target, format: 'text' }),
    }
  )
  const json = await res.json()
  const translations = json?.data?.translations ?? []
  return {
    translated: translations.map((t: any) => decodeHtmlEntities(String(t.translatedText ?? ''))),
    detected: translations.map((t: any) => String(t.detectedSourceLanguage ?? '')),
  }
}

// Probes each target locale in order (the first call also reveals the source
// language; once known, skip translating into the source language itself),
// and returns per-target translations for every text in `texts`, aligned by
// index, plus the detected source locale (may be outside TARGETS, e.g. 'uz').
export async function translateTexts(
  texts: string[],
  apiKey: string
): Promise<{ sourceLocale: string | null; translatedByTarget: Map<Target, string[]> }> {
  let sourceLocale: string | null = null
  const translatedByTarget = new Map<Target, string[]>()

  for (const target of TARGETS) {
    if (sourceLocale === target) continue
    const { translated, detected } = await translateBatch(texts, target, apiKey)
    if (sourceLocale === null) sourceLocale = detected[0] || null
    if (sourceLocale === target) continue // this call translated source -> itself, discard
    translatedByTarget.set(target, translated)
  }

  return { sourceLocale, translatedByTarget }
}

export function buildI18n(
  original: string,
  sourceLocale: string,
  translatedByTarget: Map<Target, string[]>,
  fieldIndex: number
): Record<Target, string> {
  const out = {} as Record<Target, string>
  for (const loc of TARGETS) {
    if (loc === sourceLocale) {
      out[loc] = original
    } else {
      out[loc] = translatedByTarget.get(loc)?.[fieldIndex] ?? original
    }
  }
  return out
}
