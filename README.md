# OlahMenu

OlahMenu adalah aplikasi Flutter untuk membantu pengguna memasak dari bahan yang sudah tersedia di rumah. Aplikasi ini menggabungkan katalog resep, pencocokan bahan, resep AI, favorit tersimpan, dan pengelolaan akun berbasis Supabase.

## Ringkasan Produk

- Pilih bahan yang ada di rumah lalu temukan resep yang paling cocok.
- Lihat katalog resep lengkap dengan pencarian dan filter.
- Buka detail resep untuk melihat bahan, langkah memasak, dan penyesuaian porsi.
- Simpan resep favorit, termasuk resep AI.
- Kelola akun pengguna, foto profil, password, dan hapus akun.

## Fitur Utama

- Onboarding pertama kali untuk memperkenalkan alur aplikasi.
- Autentikasi pengguna:
  - Login
  - Register
  - Reset password
- Pemilihan bahan:
  - Pencarian bahan
  - Filter kategori
  - Tambah bahan baru ke database
  - Pilih dan reset bahan terpilih
- Rekomendasi resep:
  - Pencocokan bahan terhadap resep database
  - Skor kecocokan resep
  - Filter hasil berdasarkan relevansi, kecepatan, dan kemudahan
- Resep AI:
  - Generate resep dari bahan yang dipilih
  - Tampilkan bahan, langkah, tips, dan catatan AI
- Detail resep:
  - Detail bahan wajib dan opsional
  - Penyesuaian porsi
  - Langkah memasak terurut
- Favorit:
  - Simpan resep database
  - Simpan resep AI
  - Sinkronisasi favorit per akun saat login
- Profil:
  - Lihat ringkasan akun
  - Ubah foto profil
  - Ubah nama dan password
  - Hapus akun permanen

## Tech Stack

- Flutter
- Dart
- Provider
- Supabase
- Shared Preferences
- Cached Network Image
- Image Picker
- Google Fonts

## Struktur Proyek

- `lib/` kode aplikasi Flutter
- `assets/` gambar, ilustrasi onboarding, background, dan resep
- `supabase/migrations/` skema database dan perubahan schema
- `supabase/functions/` Edge Functions untuk generate resep AI dan hapus akun
- `test/` unit test dan widget test

## Prasyarat

- Flutter SDK
- Dart SDK
- Akun Supabase
- Project Supabase dengan tabel, bucket storage, migration, dan Edge Functions yang sesuai

## Setup

1. Clone repository ini.
2. Jalankan instalasi dependency:

```bash
flutter pub get
```

3. Siapkan nilai Supabase saat menjalankan aplikasi:

```bash
flutter run \
  --dart-define=SUPABASE_URL=your_supabase_url \
  --dart-define=SUPABASE_ANON_KEY=your_supabase_anon_key
```

4. Untuk build release, gunakan perintah Flutter sesuai platform target.

## Konfigurasi Supabase

Aplikasi ini membutuhkan:

- Tabel data resep, bahan, langkah, profil, dan favorit
- Storage bucket untuk gambar bahan dan avatar profil
- Edge Function `generate-recipe`
- Edge Function `delete-account`

Migration Supabase tersedia di folder `supabase/migrations/`.

## Testing

Jalankan test dengan:

```bash
flutter test
```

## Navigasi Aplikasi

- Home
- Pilih Bahan
- Daftar Resep
- Favorit
- Profil

## Dokumentasi Produk

- [PRD](./PRD.md)

## Lisensi

Proyek ini bersifat private atau internal, sesuai pengaturan `publish_to: none` pada `pubspec.yaml`.
