# KosFinder

Aplikasi Android Flutter untuk melihat, mencari, memfilter, dan mengelola data kos. Pencari dapat mengakses daftar tanpa login; pemilik login untuk menambah, mengubah, dan menghapus kos miliknya sendiri.

Identitas: **2415051066 - Agus Adrian Satria Ananta**

Versi rilis: **v0.1.0**

## Fitur

- Daftar kos dari tabel `public.kos` di Supabase.
- Detail kos dengan status `Penuh` saat `jumlah_kamar = 0`.
- Pencarian area case-insensitive dan filter harga maksimum.
- Pesan ramah saat hasil kosong atau koneksi gagal.
- Register, login, dan logout pemilik.
- Tambah, ubah, dan hapus kos milik sendiri.
- Hak akses ditegakkan dengan Row Level Security di Supabase.

Dokumen acuan:

- `docs/input/ide.md`
- `docs/PRD.md`
- `docs/ARCHITECTURE.md`
- `docs/TASKS.md`
- `docs/test-plan.md`

## Arsitektur singkat

Alur yang dipakai: **Screen -> Provider -> Repository -> Supabase**.

Komponen utama:

- `lib/screens/`: `KosListPage`, `KosDetailPage`, `KosFormPage`, `AuthPage`, `AboutPage`.
- `lib/providers/`: `KosProvider`, `AuthProvider`.
- `lib/repositories/`: `KosRepository`, `AuthRepository`.
- `lib/models/kos.dart`: model satu baris tabel `public.kos`.
- `lib/config/supabase_config.dart`: pembaca konfigurasi dari `--dart-define`.

Prasyarat:

- Flutter SDK dengan Dart `^3.14.0`.
- Project Supabase dengan tabel `public.kos`.
- Android SDK/device emulator untuk menjalankan APK.

## Menyiapkan Supabase

1. Buka Supabase Dashboard project Anda.
2. Masuk ke **SQL Editor**.
3. Jalankan seluruh isi `supabase/migrations/001_init.sql`.
4. Pastikan tabel `public.kos` dan policy RLS `kos_public_read`, `kos_owner_insert`, `kos_owner_update`, `kos_owner_delete` terbentuk.
5. Gunakan anon/publishable key di aplikasi. Jangan pernah memakai service_role key.

## Konfigurasi dan menjalankan

Tanpa konfigurasi, aplikasi tetap terbuka memakai sumber data kosong:

```powershell
flutter pub get
flutter run
```

Dengan Supabase:

```powershell
flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

Ganti nilai placeholder dengan konfigurasi project Anda. Kredensial tidak boleh disimpan di repository.

## Pengujian

```powershell
flutter analyze --no-pub
flutter test --no-pub
flutter build apk --debug --no-pub
flutter build apk --release --no-pub
```

Hasil saat dokumen ini ditulis:

- `flutter analyze --no-pub`: bersih.
- `flutter test --no-pub`: **37 tests passed**.
- `flutter build apk --debug --no-pub`: berhasil.
- `flutter build apk --release --no-pub`: berhasil menghasilkan `build/app/outputs/flutter-apk/app-release.apk` (48,9 MB).

Detail pemetaan acceptance criteria dan prosedur uji dua akun ada di `docs/test-plan.md`.

## Build APK

APK tidak di-commit ke repository. Lokasi keluaran:

```text
build/app/outputs/flutter-apk/app-debug.apk
build/app/outputs/flutter-apk/app-release.apk
```

Jika proses signing release bermasalah pada lingkungan tertentu, debug APK boleh dipakai dengan alasan yang dicatat di catatan rilis.

## Checklist rilis v0.1.0

- [x] AC US01-US09 diimplementasikan pada Slice 1-4.
- [x] `flutter analyze --no-pub` bersih.
- [x] `flutter test --no-pub` lulus (37 tests).
- [x] `flutter build apk --release --no-pub` berhasil.
- [x] Versi `pubspec.yaml` diset ke `0.1.0+1`.
- [x] Uji interaktif di device/emulator dengan Supabase aktif.
- [x] Uji RLS dengan dua akun berbeda seperti `docs/test-plan.md`.
- [ ] Buat dan push tag `v0.1.0`.
- [ ] Unggah APK ke GitHub Release `v0.1.0`.
- [ ] Lampirkan bukti uji manual ke catatan rilis.

## Catatan keamanan

- URL dan anon/publishable key hanya dibaca dari `--dart-define`.
- Tidak ada key, password, atau token di kode maupun repository.
- Service_role key tidak dipakai aplikasi.
- Penolakan pemilik lain dilakukan oleh RLS Supabase, bukan sekadar menyembunyikan tombol.

## Status verifikasi

Uji manual di device/emulator dan uji RLS dua akun pada project Supabase nyata sudah dilakukan. Bukti otomatis ada di `outputs/rls_test_result.txt`.
