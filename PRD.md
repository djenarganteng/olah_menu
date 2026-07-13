# Product Requirements Document - OlahMenu

## 1. Ringkasan Produk

OlahMenu adalah aplikasi mobile Flutter untuk membantu pengguna memasak dari bahan yang tersedia di rumah. Aplikasi menampilkan katalog resep, mencocokkan bahan yang dipilih dengan resep yang ada, menyediakan resep yang dibuat AI, serta menyimpan favorit dan data profil pengguna melalui Supabase.

## 2. Masalah yang Diselesaikan

- Pengguna sering memiliki bahan di rumah tetapi bingung mau memasak apa.
- Mencari resep yang cocok biasanya memakan waktu dan tidak selalu sesuai stok bahan.
- Pengguna ingin menyimpan resep favorit agar mudah diakses lagi.
- Pengguna membutuhkan resep alternatif ketika tidak ada resep database yang pas.

## 3. Tujuan Produk

- Mempercepat proses menemukan resep berdasarkan bahan yang ada.
- Mengurangi pemborosan bahan makanan.
- Menyediakan pengalaman pencarian resep yang sederhana dan personal.
- Memberikan opsi resep AI ketika katalog resep belum cukup cocok.

## 4. Target Pengguna

- Pengguna rumahan yang ingin memasak cepat dan praktis.
- Pengguna yang ingin memanfaatkan bahan sisa di dapur.
- Pengguna yang suka menyimpan resep untuk dipakai ulang.
- Pengguna yang ingin mencoba ide resep berbasis AI.

## 5. Value Proposition

OlahMenu membantu pengguna mengubah bahan yang sudah ada menjadi ide masakan yang relevan, hemat waktu, dan lebih sedikit mubazir.

## 6. Ruang Lingkup Produk

### In Scope

- Onboarding awal.
- Login, register, reset password, logout.
- Pemilihan bahan dari database.
- Penambahan bahan baru oleh pengguna.
- Rekomendasi resep berbasis pencocokan bahan.
- Daftar resep lengkap dengan pencarian dan filter.
- Detail resep dengan bahan, porsi, dan langkah memasak.
- Resep AI dari bahan terpilih.
- Favorit resep database dan AI.
- Profil pengguna, foto avatar, ubah nama, ubah password, dan hapus akun.

### Out of Scope

- Marketplace belanja bahan.
- Integrasi pembayaran.
- Komunitas komentar dan rating publik.
- Meal planner mingguan.
- Sinkronisasi multi-device di luar data akun dan favorit yang sudah ada.

## 7. User Journey Utama

1. Pengguna membuka aplikasi dan melihat onboarding.
2. Pengguna login atau register.
3. Pengguna memilih bahan yang tersedia di rumah.
4. Sistem menghitung kecocokan resep dari database.
5. Jika tidak ada hasil yang memadai, pengguna dapat membuat resep AI.
6. Pengguna membuka detail resep, menyesuaikan porsi, dan membaca langkah memasak.
7. Pengguna menyimpan resep ke favorit.
8. Pengguna mengelola profil dari halaman profil.

## 8. Fitur dan Kebutuhan Fungsional

### 8.1 Onboarding

- Menampilkan beberapa halaman perkenalan.
- Memiliki tombol lanjut dan lewati.
- Menyimpan status onboarding agar tidak muncul ulang setelah selesai.

### 8.2 Autentikasi

- Pengguna dapat register dengan email, password, dan nama lengkap.
- Pengguna dapat login dan logout.
- Pengguna dapat reset password via email.
- Aplikasi harus mendukung password recovery flow.

### 8.3 Pemilihan Bahan

- Menampilkan daftar bahan dari Supabase.
- Mendukung pencarian bahan.
- Mendukung filter kategori bahan.
- Pengguna dapat memilih beberapa bahan sekaligus.
- Pengguna dapat menambahkan bahan baru.
- Bahan baru divalidasi agar tidak duplikat dan harus punya nama serta kategori.

### 8.4 Rekomendasi Resep

- Sistem mencocokkan bahan yang dipilih dengan resep database.
- Resep diprioritaskan berdasarkan tingkat kecocokan.
- Hasil dapat difilter berdasarkan:
  - Paling cocok
  - Cepat
  - Bahan kurang sedikit
  - Mudah
- Jika tidak ada resep yang cocok, aplikasi menampilkan opsi resep AI.

### 8.5 Resep AI

- Pengguna dapat meminta resep AI berdasarkan bahan yang dipilih.
- Resep AI menampilkan judul, deskripsi, bahan, langkah, tips, dan catatan AI.
- Resep AI dapat disimpan ke favorit.

### 8.6 Daftar Resep

- Menampilkan seluruh resep yang tersedia.
- Menyediakan pencarian berdasarkan nama atau deskripsi.
- Menyediakan filter:
  - Semua
  - Cepat
  - Mudah
  - Bahan sedikit

### 8.7 Detail Resep

- Menampilkan gambar resep.
- Menampilkan deskripsi resep.
- Menampilkan bahan utama dan tambahan.
- Menampilkan langkah memasak.
- Menampilkan kontrol porsi.
- Takaran bahan menyesuaikan porsi.

### 8.8 Favorit

- Pengguna dapat menyimpan atau menghapus resep favorit.
- Favorit mencakup resep database dan resep AI.
- Favorit disimpan per pengguna ketika akun aktif.

### 8.9 Profil dan Akun

- Menampilkan nama, email, avatar, dan ringkasan aktivitas.
- Pengguna dapat mengganti foto profil dari galeri.
- Pengguna dapat mengubah nama dan password.
- Pengguna dapat menghapus akun secara permanen setelah re-authentication.

## 9. Kebutuhan Non-Fungsional

- Aplikasi harus responsif untuk ukuran layar mobile umum.
- UI harus tetap dapat digunakan tanpa koneksi sempurna, dengan state loading dan error yang jelas.
- Data akun dan favorit harus aman dan terkait dengan user Supabase.
- Aplikasi harus mempertahankan performa yang baik saat menampilkan daftar resep dan gambar.
- Aplikasi harus memiliki fallback ketika konfigurasi Supabase belum lengkap.

## 10. Integrasi Backend

### Supabase

- Auth untuk login, register, reset password, dan user session.
- Database untuk resep, bahan, langkah, profil, dan favorit.
- Storage untuk avatar dan gambar bahan.

### Edge Functions

- `generate-recipe` untuk menghasilkan resep AI.
- `delete-account` untuk menghapus data akun secara permanen.

## 11. Data Utama

- `ingredients`
- `recipes`
- `recipe_ingredients`
- `recipe_steps`
- `profiles`
- `user_favorite_recipes`
- `user_favorite_ai_recipes`
- `ai_generated_recipes`

## 12. Keberhasilan Produk

Metrik yang dapat dipakai untuk mengevaluasi produk:

- Persentase pengguna yang menyelesaikan onboarding dan login.
- Jumlah pengguna yang memilih bahan sebelum keluar dari aplikasi.
- Persentase rekomendasi resep yang dibuka ke halaman detail.
- Jumlah resep yang disimpan ke favorit.
- Jumlah pemakaian fitur resep AI.
- Rasio pengguna yang kembali membuka aplikasi setelah penggunaan pertama.

## 13. Risiko dan Ketergantungan

- Konfigurasi Supabase yang belum diisi akan membuat aplikasi tidak bisa berjalan penuh.
- Edge Function `generate-recipe` harus aktif agar fitur AI berjalan.
- Edge Function `delete-account` harus aktif agar penghapusan akun bekerja.
- Sinkronisasi favorit bergantung pada status login dan skema database yang sesuai.

## 14. Rencana Rilis

### Versi Saat Ini

- Navigasi utama, auth, bahan, rekomendasi, resep AI, favorit, dan profil sudah tersedia.

### Pengembangan Berikutnya

- Penyempurnaan kualitas hasil rekomendasi.
- Peningkatan observabilitas error backend.
- Personalisasi rekomendasi yang lebih canggih.
- Fitur pencarian dan filter yang lebih detail pada katalog resep.

## 15. Catatan Implementasi

- Aplikasi dibangun dengan Flutter dan Provider.
- Status login dikelola melalui Supabase Auth.
- Favorit disimpan dengan dukungan sinkronisasi akun dan cache lokal.
- Assets dan gambar resep sudah disiapkan di folder `assets/`.
