import { localize, normalizeLocale, Locale } from './i18n.ts'

export async function sendLocalizedPush(
  admin: any,
  userIds: string[],
  messageKey: 'task_new' | 'task_redo' | 'task_done' | 'request_new' | 'announcement_new',
  params: Record<string, string>
): Promise<{ sent: number; groups: number }> {
  const ids = [...new Set(userIds)].filter(Boolean)
  if (ids.length === 0) return { sent: 0, groups: 0 }

  const { data: profiles } = await admin
    .from('profiles')
    .select('id, locale')
    .in('id', ids)

  const localeByUser = new Map<string, Locale>()
  for (const p of profiles ?? []) {
    localeByUser.set(p.id, normalizeLocale(p.locale))
  }

  const { data: rows } = await admin
    .from('device_tokens')
    .select('user_id, token')
    .in('user_id', ids)

  const tokensByLocale = new Map<Locale, string[]>()
  for (const r of rows ?? []) {
    const locale = localeByUser.get(r.user_id) ?? 'ru'
    const list = tokensByLocale.get(locale) ?? []
    list.push(r.token)
    tokensByLocale.set(locale, list)
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL')!
  const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

  let sent = 0
  for (const [locale, tokens] of tokensByLocale) {
    if (tokens.length === 0) continue
    const { title, body } = localize(messageKey, locale, params)
    const res = await fetch(`${supabaseUrl}/functions/v1/send-push`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${serviceKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ tokens, title, body, data: { type: messageKey } }),
    })
    if (res.ok) sent += tokens.length
  }

  return { sent, groups: tokensByLocale.size }
}
