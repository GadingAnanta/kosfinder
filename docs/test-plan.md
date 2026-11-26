# Test Plan: KosFinder v0.1.0

Sumber: `docs/PRD.md`, `docs/ARCHITECTURE.md`, dan `docs/TASKS.md`.

## 1. Cara menjalankan

```powershell
flutter analyze --no-pub
flutter test --no-pub
flutter build apk --debug --no-pub
```

Untuk uji manual dengan Supabase:

```powershell
flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

Jangan memakai service_role key. Tanpa `--dart-define`, aplikasi memakai sumber data kosong dan tetap harus terbuka.

## 2. Pemetaan acceptance criteria

| AC | Skenario singkat | Bukti otomatis | Uji manual | Status |
| --- | --- | --- | --- | --- |
| US01-AC1 | Daftar kos menampilkan nama, area, harga angka, jumlah kamar | `kos_model_test.dart`, `kos_repository_test.dart`, `widget_test.dart` | Buka aplikasi dengan Supabase aktif; cek baris daftar | Otomatis lulus; manual Supabase belum |
| US01-AC2 | Tabel kos kosong menampilkan pesan ramah | `kos_repository_test.dart`, `kos_provider_test.dart` | Kosongkan tabel `public.kos`; buka ulang aplikasi | Otomatis lulus |
| US02-AC1 | Detail menampilkan nama, area, harga, fasilitas, jumlah kamar | `widget_test.dart` | Pilih salah satu kos dari daftar | Otomatis lulus |
| US02-AC2 | `jumlah_kamar = 0` tampil sebagai `Penuh` | `widget_test.dart` | Buka detail kos dengan 0 kamar | Otomatis lulus |
| US03-AC1 | Cari `singaraja` menampilkan kos Singaraja | `search_test.dart` | Ketik `singaraja` pada kolom cari area | Otomatis lulus |
| US03-AC2 | `singaraja` dan `Singaraja` memberi hasil sama | `search_test.dart` | Ulangi pencarian dengan huruf kapital | Otomatis lulus |
| US04-AC1 | Filter Rp2.000.000: Rp900.000 tampil, Rp2.500.000 tidak | `filter_test.dart` | Isi kolom harga maksimum dengan `2000000` | Otomatis lulus |
| US04-AC2 | Filter tanpa hasil menampilkan pesan kosong | `filter_test.dart` | Isi batas harga di bawah semua kos | Otomatis lulus |
| US05-AC1 | Koneksi gagal menampilkan pesan dan tidak crash | `kos_provider_test.dart` | Matikan internet, buka daftar | Otomatis lulus; manual device belum |
| US05-AC2 | Koneksi kembali, daftar tampil lagi | `kos_provider_test.dart`, `widget_test.dart` | Nyalakan internet, tekan **Coba lagi** | Otomatis lulus |
| US06-AC1 | Register lalu login mengaktifkan sesi pemilik | `auth_test.dart` | Daftar akun baru, lalu masuk | Otomatis lulus; manual Supabase belum |
| US06-AC2 | Logout mengakhiri sesi; pencari tetap melihat daftar | `auth_test.dart`, `widget_test.dart` | Logout, lalu periksa daftar masih tampil | Otomatis lulus |
| US07-AC1 | Pemilik login menambah kos dengan `owner_id` sendiri | `kos_form_test.dart` | Tambah kos; isi harga `2.000.000` | Otomatis lulus; manual Supabase belum |
| US07-AC2 | Harga bukan angka ditolak dengan pesan jelas | `kos_form_test.dart` | Isi harga `abc`, tekan **Simpan** | Otomatis lulus |
| US08-AC1 | Ubah jumlah kamar menjadi 3; detail pencari menampilkan 3 | `kos_update_test.dart` | Pilih kos di form, ubah kamar jadi 3, buka ulang detail | Otomatis lulus; manual Supabase belum |
| US08-AC2 | Pemilik B gagal mengubah kos pemilik A | `kos_update_test.dart` | Uji dua akun seperti prosedur di bawah | Otomatis lulus; RLS Supabase belum |
| US09-AC1 | Hapus kos sendiri; kos hilang dari daftar | `kos_delete_test.dart` | Tekan ikon hapus pada kos sendiri, konfirmasi | Otomatis lulus; manual Supabase belum |
| US09-AC2 | Pemilik B gagal menghapus kos pemilik A | `kos_delete_test.dart` | Uji dua akun seperti prosedur di bawah | Otomatis lulus; RLS Supabase belum |

## 3. Prosedur uji dua akun (RLS)

1. Di Supabase Authentication, buat dua akun: `ownerA@example.com` dan `ownerB@example.com`.
2. Login sebagai A, tambah satu kos. Catat `id` kos tersebut.
3. Logout, login sebagai B.
4. Buka form ubah, coba ubah kos A menjadi 3 kamar. Harus gagal dengan pesan **Kos ini bukan milik Anda.** dan data A tetap 1 kamar.
5. Kembali ke daftar. Tombol hapus tidak boleh tampil pada kos A ketika B login.
6. Coba hapus kos A lewat request Supabase langsung dengan sesi B. RLS `kos_owner_delete` harus menolak.
7. Login kembali sebagai A. Kos A masih ada dan bisa diubah/dihapus.

## 4. Ringkasan hasil saat ini

- `flutter analyze --no-pub`: bersih.
- `flutter test --no-pub`: **37 tests passed**.
- `flutter build apk --debug --no-pub`: berhasil.
- Belum dibuktikan: uji RLS dua akun di project Supabase nyata dan uji interaktif di device/emulator.

## 5. Catatan bonus

T11 (sinkronisasi jumlah kamar ke halaman detail) secara fungsional sudah tercakup oleh `updateKos()` yang memuat ulang daftar; detail menerima objek `Kos` terbaru dari daftar. Uji manual tetap diperlukan sebelum fitur bonus dinyatakan selesai.
