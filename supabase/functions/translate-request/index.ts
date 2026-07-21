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
    const description = String(record.description ?? '')

    // Avoid re-translating on unrelated updates (status/rating/contractor_id/...)
    // and avoid looping on our own UPDATE of the *_i18n columns below.
    const textChanged =
      !oldRecord || record.title !== oldRecord.title || record.description !== oldRecord.description

    let titleI18n: Record<string, string> | null = null
    let descriptionI18n: Record<string, string> | null = null
    let sourceLocale: string | null = null
    let translateError: string | null = null

    if (textChanged && (title || description)) {
      try {
        const apiKey = Deno.env.get('GOOGLE_TRANSLATE_API_KEY')!
        const texts = description ? [title, description] : [title]
        const result = await translateTexts(texts, apiKey)
        sourceLocale = result.sourceLocale
        if (sourceLocale !== null) {
          titleI18n = buildI18n(title, sourceLocale, result.translatedByTarget, 0)
          descriptionI18n = description
            ? buildI18n(description, sourceLocale, result.translatedByTarget, 1)
            : null
          await admin
            .from('requests')
            .update({ original_locale: sourceLocale, title_i18n: titleI18n, description_i18n: descriptionI18n })
            .eq('id', record.id)
        }
      } catch (e) {
        translateError = String(e)
      }
    }

    // The first push for a new request must carry the translation, so we
    // trigger notify-request ourselves right after translation completes
    // (or fails) instead of racing it via a parallel INSERT webhook — the
    // notify-request-hook webhook's Insert event should be removed/disabled.
    let notifyStatus: number | null = null
    if (!oldRecord) {
      const res = await fetch(`${supabaseUrl}/functions/v1/notify-request`, {
        method: 'POST',
        headers: { Authorization: `Bearer ${serviceKey}`, 'Content-Type': 'application/json' },
        body: JSON.stringify({
          record: { ...record, title_i18n: titleI18n, description_i18n: descriptionI18n },
        }),
      })
      notifyStatus = res.status
    }

    return new Response(JSON.stringify({ ok: true, sourceLocale, translateError, notifyStatus }))
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), { status: 500 })
  }
})
