import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';
import 'models/post.dart';
import 'repositories/post_repository.dart';

final dioProvider = Provider<Dio>((ref) => createDio());

final postRepositoryProvider = Provider<PostRepository>(
  (ref) => PostRepository(ref.watch(dioProvider)),
);

class PostListNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    final repository = ref.watch(postRepositoryProvider);
    return repository.fetchPosts();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(postRepositoryProvider);
      return repository.fetchPosts();
    });
  }
}

final postListProvider =
    AsyncNotifierProvider<PostListNotifier, List<Post>>(PostListNotifier.new);

Future<List<Post>> readPostsOnce(ProviderContainer container) {
  return container.read(postListProvider.future);
}

Future<Object?> readPostsErrorOnce(ProviderContainer container) async {
  final subscription = container.listen(postListProvider, (_, _) {});
  try {
    await Future<void>.delayed(Duration.zero);
    final state = container.read(postListProvider);
    return state.error;
  } finally {
    subscription.close();
  }
}

String friendlyErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi timeout, periksa jaringan Anda.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server atau tidak ada koneksi internet.';
      default:
        return error.message ?? 'Terjadi kesalahan jaringan.';
    }
  }
  return error.toString();
}
