import { createClient } from "https://esm.sh/@supabase/supabase-js@2"
import { sendLocalizedPush } from "../_shared/notify.ts"

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

    // 1. Кому шлём: все admin и worker этого дома
    const { data: staff } = await admin
      .from('profiles')
      .select('id')
      .eq('building_id', record.building_id)
      .in('role', ['admin', 'worker'])

    const staffIds = (staff ?? [])
      .map((p) => p.id)
      .filter((id) => id !== record.created_by)

    if (staffIds.length === 0) {
      return new Response(JSON.stringify({ ok: true, skipped: 'no staff' }))
    }

    // 2. Номер квартиры, если заявка от жильца
    let apartment = ''
    if (record.apartment_id) {
      const { data: apt } = await admin
        .from('apartments')
        .select('number')
        .eq('id', record.apartment_id)
        .maybeSingle()
      if (apt) apartment = String(apt.number ?? '')
    }

    const result = await sendLocalizedPush(admin, staffIds, 'request_new', {
      title: String(record.title ?? record.description ?? '').slice(0, 120),
      apartment,
    })

    return new Response(JSON.stringify({ ok: true, ...result }))
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), { status: 500 })
  }
})
