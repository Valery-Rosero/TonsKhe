-- Ejecuta esto en Supabase → SQL Editor → New Query

create table if not exists used_items (
  id          bigint generated always as identity primary key,
  item_id     text not null unique,
  used_at     timestamptz not null default now()
);

-- Permitir lectura y escritura sin autenticación (es una app privada con contraseña propia)
alter table used_items enable row level security;

create policy "allow read" on used_items for select using (true);
create policy "allow insert" on used_items for insert with check (true);
create policy "allow update" on used_items for update using (true);
