import { createClient } from "https://esm.sh/@supabase/supabase-js@2"
import { buildI18n, translateTexts } from "../_shared/translate.ts"

Deno.serve(async (req) => {
  try {
    const payload = await req.json()
    const record = payload.record
    const oldRecord = payload.old_record
    if (!record) {
      return new Response(JSON.stringify({ error: 'No record' }), { status: 400 })
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const admin = createClient(supabaseUrl, serviceKey)

    const title = String(record.title ?? '')
    const body = String(record.body ?? '')

    // Avoid looping on our own UPDATE of the *_i18n columns below.
    const textChanged = !oldRecord || record.title !== oldRecord.title || record.body !== oldRecord.body

    let titleI18n: Record<string, string> | null = null
    let bodyI18n: Record<string, string> | null = null
    let sourceLocale: string | null = null
    let translateError: string | null = null

    if (textChanged && (title || body)) {
      try {
        const apiKey = Deno.env.get('GOOGLE_TRANSLATE_API_KEY')!
        const texts = body ? [title, body] : [title]
        const result = await translateTexts(texts, apiKey)
        sourceLocale = result.sourceLocale
        if (sourceLocale !== null) {
          titleI18n = buildI18n(title, sourceLocale, result.translatedByTarget, 0)
          bodyI18n = body ? buildI18n(body, sourceLocale, result.translatedByTarget, 1) : null
          await admin
            .from('announcements')
            .update({ original_locale: sourceLocale, title_i18n: titleI18n, body_i18n: bodyI18n })
            .eq('id', record.id)
        }
      } catch (e) {
        translateError = String(e)
      }
    }

    // The first push for a new announcement must carry the translation, so
    // we trigger notify-announcement ourselves right after translation
    // completes (or fails) instead of racing it via a parallel INSERT
    // webhook — the notify-announcement-hook webhook should be removed/disabled.
    let notifyStatus: number | null = null
    if (!oldRecord) {
      const res = await fetch(`${supabaseUrl}/functions/v1/notify-announcement`, {
        method: 'POST',
        headers: { Authorization: `Bearer ${serviceKey}`, 'Content-Type': 'application/json' },
        body: JSON.stringify({
          record: { ...record, title_i18n: titleI18n, body_i18n: bodyI18n },
        }),
      })
      notifyStatus = res.status
    }

    return new Response(JSON.stringify({ ok: true, sourceLocale, translateError, notifyStatus }))
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), { status: 500 })
  }
})
