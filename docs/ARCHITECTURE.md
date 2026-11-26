# ARCHITECTURE: KosFinder Versi 1

## Komponen

Pola yang dipakai: **Screen -> Provider -> Repository -> Supabase**.

| Komponen | Tugas | Story terkait |
| --- | --- | --- |
| `KosListPage` | Menampilkan daftar, pencarian area, filter harga, pesan kosong/gagal | US01, US03, US04, US05 |
| `KosDetailPage` | Menampilkan detail kos dan status `Penuh` | US02 |
| `KosFormPage` | Tambah/ubah kos milik sendiri | US07, US08 |
| `AuthPage` | Register, login, logout pemilik | US06 |
| `AboutPage` | Menampilkan `2415051066 - Agus Adrian Satria Ananta` | - |
| `KosProvider` | Menyimpan state daftar, detail, query, filter, loading, error | US01-US05, US07-US09 |
| `AuthProvider` | Menyimpan sesi pemilik | US06 |
| `KosRepository` | Query dan CRUD ke tabel `public.kos` lewat Supabase | US01-US09 |
| `AuthRepository` | Sign up, sign in, sign out | US06 |

Struktur berkas yang direncanakan:

```text
lib/
  main.dart
  app.dart
  config/supabase_config.dart
  models/kos.dart
  repositories/kos_repository.dart
  repositories/auth_repository.dart
  providers/kos_provider.dart
  providers/auth_provider.dart
  screens/kos_list_page.dart
  screens/kos_detail_page.dart
  screens/kos_form_page.dart
  screens/auth_page.dart
  screens/about_page.dart
```

## Navigasi

- `KosListPage` -> `KosDetailPage` saat kos dipilih.
- `KosListPage` -> `AboutPage` lewat ikon AppBar.
- `KosListPage` -> `AuthPage` hanya untuk pemilik yang ingin mengelola kos.
- `AuthPage` / `KosListPage` -> `KosFormPage` setelah sesi pemilik aktif.
- Pencari tanpa login tetap bisa berada di `KosListPage` dan `KosDetailPage`.

## Database

Tabel: `public.kos`.

| Kolom | Tipe | Aturan |
| --- | --- | --- |
| `id` | `uuid` | Primary key, default `gen_random_uuid()` |
| `owner_id` | `uuid` | Foreign key ke `auth.users(id)` |
| `nama` | `text` | Wajib |
| `area` | `text` | Wajib, dipakai pencarian case-insensitive |
| `harga` | `integer` | Wajib, angka, bukan teks; `>= 0` |
| `fasilitas` | `text` | Teks bebas, tampil di detail; bukan filter |
| `jumlah_kamar` | `integer` | Wajib, `>= 0`; `0` ditampilkan `Penuh` |
| `created_at` | `timestamptz` | Default `now()` |

Indeks: `lower(area)` untuk pencarian dan `harga` untuk filter.

## Aturan akses (RLS)

- `SELECT`: `anon` dan `authenticated` boleh melihat semua kos.
- `INSERT`: hanya `authenticated` dengan `owner_id = auth.uid()`.
- `UPDATE`: hanya `authenticated` pada baris dengan `owner_id = auth.uid()`.
- `DELETE`: hanya `authenticated` pada baris dengan `owner_id = auth.uid()`.

Dengan aturan ini, pemilik B gagal mengubah atau menghapus kos milik pemilik A meskipun mencoba lewat aplikasi atau request langsung. Diuji pada US08-AC2 dan US09-AC2.

## Konfigurasi

Baca konfigurasi dari `--dart-define`, bukan kode:

```powershell
flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

Gunakan anon/publishable key. Jangan pernah memakai service_role key.

## Rilis

- Jalankan `flutter analyze` dan `flutter test`.
- Build: `flutter build apk --release`.
- Jika signing release bermasalah, boleh memakai debug APK dengan alasan yang dicatat di README.
- Buat tag `v0.1.0` dan push.
- Unggah APK dari `build/app/outputs/flutter-apk/` ke GitHub Release.
- Jangan commit APK ke repository.

## Package

| Package | Alasan | Story |
| --- | --- | --- |
| `supabase_flutter` | Auth, database, dan RLS | US01-US09 |
| `provider` | State daftar, filter, dan sesi | US01-US09 |

Tidak ada package lain tanpa persetujuan SE.
