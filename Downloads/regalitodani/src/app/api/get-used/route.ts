import { NextResponse } from 'next/server'
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)

export async function GET() {
  const { data, error } = await supabase
    .from('used_items')
    .select('item_id')

  if (error) return NextResponse.json({ error: error.message }, { status: 500 })

  const usedIds = (data || []).map((row: { item_id: string }) => row.item_id)
  return NextResponse.json({ usedIds })
}
