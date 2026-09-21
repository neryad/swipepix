import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_routes.dart';
import '../../../app/design_system.dart';
import '../../../l10n/app_localizations.dart';
import '../../cleanup/application/cleanup_controller.dart';
import '../application/gallery_controller.dart';
import '../domain/gallery_repository.dart';
import 'gallery_screen.dart' show PhotoTile, formatFileSize;

class AlbumsScreen extends ConsumerStatefulWidget {
  const AlbumsScreen({super.key});

  @override
  ConsumerState<AlbumsScreen> createState() => _AlbumsScreenState();
}

class _AlbumsScreenState extends ConsumerState<AlbumsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final gallery = ref.read(galleryProvider);
      if (!gallery.access.canRead && !gallery.busy) {
        ref.read(galleryProvider.notifier).refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final albums = ref.watch(galleryAlbumsProvider);
    final gallery = ref.watch(galleryProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.albums),
        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(galleryAlbumsProvider);
              ref.read(galleryProvider.notifier).refresh();
            },
            icon: const Icon(Icons.refresh),
            tooltip: l.refresh,
          ),
        ],
      ),
      body: SafeArea(
        child: albums.when(
          data: (items) => CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  SwipeSpacing.lg,
                  0,
                  SwipeSpacing.lg,
                  SwipeSpacing.lg,
                ),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    l.chooseWhatToClean,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (gallery.access.canRead)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SwipeSpacing.lg,
                  ),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      if (index == 0) {
                        final count =
                            gallery.totalPhotoCount ?? gallery.photos.length;
                        return _AllPhotosAlbumTile(
                          count: count,
                          coverPhoto: gallery.photos.firstOrNull,
                          onTap: () => context.go(AppRoutes.gallery),
                        );
                      }
                      final album = items[index - 1];
                      return _AlbumGridTile(
                        title: album.name,
                        subtitle: l.albumPhotoCount(album.photoCount),
                        coverPhoto: album.coverPhoto,
                        onTap: () => context.push(
                          '/album/${Uri.encodeComponent(album.id)}',
                        ),
                      );
                    }, childCount: items.length + 1),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: SwipeSpacing.md,
                          crossAxisSpacing: SwipeSpacing.md,
                          childAspectRatio: 0.98,
                        ),
                  ),
                )
              else
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _AlbumsMessage(
                    icon: Icons.photo_library_outlined,
                    title: l.albums,
                    body: _accessBody(l, gallery.access),
                    actionLabel:
                        gallery.access == GalleryAccess.notDetermined ||
                            gallery.access == GalleryAccess.denied
                        ? l.allow
                        : null,
                    onAction:
                        gallery.access == GalleryAccess.notDetermined ||
                            gallery.access == GalleryAccess.denied
                        ? () => ref
                              .read(galleryProvider.notifier)
                              .refresh(request: true)
                        : null,
                  ),
                ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => _AlbumsMessage(
            icon: Icons.error_outline,
            title: l.error,
            body: l.retry,
            actionLabel: l.retry,
            onAction: () => ref.invalidate(galleryAlbumsProvider),
          ),
        ),
      ),
    );
  }

  String _accessBody(AppLocalizations l, GalleryAccess access) =>
      switch (access) {
        GalleryAccess.limited => l.noAlbums,
        GalleryAccess.denied => l.denied,
        GalleryAccess.restricted => l.restricted,
        GalleryAccess.unsupported => l.unsupported,
        GalleryAccess.notDetermined => l.permissionIntro,
        GalleryAccess.authorized => l.noAlbums,
      };
}

class AlbumScreen extends ConsumerWidget {
  const AlbumScreen({super.key, required this.albumId});

  final String albumId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final album = ref.watch(galleryAlbumProvider(albumId));
    final photos = ref.watch(galleryAlbumPhotosProvider(albumId));
    final cleanup = ref.watch(cleanupProvider);
    final title = album.maybeWhen(
      data: (value) => value?.name ?? l.albums,
      orElse: () => l.albums,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(galleryAlbumProvider(albumId));
              ref.invalidate(galleryAlbumPhotosProvider(albumId));
            },
            icon: const Icon(Icons.refresh),
            tooltip: l.refresh,
          ),
        ],
      ),
      body: album.when(
        data: (value) {
          if (value == null) {
            return Center(child: Text(l.albumNotFound));
          }
          return SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    SwipeSpacing.lg,
                    0,
                    SwipeSpacing.lg,
                    SwipeSpacing.xl,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          value.name,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.6,
                              ),
                        ),
                        const SizedBox(height: SwipeSpacing.xs),
                        Text(
                          l.albumPhotoCount(value.photoCount),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: SwipeSpacing.lg),
                        SizedBox(
                          height: 46,
                          child: FilledButton.icon(
                            onPressed: photos.maybeWhen(
                              data: (loaded) => loaded.isEmpty
                                  ? null
                                  : () => _startAlbumCleanup(
                                      context,
                                      ref,
                                      album: value,
                                      photos: loaded,
                                      replaceExisting:
                                          cleanup.index > 0 ||
                                          cleanup.pendingDeletion.isNotEmpty,
                                    ),
                              orElse: () => null,
                            ),
                            icon: const Icon(
                              Icons.cleaning_services_outlined,
                              size: 18,
                            ),
                            label: Text(l.startAlbumCleanup),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                photos.when(
                  data: (loaded) => SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SwipeSpacing.lg,
                    ),
                    sliver: SliverGrid.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 122,
                            mainAxisSpacing: SwipeSpacing.sm,
                            crossAxisSpacing: SwipeSpacing.sm,
                          ),
                      itemCount: loaded.length,
                      itemBuilder: (context, index) => PhotoTile(
                        key: ValueKey(loaded[index].id),
                        photo: loaded[index],
                      ),
                    ),
                  ),
                  loading: () => const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, _) => SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text(l.error)),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l.error)),
      ),
    );
  }

  Future<void> _startAlbumCleanup(
    BuildContext context,
    WidgetRef ref, {
    required GalleryAlbum album,
    required List<Photo> photos,
    required bool replaceExisting,
  }) async {
    final l = AppLocalizations.of(context)!;
    if (replaceExisting) {
      final replace = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l.replaceSessionTitle),
          content: Text(l.replaceSessionBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l.startNewCleanup),
            ),
          ],
        ),
      );
      if (replace != true || !context.mounted) return;
    }
    ref
        .read(cleanupProvider.notifier)
        .start(
          photos,
          source: CleanupSource.album(albumId: album.id, albumName: album.name),
        );
    context.push(AppRoutes.cleanup);
  }
}

class _AllPhotosAlbumTile extends StatelessWidget {
  const _AllPhotosAlbumTile({
    required this.count,
    required this.coverPhoto,
    required this.onTap,
  });

  final int count;
  final Photo? coverPhoto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return _AlbumGridTile(
      title: l.allPhotos,
      subtitle: l.albumPhotoCount(count),
      coverPhoto: coverPhoto,
      leadingIcon: Icons.photo_library_outlined,
      onTap: onTap,
    );
  }
}

class _AlbumGridTile extends StatelessWidget {
  const _AlbumGridTile({
    required this.title,
    required this.subtitle,
    required this.coverPhoto,
    required this.onTap,
    this.leadingIcon,
  });

  final String title;
  final String subtitle;
  final Photo? coverPhoto;
  final VoidCallback onTap;
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    final palette = SwipePixPalette.of(context);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(SwipeRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SwipeRadius.card),
        child: Stack(
          fit: StackFit.expand,
          children: [
            PhotoCover(photo: coverPhoto, radius: SwipeRadius.card),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(SwipeRadius.card),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.02),
                      Colors.black.withValues(alpha: 0.82),
                    ],
                    stops: const [0.2, 1],
                  ),
                ),
              ),
            ),
            Positioned(
              left: SwipeSpacing.md,
              right: SwipeSpacing.md,
              bottom: SwipeSpacing.md,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leadingIcon != null) ...[
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: palette.accent.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(SwipeRadius.chip),
                      ),
                      child: Icon(
                        leadingIcon,
                        size: 18,
                        color: const Color(0xff05201b),
                      ),
                    ),
                    const SizedBox(height: SwipeSpacing.sm),
                  ],
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: SwipeSpacing.xxs),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.78),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AlbumCover extends ConsumerWidget {
  const AlbumCover({super.key, required this.album, this.radius = 18});

  final GalleryAlbum album;
  final double radius;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      PhotoCover(photo: album.coverPhoto, radius: radius);
}

class PhotoCover extends ConsumerWidget {
  const PhotoCover({super.key, required this.photo, this.radius = 18});

  final Photo? photo;
  final double radius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    Widget placeholder() => ColoredBox(
      color: scheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.photo_library_outlined,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: photo == null
          ? placeholder()
          : ref
                .watch(thumbnailProvider(photo!.id))
                .when(
                  data: (bytes) => bytes == null
                      ? placeholder()
                      : Image.memory(
                          bytes,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => placeholder(),
                        ),
                  error: (_, _) => placeholder(),
                  loading: () => placeholder(),
                ),
    );
  }
}

class _AlbumsMessage extends StatelessWidget {
  const _AlbumsMessage({
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = SwipePixPalette.of(context);
    return Padding(
      padding: const EdgeInsets.all(SwipeSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: palette.accentLow,
              borderRadius: BorderRadius.circular(SwipeRadius.card),
            ),
            child: Icon(icon, color: palette.accent, size: 30),
          ),
          const SizedBox(height: SwipeSpacing.lg),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: SwipeSpacing.sm),
          Text(
            body,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: SwipeSpacing.lg),
            FilledButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

String albumSubtitle(BuildContext context, GalleryAlbum album) =>
    AppLocalizations.of(context)!.albumPhotoCount(album.photoCount);

String? photoSizeLabel(Photo photo) =>
    photo.sizeBytes == null ? null : formatFileSize(photo.sizeBytes!);
