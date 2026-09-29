# week4_api

Achmad Anval Adhiem Allain 
244107020039
TI-3E

## AI Verification Checklist
Sebelum kode AI diterima, verifikasi hal berikut dan catat temuan Anda di README:

- Apakah UI memanggil Dio secara langsung (dilarang) atau lewat repository?
    => Jawaban : Tidak, UI tidak memanggil Dio secara langsung

- Apakah fromJson aman null, atau masih memakai cast langsung yang bisa crash?
    => Jawaban : aman null, menggunakan cast yang aman 

- Apakah semua tipe DioExceptionType (timeout, connectionError, badResponse) dipetakan ke pesan pengguna?
    => Jawaban : Ya, semua tipe DioExceptionType dipetakan ke pesan pengguna

- Apakah baseUrl/timeout terpusat di satu client, bukan tersebar di tiap method?
    => Jawaban : Ya, baseUrl/timeout terpusat di satu client, bukan tersebar di tiap method

- Apakah test AI benar-benar menguji kasus field hilang, atau hanya happy path? Tambahkan minimal 1 edge case sendiri.
    => Jawaban : Ya, test AI menguji kasus field hilang, dan saya menambahkan minimal 1 edge case sendiri

- Jalankan flutter analyze dan flutter test, apakah hasil AI lolos tanpa warning?
    => Jawaban : Ya, flutter analyze (0 issues) dan flutter test (semua 5 test lolos tanpa warning/error)

### Melakukan Refactoring 

ketika melakukan refactoring, saya menemukan bahwa ada beberapa perubahan yang perlu dilakukan agar kode lebih efisien dan mudah dipelihara. Berikut adalah beberapa perubahan yang saya lakukan:

1. Memisahkan logika repository dari provider
2. Menggunakan asyncNotifierProvider untuk state management
3. Menambahkan test untuk memastikan kode berfungsi dengan benar
