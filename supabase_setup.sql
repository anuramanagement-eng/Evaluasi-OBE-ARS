-- ============================================================================
-- Evaluasi OBE — S1 Administrasi Rumah Sakit UNBL
-- Skema database + keamanan (Row Level Security) untuk Supabase
-- Jalankan seluruh isi berkas ini di Supabase → SQL Editor → New query → Run.
-- ============================================================================

-- 1) Tabel data utama. Semua koleksi (mk, cpmk, dosen, mhs, kelas, asesmen,
--    nilai, setting) disimpan di satu tabel sebagai JSON, meniru struktur
--    penyimpanan aplikasi.
create table if not exists public.records (
  coll        text        not null,
  id          text        not null,
  data        jsonb       not null,
  updated_at  timestamptz default now(),
  updated_by  text,
  primary key (coll, id)
);
create index if not exists records_coll_idx on public.records (coll);

-- 2) Daftar email admin prodi (dipakai oleh fungsi keamanan is_admin()).
create table if not exists public.admins ( email text primary key );

-- 3) Hak akses dasar untuk pengguna yang sudah login.
grant select, insert, update, delete on public.records to authenticated;
grant select on public.admins to authenticated;

-- 4) Aktifkan Row Level Security.
alter table public.records enable row level security;
alter table public.admins  enable row level security;

-- 5) Fungsi penentu admin: benar bila email pengguna ada di tabel admins,
--    atau ada baris dosen dengan role = 'admin' dan email yang sama.
create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.admins a
                 where lower(a.email) = lower(auth.email()))
      or exists (select 1 from public.records r
                 where r.coll = 'dosen'
                   and lower(r.data->>'email') = lower(auth.email())
                   and r.data->>'role' = 'admin');
$$;

-- 6) Kebijakan akses.
-- 6a) Semua pengguna login boleh MEMBACA seluruh data.
drop policy if exists "baca semua" on public.records;
create policy "baca semua" on public.records
  for select to authenticated using (true);

-- 6b) Data master (kurikulum, dosen, mahasiswa, kelas, pengaturan):
--     hanya admin prodi yang boleh menulis.
drop policy if exists "tulis master (admin)" on public.records;
create policy "tulis master (admin)" on public.records
  for all to authenticated
  using      (coll in ('mk','cpmk','dosen','mhs','kelas','setting') and public.is_admin())
  with check (coll in ('mk','cpmk','dosen','mhs','kelas','setting') and public.is_admin());

-- 6c) Rencana asesmen & nilai: semua pengguna login boleh menulis.
--     (Pembatasan "hanya dosen pengampu" + kunci nilai final ditegakkan di
--     aplikasi. Lihat blok OPSIONAL di bawah untuk penegakan di level database.)
drop policy if exists "tulis nilai (login)" on public.records;
create policy "tulis nilai (login)" on public.records
  for all to authenticated
  using      (coll in ('asesmen','nilai'))
  with check (coll in ('asesmen','nilai'));

-- 6d) Tabel admins boleh dibaca pengguna login (opsional, untuk transparansi).
drop policy if exists "baca admins" on public.admins;
create policy "baca admins" on public.admins
  for select to authenticated using (true);

-- 7) Daftarkan admin prodi pertama. GANTI dengan email admin sebenarnya,
--    dan gunakan email yang sama di window.ADMIN_EMAILS pada index.html.
insert into public.admins (email) values ('admin@unbl.ac.id')
  on conflict do nothing;

-- ============================================================================
-- OPSIONAL (pengetatan lanjutan) — jalankan bila ingin membatasi penulisan
-- nilai hanya oleh dosen pengampu kelas, ditegakkan di level database.
-- Hapus dulu kebijakan 6c, lalu buat fungsi + kebijakan berikut.
-- ----------------------------------------------------------------------------
-- drop policy if exists "tulis nilai (login)" on public.records;
--
-- create or replace function public.can_edit_kelas(kelas_id text) returns boolean
-- language sql stable security definer set search_path = public as $$
--   select public.is_admin()
--       or exists (
--         select 1 from public.records k
--         join public.records d
--           on d.coll = 'dosen' and d.id = k.data->>'dosen'
--         where k.coll = 'kelas' and k.id = kelas_id
--           and lower(d.data->>'email') = lower(auth.email())
--       );
-- $$;
--
-- create policy "tulis nilai (pengampu)" on public.records
--   for all to authenticated
--   using      (coll in ('asesmen','nilai') and public.can_edit_kelas(id))
--   with check (coll in ('asesmen','nilai') and public.can_edit_kelas(id));
-- ============================================================================
