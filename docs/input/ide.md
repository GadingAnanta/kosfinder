# Ide: KosFinder

## Pengguna

- Mahasiswa atau masyarakat yang mencari kos di sekitar kampus. Pencari dapat melihat daftar kos tanpa login.
- Pemilik kos yang ingin mempublikasikan kosnya. Pemilik wajib login untuk mengelola data kosnya.

## Masalah

- Informasi kos tersebar di media sosial, grup WhatsApp, dan dari mulut ke mulut.
- Pencari sulit membandingkan harga dan fasilitas kos.
- Pemilik kesulitan memperbarui ketersediaan kamar ketika ada perubahan.

## Yang diharapkan bisa dilakukan

- Pencari melihat daftar kos dari Supabase dan membuka detail kos.
- Pencari mencari kos berdasarkan area dengan huruf besar/kecil dianggap sama, misalnya `singaraja` dan `Singaraja` menghasilkan data yang sama.
- Pencari menyaring kos berdasarkan harga maksimum; kos Rp900.000 tampil saat batas Rp2.000.000, sedangkan kos Rp2.500.000 tidak tampil.
- Pencari melihat pesan ramah ketika hasil pencarian kosong atau koneksi gagal.
- Pemilik mendaftar, masuk, keluar, menambah kos, mengubah kos, dan menghapus kos MILIKNYA SENDIRI.
- Pemilik mengubah jumlah kamar. Pada halaman detail pencari, jumlah kamar ikut berubah dan kamar 0 ditampilkan sebagai `Penuh`.
- Pemilik lain tidak dapat mengubah atau menghapus kos milik pemilik A, meskipun mencoba lewat aplikasi.

## Batasan

- Aplikasi Android dibuat dengan Flutter. Backend memakai Supabase.
- Versi pertama TIDAK mencakup: pembayaran online, chat, ulasan dan rating, rekomendasi AI, verifikasi identitas pemilik, upload foto, dan peta.
- Data harga bertipe angka, bukan teks.
- Hak akses ditegakkan di backend Supabase melalui Row Level Security, bukan hanya dengan menyembunyikan tombol di aplikasi.
- Versi pertama hanya memakai data kos berupa teks dan angka; tidak ada foto, tidak ada peta, tidak ada notifikasi.
