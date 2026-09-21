import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/local_store.dart';
import '../../gallery/application/gallery_controller.dart';
import '../../gallery/domain/gallery_repository.dart';

enum CleanupDecision { keep, markForDeletion }

class CleanupAction {
  const CleanupAction({required this.photoId, required this.decision});

  final String photoId;
  final CleanupDecision decision;
}

class DeleteOutcome {
  DeleteOutcome({
    required List<String> deleted,
    required List<String> remaining,
  }) : deleted = List.unmodifiable(deleted),
       remaining = List.unmodifiable(remaining);

  final List<String> deleted;
  final List<String> remaining;
}

enum CleanupSourceType { library, album }

class CleanupSource {
  const CleanupSource.library({this.sort = GallerySort.newest})
    : type = CleanupSourceType.library,
      albumId = null,
      albumName = null;

  const CleanupSource.album({
    required this.albumId,
    required this.albumName,
    this.sort = GallerySort.newest,
  }) : type = CleanupSourceType.album;

  final CleanupSourceType type;
  final String? albumId;
  final String? albumName;
  final GallerySort sort;
}

class CleanupState {
  CleanupState({
    List<Photo> photos = const [],
    this.index = 0,
    Set<String> pendingDeletion = const {},
    List<CleanupAction> history = const [],
    this.deleting = false,
    this.deleteFailed = false,
    this.restoring = false,
    this.restoreFailed = false,
    this.loadingNextBatch = false,
    this.source = const CleanupSource.library(),
  }) : photos = List.unmodifiable(photos),
       pendingDeletion = Set.unmodifiable(pendingDeletion),
       history = List.unmodifiable(history);

  final List<Photo> photos;
  final int index;
  final Set<String> pendingDeletion;
  final List<CleanupAction> history;
  final bool deleting;
  final bool deleteFailed;
  final bool restoring;
  final bool restoreFailed;
  final bool loadingNextBatch;
  final CleanupSource source;

  Photo? get current => index < photos.length ? photos[index] : null;
  bool get hasSession => photos.isNotEmpty;
  bool get hasUnreviewed => current != null;
  bool get isComplete => photos.isNotEmpty && index >= photos.length;
  bool get canUndo => history.isNotEmpty && !deleting && !loadingNextBatch;
  List<Photo> get pendingPhotos => photos
      .where((photo) => pendingDeletion.contains(photo.id))
      .toList(growable: false);
}

final cleanupProvider = NotifierProvider<CleanupController, CleanupState>(
  CleanupController.new,
);

class CleanupController extends Notifier<CleanupState> {
  Future<void> _writeQueue = Future.value();
  LocalStore get _store => ref.read(localStoreProvider);

  @override
  CleanupState build() =>
      _decodeSession(_store.getString(LocalStoreKeys.cleanupSession));

  void start(
    Iterable<Photo> photos, {
    CleanupSource source = const CleanupSource.library(),
  }) {
    final unique = <String, Photo>{for (final photo in photos) photo.id: photo};
    state = CleanupState(
      photos: unique.values.toList(growable: false),
      source: source,
    );
    _persist();
  }

  void keep() => _decide(CleanupDecision.keep);

  void markForDeletion() => _decide(CleanupDecision.markForDeletion);

  void _decide(CleanupDecision decision) {
    final photo = state.current;
    if (photo == null || state.deleting) return;
    final pending = {...state.pendingDeletion};
    if (decision == CleanupDecision.markForDeletion) {
      pending.add(photo.id);
    }
    state = CleanupState(
      photos: state.photos,
      index: state.index + 1,
      pendingDeletion: pending,
      history: [
        ...state.history,
        CleanupAction(photoId: photo.id, decision: decision),
      ],
      source: state.source,
    );
    _persist();
  }

  void undo() {
    if (!state.canUndo) return;
    final last = state.history.last;
    final pending = {...state.pendingDeletion};
    if (last.decision == CleanupDecision.markForDeletion) {
      pending.remove(last.photoId);
    }
    state = CleanupState(
      photos: state.photos,
      index: state.index - 1,
      pendingDeletion: pending,
      history: state.history.sublist(0, state.history.length - 1),
      source: state.source,
    );
    _persist();
  }

  void unmark(String id) {
    if (state.deleting ||
        state.loadingNextBatch ||
        !state.pendingDeletion.contains(id)) {
      return;
    }
    state = CleanupState(
      photos: state.photos,
      index: state.index,
      pendingDeletion: {...state.pendingDeletion}..remove(id),
      history: state.history,
      source: state.source,
    );
    _persist();
  }

  Future<bool> restore() async {
    if (!state.hasSession || state.restoring) return false;
    final saved = state;
    state = CleanupState(
      photos: saved.photos,
      index: saved.index,
      pendingDeletion: saved.pendingDeletion,
      history: saved.history,
      restoring: true,
      source: saved.source,
    );
    try {
      final access = await ref.read(galleryRepositoryProvider).access();
      if (!access.canRead) {
        state = CleanupState(
          photos: saved.photos,
          index: saved.index,
          pendingDeletion: saved.pendingDeletion,
          history: saved.history,
          restoreFailed: true,
          source: saved.source,
        );
        return false;
      }
      final resolved = await ref
          .read(galleryRepositoryProvider)
          .resolvePhotos(saved.photos.map((photo) => photo.id));
      final resolvedById = {for (final photo in resolved) photo.id: photo};
      final validIds = resolvedById.keys.toSet();
      final missingBeforeCurrent = saved.photos
          .take(saved.index)
          .where((photo) => !validIds.contains(photo.id))
          .length;
      final photos = saved.photos
          .where((photo) => validIds.contains(photo.id))
          .map((photo) {
            final current = resolvedById[photo.id]!;
            return Photo(
              id: current.id,
              createdAt: current.createdAt,
              sizeBytes: photo.sizeBytes,
            );
          })
          .toList(growable: false);
      if (photos.isEmpty) {
        discardSession();
        return false;
      }
      state = CleanupState(
        photos: photos,
        index: (saved.index - missingBeforeCurrent).clamp(0, photos.length),
        pendingDeletion: saved.pendingDeletion.intersection(validIds),
        history: saved.history
            .where((action) => validIds.contains(action.photoId))
            .toList(growable: false),
        source: saved.source,
      );
      _persist();
      return true;
    } catch (_) {
      state = CleanupState(
        photos: saved.photos,
        index: saved.index,
        pendingDeletion: saved.pendingDeletion,
        history: saved.history,
        restoreFailed: true,
        source: saved.source,
      );
      return false;
    }
  }

  void discardSession() {
    state = CleanupState();
    _writeQueue = _writeQueue
        .then((_) => _store.remove(LocalStoreKeys.cleanupSession))
        .catchError((_) {});
  }

  Future<void> flushPersistence() => _writeQueue;

  Future<int> loadNextBatch() async {
    if (!state.isComplete || state.loadingNextBatch || state.deleting) return 0;
    final completed = state;
    state = CleanupState(
      photos: completed.photos,
      index: completed.index,
      pendingDeletion: completed.pendingDeletion,
      history: completed.history,
      deleteFailed: completed.deleteFailed,
      restoreFailed: completed.restoreFailed,
      loadingNextBatch: true,
      source: completed.source,
    );
    try {
      final next = switch (completed.source.type) {
        CleanupSourceType.album => await _nextAlbumPhotos(completed),
        CleanupSourceType.library => await _nextLibraryPhotos(completed),
      };
      if (next.isEmpty) {
        state = CleanupState(
          photos: completed.photos,
          index: completed.index,
          pendingDeletion: completed.pendingDeletion,
          history: completed.history,
          deleteFailed: completed.deleteFailed,
          restoreFailed: completed.restoreFailed,
          source: completed.source,
        );
        return 0;
      }
      final batch = next
          .take(GalleryController.pageSize)
          .toList(growable: false);
      state = CleanupState(
        photos: [...completed.photos, ...batch],
        index: completed.index,
        pendingDeletion: completed.pendingDeletion,
        history: completed.history,
        deleteFailed: completed.deleteFailed,
        restoreFailed: completed.restoreFailed,
        source: completed.source,
      );
      _persist();
      return batch.length;
    } catch (_) {
      state = CleanupState(
        photos: completed.photos,
        index: completed.index,
        pendingDeletion: completed.pendingDeletion,
        history: completed.history,
        deleteFailed: completed.deleteFailed,
        restoreFailed: completed.restoreFailed,
        source: completed.source,
      );
      return 0;
    }
  }

  Future<List<Photo>> _nextLibraryPhotos(CleanupState completed) async {
    var gallery = ref.read(galleryProvider);
    var next = _unreviewedPhotos(completed, gallery.photos);
    while (next.isEmpty && gallery.hasMore) {
      final loadedBefore = gallery.photos.length;
      await ref.read(galleryProvider.notifier).loadMore();
      gallery = ref.read(galleryProvider);
      next = _unreviewedPhotos(completed, gallery.photos);
      if (gallery.failed || gallery.photos.length == loadedBefore) break;
    }
    return next;
  }

  Future<List<Photo>> _nextAlbumPhotos(CleanupState completed) async {
    final albumId = completed.source.albumId;
    if (albumId == null) return const [];
    final loadedIds = completed.photos.map((photo) => photo.id).toSet();
    var page = completed.photos.length ~/ GalleryController.pageSize;
    for (var attempts = 0; attempts < 4; attempts++) {
      final photos = await ref
          .read(galleryRepositoryProvider)
          .albumPage(
            albumId,
            page,
            GalleryController.pageSize,
            sort: completed.source.sort,
          );
      if (photos.isEmpty) return const [];
      final next = photos
          .where((photo) => !loadedIds.contains(photo.id))
          .toList(growable: false);
      if (next.isNotEmpty) return next;
      page++;
    }
    return const [];
  }

  List<Photo> _unreviewedPhotos(
    CleanupState completed,
    Iterable<Photo> photos,
  ) {
    final reviewedIds = completed.photos.map((photo) => photo.id).toSet();
    return photos
        .where((photo) => !reviewedIds.contains(photo.id))
        .toList(growable: false);
  }

  Future<DeleteOutcome> deletePending() async {
    final requested = state.pendingDeletion.toList(growable: false);
    if (requested.isEmpty || state.deleting || state.loadingNextBatch) {
      return DeleteOutcome(deleted: const [], remaining: requested);
    }
    state = CleanupState(
      photos: state.photos,
      index: state.index,
      pendingDeletion: state.pendingDeletion,
      history: state.history,
      deleting: true,
      source: state.source,
    );
    try {
      final access = await ref.read(galleryRepositoryProvider).access();
      if (!access.canRead) {
        state = CleanupState(
          photos: state.photos,
          index: state.index,
          pendingDeletion: state.pendingDeletion,
          history: state.history,
          deleteFailed: true,
          source: state.source,
        );
        _persist();
        return DeleteOutcome(deleted: const [], remaining: requested);
      }
      final returned = await ref
          .read(galleryRepositoryProvider)
          .deletePhotos(requested);
      final requestedSet = requested.toSet();
      final deleted = returned.where(requestedSet.contains).toSet();
      final remaining = requestedSet.difference(deleted);
      final deletedBeforeCurrent = state.photos
          .take(state.index)
          .where((photo) => deleted.contains(photo.id))
          .length;
      final remainingPhotos = state.photos
          .where((photo) => !deleted.contains(photo.id))
          .toList(growable: false);
      ref.read(galleryProvider.notifier).removeDeleted(deleted);
      final updated = CleanupState(
        photos: remainingPhotos,
        index: state.index - deletedBeforeCurrent,
        pendingDeletion: remaining,
        history: state.history
            .where((action) => !deleted.contains(action.photoId))
            .toList(growable: false),
        deleteFailed: remaining.isNotEmpty,
        source: state.source,
      );
      if (remaining.isEmpty && !updated.hasUnreviewed) {
        state = CleanupState();
        _clearStored();
      } else {
        state = updated;
        _persist();
      }
      return DeleteOutcome(
        deleted: deleted.toList(growable: false),
        remaining: remaining.toList(growable: false),
      );
    } catch (_) {
      state = CleanupState(
        photos: state.photos,
        index: state.index,
        pendingDeletion: state.pendingDeletion,
        history: state.history,
        deleteFailed: true,
        source: state.source,
      );
      _persist();
      return DeleteOutcome(deleted: const [], remaining: requested);
    }
  }

  void _persist() {
    final payload = _encodeSession(state);
    _writeQueue = _writeQueue
        .then((_) => _store.setString(LocalStoreKeys.cleanupSession, payload))
        .catchError((_) {});
  }

  void _clearStored() {
    _writeQueue = _writeQueue
        .then((_) => _store.remove(LocalStoreKeys.cleanupSession))
        .catchError((_) {});
  }

  String _encodeSession(CleanupState value) => jsonEncode({
    'version': 1,
    'index': value.index,
    'photos': [for (final photo in value.photos) _encodePhoto(photo)],
    'pending': value.pendingDeletion.toList(growable: false),
    'source': _encodeSource(value.source),
    'history': [
      for (final action in value.history)
        {'photoId': action.photoId, 'decision': action.decision.name},
    ],
  });

  Map<String, Object?> _encodeSource(CleanupSource source) => {
    'type': source.type.name,
    'albumId': source.albumId,
    'albumName': source.albumName,
    'sort': source.sort.name,
  };

  Map<String, Object> _encodePhoto(Photo photo) {
    final result = <String, Object>{
      'id': photo.id,
      'createdAt': photo.createdAt.millisecondsSinceEpoch,
    };
    final size = photo.sizeBytes;
    if (size != null) result['sizeBytes'] = size;
    return result;
  }

  CleanupState _decodeSession(String? raw) {
    if (raw == null) return CleanupState();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic> || decoded['version'] != 1) {
        return CleanupState();
      }
      final photos = <Photo>[];
      for (final item in decoded['photos'] as List? ?? const []) {
        if (item is! Map<String, dynamic>) continue;
        final id = item['id'];
        final createdAt = item['createdAt'];
        if (id is! String || createdAt is! num) continue;
        photos.add(
          Photo(
            id: id,
            createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt.toInt()),
            sizeBytes: (item['sizeBytes'] as num?)?.toInt(),
          ),
        );
      }
      if (photos.isEmpty) return CleanupState();
      final validIds = photos.map((photo) => photo.id).toSet();
      final pending = (decoded['pending'] as List? ?? const [])
          .whereType<String>()
          .where(validIds.contains)
          .toSet();
      final history = <CleanupAction>[];
      for (final item in decoded['history'] as List? ?? const []) {
        if (item is! Map<String, dynamic>) continue;
        final photoId = item['photoId'];
        final decisionName = item['decision'];
        if (photoId is! String ||
            decisionName is! String ||
            !validIds.contains(photoId)) {
          continue;
        }
        final decision = CleanupDecision.values
            .where((value) => value.name == decisionName)
            .firstOrNull;
        if (decision != null) {
          history.add(CleanupAction(photoId: photoId, decision: decision));
        }
      }
      final savedIndex = (decoded['index'] as num?)?.toInt() ?? 0;
      return CleanupState(
        photos: photos,
        index: savedIndex.clamp(0, photos.length),
        pendingDeletion: pending,
        history: history.take(savedIndex).toList(growable: false),
        source: _decodeSource(decoded['source']),
      );
    } catch (_) {
      return CleanupState();
    }
  }

  CleanupSource _decodeSource(Object? raw) {
    if (raw is! Map<String, dynamic>) return const CleanupSource.library();
    final sortName = raw['sort'];
    final sort =
        GallerySort.values
            .where((value) => value.name == sortName)
            .firstOrNull ??
        GallerySort.newest;
    if (raw['type'] == CleanupSourceType.album.name) {
      final albumId = raw['albumId'];
      final albumName = raw['albumName'];
      if (albumId is String && albumName is String) {
        return CleanupSource.album(
          albumId: albumId,
          albumName: albumName,
          sort: sort,
        );
      }
    }
    return CleanupSource.library(sort: sort);
  }
}
