# Dokumentasi Verifikasi Mandiri & Hasil AI

**Nama**: Achmad Anval Adhiem Allain  
**NIM**: 244107020039  
**Kelas**: TI-3E  
**Mata Kuliah**: Praktikum Pemrograman Mobile (Week 5 - Local Storage & Offline-First)

---

## 📋 Ringkasan Verifikasi Mandiri

### 1. UI Tidak Memanggil SQLite/SharedPreferences Langsung
- **Status**: ✅ **Terpenuhi**
- **Penjelasan**:
  - Akses `SharedPreferences` dipusatkan di `PrefsRepository` (`lib/data/prefs.dart`).
  - Akses SQLite dipusatkan di `NoteRepository` (`lib/data/repositories/note_repository.dart`).
  - Lapisan antarmuka (`lib/pages/`) hanya berinteraksi melalui Riverpod Providers (`notesProvider`, `noteByIdProvider`, `dirtyCountProvider`, `postsProvider`, `darkModeProvider`, `forceOfflineProvider`).

---

### 2. Aplikasi Penuh Berfungsi dalam Mode Pesawat
- **Status**: ✅ **Terpenuhi**
- **Penjelasan**:
  - Operasi membaca, menambah, dan menghapus catatan dieksekusi langsung pada database SQLite lokal (`offline_notes.db`).
  - Tidak ada pemblokiran antarmuka oleh jaringan internet saat membuat atau membaca catatan lokal.

---

### 3. Badge Dirty Akurat & Cache Posts Tampil Tanpa Internet
- **Status**: ✅ **Terpenuhi**
- **Penjelasan**:
  - Badge dirty menghitung catatan lokal yang belum disinkronkan (`dirty = 1`) secara reaktif via `dirtyCountProvider`.
  - Tombol sinkronisasi mensimulasikan pengunggahan, memperbarui kolom menjadi `dirty = 0`, dan menginvalidasi provider untuk memperbarui UI.
  - Halaman postingan menerapkan strategi **Cache-First**: data lokal langsung ditampilkan dari tabel `cached_posts`, sehingga postingan tetap dapat dibaca secara offline disertai banner mode offline.

---

### 4. `flutter analyze` Bebas Issue & Semua Unit Test Lolos
- **Status**: ✅ **Terpenuhi**
- **Hasil Pengujian**:
  - `flutter analyze`: **No issues found!**
  - `flutter test`: **All tests passed!** (5 test kasus: parsing null-safe model, integritas flag dirty saat serialisasi, provider sukses dengan repository palsu, provider error dengan penanganan retry Riverpod 3, serta widget serialization test).

---

## 🤖 Log Interaksi & Verifikasi AI

### Interaksi 1: Mengatasi Error Kompilasi dan Pemindahan Lokasi File
* **Prompt**: Pengguna menanyakan mengapa terjadi error saat kode provider diletakkan di `lib/data/repositories/providers.dart`.
* **Analisis & Solusi AI**:
  1. File `providers.dart` dan `api_client.dart` salah penempatan direktori. Keduanya dipindahkan ke `lib/data/providers.dart` dan `lib/data/api_client.dart` agar import relatif (`local/note.dart`, `prefs.dart`, `repositories/note_repository.dart`) valid.
  2. Melengkapi implementasi file-file pendukung yang masih kosong (`prefs.dart`, `local/db.dart`, `local/note.dart`, `models/post.dart`, `repositories/note_repository.dart`, `repositories/post_repository.dart`, dan `sync.dart`).
  3. Menambahkan dependensi `go_router` untuk routing halaman.
* **Hasil Verifikasi**: Kode berhasil dikompilasi tanpa issue (`flutter analyze` bersih).

---

### Interaksi 2: Mengatasi Timeout Test pada Riverpod 3
* **Prompt**: `flutter test` mengalami timeout 30 detik pada unit test `provider error dengan repository palsu`.
* **Analisis & Solusi AI**:
  1. Proyek menggunakan versi terbaru `flutter_riverpod: ^3.4.3`.
  2. Riverpod 3 secara default mengaktifkan mekanisme *automatic retry with exponential backoff* saat sebuah `AsyncNotifier` mengalami kegagalan di `build()`. Hal ini menyebabkan future tidak langsung di-*reject*, melainkan menunggu seluruh siklus retry hingga melebihi batas waktu test 30 detik.
  3. Solusi yang diterapkan adalah menonaktifkan auto-retry khusus pada unit test error menggunakan `retry: (_, _) => null` pada instance `ProviderContainer`:
     ```dart
     final container = ProviderContainer(
       retry: (_, _) => null,
       overrides: [
         noteRepositoryProvider.overrideWithValue(
           FakeNoteRepository(throwError: true),
         ),
       ],
     );
     ```
* **Hasil Verifikasi**: Seluruh unit test berjalan instan dan lulus 100% (`All tests passed!`).

---

## ⚖️ Evaluasi & Keputusan Akhir
Semua solusi telah ditinjau dan disesuaikan dengan arsitektur resmi praktikum (Riverpod + SQLite + SharedPreferences). Pemisahan modul dipertahankan dengan ketat demi menjaga prinsip *Single Responsibility Principle* dan mempermudah pengujian otomatis.
