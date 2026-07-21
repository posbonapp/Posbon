import { createClient } from "https://esm.sh/@supabase/supabase-js@2"
import { sendLocalizedPush } from "../_shared/notify.ts"

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

    const assignee = record.assigned_to

    // Новая задача назначена исполнителю
    if (!oldRecord && assignee) {
      const result = await sendLocalizedPush(admin, [assignee], 'task_new', {
        title: String(record.title ?? ''),
        urgent: record.is_urgent ? '1' : '0',
      })
      return new Response(JSON.stringify({ ok: true, ...result }))
    }

    // Задачу вернули на переделку
    if (oldRecord && oldRecord.status !== 'redo' && record.status === 'redo' && assignee) {
      const result = await sendLocalizedPush(admin, [assignee], 'task_redo', {
        title: String(record.title ?? ''),
      })
      return new Response(JSON.stringify({ ok: true, ...result }))
    }

    // Работа принята админом -> сообщаем жильцу квартиры
    if (oldRecord && oldRecord.status !== 'done' && record.status === 'done' && record.apartment_id) {
      const { data: apt } = await admin
        .from('apartments')
        .select('tenant_id')
        .eq('id', record.apartment_id)
        .maybeSingle()
      if (apt?.tenant_id) {
        const result = await sendLocalizedPush(admin, [apt.tenant_id], 'task_done', {
          title: String(record.title ?? ''),
        })
        return new Response(JSON.stringify({ ok: true, ...result }))
      }
    }

    return new Response(JSON.stringify({ ok: true, skipped: 'not a push event' }))
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), { status: 500 })
  }
})
