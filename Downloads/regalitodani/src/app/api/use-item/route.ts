import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@supabase/supabase-js'
import { Resend } from 'resend'
import { ALL_ITEMS } from '@/lib/data'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)

const resend = new Resend(process.env.RESEND_API_KEY)

export async function POST(req: NextRequest): Promise<NextResponse> {
  const { itemId } = await req.json() as { itemId: string }

  const item = ALL_ITEMS.find(i => i.id === itemId)
  if (!item) return NextResponse.json({ error: 'Item not found' }, { status: 404 })

  // Guardar en Supabase
  const { error } = await supabase
    .from('used_items')
    .upsert({ item_id: itemId, used_at: new Date().toISOString() }, { onConflict: 'item_id' })

  if (error) return NextResponse.json({ error: error.message }, { status: 500 })

  // Enviar email a Valery
  const isAbre = item.type === 'abre'
  const emoji = isAbre ? '💌' : '🎟️'
  const action = isAbre ? 'abrió una nota' : 'canjeó un vale'

  await resend.emails.send({
    from: 'Regalito de Danilo <onboarding@resend.dev>',
    to: process.env.NOTIFY_EMAIL!,
    subject: `${emoji} Danilo ${action}: "${item.title}"`,
    html: `
      <div style="font-family: Georgia, serif; max-width: 500px; margin: 0 auto; background: #fff9fb; padding: 32px; border-radius: 16px; border: 1px solid #f0d0e0;">
        <div style="text-align:center; font-size: 48px; margin-bottom: 16px;">${emoji}</div>
        <h2 style="font-family: Georgia, serif; color: #8B2252; text-align:center; margin: 0 0 8px;">
          ¡Danilo ${action}!
        </h2>
        <p style="color: #a06080; text-align:center; font-size: 13px; margin: 0 0 24px;">
          ${new Date().toLocaleString('es-CO', { dateStyle: 'full', timeStyle: 'short' })}
        </p>
        <div style="background: linear-gradient(135deg, #fdf0f5, #fde8e8); border-radius: 12px; padding: 20px 24px; border-left: 4px solid #8B2252; margin-bottom: 20px;">
          <p style="margin: 0 0 6px; font-size: 12px; color: #c0809a; text-transform: uppercase; letter-spacing: 0.08em; font-family: Arial, sans-serif;">
            ${item.category}
          </p>
          <p style="margin: 0; font-size: 18px; color: #5a1a3a; font-weight: bold;">
            ${item.title}
          </p>
          ${item.message ? `<p style="margin: 12px 0 0; font-size: 15px; color: #6a3050; font-style: italic; line-height: 1.6;">"${item.message}"</p>` : ''}
        </div>
        <p style="color: #c0a0b0; font-size: 12px; text-align:center; margin: 0;">
          Con amor, de Valery para Danilo 💕
        </p>
      </div>
    `,
  })

  return NextResponse.json({ ok: true })
}
