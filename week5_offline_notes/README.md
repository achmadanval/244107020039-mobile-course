# Laporan Praktikum Minggu 5: Local Storage & Offline-First

**Nama**: Achmad Anval Adhiem Allain  
**NIM**: 244107020039  
**Kelas**: TI-3E  
**Mata Kuliah**: Praktikum Pemrograman Mobile  
**Topik**: Week 5 — Local Storage (SharedPreferences & SQLite) & Offline-First Architecture  

---

## 📁 Struktur Arsitektur Proyek

Aplikasi dirancang dengan pemisahan tanggung jawab yang jelas (*Separation of Concerns*) dan menerapkan pola *Repository Pattern* bersama Riverpod 3:

```text
lib/
├── data/
│   ├── api_client.dart           # Konfigurasi client Dio (base URL, timeout, interceptor)
│   ├── prefs.dart                # PrefsRepository: akses terpusat ke SharedPreferences
│   ├── providers.dart            # Orkestrasi Riverpod provider untuk UI
│   ├── sync.dart                 # SyncService: isolasi cache-first & antrean sinkronisasi
│   ├── local/
│   │   ├── db.dart               # SQLite Database helper (tabel notes & cached_posts)
│   │   └── note.dart             # Model Note (field dirty, toMap/fromMap aman null)
│   ├── models/
│   │   └── post.dart             # Model Post untuk data REST API
│   └── repositories/
│       ├── note_repository.dart  # CRUD catatan lokal, countDirty, markAllSynced
│       └── post_repository.dart  # Fetch postingan daring via Dio
├── pages/
│   ├── note_detail_page.dart     # Halaman detail catatan berbasis family provider
│   ├── notes_page.dart           # Daftar catatan, badge dirty dinamis, aksi sinkronisasi
│   ├── posts_page.dart           # Daftar postingan dengan strategi cache-first & offline banner
│   ├── settings_page.dart        # Pengaturan mode gelap, simulasi offline, dan riwayat buka
│   └── widgets/
│       └── note_tile.dart        # Komponen tile catatan + badge "Belum tersinkron"
├── main.dart                     # Entry point, inisialisasi preferensi waktu buka, tema gelap
└── router.dart                   # Navigasi deklaratif menggunakan GoRouter
```

---

## 📋 Checklist Verifikasi Mandiri

| No | Poin Checklist | Status | Ringkasan Verifikasi |
|---|---|:---:|---|
| 1 | UI tidak memanggil SQLite/SharedPreferences langsung; semua lewat repository + provider | ✅ **Terpenuhi** | Lapisan UI murni `ConsumerWidget`, seluruh query dan I/O diisolasi di `NoteRepository`, `PrefsRepository`, dan `SyncService`. |
| 2 | Aplikasi penuh berfungsi dalam mode pesawat: baca, tambah, hapus catatan | ✅ **Terpenuhi** | Operasi CRUD catatan berjalan 100% pada SQLite lokal (`offline_notes.db`) tanpa memerlukan koneksi jaringan. |
| 3 | Badge dirty akurat sebelum/sesudah sync; cache posts tampil tanpa internet | ✅ **Terpenuhi** | Agregasi `COUNT(*) WHERE dirty = 1` ditampilkan pada AppBar & item tile; sync mereset status secara reaktif; data post tampil instan dari cache lokal. |
| 4 | `flutter analyze` tanpa issue dan semua test lulus | ✅ **Terpenuhi** | `flutter analyze` menghasilkan 0 error/warning; 5 unit test di `flutter test` lulus 100%. |
| 5 | Hasil AI diverifikasi dan didokumentasikan pada folder `docs/` | ✅ **Terpenuhi** | Terdokumentasi lengkap pada `docs/ai_verification.md`. |

### Rincian Verifikasi Mandiri

### 1. UI Tidak Memanggil SQLite/SharedPreferences Langsung
* **Status**: ✅ **Terpenuhi**
* **Implementasi**:
  * Akses penyimpanan key-value diisolasi di [`lib/data/prefs.dart`](lib/data/prefs.dart) (`PrefsRepository`).
  * Akses database relasional SQLite diisolasi di [`lib/data/repositories/note_repository.dart`](lib/data/repositories/note_repository.dart) (`NoteRepository`).
  * Lapisan widget (`NotesPage`, `NoteDetailPage`, `PostsPage`, `SettingsPage`) hanya membaca provider (`notesProvider`, `noteByIdProvider`, `dirtyCountProvider`, `postsProvider`, `darkModeProvider`, `forceOfflineProvider`).
  * Tidak ada pemanggilan langsung ke `sqflite`, `openDatabase`, maupun `SharedPreferences.getInstance()` di dalam widget UI.

### 2. Aplikasi Berfungsi Penuh dalam Mode Pesawat (Offline)
* **Status**: ✅ **Terpenuhi**
* **Implementasi**:
  * **Tambah Catatan**: Menyimpan ke tabel SQLite lokal dengan `dirty = 1` dan stempel waktu `updated_at` saat itu.
  * **Baca Catatan**: Mengambil seluruh entri catatan dari tabel `notes` terurut `updated_at DESC`.
  * **Hapus Catatan**: Mengeksekusi query `DELETE` lokal seketika tanpa menunggu komunikasi server.
  * Modul catatan tidak memiliki ketergantungan terhadap koneksi HTTP sehingga dapat beroperasi penuh secara offline.

### 3. Badge Dirty Akurat Sebelum/Sesudah Sync & Cache Posts Offline
* **Status**: ✅ **Terpenuhi**
* **Implementasi**:
  * Sebelum sinkronisasi, catatan baru diberi flag `dirty = 1`. Provider `dirtyCountProvider` menghitung jumlah catatan kotor via query `SELECT COUNT(*) AS c FROM notes WHERE dirty = 1`.
  * Jumlah ini ditampilkan pada widget `DirtyBadge` (ikon awan dengan badge counter oranye) di AppBar serta badge `Belum tersinkron` pada masing-masing `NoteTile`.
  * Saat tombol sinkronisasi ditekan, `SyncService.syncNotes()` mensimulasikan pengunggahan, memperbarui database lokal (`UPDATE notes SET dirty = 0 WHERE dirty = 1`), lalu menginvalidasi provider Riverpod sehingga UI otomatis terupdate (badge dirty kembali menjadi 0).
  * Pada halaman Postingan, diterapkan pola **Cache-First**: data lokal dari tabel `cached_posts` langsung dikembalikan ke UI seketika di `PostsNotifier.build()`, lalu proses penyegaran jaringan dijalankan di latar belakang. Jika perangkat dalam kondisi offline (atau toggle *Simulasi offline* aktif), data cache tetap tampil lengkap dengan banner oranye: *"Mode offline — menampilkan data cache"*.

### 4. `flutter analyze` Tanpa Issue & Semua Test Lulus
* **Status**: ✅ **Terpenuhi**
* **Bukti Eksekusi**:
  * **Analisis Kode**:
    ```text
    $ flutter analyze
    Analyzing week5_offline_notes...
    No issues found! (ran in 9.8s)
    ```
  * **Automated Unit Testing**:
    ```text
    $ flutter test
    00:00 +0: fromMap aman terhadap field yang hilang
    00:00 +1: flag dirty bertahan pada serialisasi
    00:00 +2: provider sukses dengan repository palsu
    00:00 +3: provider error dengan repository palsu
    00:00 +4: Note fromMap & toMap serialization test
    00:00 +5: All tests passed!
    ```

### 5. Hasil AI Diverifikasi
* **Status**: ✅ **Terpenuhi**
* **Implementasi**: Seluruh perbaikan kode oleh AI (pemindahan folder repositori/provider, implementasi CRUD, konfigurasi dependency, serta perbaikan timeout pada Riverpod 3) telah ditinjau, diverifikasi, dan dicatat di [`docs/ai_verification.md`](docs/ai_verification.md).

---

## 💡 Refleksi

### 1. Mengapa daftar catatan tidak boleh disimpan di SharedPreferences? Apa yang rusak jika aturan ini dilanggar?
* **Tujuan Desain SharedPreferences**:
  `SharedPreferences` dirancang khusus untuk menyimpan preferensi pengguna berupa nilai primitif kecil (*key-value pairs* seperti `bool`, `int`, `double`, `string`) seperti setelan tema gelap atau stempel waktu aplikasi terakhir dibuka. Secara internal, SharedPreferences memuat seluruh berkas XML/plist ke dalam memori (RAM) saat aplikasi dimuat.
* **Kerusakan dan Masalah Jika Aturan Ini Dilanggar**:
  1. **Hilangnya Atomisitas & Kerapuhan Data (Risk of Data Corruption)**:
     Untuk memodifikasi satu baris catatan saja, seluruh daftar catatan harus di-deserialize dari JSON string, dimanipulasi di memori, di-serialize kembali, lalu ditulis ulang secara penuh ke disk. Jika terjadi force-close atau crash saat penulisan, seluruh berkas preferensi dapat rusak, mengakibatkan hilangnya semua catatan sekaligus.
  2. **I/O Bottleneck & UI Jank ($O(N)$ Overhead)**:
     Semakin banyak catatan yang disimpan, ukuran string JSON akan membengkak. Proses parsing dan serialisasi string besar pada UI thread (main isolate) akan memicu *frame drop* dan *jank* (antarmuka tersendat).
  3. **Ketiadaan Fitur Query Relasional**:
     SharedPreferences tidak mendukung operasi database seperti indexing, pengurutan dinamis (`ORDER BY updated_at DESC`), pemfilteran, agregasi hitung status (`COUNT(*) WHERE dirty = 1`), maupun paging (`LIMIT` dan `OFFSET`). Seluruh data terpaksa harus dimuat ke memori sebelum disaring secara manual oleh CPU.
  4. **Kompleksitas Sinkronisasi Per-Item**:
     Menandai perubahan status lokal (*dirty flag*) atau mengelola konflik per catatan menjadi sangat rumit karena tidak ada transaksi tingkat baris (*row-level locking/transaction*).

---

### 2. Kapan cache-first cukup, dan kapan Anda membutuhkan strategi lain (misalnya network-first untuk data harga real-time)?
* **Kapan Cache-First Cukup**:
  * Strategi **Cache-First** sangat cocok untuk data yang bersifat *read-heavy*, frekuensi pembaruannya relatif rendah (*low mutation frequency*), serta toleran terhadap data yang sedikit kedaluwarsa (*stale-while-revalidate*).
  * *Contoh*: Daftar postingan artikel/blog, feed berita, katalog produk referensi, dan konten edukasi. Keuntungan utamanya adalah *instant UI render* (antarmuka langsung terisi data tanpa menunggu loading spinner jaringan) dan dapat dibuka tanpa koneksi internet.
* **Kapan Membutuhkan Strategi Lain**:
  * **Network-First**:
    Dibutuhkan untuk data yang menuntut kebaruan mutlak (*high freshness & critical accuracy*), di mana menampilkan data usang dapat berisiko kerugian finansial atau informasi yang salah.
    * *Contoh*: Data fluktuasi harga saham/kripto real-time, ketersediaan tiket konser/kursi bioskop, sisa stok flash sale, dan saldo rekening dompet digital.
    * Pada skenario ini, aplikasi wajib mencoba mengambil data terbaru dari jaringan terlebih dahulu. Jika jaringan gagal/offline, barulah aplikasi menampilkan data cache lokal yang disertai penanda peringatan jelas (*"Menampilkan data offline per [waktu]"*).
  * **Network-Only**:
    Wajib digunakan untuk aksi transaksi sensitif yang tidak boleh menggunakan cache sama sekali, seperti proses checkout pembayaran, transfer dana perbankan, dan validasi OTP/2FA.
  * **Stale-While-Revalidate (Cache and Network)**:
    Menampilkan data cache lokal secara instan ke layar pengguna, lalu di latar belakang mengirim request ke server untuk memperbarui data lokal dan memperbarui UI secara mulus begitu respons tiba.

---

### 3. Bagaimana dirty flag berubah menjadi antrean sync tanpa memblokir UI? Kapan antrean terpisah (tabel outbox) menjadi perlu?
* **Mekanisme Dirty Flag Menjadi Antrean Non-Blocking**:
  * Setiap kali pengguna menambah atau mengedit catatan, data langsung disimpan ke database SQLite lokal dengan nilai `dirty = 1`. Operasi disk lokal ini selesai dalam fraksi milidetik, sehingga UI merespons seketika (*optimistic UI update*) tanpa memblokir interaksi pengguna.
  * Saat sinkronisasi dipicu, `SyncService.syncNotes()` membaca seluruh data kotor melalui query `SELECT * FROM notes WHERE dirty = 1` di latar belakang (*background async task*).
  * Pengguna tetap bebas menjelajah dan membuat catatan baru selama proses upload berjalan.
  * Setelah server berhasil menerima data (status HTTP 2xx), database lokal mengeksekusi `UPDATE notes SET dirty = 0 WHERE dirty = 1`, kemudian menginvalidasi state Riverpod untuk memperbarui badge secara reaktif.
* **Kapan Antrean Terpisah (Tabel Outbox) Menjadi Perlu**:
  Penggunaan sekadar kolom boolean/integer `dirty` hanya merekam **kondisi akhir (state)**, bukan **rekam jejak kejadian (event log/sequence of actions)**. Tabel *outbox* terpisah menjadi mutlak diperlukan apabila:
  1. **Membutuhkan Urutan Operasi yang Presisi (Action Chronology)**:
     Jika pengguna membuat catatan, lalu mengeditnya, kemudian menghapusnya saat offline, server harus menerima urutan event yang tepat: `INSERT` -> `UPDATE` -> `DELETE`. Kolom dirty tunggal tidak dapat membedakan apakah catatan yang dihapus perlu dikirim operasi `DELETE` ke server jika barisnya sudah terhapus di database lokal.
  2. **Manajemen Kegagalan & Retry Granular**:
     Tabel outbox memungkinkan pencatatan metadata seperti `retry_count`, `last_error`, `payload`, dan `timestamp` untuk masing-masing aksi. Jika 1 catatan gagal lolos validasi server, sinkronisasi catatan lainnya tidak terhenti.
  3. **Penyelesaian Konflik Mutakhir (Advanced Conflict Resolution)**:
     Tabel outbox dapat menyimpan salinan *snapshot* sebelum mutasi untuk memfasilitasi algoritma resolusi konflik seperti *three-way merge* atau *vector clocks*.

---

### 4. Bagian mana dari rekomendasi AI yang Anda tolak, dan mengapa?
1. **Penolakan Struktur Penempatan File `providers.dart` dan `api_client.dart`**:
   * **Rekomendasi Awal**: Awalnya file diletakkan di dalam subdirektori `lib/data/repositories/`.
   * **Alasan Penolakan**: Penempatan ini merusak hierarki modul (*Separation of Concerns*) dan menyebabkan import path relatif menjadi salah (*Target of URI doesn't exist*). Provider Riverpod bertindak sebagai orkestrator yang menjembatani repository, local storage, dan UI, sehingga tempat yang tepat adalah di `lib/data/providers.dart` dan `lib/data/api_client.dart`.
2. **Penolakan Pengujian Error Asynchronous Standar pada Riverpod 3**:
   * **Rekomendasi Awal**: Menuliskan pengujian error provider secara naif dengan `await expectLater(container.read(notesProvider.future), throwsA(...))`.
   * **Alasan Penolakan**: Pada Riverpod 3 (`flutter_riverpod: ^3.4.3`), `AsyncNotifierProvider` secara default mengaktifkan fitur *automatic exponential retry* saat terjadi kegagalan di `build()`. Hal ini menyebabkan test menggantung hingga terkena batas timeout 30 detik.
   * **Penyesuaian**: Rekomendasi diubah dengan menambahkan opsi `retry: (_, _) => null` pada `ProviderContainer` khusus unit test error:
     ```dart
     final container = ProviderContainer(
       retry: (_, _) => null, // Mematikan auto-retry agar error langsung dilempar
       overrides: [
         noteRepositoryProvider.overrideWithValue(
           FakeNoteRepository(throwError: true),
         ),
       ],
     );
     ```
     Dengan perubahan ini, pengujian error berjalan instan (< 1 detik) dan deterministik.
3. **Penolakan Penggabungan Logika Sinkronisasi ke Dalam Repository**:
   * **Rekomendasi Awal**: Seringkali AI menggabungkan pemanggilan Dio, caching SQLite, dan CRUD ke dalam satu kelas `NoteRepository`.
   * **Alasan Penolakan**: Ditolak demi mematuhi *Single Responsibility Principle* (SRP). Logika caching dan antrean sinkronisasi dipisahkan ke dalam `SyncService` ([`lib/data/sync.dart`](lib/data/sync.dart)), sehingga `NoteRepository` tetap murni menangani CRUD lokal dan mudah di-mock menggunakan `FakeNoteRepository` saat pengujian.
