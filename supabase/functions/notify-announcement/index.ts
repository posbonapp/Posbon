import { createClient } from "https://esm.sh/@supabase/supabase-js@2"
import { sendLocalizedPush } from "../_shared/notify.ts"
import { Locale, pickI18nField } from "../_shared/i18n.ts"

Deno.serve(async (req) => {
  try {
    // Триггер БД присылает { record, old_record }
    const payload = await req.json()
    const record = payload.record
    if (!record) {
      return new Response(JSON.stringify({ error: 'No record' }), { status: 400 })
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const admin = createClient(supabaseUrl, serviceKey)

    // Кому шлём: жильцы и сотрудники дома, кроме автора объявления
    const { data: people } = await admin
      .from('profiles')
      .select('id')
      .eq('building_id', record.building_id)
      .in('role', ['tenant', 'worker'])

    const ids = (people ?? [])
      .map((p) => p.id)
      .filter((id) => id !== record.created_by)

    if (ids.length === 0) {
      return new Response(JSON.stringify({ ok: true, skipped: 'no recipients' }))
    }

    const fallbackTitle = String(record.title ?? '')
    const fallbackBody = String(record.body ?? '').slice(0, 120)

    const result = await sendLocalizedPush(
      admin,
      ids,
      'announcement_new',
      { title: fallbackTitle, body: fallbackBody },
      (locale: Locale) => ({
        title: pickI18nField(record.title_i18n, locale, fallbackTitle),
        body: pickI18nField(record.body_i18n, locale, fallbackBody).slice(0, 120),
      })
    )

    return new Response(JSON.stringify({ ok: true, ...result }))
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), { status: 500 })
  }
})
