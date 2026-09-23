# Evaluasi OBE — Program Studi S1 Administrasi Rumah Sakit UNBL

Aplikasi web untuk menyusun laporan akademik per semester berbasis Outcome-Based
Education (OBE): input nilai oleh dosen sampai rekap capaian per CPMK dan CPL per
mahasiswa. Data kurikulum (CPL, mata kuliah, CPMK) mengikuti Buku Kurikulum 2024
dan Simulasi Kurikulum 2024 Revisi 3.1.

## Struktur berkas
- `index.html` — seluruh aplikasi (HTML, CSS, JavaScript dalam satu berkas).
- `netlify.toml` — konfigurasi hosting Netlify.
- `Code.gs` — backend Google Apps Script (dipakai hanya bila berjalan di Apps Script).

## Mode penyimpanan data
Aplikasi mendeteksi lingkungannya secara otomatis:

| Lingkungan            | Penyimpanan            | Bisa dipakai bersama? |
|-----------------------|------------------------|-----------------------|
| Netlify / hosting statis | localStorage peramban | Tidak — per perangkat |
| Google Apps Script    | Google Spreadsheet     | Ya — multi-user        |

Deploy ke Netlify menjalankan **mode demo** (localStorage). Untuk penggunaan
bersama antar-dosen dan admin, gunakan Google Apps Script, atau tambahkan backend
(mis. Supabase) pada lapisan `Store` di dalam `index.html`.

## Cara deploy ke Netlify
1. Unggah berkas ini ke sebuah repository GitHub.
2. Di Netlify: **Add new site → Import an existing project → GitHub**, pilih repo.
3. Build command dikosongkan, Publish directory diisi `.` (titik).
4. **Deploy**. Setiap `push` ke GitHub akan otomatis memutakhirkan situs.

## Lisensi / kepemilikan
Hak cipta Program Studi S1 Administrasi Rumah Sakit, Universitas Borneo Lestari.
