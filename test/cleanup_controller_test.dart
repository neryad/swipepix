import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipepix/features/cleanup/application/cleanup_controller.dart';
import 'package:swipepix/features/gallery/application/gallery_controller.dart';
import 'package:swipepix/features/gallery/domain/gallery_repository.dart';
import 'package:swipepix/core/data/local_store.dart';

import 'gallery_controller_test.dart' show FakeGallery;

void main() {
  late FakeGallery repository;
  late ProviderContainer container;
  late CleanupController controller;
  final photos = [
    Photo(id: 'one', createdAt: DateTime(2026, 1, 1)),
    Photo(id: 'two', createdAt: DateTime(2026, 1, 2)),
    Photo(id: 'three', createdAt: DateTime(2026, 1, 3)),
  ];

  setUp(() {
    repository = FakeGallery();
    container = ProviderContainer(
      overrides: [galleryRepositoryProvider.overrideWithValue(repository)],
    );
    controller = container.read(cleanupProvider.notifier);
    controller.start(photos);
  });

  tearDown(() => container.dispose());

  test('mark and keep advance without deleting', () {
    controller.markForDeletion();
    controller.keep();

    final state = container.read(cleanupProvider);
    expect(state.index, 2);
    expect(state.pendingDeletion, {'one'});
    expect(repository.deleteCalls, 0);
  });

  test('undo restores the previous card and pending selection', () {
    controller.markForDeletion();
    controller.undo();

    final state = container.read(cleanupProvider);
    expect(state.current?.id, 'one');
    expect(state.pendingDeletion, isEmpty);
    expect(state.history, isEmpty);
  });

  test('unmark keeps a photo out of deletion request', () async {
    controller.markForDeletion();
    controller.markForDeletion();
    controller.unmark('one');

    final result = await controller.deletePending();

    expect(result.deleted, ['two']);
    expect(repository.deleteCalls, 1);
    expect(container.read(cleanupProvider).pendingDeletion, isEmpty);
  });

  test('partial deletion preserves photos that were not deleted', () async {
    repository.deleteResult = ['one'];
    controller.markForDeletion();
    controller.markForDeletion();

    final result = await controller.deletePending();

    expect(result.deleted, ['one']);
    expect(result.remaining, ['two']);
    expect(container.read(cleanupProvider).pendingDeletion, {'two'});
    expect(container.read(cleanupProvider).deleteFailed, isTrue);
  });

  test(
    'deleting during a session preserves the next unreviewed photo',
    () async {
      controller.markForDeletion();

      await controller.deletePending();

      final state = container.read(cleanupProvider);
      expect(state.current?.id, 'two');
      expect(state.index, 0);
      expect(state.photos.map((photo) => photo.id), ['two', 'three']);
    },
  );

  test('revoked access blocks deletion and preserves selection', () async {
    repository.permission = GalleryAccess.denied;
    controller.markForDeletion();

    final result = await controller.deletePending();

    expect(repository.deleteCalls, 0);
    expect(result.remaining, ['one']);
    expect(container.read(cleanupProvider).pendingDeletion, {'one'});
  });

  test('plugin failure preserves all selected photos', () async {
    repository.fail = true;
    controller.markForDeletion();

    final result = await controller.deletePending();

    expect(result.deleted, isEmpty);
    expect(result.remaining, ['one']);
    expect(container.read(cleanupProvider).pendingDeletion, {'one'});
  });

  test('next batch loads new photos without repeating reviewed ones', () async {
    repository.fetch = (page) async => page == 0
        ? List.generate(
            GalleryController.pageSize,
            (index) => Photo(id: '$index', createdAt: DateTime(2026)),
          )
        : [
            Photo(id: '59', createdAt: DateTime(2026)),
            Photo(id: '60', createdAt: DateTime(2026)),
          ];
    await container.read(galleryProvider.notifier).refresh();
    controller.start(container.read(galleryProvider).photos);
    for (var index = 0; index < GalleryController.pageSize; index++) {
      controller.keep();
    }

    final added = await controller.loadNextBatch();
    final state = container.read(cleanupProvider);

    expect(added, 1);
    expect(repository.reads, 2);
    expect(state.current?.id, '60');
    expect(state.photos.map((photo) => photo.id).toSet(), hasLength(61));
    expect(state.loadingNextBatch, isFalse);
  });

  test('next batch first uses already loaded unseen photos', () async {
    repository.fetch = (_) async => [
      Photo(id: 'one', createdAt: DateTime(2026)),
      Photo(id: 'two', createdAt: DateTime(2026)),
    ];
    await container.read(galleryProvider.notifier).refresh();
    controller.start([Photo(id: 'one', createdAt: DateTime(2026))]);
    controller.keep();

    final added = await controller.loadNextBatch();

    expect(added, 1);
    expect(repository.reads, 1);
    expect(container.read(cleanupProvider).current?.id, 'two');
  });

  test('session survives a new provider container', () async {
    final store = MemoryLocalStore();
    final first = ProviderContainer(
      overrides: [
        localStoreProvider.overrideWithValue(store),
        galleryRepositoryProvider.overrideWithValue(repository),
      ],
    );
    final firstController = first.read(cleanupProvider.notifier);
    firstController.start(photos);
    firstController.markForDeletion();
    await firstController.flushPersistence();
    first.dispose();

    final second = ProviderContainer(
      overrides: [
        localStoreProvider.overrideWithValue(store),
        galleryRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(second.dispose);
    final restored = second.read(cleanupProvider);

    expect(restored.index, 1);
    expect(restored.current?.id, 'two');
    expect(restored.pendingDeletion, {'one'});
  });

  test('restore discards inaccessible photos and adjusts progress', () async {
    final store = MemoryLocalStore();
    final first = ProviderContainer(
      overrides: [
        localStoreProvider.overrideWithValue(store),
        galleryRepositoryProvider.overrideWithValue(repository),
      ],
    );
    final firstController = first.read(cleanupProvider.notifier);
    firstController.start(photos);
    firstController.markForDeletion();
    firstController.keep();
    await firstController.flushPersistence();
    first.dispose();
    repository.unavailableIds.add('one');

    final second = ProviderContainer(
      overrides: [
        localStoreProvider.overrideWithValue(store),
        galleryRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(second.dispose);
    final didRestore = await second.read(cleanupProvider.notifier).restore();
    final restored = second.read(cleanupProvider);

    expect(didRestore, isTrue);
    expect(restored.photos.map((photo) => photo.id), ['two', 'three']);
    expect(restored.index, 1);
    expect(restored.current?.id, 'three');
    expect(restored.pendingDeletion, isEmpty);
  });

  test('corrupted saved session is ignored safely', () async {
    final store = MemoryLocalStore();
    await store.setString(LocalStoreKeys.cleanupSession, '{not valid json');
    final restoredContainer = ProviderContainer(
      overrides: [
        localStoreProvider.overrideWithValue(store),
        galleryRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(restoredContainer.dispose);

    expect(restoredContainer.read(cleanupProvider).hasSession, isFalse);
  });
}
