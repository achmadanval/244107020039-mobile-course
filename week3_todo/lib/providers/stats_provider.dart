import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Model data untuk merepresentasikan satu item statistik.
/// Berisi judul, nilai statistik, ikon, dan deskripsi singkat.
class StatItem {
  final String title;
  final String value;
  final IconData icon;
  final String description;

  const StatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.description,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatItem &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          value == other.value &&
          icon == other.icon &&
          description == other.description;

  @override
  int get hashCode => Object.hash(title, value, icon, description);
}

/// [StatsNotifier] adalah State Notifier berbasis AsyncNotifier dari Riverpod.
/// Bertugas mengelola asynchronous state (loading, error, success) untuk data statistik.
class StatsNotifier extends AsyncNotifier<List<StatItem>> {
  // Objek Random untuk menghasilkan angka acak dalam simulasi kegagalan.
  Random _random = Random();

  // Durasi delay simulasi jaringan (default: 2 detik).
  Duration delayDuration = const Duration(seconds: 2);

  // Getter & setter custom untuk mempermudah mocking / pengujian unit test yang deterministik.
  @visibleForTesting
  set randomGenerator(Random customRandom) => _random = customRandom;

  /// Method [build] dipanggil otomatis saat provider pertama kali diinisialisasi atau di-invalidate.
  /// Method ini mengembalikan Future berisi list data statistik.
  @override
  Future<List<StatItem>> build() async {
    // Memulai proses pengambilan data statistik saat inisialisasi awal.
    return _fetchStats();
  }

  /// Method internal untuk mensimulasikan pengambilan data statistik dari server/API.
  /// Memiliki delay 2 detik dan kemungkinan gagal sebesar 30%.
  Future<List<StatItem>> _fetchStats() async {
    // 1. Simulasi delay jaringan selama 2 detik sesuai requirements.
    await Future.delayed(delayDuration);

    // 2. Simulasi kemungkinan error 30%:
    // nextDouble() menghasilkan nilai antara 0.0 sampai 1.0. Jika < 0.3 (30%), lemparkan exception.
    if (_random.nextDouble() < 0.3) {
      throw Exception('Gagal memuat data statistik dari server (Simulasi error 30%).');
    }

    // 3. Mengembalikan tepat 3 item data statistik jika berhasil.
    return const [
      StatItem(
        title: 'Total Tugas',
        value: '28',
        icon: Icons.assignment_outlined,
        description: 'Semua tugas yang telah didaftarkan',
      ),
      StatItem(
        title: 'Tugas Selesai',
        value: '20',
        icon: Icons.task_alt_outlined,
        description: 'Tugas yang telah berhasil diselesaikan',
      ),
      StatItem(
        title: 'Tingkat Efisiensi',
        value: '71.4%',
        icon: Icons.trending_up_outlined,
        description: 'Persentase keberhasilan penyelesaian tugas',
      ),
    ];
  }

  /// Method [retry] digunakan oleh UI untuk memicu pengambilan data ulang ketika terjadi error.
  Future<void> retry() async {
    // Ubah state menjadi AsyncLoading agar UI menampilkan spinner loading kembali.
    state = const AsyncLoading();

    // AsyncValue.guard secara otomatis menangkap exception dan mengubah state menjadi AsyncError jika gagal,
    // atau AsyncData jika berhasil.
    state = await AsyncValue.guard(() => _fetchStats());
  }
}

/// [statsProvider] adalah AsyncNotifierProvider global yang digunakan oleh widget untuk
/// membaca dan mengamati perubahan state dari [StatsNotifier].
final statsProvider = AsyncNotifierProvider<StatsNotifier, List<StatItem>>(
  StatsNotifier.new,
);
