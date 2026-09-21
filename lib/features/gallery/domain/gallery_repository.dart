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

class Photo {
  const Photo({required this.id, required this.createdAt, this.sizeBytes});
  final String id;
  final DateTime createdAt;
  final int? sizeBytes;
}

class GalleryAlbum {
  const GalleryAlbum({
    required this.id,
    required this.name,
    required this.photoCount,
    this.coverPhoto,
  });

  final String id;
  final String name;
  final int photoCount;
  final Photo? coverPhoto;
}

List<Photo> sortPhotosLargestFirst(Iterable<Photo> photos) {
  final sorted = photos.toList(growable: false);
  sorted.sort((a, b) {
    final bySize = (b.sizeBytes ?? -1).compareTo(a.sizeBytes ?? -1);
    return bySize != 0 ? bySize : b.createdAt.compareTo(a.createdAt);
  });
  return List.unmodifiable(sorted);
}

abstract interface class GalleryRepository {
  Future<GalleryAccess> access({bool request = false});
  Future<int?> photoCount();
  Future<List<GalleryAlbum>> albums({int? limit});
  Future<GalleryAlbum?> album(String id);
  Future<List<Photo>> page(
    int page,
    int size, {
    GallerySort sort = GallerySort.newest,
  });
  Future<List<Photo>> albumPage(
    String albumId,
    int page,
    int size, {
    GallerySort sort = GallerySort.newest,
  });
  Future<List<Photo>> resolvePhotos(Iterable<String> ids);
  Future<Uint8List?> thumbnail(String id);
  Future<Uint8List?> preview(String id);
  Future<List<String>> deletePhotos(List<String> ids);
  Future<void> manageLimited();
  Future<void> openSettings();
}
