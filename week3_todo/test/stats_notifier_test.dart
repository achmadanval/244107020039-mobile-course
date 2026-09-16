import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_todo/providers/stats_provider.dart';

/// Fake/Mock Random class untuk mengontrol hasil `nextDouble()` secara deterministik dalam unit test.
class FakeRandom implements Random {
  final double nextDoubleValue;

  FakeRandom(this.nextDoubleValue);

  @override
  double nextDouble() => nextDoubleValue;

  @override
  bool nextBool() => false;

  @override
  int nextInt(int max) => 0;
}

void main() {
  group('StatsNotifier Unit Tests', () {
    test('1. State awal provider harus bernilai AsyncLoading', () {
      // ProviderContainer digunakan untuk menguji Riverpod providers di luar widget tree.
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Membaca state awal provider sebelum delay asynchronous selesai.
      final initialData = container.read(statsProvider);

      // Verifikasi bahwa state awal adalah AsyncLoading (atau isLoading == true).
      expect(initialData, isA<AsyncLoading<List<StatItem>>>());
      expect(initialData.isLoading, isTrue);
    });

    test('2. Berhasil mengembalikan tepat 3 item statistik saat tidak terjadi error (AsyncData)', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Mengambil instance notifier untuk mengatur kondisi pengujian:
      // - Mengatur delay menjadi 0 milidetik agar pengujian berjalan cepat.
      // - Mengatur random generator menghasilkan 0.5 (>= 0.3 artinya BERHASIL / tidak error).
      final notifier = container.read(statsProvider.notifier);
      notifier.delayDuration = Duration.zero;
      notifier.randomGenerator = FakeRandom(0.5);

      // Memicu retry agar mengambil data baru dengan konfigurasi di atas.
      await notifier.retry();

      // Membaca state akhir setelah Future selesai.
      final state = container.read(statsProvider);

      // Verifikasi state adalah AsyncData
      expect(state, isA<AsyncData<List<StatItem>>>());
      expect(state.hasValue, isTrue);

      final items = state.value!;
      // Memastikan jumlah item yang dikembalikan adalah tepat 3 item
      expect(items.length, equals(3));
      expect(items[0].title, equals('Total Tugas'));
      expect(items[0].value, equals('28'));
      expect(items[1].title, equals('Tugas Selesai'));
      expect(items[1].value, equals('20'));
      expect(items[2].title, equals('Tingkat Efisiensi'));
      expect(items[2].value, equals('71.4%'));
    });

    test('3. Menghasilkan AsyncError saat simulasi kegagalan 30% terjadi', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(statsProvider.notifier);
      notifier.delayDuration = Duration.zero;
      // Mengatur random generator menghasilkan 0.1 (< 0.3 artinya GAGAL / memicu error 30%).
      notifier.randomGenerator = FakeRandom(0.1);

      // Menjalankan retry untuk memproses simulasi error.
      await notifier.retry();

      // Membaca state hasil simulasi kegagalan.
      final state = container.read(statsProvider);

      // Verifikasi state adalah AsyncError
      expect(state, isA<AsyncError<List<StatItem>>>());
      expect(state.hasError, isTrue);
      expect(
        state.error.toString(),
        contains('Gagal memuat data statistik dari server (Simulasi error 30%).'),
      );
    });

    test('4. Fitur retry() berhasil memulihkan state dari AsyncError menjadi AsyncData', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(statsProvider.notifier);
      notifier.delayDuration = Duration.zero;

      // Langkah A: Simulasikan kondisi error terlebih dahulu (random = 0.2 < 0.3).
      notifier.randomGenerator = FakeRandom(0.2);
      await notifier.retry();

      expect(container.read(statsProvider), isA<AsyncError<List<StatItem>>>());

      // Langkah B: Pengguna menekan tombol "Coba Lagi" (Retry) saat koneksi berhasil (random = 0.9 >= 0.3).
      notifier.randomGenerator = FakeRandom(0.9);
      await notifier.retry();

      // Verifikasi state berhasil pulih menjadi AsyncData dengan 3 item.
      final recoveredState = container.read(statsProvider);
      expect(recoveredState, isA<AsyncData<List<StatItem>>>());
      expect(recoveredState.value?.length, equals(3));
    });
  });
}
