# PRD: KosFinder Versi 1

## 1. Masalah dan tujuan yang bisa diukur

Informasi kos tersebar di media sosial dan grup WhatsApp sehingga pencari sulit membandingkan harga dan fasilitas; pemilik juga sulit memperbarui ketersediaan kamar.

Tujuan yang bisa diukur:

- Daftar dan detail kos terbaca dari Supabase, bukan data tiruan.
- 100% acceptance criteria di bawah lulus saat diuji di emulator/HP.
- Uji dua akun berbeda membuktikan pemilik B gagal mengubah/menghapus kos milik pemilik A.
- Aplikasi tetap menampilkan pesan ramah saat hasil kosong atau koneksi gagal.
- APK release `v0.1.0` berhasil dirilis.

## 2. Pengguna

- **Pencari**: mahasiswa/masyarakat; melihat daftar, mencari, memfilter, dan membuka detail tanpa login.
- **Pemilik**: akun yang mendaftar/login untuk menambah, mengubah, dan menghapus kos miliknya sendiri.

## 3. Scope versi 1

**Masuk:** daftar kos dari Supabase, detail kos, pencarian area case-insensitive, filter harga maksimum, pesan kosong/gagal, register/login/logout pemilik, tambah/ubah/hapus kos milik sendiri, RLS di Supabase, halaman About berisi NIM dan Nama sesuai identitas mahasiswa.

**TIDAK masuk:** pembayaran online, chat, ulasan/rating, rekomendasi AI, verifikasi identitas pemilik, upload foto, peta, notifikasi, dan filter fasilitas. Fasilitas hanya ditampilkan sebagai teks di detail.

## 4. NFR (bisa diuji)

- **Keamanan:** URL dan anon/publishable key dibaca dari `--dart-define`; tidak ada service_role key di kode/repo; hak akses ditegakkan RLS (diuji US08-AC2 dan US09-AC2).
- **Keandalan:** saat koneksi gagal, aplikasi menampilkan pesan dan tidak crash (US05-AC1).
- **Kemudahan pakai:** dari daftar, pencarian area dan filter harga dapat dilakukan tanpa membuka menu tersembunyi.
- **Performa:** dengan 20 data kos contoh, daftar tampil dalam waktu wajar di emulator tanpa loading tak berujung.
- **Privasi:** tidak mengumpulkan foto, lokasi GPS, atau data pribadi selain email akun pemilik; NIM/Nama hanya tampil di About.

## 5. User story dan acceptance criteria

### US01 - Melihat daftar kos

Sebagai pencari, saya ingin melihat daftar kos dari Supabase tanpa login, agar dapat mulai membandingkan pilihan.

- **US01-AC1** Given Supabase berisi kos, When aplikasi dibuka, Then daftar menampilkan nama, area, harga bertipe angka, dan jumlah kamar.
- **US01-AC2** Given tabel kos kosong, When aplikasi dibuka, Then pesan "Belum ada kos yang tersedia" tampil dan aplikasi tidak crash.

### US02 - Membuka detail kos

Sebagai pencari, saya ingin membuka detail kos, agar dapat melihat informasi lengkap sebelum memutuskan.

- **US02-AC1** Given daftar kos tampil, When salah satu kos dipilih, Then detail menampilkan nama, area, harga, fasilitas, dan jumlah kamar.
- **US02-AC2** Given `jumlah_kamar` bernilai 0, When detail dibuka, Then status "Penuh" tampil.

### US03 - Mencari area

Sebagai pencari, saya ingin mencari kos berdasarkan area tanpa peduli huruf besar/kecil, agar hasil tetap konsisten.

- **US03-AC1** Given kos dengan area `Singaraja`, When saya mencari `singaraja`, Then kos tersebut tampil.
- **US03-AC2** Given pencarian `singaraja` dan `Singaraja`, When keduanya dijalankan, Then hasilnya sama.

### US04 - Memfilter harga

Sebagai pencari, saya ingin memfilter kos berdasarkan harga maksimum, agar sesuai anggaran.

- **US04-AC1** Given kos Rp900.000 dan Rp2.500.000, When filter maksimum Rp2.000.000 diterapkan, Then kos Rp900.000 tampil dan Rp2.500.000 tidak tampil.
- **US04-AC2** Given filter menghasilkan nol kos, When diterapkan, Then pesan hasil kosong tampil.

### US05 - Koneksi gagal

Sebagai pencari, saya ingin mendapat pesan yang jelas saat koneksi gagal, agar tidak mengira aplikasi rusak.

- **US05-AC1** Given Supabase tidak dapat dihubungi, When daftar dibuka, Then pesan error ramah tampil dan aplikasi tidak crash.
- **US05-AC2** Given koneksi kembali normal, When aplikasi dibuka ulang, Then daftar kos tampil lagi.

### US06 - Akun pemilik

Sebagai pemilik, saya ingin mendaftar, masuk, dan keluar, agar dapat mengelola kos saya.

- **US06-AC1** Given email/password valid, When pemilik mendaftar lalu masuk, Then sesi pemilik aktif.
- **US06-AC2** Given sesi pemilik aktif, When pemilik logout, Then sesi berakhir dan pencari tetap bisa melihat daftar tanpa login.

### US07 - Menambah kos

Sebagai pemilik, saya ingin menambah kos, agar data kos saya tampil di aplikasi.

- **US07-AC1** Given pemilik login, When menambah kos berisi nama, area, harga angka, fasilitas, dan jumlah kamar, Then kos tersimpan dengan `owner_id` pemilik tersebut.
- **US07-AC2** Given harga diisi bukan angka, When disimpan, Then validasi menolak dan pesan jelas tampil.

### US08 - Mengubah kos milik sendiri

Sebagai pemilik, saya ingin mengubah kos saya, agar informasi tetap mutakhir.

- **US08-AC1** Given pemilik A memiliki kos, When jumlah kamar diubah menjadi 3, Then perubahan tersimpan dan detail pencari menampilkan 3.
- **US08-AC2** Given pemilik A login dan kos milik pemilik B, When pemilik A mencoba mengubah kos tersebut, Then RLS menolak dan data pemilik B tetap utuh.

### US09 - Menghapus kos milik sendiri

Sebagai pemilik, saya ingin menghapus kos saya, agar data lama tidak tampil.

- **US09-AC1** Given pemilik A memiliki kos, When kos tersebut dihapus, Then kos tidak lagi tampil di daftar.
- **US09-AC2** Given pemilik B login, When mencoba menghapus kos milik pemilik A, Then RLS menolak dan kos milik A tetap ada.

## Pertanyaan yang masih ambigu

Tidak ada. Semua keputusan sudah diklarifikasi pada Tahap 2 dan disetujui SE.
