import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipepix/features/gallery/application/gallery_controller.dart';
import 'package:swipepix/features/gallery/domain/gallery_repository.dart';

class FakeGallery implements GalleryRepository {
  GalleryAccess permission = GalleryAccess.authorized;
  int reads = 0;
  int requests = 0;
  bool fail = false;
  List<String>? deleteResult;
  int deleteCalls = 0;
  final List<GallerySort> requestedSorts = [];
  final Set<String> unavailableIds = {};
  List<GalleryAlbum> fakeAlbums = const [];
  Future<List<Photo>> Function(String, int)? fetchAlbum;
  Future<List<Photo>> Function(int)? fetch;
  @override
  Future<GalleryAccess> access({bool request = false}) async {
    if (request) requests++;
    return permission;
  }

  @override
  Future<int?> photoCount() async => 1;

  @override
  Future<List<GalleryAlbum>> albums({int? limit}) async => limit == null
      ? fakeAlbums
      : fakeAlbums.take(limit).toList(growable: false);

  @override
  Future<GalleryAlbum?> album(String id) async =>
      fakeAlbums.where((album) => album.id == id).firstOrNull;

  @override
  Future<List<Photo>> page(
    int page,
    int size, {
    GallerySort sort = GallerySort.newest,
  }) async {
    reads++;
    requestedSorts.add(sort);
    if (fail) throw StateError('Unavailable');
    return fetch != null
        ? await fetch!(page)
        : [Photo(id: 'one', createdAt: DateTime(2026))];
  }

  @override
  Future<List<Photo>> albumPage(
    String albumId,
    int page,
    int size, {
    GallerySort sort = GallerySort.newest,
  }) async {
    requestedSorts.add(sort);
    if (fail) throw StateError('Unavailable');
    return fetchAlbum != null
        ? await fetchAlbum!(albumId, page)
        : [Photo(id: '$albumId-one', createdAt: DateTime(2026))];
  }

  @override
  Future<Uint8List?> thumbnail(String id) async => null;
  @override
  Future<Uint8List?> preview(String id) async => null;
  @override
  Future<List<Photo>> resolvePhotos(Iterable<String> ids) async => ids
      .where((id) => !unavailableIds.contains(id))
      .map((id) => Photo(id: id, createdAt: DateTime(2026)))
      .toList(growable: false);
  @override
  Future<List<String>> deletePhotos(List<String> ids) async {
    deleteCalls++;
    if (fail) throw StateError('Unavailable');
    return deleteResult ?? ids;
  }

  @override
  Future<void> manageLimited() async {}
  @override
  Future<void> openSettings() async {}
}

void main() {
  late FakeGallery repo;
  late ProviderContainer container;
  late GalleryController controller;
  setUp(() {
    repo = FakeGallery();
    container = ProviderContainer(
      overrides: [galleryRepositoryProvider.overrideWithValue(repo)],
    );
    controller = container.read(galleryProvider.notifier);
  });
  tearDown(() => container.dispose());
  for (final permission in [
    GalleryAccess.denied,
    GalleryAccess.restricted,
    GalleryAccess.notDetermined,
    GalleryAccess.unsupported,
  ]) {
    test('$permission never queries photos', () async {
      repo.permission = permission;
      await controller.refresh();
      expect(repo.reads, 0);
      expect(container.read(galleryProvider).access, permission);
      expect(repo.requests, 0);
    });
  }
  test(
    'limited access loads selected photos and requests only explicitly',
    () async {
      repo.permission = GalleryAccess.limited;
      await controller.refresh(request: true);
      expect(repo.requests, 1);
      expect(container.read(galleryProvider).photos.single.id, 'one');
    },
  );
  test('revocation clears previously visible photos', () async {
    await controller.refresh();
    repo.permission = GalleryAccess.denied;
    await controller.refresh();
    expect(container.read(galleryProvider).photos, isEmpty);
    expect(repo.reads, 1);
  });
  test('failed page can be retried', () async {
    repo.fail = true;
    await controller.refresh();
    expect(container.read(galleryProvider).failed, isTrue);
    repo.fail = false;
    await controller.refresh();
    expect(container.read(galleryProvider).failed, isFalse);
    expect(container.read(galleryProvider).photos, hasLength(1));
  });
  test('pagination deduplicates and stops at last page', () async {
    repo.fetch = (page) async => page == 0
        ? List.generate(60, (i) => Photo(id: '$i', createdAt: DateTime(2026)))
        : [
            Photo(id: '59', createdAt: DateTime(2026)),
            Photo(id: '60', createdAt: DateTime(2026)),
          ];
    await controller.refresh();
    expect(container.read(galleryProvider).hasMore, isTrue);
    await controller.loadMore();
    expect(container.read(galleryProvider).photos, hasLength(61));
    expect(container.read(galleryProvider).hasMore, isFalse);
    await controller.loadMore();
    expect(repo.reads, 2);
  });
  test('pagination keeps existing photos visible while loading', () async {
    final nextPage = Completer<List<Photo>>();
    repo.fetch = (page) async => page == 0
        ? List.generate(
            GalleryController.pageSize,
            (i) => Photo(id: '$i', createdAt: DateTime(2026)),
          )
        : nextPage.future;
    await controller.refresh();

    final loading = controller.loadMore();
    await Future<void>.delayed(Duration.zero);

    final pending = container.read(galleryProvider);
    expect(pending.busy, isFalse);
    expect(pending.loadingMore, isTrue);
    expect(pending.photos, hasLength(GalleryController.pageSize));

    nextPage.complete([]);
    await loading;
    expect(container.read(galleryProvider).loadingMore, isFalse);
  });
  test(
    'changing sort reloads the first page with the selected order',
    () async {
      await controller.refresh();

      await controller.selectSort(GallerySort.oldest);

      expect(repo.requestedSorts, [GallerySort.newest, GallerySort.oldest]);
      expect(container.read(galleryProvider).sort, GallerySort.oldest);
      expect(repo.reads, 2);
    },
  );
  test('largest sorting uses size then newest date and puts unknown last', () {
    final sorted = sortPhotosLargestFirst([
      Photo(id: 'unknown', createdAt: DateTime(2026, 1, 5)),
      Photo(id: 'small', createdAt: DateTime(2026, 1, 4), sizeBytes: 5),
      Photo(id: 'large-old', createdAt: DateTime(2026, 1, 1), sizeBytes: 10),
      Photo(id: 'large-new', createdAt: DateTime(2026, 1, 2), sizeBytes: 10),
    ]);

    expect(sorted.map((photo) => photo.id), [
      'large-new',
      'large-old',
      'small',
      'unknown',
    ]);
  });
  test(
    'old request cannot restore photos after permission revocation',
    () async {
      final pending = Completer<List<Photo>>();
      repo.fetch = (_) => pending.future;
      final old = controller.refresh();
      await Future<void>.delayed(Duration.zero);
      repo.permission = GalleryAccess.denied;
      await controller.refresh();
      pending.complete([Photo(id: 'stale', createdAt: DateTime(2026))]);
      await old;
      expect(container.read(galleryProvider).access, GalleryAccess.denied);
      expect(container.read(galleryProvider).photos, isEmpty);
    },
  );
  test(
    'permission revoked before pagination does not query next page',
    () async {
      repo.fetch = (_) async =>
          List.generate(60, (i) => Photo(id: '$i', createdAt: DateTime(2026)));
      await controller.refresh();
      repo.permission = GalleryAccess.denied;
      await controller.loadMore();
      expect(repo.reads, 1);
      expect(container.read(galleryProvider).photos, isEmpty);
    },
  );
}
