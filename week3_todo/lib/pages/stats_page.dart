import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/stats_provider.dart';

/// [StatsPage] adalah tampilan (UI) statistik yang menggunakan [ConsumerWidget].
/// [ConsumerWidget] menyediakan parameter [WidgetRef] pada method build,
/// yang memungkinkan widget untuk berinteraksi dan mengamati (watch) Provider Riverpod.
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. ref.watch(statsProvider) digunakan untuk mengamati nilai state dari statsProvider secara reaktif.
    // Jika state berubah (Loading -> Data / Error), widget build akan dijalankan ulang secara otomatis.
    final statsAsyncValue = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik Aktivitas'),
        actions: [
          // Tombol refresh di AppBar untuk memudahkan pengguna me-refresh data kapan saja.
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Statistik',
            onPressed: () {
              // Memanggil method retry pada StatsNotifier untuk memicu ulang pengambilan data.
              ref.read(statsProvider.notifier).retry();
            },
          ),
        ],
      ),
      // 2. statsAsyncValue.when() adalah pattern matching khas Riverpod untuk menangani 3 state asynchronous:
      // - loading: Saat data sedang dalam proses pengambilan (delay 2 detik).
      // - error: Saat terjadi kesalahan (simulasi 30% error).
      // - data: Saat data berhasil didapatkan (menampilkan 3 item statistik).
      body: statsAsyncValue.when(
        // === STATE 1: LOADING ===
        // Menampilkan spinner indikator loading dan teks informasi.
        loading: () => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Mengambil data statistik...',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),

        // === STATE 2: ERROR ===
        // Menampilkan pesan kegagalan dan tombol retry untuk mencoba lagi.
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ikon peringatan error dengan warna merah/error
                Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Terjadi Kesalahan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Menampilkan detail pesan error yang diterima dari provider
                Text(
                  error.toString().replaceAll('Exception: ', ''),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                // Tombol "Coba Lagi" (Retry) yang memicu retry() pada notifier
                FilledButton.icon(
                  onPressed: () {
                    // Memicu refresh/retry pada notifier
                    ref.read(statsProvider.notifier).retry();
                  },
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),

        // === STATE 3: SUCCESS (DATA) ===
        // Menampilkan ListView berisi tepat 3 item statistik menggunakan ListTile & Card
        data: (statsList) => RefreshIndicator(
          // RefreshIndicator memungkinkan gesture pull-to-refresh
          onRefresh: () async {
            await ref.read(statsProvider.notifier).retry();
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: statsList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = statsList[index];

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 16.0,
                  ),
                  child: Row(
                    children: [
                      // Ikon indikator statistik
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          item.icon,
                          size: 28,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Teks Judul dan Deskripsi
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.description,
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Nilai statistik utama (misal: "28", "20", "71.4%")
                      Text(
                        item.value,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
