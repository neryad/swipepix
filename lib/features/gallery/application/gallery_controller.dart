import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/local_store.dart';
import '../data/device_gallery_repository.dart';
import '../domain/gallery_repository.dart';

final galleryRepositoryProvider = Provider<GalleryRepository>(
  (ref) => DeviceGalleryRepository(),
);
final thumbnailProvider = FutureProvider.autoDispose.family<Uint8List?, String>(
  (ref, id) => ref.watch(galleryRepositoryProvider).thumbnail(id),
);
final photoPreviewProvider = FutureProvider.autoDispose
    .family<Uint8List?, String>(
      (ref, id) => ref.watch(galleryRepositoryProvider).preview(id),
    );
final galleryAlbumsProvider = FutureProvider.autoDispose<List<GalleryAlbum>>((
  ref,
) async {
  final repository = ref.watch(galleryRepositoryProvider);
  final access = await repository.access();
  if (!access.canRead) return const [];
  return repository.albums();
});
final galleryAlbumProvider = FutureProvider.autoDispose
    .family<GalleryAlbum?, String>((ref, id) async {
      final repository = ref.watch(galleryRepositoryProvider);
      final access = await repository.access();
      if (!access.canRead) return null;
      return repository.album(id);
    });
final galleryAlbumPhotosProvider = FutureProvider.autoDispose
    .family<List<Photo>, String>((ref, id) async {
      final repository = ref.watch(galleryRepositoryProvider);
      final access = await repository.access();
      if (!access.canRead) return const [];
      return repository.albumPage(id, 0, GalleryController.pageSize);
    });
final galleryProvider = NotifierProvider<GalleryController, GalleryState>(
  GalleryController.new,
);

class GalleryState {
  GalleryState({
    this.access = GalleryAccess.notDetermined,
    List<Photo> photos = const [],
    this.busy = false,
    this.loadingMore = false,
    this.failed = false,
    this.hasMore = false,
    this.sort = GallerySort.newest,
    this.totalPhotoCount,
  }) : photos = List.unmodifiable(photos);
  final GalleryAccess access;
  final List<Photo> photos;
  final bool busy, loadingMore, failed, hasMore;
  final GallerySort sort;
  final int? totalPhotoCount;
}

class GalleryController extends Notifier<GalleryState> {
  static const pageSize = 60;
  int _page = 0;
  int _generation = 0;
  @override
  GalleryState build() {
    final savedSort = ref
        .read(localStoreProvider)
        .getString(LocalStoreKeys.gallerySort);
    final sort = GallerySort.values
        .where((value) => value.name == savedSort)
        .firstOrNull;
    return GalleryState(sort: sort ?? GallerySort.newest);
  }

  GalleryRepository get _repository => ref.read(galleryRepositoryProvider);
  Future<void> refresh({bool request = false}) async {
    final generation = ++_generation;
    // Clear stale thumbnails when access or the selected photo set changes.
    ref.invalidate(thumbnailProvider);
    ref.invalidate(galleryAlbumsProvider);
    state = GalleryState(
      access: state.access,
      busy: true,
      sort: state.sort,
      totalPhotoCount: state.totalPhotoCount,
    );
    try {
      final access = await _repository.access(request: request);
      final (photos, totalPhotoCount) = access.canRead
          ? await (
              _repository.page(0, pageSize, sort: state.sort),
              _repository.photoCount(),
            ).wait
          : (<Photo>[], null);
      if (!ref.mounted || generation != _generation) return;
      _page = 0;
      state = GalleryState(
        access: access,
        photos: photos,
        hasMore: photos.length == pageSize,
        sort: state.sort,
        totalPhotoCount: totalPhotoCount,
      );
    } catch (_) {
      if (ref.mounted && generation == _generation) {
        state = GalleryState(
          access: state.access,
          failed: true,
          sort: state.sort,
          totalPhotoCount: state.totalPhotoCount,
        );
      }
    }
  }

  Future<void> loadMore() async {
    if (state.busy ||
        state.loadingMore ||
        !state.hasMore ||
        !state.access.canRead) {
      return;
    }
    final before = state;
    final generation = _generation;
    state = GalleryState(
      access: before.access,
      photos: before.photos,
      hasMore: true,
      loadingMore: true,
      sort: before.sort,
      totalPhotoCount: before.totalPhotoCount,
    );
    try {
      final access = await _repository.access();
      if (!ref.mounted || generation != _generation) return;
      if (access != before.access || !access.canRead) {
        await refresh();
        return;
      }
      final photos = await _repository.page(
        _page + 1,
        pageSize,
        sort: before.sort,
      );
      if (!ref.mounted || generation != _generation) return;
      _page++;
      final byId = {
        for (final p in [...before.photos, ...photos]) p.id: p,
      };
      state = GalleryState(
        access: access,
        photos: byId.values.toList(),
        hasMore: photos.length == pageSize,
        sort: before.sort,
        totalPhotoCount: before.totalPhotoCount,
      );
    } catch (_) {
      if (ref.mounted && generation == _generation) {
        state = GalleryState(
          access: before.access,
          photos: before.photos,
          hasMore: true,
          failed: true,
          sort: before.sort,
          totalPhotoCount: before.totalPhotoCount,
        );
      }
    }
  }

  Future<void> manageLimited() async {
    if (state.busy || state.access != GalleryAccess.limited) return;
    try {
      await _repository.manageLimited();
      await refresh();
    } catch (_) {
      if (ref.mounted) {
        state = GalleryState(
          access: state.access,
          photos: state.photos,
          failed: true,
          sort: state.sort,
          totalPhotoCount: state.totalPhotoCount,
        );
      }
    }
  }

  Future<void> openSettings() async {
    try {
      await _repository.openSettings();
    } catch (_) {
      if (ref.mounted) {
        state = GalleryState(
          access: state.access,
          photos: state.photos,
          failed: true,
          sort: state.sort,
        );
      }
    }
  }

  void removeDeleted(Iterable<String> ids) {
    final deleted = ids.toSet();
    if (deleted.isEmpty) return;
    for (final id in deleted) {
      ref.invalidate(thumbnailProvider(id));
      ref.invalidate(photoPreviewProvider(id));
    }
    state = GalleryState(
      access: state.access,
      photos: state.photos
          .where((photo) => !deleted.contains(photo.id))
          .toList(),
      busy: state.busy,
      loadingMore: state.loadingMore,
      failed: state.failed,
      hasMore: state.hasMore,
      sort: state.sort,
      totalPhotoCount: state.totalPhotoCount == null
          ? null
          : (state.totalPhotoCount! - deleted.length).clamp(0, 1 << 31),
    );
  }

  Future<void> selectSort(GallerySort sort) async {
    if (state.busy || state.loadingMore || state.sort == sort) return;
    state = GalleryState(
      access: state.access,
      photos: state.photos,
      hasMore: state.hasMore,
      sort: sort,
      totalPhotoCount: state.totalPhotoCount,
    );
    unawaited(
      ref
          .read(localStoreProvider)
          .setString(LocalStoreKeys.gallerySort, sort.name)
          .catchError((_) {}),
    );
    await refresh();
  }
}
