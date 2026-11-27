-- supabase/migrations/001_init.sql
-- Jalankan manual di Supabase Dashboard -> SQL Editor.
-- Tidak ada service_role key di aplikasi. Hak akses ditegakkan di sini.

create table if not exists public.kos (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  nama text not null,
  area text not null,
  harga integer not null check (harga >= 0),
  fasilitas text not null default '',
  jumlah_kamar integer not null default 0 check (jumlah_kamar >= 0),
  created_at timestamptz not null default now()
);

create index if not exists kos_area_idx on public.kos (lower(area));
create index if not exists kos_harga_idx on public.kos (harga);

alter table public.kos enable row level security;

-- Role PostgREST juga butuh privilege tabel, bukan hanya policy RLS.
grant select on public.kos to anon, authenticated;
grant insert, update, delete on public.kos to authenticated;

-- Semua orang, termasuk pencari tanpa login, boleh melihat kos.
drop policy if exists "kos_public_read" on public.kos;
create policy "kos_public_read"
on public.kos
for select
to anon, authenticated
using (true);

-- Hanya pemilik yang bisa menambah kos atas namanya sendiri.
drop policy if exists "kos_owner_insert" on public.kos;
create policy "kos_owner_insert"
on public.kos
for insert
to authenticated
with check (auth.uid() = owner_id);

-- Hanya pemilik yang bisa mengubah kosnya sendiri.
drop policy if exists "kos_owner_update" on public.kos;
create policy "kos_owner_update"
on public.kos
for update
to authenticated
using (auth.uid() = owner_id)
with check (auth.uid() = owner_id);

-- Hanya pemilik yang bisa menghapus kosnya sendiri.
drop policy if exists "kos_owner_delete" on public.kos;
create policy "kos_owner_delete"
on public.kos
for delete
to authenticated
using (auth.uid() = owner_id);
