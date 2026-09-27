import 'dart:typed_data';

enum GalleryAccess {
  notDetermined,
  authorized,
  limited,
  denied,
  restricted,
  unsupported,
}

extension GalleryAccessCheck on GalleryAccess {
  bool get canRead =>
      this == GalleryAccess.authorized || this == GalleryAccess.limited;
}

enum GallerySort { newest, oldest, largest }

enum MediaType { image, video }

class MediaAsset {
  const MediaAsset({
    required this.id,
    required this.createdAt,
    this.sizeBytes,
    this.mediaType = MediaType.image,
    this.duration,
  });

  final String id;
  final DateTime createdAt;
  final int? sizeBytes;
  final MediaType mediaType;
  final Duration? duration;

  bool get isVideo => mediaType == MediaType.video;
}

class GalleryAlbum {
  const GalleryAlbum({
    required this.id,
    required this.name,
    required this.mediaCount,
    this.coverMedia,
  });

  final String id;
  final String name;
  final int mediaCount;
  final MediaAsset? coverMedia;
}

List<MediaAsset> sortMediaLargestFirst(Iterable<MediaAsset> photos) {
  final sorted = photos.toList(growable: false);
  sorted.sort((a, b) {
    final bySize = (b.sizeBytes ?? -1).compareTo(a.sizeBytes ?? -1);
    return bySize != 0 ? bySize : b.createdAt.compareTo(a.createdAt);
  });
  return List.unmodifiable(sorted);
}

abstract interface class GalleryRepository {
  Future<GalleryAccess> access({bool request = false});
  Future<int?> mediaCount();
  Future<List<GalleryAlbum>> albums({int? limit});
  Future<GalleryAlbum?> album(String id);
  Future<List<MediaAsset>> page(
    int page,
    int size, {
    GallerySort sort = GallerySort.newest,
  });
  Future<List<MediaAsset>> albumPage(
    String albumId,
    int page,
    int size, {
    GallerySort sort = GallerySort.newest,
  });
  Future<List<MediaAsset>> resolveMedia(Iterable<String> ids);
  Future<Uint8List?> thumbnail(String id);
  Future<Uint8List?> preview(String id);
  Future<List<String>> deleteMedia(List<String> ids);
  Future<void> manageLimited();
  Future<void> openSettings();
}
