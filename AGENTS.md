# AGENTS.md

## Konteks proyek

Project ini adalah **KosFinder versi 1**, aplikasi Android Flutter dengan backend Supabase. Tidak boleh melanjutkan `kosfinder_device_demo` atau `tugas_9` sebagai source code utama. Project ini dibangun dari awal dengan alur vibe coding terstruktur: ide -> PRD -> arsitektur -> task -> implementasi -> uji -> rilis.

Dokumen acuan yang wajib dibaca sebelum bekerja:

- `docs/input/ide.md`
- `docs/PRD.md`
- `docs/ARCHITECTURE.md`
- `docs/TASKS.md`

Baca berkas yang disebut saja. Jangan membaca seluruh repository tanpa arah.

## Cara kerja

- Satu task per permintaan. Jangan mengerjakan beberapa task sekaligus.
- Jangan mengubah file di luar file yang disebut pada task.
- Untuk perubahan besar, rencanakan dulu dan minta persetujuan.
- Pilih solusi paling sederhana yang memenuhi PRD.
- Jangan menambah package tanpa persetujuan SE.
- Jangan menambah fitur di luar PRD, terutama foto, peta, chat, rating, pembayaran, rekomendasi AI, verifikasi identitas, notifikasi, dan filter fasilitas.
- Jawab ringkas. Tampilkan hanya yang berubah.

## Teknologi

- Flutter (Dart), Android.
- Provider untuk state management.
- Supabase untuk auth, database, dan Row Level Security.
- Navigasi memakai `Navigator` bawaan Flutter, tanpa package router tambahan.

## Keamanan

- Tidak ada key, password, atau token di chat, kode, `.env`, maupun repository.
- `SUPABASE_URL` dan `SUPABASE_ANON_KEY` hanya dibaca dari `--dart-define`.
- Service_role key tidak pernah dipakai di aplikasi.
- Hak akses ditegakkan dengan Row Level Security di Supabase, bukan hanya dengan menyembunyikan tombol.
- Setiap tabel baru wajib memiliki policy RLS dan diuji dengan dua akun berbeda.

## Git

- Satu task atau satu dokumen, satu commit.
- Pesan commit harus menyebut ID task atau dokumen, misalnya `T03: filter harga (US04-AC1)` atau `docs: tambah PRD`.
- Commit hanya setelah SE menyetujui hasil.
- Jangan commit file `.env`, APK, atau kredensial.

## Definition of Done

Sebuah task hanya selesai jika:

- `flutter analyze` bersih.
- `flutter test` lulus.
- Aplikasi dijalankan di device/emulator dan AC terkait dicoba.
- Perubahan dijelaskan ringkas untuk SE: file apa yang berubah, fungsinya, cara mencobanya, serta risiko/kelemahan yang belum diuji.

## Identitas tampilan

Tampilkan NIM dan Nama di halaman About dengan format:

```text
2415051066 - Agus Adrian Satria Ananta
```
