# TASKS: KosFinder Versi 1

Sumber: `docs/PRD.md`, `docs/ARCHITECTURE.md`, dan `AGENTS.md`.

Aturan: satu task per permintaan, satu commit per task, pesan commit menyebut ID task. Setiap slice harus menghasilkan aplikasi yang bisa dijalankan. Slice 1-4 wajib; Slice 5 bonus.

| ID | Slice | Tujuan | Story / AC | File yang boleh diubah | Cara uji | Status |
| --- | --- | --- | --- | --- | --- | --- |
| T01 | 1 | Siapkan konfigurasi Supabase dari `--dart-define` dan model `Kos` | US01-AC1 | `lib/main.dart`, `lib/app.dart`, `lib/config/supabase_config.dart`, `lib/models/kos.dart`, `test/kos_model_test.dart` | `flutter analyze`, `flutter test`, aplikasi terbuka tanpa key di kode | todo |
| T02 | 1 | Repository mengambil daftar kos dari `public.kos` | US01-AC1, US01-AC2 | `lib/repositories/kos_repository.dart`, `test/kos_repository_test.dart` | Daftar kos tampil; tabel kosong memunculkan pesan | todo |
| T03 | 1 | Provider menyimpan state daftar, loading, dan error koneksi | US01-AC2, US05-AC1, US05-AC2 | `lib/providers/kos_provider.dart`, `test/kos_provider_test.dart` | Matikan internet: pesan muncul, tidak crash; nyala lagi: daftar kembali | todo |
| T04 | 1 | Tampilkan daftar, detail kos, status Penuh, dan About | US01-AC1, US02-AC1, US02-AC2 | `lib/screens/kos_list_page.dart`, `lib/screens/kos_detail_page.dart`, `lib/screens/about_page.dart`, `lib/app.dart` | Buka daftar, pilih detail, cek kos `jumlah_kamar = 0` tampil Penuh, cek NIM-Nama di About | todo |
| T05 | 2 | Cari area case-insensitive | US03-AC1, US03-AC2 | `lib/repositories/kos_repository.dart`, `lib/providers/kos_provider.dart`, `lib/screens/kos_list_page.dart`, `test/search_test.dart` | Cari `singaraja` dan `Singaraja`, hasil sama | todo |
| T06 | 2 | Filter harga maksimum dengan harga bertipe angka | US04-AC1, US04-AC2 | `lib/repositories/kos_repository.dart`, `lib/providers/kos_provider.dart`, `lib/screens/kos_list_page.dart`, `test/filter_test.dart` | Filter Rp2.000.000: Rp900.000 tampil, Rp2.500.000 tidak; hasil kosong ada pesan | todo |
| T07 | 3 | Register, login, logout pemilik; pencari tetap tanpa login | US06-AC1, US06-AC2 | `lib/repositories/auth_repository.dart`, `lib/providers/auth_provider.dart`, `lib/screens/auth_page.dart`, `lib/app.dart`, `test/auth_test.dart` | Daftar + login + logout; setelah logout daftar tetap bisa dilihat | todo |
| T08 | 4 | Tambah kos milik pemilik login dengan validasi harga angka | US07-AC1, US07-AC2 | `lib/screens/kos_form_page.dart`, `lib/providers/kos_provider.dart`, `lib/repositories/kos_repository.dart`, `lib/app.dart`, `test/kos_form_test.dart` | Tambah kos berhasil; harga bukan angka ditolak dengan pesan | todo |
| T09 | 4 | Ubah kos milik sendiri dan tolak kos milik pemilik lain | US08-AC1, US08-AC2 | `lib/screens/kos_form_page.dart`, `lib/providers/kos_provider.dart`, `lib/repositories/kos_repository.dart`, `test/kos_update_test.dart` | Ubah kamar jadi 3; login sebagai pemilik B gagal mengubah kos A | todo |
| T10 | 4 | Hapus kos milik sendiri dan tolak kos milik pemilik lain | US09-AC1, US09-AC2 | `lib/screens/kos_list_page.dart`, `lib/providers/kos_provider.dart`, `lib/repositories/kos_repository.dart`, `test/kos_delete_test.dart` | Hapus kos sendiri; pemilik B gagal menghapus kos A | todo |
| T11 | 5 | Bonus: sinkronisasi jumlah kamar ke halaman detail | US02-AC2, US08-AC1 | `lib/screens/kos_detail_page.dart`, `lib/providers/kos_provider.dart` | Pemilik ubah kamar, buka ulang detail pencari; angka berubah, 0 tampil Penuh | bonus |
