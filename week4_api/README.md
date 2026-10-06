# week4_api

Achmad Anval Adhiem Allain 
244107020039
TI-3E

## AI Verification Checklist
Sebelum kode AI diterima, verifikasi hal berikut dan catat temuan Anda di README:

- Apakah UI memanggil Dio secara langsung (dilarang) atau lewat repository?
    Tidak, UI tidak memanggil Dio secara langsung

- Apakah fromJson aman null, atau masih memakai cast langsung yang bisa crash?
    aman null, menggunakan cast yang aman 

- Apakah semua tipe DioExceptionType (timeout, connectionError, badResponse) dipetakan ke pesan pengguna?
    Ya, semua tipe DioExceptionType dipetakan ke pesan pengguna

- Apakah baseUrl/timeout terpusat di satu client, bukan tersebar di tiap method?
    Ya, baseUrl/timeout terpusat di satu client, bukan tersebar di tiap method

- Apakah test AI benar-benar menguji kasus field hilang, atau hanya happy path? Tambahkan minimal 1 edge case sendiri.
    Ya, test AI menguji kasus field hilang, dan saya menambahkan minimal 1 edge case sendiri

- Jalankan flutter analyze dan flutter test, apakah hasil AI lolos tanpa warning?
    Ya, flutter analyze (0 issues) dan flutter test (semua 5 test lolos tanpa warning/error)

### Melakukan Refactoring 

ketika melakukan refactoring, saya menemukan bahwa ada beberapa perubahan yang perlu dilakukan agar kode lebih efisien dan mudah dipelihara. Berikut adalah beberapa perubahan yang saya lakukan:

1. Memisahkan logika repository dari provider
2. Menggunakan asyncNotifierProvider untuk state management
3. Menambahkan test untuk memastikan kode berfungsi dengan benar


### Refleksi

1. Mengapa UI dilarang memanggil Dio langsung? Apa yang rusak jika aturan ini dilanggar?
    UI dilarang memanggil Dio langsung agar kode lebih bersih dan mudah dipelihara. Jika UI memanggil Dio langsung, maka kode akan menjadi lebih rumit dan sulit untuk di-maintain.
2. Kapan pagination client-side cukup, dan kapan harus mengandalkan pagination server (_page/_limit)?
    Pagination client-side cukup ketika data yang ditampilkan sedikit dan tidak memerlukan banyak resource. Namun, ketika data yang ditampilkan banyak, maka harus mengandalkan pagination server (_page/_limit).
3. Bagaimana exception repository berubah menjadi AsyncError tanpa try/catch di setiap widget? Kapan try/catch eksplisit tetap dibutuhkan?
    Exception repository berubah menjadi AsyncError tanpa try/catch di setiap widget karena menggunakan AsyncNotifier yang dapat menangani exception secara otomatis. Try/catch eksplisit tetap dibutuhkan ketika ingin menangani exception secara khusus.
4. Bagian mana dari hasil AI yang Anda perbaiki, dan mengapa?
    Bagian dari hasil AI yang saya perbaiki adalah bagian exception handling. Saya menambahkan try/catch untuk menangani exception agar kode lebih robust dan tidak crash ketika terjadi error.