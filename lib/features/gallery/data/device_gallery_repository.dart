import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';
import '../domain/gallery_repository.dart';

class DeviceGalleryRepository implements GalleryRepository {
  List<Photo>? _largestCache;
  List<AssetPathEntity>? _albumCache;
  static const _permission = PermissionRequestOption(
    androidPermission: AndroidPermission(
      type: RequestType.image,
      mediaLocation: false,
    ),
  );
  @override
  Future<GalleryAccess> access({bool request = false}) async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return GalleryAccess.unsupported;
    }
    final value = request
        ? await PhotoManager.requestPermissionExtend(requestOption: _permission)
        : await PhotoManager.getPermissionState(requestOption: _permission);
    return switch (value) {
      PermissionState.authorized => GalleryAccess.authorized,
      PermissionState.limited => GalleryAccess.limited,
      PermissionState.denied => GalleryAccess.denied,
      PermissionState.restricted => GalleryAccess.restricted,
      PermissionState.notDetermined => GalleryAccess.notDetermined,
    };
  }

  @override
  Future<int?> photoCount() =>
      PhotoManager.getAssetCount(type: RequestType.image);

  @override
  Future<List<GalleryAlbum>> albums({int? limit}) async {
    final paths = await _loadAlbumPaths(
      filterOption: _filterForSort(GallerySort.newest),
    );
    final albums = <GalleryAlbum>[];
    for (final path in paths) {
      if (limit != null && albums.length >= limit) break;
      try {
        final count = await path.assetCountAsync;
        if (count <= 0) continue;
        final coverAssets = await path.getAssetListPaged(
          page: 0,
          size: 1,
          type: RequestType.image,
        );
        albums.add(
          GalleryAlbum(
            id: path.id,
            name: path.name,
            photoCount: count,
            coverPhoto: coverAssets.isEmpty ? null : _toPhoto(coverAssets[0]),
          ),
        );
      } catch (_) {
        continue;
      }
    }
    return List.unmodifiable(albums);
  }

  @override
  Future<GalleryAlbum?> album(String id) async {
    final path = await _albumPath(id);
    if (path == null) return null;
    try {
      final count = await path.assetCountAsync;
      final coverAssets = count == 0
          ? <AssetEntity>[]
          : await path.getAssetListPaged(
              page: 0,
              size: 1,
              type: RequestType.image,
            );
      return GalleryAlbum(
        id: path.id,
        name: path.name,
        photoCount: count,
        coverPhoto: coverAssets.isEmpty ? null : _toPhoto(coverAssets[0]),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Photo>> page(
    int page,
    int size, {
    GallerySort sort = GallerySort.newest,
  }) async {
    if (sort == GallerySort.largest) {
      return _largestPage(page, size);
    }
    final assets = await PhotoManager.getAssetListPaged(
      page: page,
      pageCount: size,
      type: RequestType.image,
      filterOption: _filterForSort(sort),
    );
    return assets.map(_toPhoto).toList(growable: false);
  }

  @override
  Future<List<Photo>> albumPage(
    String albumId,
    int page,
    int size, {
    GallerySort sort = GallerySort.newest,
  }) async {
    if (sort == GallerySort.largest) {
      final all = await _albumSizeIndex(albumId);
      final start = page * size;
      if (start >= all.length) return const [];
      final end = (start + size).clamp(0, all.length);
      return all.sublist(start, end);
    }
    final path = await _albumPath(albumId, sort: sort);
    if (path == null) return const [];
    final assets = await path.getAssetListPaged(
      page: page,
      size: size,
      type: RequestType.image,
    );
    return assets.map(_toPhoto).toList(growable: false);
  }

  Future<List<Photo>> _largestPage(int page, int size) async {
    final count = await PhotoManager.getAssetCount(type: RequestType.image);
    if (_largestCache == null || _largestCache!.length != count) {
      _largestCache = await _buildSizeIndex(count);
    }
    final start = page * size;
    if (start >= _largestCache!.length) return const [];
    final end = (start + size).clamp(0, _largestCache!.length);
    return _largestCache!.sublist(start, end);
  }

  Future<List<Photo>> _buildSizeIndex(int count) async {
    if (count == 0) return const [];
    final assets = <AssetEntity>[];
    const queryBatchSize = 500;
    for (var start = 0; start < count; start += queryBatchSize) {
      assets.addAll(
        await PhotoManager.getAssetListRange(
          start: start,
          end: (start + queryBatchSize).clamp(0, count),
          type: RequestType.image,
        ),
      );
    }

    final photos = <Photo>[];
    const metadataBatchSize = 12;
    for (var start = 0; start < assets.length; start += metadataBatchSize) {
      final end = (start + metadataBatchSize).clamp(0, assets.length);
      final batch = assets.sublist(start, end);
      photos.addAll(
        await Future.wait(
          batch.map((asset) async {
            int? sizeBytes;
            try {
              sizeBytes = await asset.fileSize;
            } catch (_) {
              sizeBytes = null;
            }
            return _toPhoto(asset, sizeBytes: sizeBytes);
          }),
        ),
      );
    }
    return sortPhotosLargestFirst(photos);
  }

  @override
  Future<Uint8List?> thumbnail(String id) async {
    final asset = await AssetEntity.fromId(id);
    return asset?.thumbnailDataWithSize(const ThumbnailSize.square(256));
  }

  @override
  Future<Uint8List?> preview(String id) async {
    final asset = await AssetEntity.fromId(id);
    return asset?.thumbnailDataWithSize(const ThumbnailSize(1440, 1440));
  }

  @override
  Future<List<Photo>> resolvePhotos(Iterable<String> ids) async {
    final orderedIds = ids.toList(growable: false);
    final photos = <Photo>[];
    const batchSize = 12;
    for (var start = 0; start < orderedIds.length; start += batchSize) {
      final end = (start + batchSize).clamp(0, orderedIds.length);
      final resolved = await Future.wait(
        orderedIds.sublist(start, end).map((id) async {
          final asset = await AssetEntity.fromId(id);
          return asset == null ? null : _toPhoto(asset);
        }),
      );
      photos.addAll(resolved.nonNulls);
    }
    return List.unmodifiable(photos);
  }

  @override
  Future<List<String>> deletePhotos(List<String> ids) {
    _largestCache = null;
    _albumCache = null;
    return PhotoManager.editor.deleteWithIds(List.unmodifiable(ids));
  }

  @override
  Future<void> manageLimited() async {
    await PhotoManager.presentLimited(type: RequestType.image);
    _largestCache = null;
    _albumCache = null;
  }

  @override
  Future<void> openSettings() => PhotoManager.openSetting();

  Future<List<Photo>> _albumSizeIndex(String albumId) async {
    final path = await _albumPath(albumId);
    if (path == null) return const [];
    final count = await path.assetCountAsync;
    if (count == 0) return const [];
    final assets = <AssetEntity>[];
    const queryBatchSize = 500;
    for (var start = 0; start < count; start += queryBatchSize) {
      assets.addAll(
        await path.getAssetListRange(
          start: start,
          end: (start + queryBatchSize).clamp(0, count),
          type: RequestType.image,
        ),
      );
    }
    final photos = <Photo>[];
    const metadataBatchSize = 12;
    for (var start = 0; start < assets.length; start += metadataBatchSize) {
      final end = (start + metadataBatchSize).clamp(0, assets.length);
      final batch = assets.sublist(start, end);
      photos.addAll(
        await Future.wait(
          batch.map((asset) async {
            int? sizeBytes;
            try {
              sizeBytes = await asset.fileSize;
            } catch (_) {
              sizeBytes = null;
            }
            return _toPhoto(asset, sizeBytes: sizeBytes);
          }),
        ),
      );
    }
    return sortPhotosLargestFirst(photos);
  }

  Future<AssetPathEntity?> _albumPath(
    String id, {
    GallerySort sort = GallerySort.newest,
  }) async {
    final cached = (_albumCache ?? await _loadAlbumPaths())
        .where((path) => path.id == id)
        .firstOrNull;
    if (cached == null) return null;
    return AssetPathEntity.fromId(
      cached.id,
      filterOption: _filterForSort(sort),
      type: RequestType.image,
      albumType: cached.albumType,
    );
  }

  Future<List<AssetPathEntity>> _loadAlbumPaths({
    FilterOptionGroup? filterOption,
  }) async {
    final paths = await PhotoManager.getAssetPathList(
      hasAll: false,
      onlyAll: false,
      type: RequestType.image,
      filterOption: filterOption ?? _filterForSort(GallerySort.newest),
    );
    _albumCache = paths
        .where((path) => path.albumType == 1 && !path.isAll)
        .toList(growable: false);
    return _albumCache!;
  }

  FilterOptionGroup _filterForSort(GallerySort sort) => FilterOptionGroup(
    orders: [
      OrderOption(
        type: OrderOptionType.createDate,
        asc: sort == GallerySort.oldest,
      ),
    ],
  );

  Photo _toPhoto(AssetEntity asset, {int? sizeBytes}) => Photo(
    id: asset.id,
    createdAt: asset.createDateTime,
    sizeBytes: sizeBytes,
  );
}
