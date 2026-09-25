import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/app_routes.dart';
import '../../../app/design_system.dart';
import '../../../app/empty_state.dart';
import '../../../l10n/app_localizations.dart';
import '../../cleanup/application/cleanup_controller.dart';
import '../application/gallery_controller.dart';
import '../domain/gallery_repository.dart';

class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({super.key});

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen>
    with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_loadMoreNearEnd);
    Future.microtask(() {
      if (mounted) ref.read(galleryProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController
      ..removeListener(_loadMoreNearEnd)
      ..dispose();
    super.dispose();
  }

  void _loadMoreNearEnd() {
    if (!_scrollController.hasClients ||
        _scrollController.position.extentAfter >= 600) {
      return;
    }
    final gallery = ref.read(galleryProvider);
    if (gallery.hasMore &&
        !gallery.busy &&
        !gallery.loadingMore &&
        !gallery.failed) {
      ref.read(galleryProvider.notifier).loadMore();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(galleryProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final state = ref.watch(galleryProvider);
    final controller = ref.read(galleryProvider.notifier);
    final cleanup = ref.watch(cleanupProvider);
    final albums = ref.watch(galleryAlbumsProvider);
    final totalCount = state.totalPhotoCount ?? state.photos.length;
    final activeSession =
        cleanup.hasSession &&
        (cleanup.index > 0 || cleanup.pendingDeletion.isNotEmpty);

    if (state.hasMore && !state.busy && !state.loadingMore && !state.failed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadMoreNearEnd();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.appTitle),
        actions: [
          IconButton(
            onPressed: state.busy || state.loadingMore
                ? null
                : () => controller.refresh(),
            icon: const Icon(Icons.refresh),
            tooltip: l.refresh,
          ),
          IconButton(
            onPressed: () => context.push(AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
            tooltip: l.settings,
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                SwipeSpacing.lg,
                0,
                SwipeSpacing.lg,
                SwipeSpacing.md,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HomeSummary(
                      count: totalCount,
                      access: state.access,
                      status: _accessLabel(l, state.access),
                    ),
                    if (activeSession) ...[
                      const SizedBox(height: SwipeSpacing.md),
                      _ContinueCleanupCard(
                        state: cleanup,
                        onContinue: cleanup.restoring
                            ? null
                            : () => _continueSession(context),
                      ),
                      const SizedBox(height: SwipeSpacing.md),
                    ] else
                      const SizedBox(height: SwipeSpacing.md),
                    _StartCleanupButton(
                      enabled:
                          state.access.canRead &&
                          !state.busy &&
                          state.photos.isNotEmpty,
                      label: activeSession ? l.startNewCleanup : l.startCleanup,
                      onPressed: () => _startSession(context),
                    ),
                    if (!state.access.canRead ||
                        state.access == GalleryAccess.limited) ...[
                      const SizedBox(height: SwipeSpacing.md),
                      _PermissionActions(state: state, controller: controller),
                    ],
                    if (state.failed) ...[
                      const SizedBox(height: SwipeSpacing.md),
                      _InlineMessage(
                        icon: Icons.error_outline,
                        text: l.error,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: state.busy
                              ? null
                              : () => controller.refresh(),
                          icon: const Icon(Icons.refresh),
                          label: Text(l.retry),
                        ),
                      ),
                    ],
                    if (state.busy)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: SwipeSpacing.xl,
                        ),
                        child: Column(
                          children: [
                            const CircularProgressIndicator(),
                            if (state.sort == GallerySort.largest) ...[
                              const SizedBox(height: 8),
                              Text(l.calculatingSizes),
                            ],
                          ],
                        ),
                      ),
                    if (!state.busy &&
                        !state.failed &&
                        state.access.canRead &&
                        state.photos.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: SwipeSpacing.xl),
                        child: AppEmptyState(
                          icon: Icons.photo_library_outlined,
                          title: l.photoSummary(0),
                          body: l.empty,
                          actionLabel: state.access == GalleryAccess.limited
                              ? null
                              : l.refresh,
                          onAction: state.access == GalleryAccess.limited
                              ? null
                              : () => controller.refresh(),
                          compact: true,
                        ),
                      ),
                    if (state.access.canRead) ...[
                      const SizedBox(height: SwipeSpacing.xl),
                      _QuickCleanup(
                        totalCount: totalCount,
                        enabled: !state.busy && !state.loadingMore,
                        onAll: () =>
                            _startWithSort(context, GallerySort.newest),
                        onLarge: () =>
                            _startWithSort(context, GallerySort.largest),
                        onOldest: () =>
                            _startWithSort(context, GallerySort.oldest),
                      ),
                      const SizedBox(height: SwipeSpacing.xl),
                      albums.when(
                        data: (items) => items.isEmpty
                            ? const SizedBox.shrink()
                            : _AlbumsSection(
                                albums: items.take(4).toList(growable: false),
                              ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, _) => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: SwipeSpacing.xl),
                      _LibraryHeader(
                        count: state.photos.length,
                        sort: state.sort,
                        enabled: !state.busy && !state.loadingMore,
                        onSortChanged: controller.selectSort,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: SwipeSpacing.lg),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 124,
                  mainAxisSpacing: SwipeSpacing.sm,
                  crossAxisSpacing: SwipeSpacing.sm,
                ),
                itemCount: state.photos.length,
                itemBuilder: (context, index) => PhotoTile(
                  key: ValueKey(state.photos[index].id),
                  photo: state.photos[index],
                ),
              ),
            ),
            if (state.loadingMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 8),
                      Text(l.loadingMorePhotos),
                    ],
                  ),
                ),
              )
            else if (state.hasMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: OutlinedButton.icon(
                    onPressed: state.busy ? null : controller.loadMore,
                    icon: const Icon(Icons.expand_more),
                    label: Text(l.more),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _accessLabel(AppLocalizations l, GalleryAccess access) =>
      switch (access) {
        GalleryAccess.authorized => l.authorized,
        GalleryAccess.limited => l.limited,
        GalleryAccess.denied => l.denied,
        GalleryAccess.restricted => l.restricted,
        GalleryAccess.unsupported => l.unsupported,
        GalleryAccess.notDetermined => l.permissionIntro,
      };

  Future<void> _continueSession(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final restored = await ref.read(cleanupProvider.notifier).restore();
    if (!context.mounted) return;
    if (restored) {
      context.push(AppRoutes.cleanup);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.sessionUnavailable)));
    }
  }

  Future<void> _startWithSort(BuildContext context, GallerySort sort) async {
    final controller = ref.read(galleryProvider.notifier);
    await controller.selectSort(sort);
    if (!context.mounted) return;
    await _startSession(
      context,
      source: CleanupSource.library(sort: ref.read(galleryProvider).sort),
    );
  }

  Future<void> _startSession(
    BuildContext context, {
    CleanupSource? source,
  }) async {
    final l = AppLocalizations.of(context)!;
    final cleanup = ref.read(cleanupProvider);
    final shouldConfirm =
        cleanup.hasSession &&
        (cleanup.index > 0 || cleanup.pendingDeletion.isNotEmpty);
    if (shouldConfirm) {
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
    final gallery = ref.read(galleryProvider);
    ref
        .read(cleanupProvider.notifier)
        .start(
          gallery.photos,
          source: source ?? CleanupSource.library(sort: gallery.sort),
        );
    context.push(AppRoutes.cleanup);
  }
}

class _HomeSummary extends StatelessWidget {
  const _HomeSummary({
    required this.count,
    required this.access,
    required this.status,
  });

  final int count;
  final GalleryAccess access;
  final String status;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            l.photoSummary(count),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (access != GalleryAccess.authorized)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: _AccessChip(label: status, canRead: access.canRead),
          ),
      ],
    );
  }
}

class _StartCleanupButton extends StatelessWidget {
  const _StartCleanupButton({
    required this.enabled,
    required this.label,
    required this.onPressed,
  });

  final bool enabled;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = SwipePixPalette.of(context);
    final scheme = Theme.of(context).colorScheme;
    return AnimatedOpacity(
      duration: SwipeMotion.quick,
      opacity: enabled ? 1 : 0.48,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(SwipeRadius.control),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(SwipeRadius.control),
          child: Ink(
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SwipeRadius.control),
              gradient: LinearGradient(
                colors: enabled
                    ? [palette.accent, palette.accentHigh]
                    : [
                        scheme.surfaceContainerHighest,
                        scheme.surfaceContainerHighest,
                      ],
              ),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: palette.accent.withValues(alpha: 0.28),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome_motion_rounded,
                  size: 18,
                  color: enabled ? Colors.white : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: SwipeSpacing.sm),
                Text(
                  label,
                  style: TextStyle(
                    color: enabled ? Colors.white : scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PermissionActions extends StatelessWidget {
  const _PermissionActions({required this.state, required this.controller});

  final GalleryState state;
  final GalleryController controller;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (state.access == GalleryAccess.notDetermined ||
            state.access == GalleryAccess.denied)
          FilledButton.icon(
            onPressed: state.busy
                ? null
                : () => controller.refresh(request: true),
            icon: const Icon(Icons.lock_open_outlined),
            label: Text(l.allow),
          ),
        if (state.access == GalleryAccess.denied ||
            state.access == GalleryAccess.restricted)
          OutlinedButton.icon(
            onPressed: state.busy ? null : controller.openSettings,
            icon: const Icon(Icons.settings_outlined),
            label: Text(l.openSettings),
          ),
        if (state.access == GalleryAccess.limited)
          OutlinedButton.icon(
            onPressed: state.busy ? null : controller.manageLimited,
            icon: const Icon(Icons.photo_filter_outlined),
            label: Text(l.manage),
          ),
      ],
    );
  }
}

class _QuickCleanup extends StatelessWidget {
  const _QuickCleanup({
    required this.totalCount,
    required this.enabled,
    required this.onAll,
    required this.onLarge,
    required this.onOldest,
  });

  final int totalCount;
  final bool enabled;
  final VoidCallback onAll;
  final VoidCallback onLarge;
  final VoidCallback onOldest;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final formattedCount = _formatCount(context, totalCount);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _SectionTitle(title: l.quickCleanup)),
            Text(
              l.seeAll,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: SwipePixPalette.of(context).accent,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: SwipeSpacing.sm),
        Wrap(
          spacing: SwipeSpacing.sm,
          runSpacing: SwipeSpacing.sm,
          children: [
            _QuickCleanupTile(
              title: l.allPhotos,
              detail: formattedCount,
              icon: Icons.photo_library_outlined,
              onPressed: enabled ? onAll : null,
            ),
            _QuickCleanupTile(
              title: l.largePhotos,
              icon: Icons.sd_storage_outlined,
              onPressed: enabled ? onLarge : null,
            ),
            _QuickCleanupTile(
              title: l.oldestPhotos,
              icon: Icons.history_outlined,
              onPressed: enabled ? onOldest : null,
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickCleanupTile extends StatelessWidget {
  const _QuickCleanupTile({
    required this.title,
    required this.icon,
    required this.onPressed,
    this.detail,
  });

  final String title;
  final String? detail;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = SwipePixPalette.of(context);
    return AnimatedOpacity(
      duration: SwipeMotion.quick,
      opacity: onPressed == null ? 0.55 : 1,
      child: Material(
        color: palette.glass,
        borderRadius: BorderRadius.circular(SwipeRadius.control),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(SwipeRadius.control),
          child: Container(
            constraints: const BoxConstraints(minWidth: 82),
            padding: const EdgeInsets.symmetric(
              horizontal: SwipeSpacing.md,
              vertical: SwipeSpacing.sm,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SwipeRadius.control),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.18),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: palette.accentHigh),
                const SizedBox(height: SwipeSpacing.xs),
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (detail != null)
                  Text(
                    detail!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AlbumsSection extends StatelessWidget {
  const _AlbumsSection({required this.albums});

  final List<GalleryAlbum> albums;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _SectionTitle(title: l.albums)),
            TextButton(
              onPressed: () => context.push(AppRoutes.albums),
              child: Text(l.seeAll),
            ),
          ],
        ),
        const SizedBox(height: SwipeSpacing.sm),
        SizedBox(
          height: 104,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: albums.length,
            separatorBuilder: (_, _) => const SizedBox(width: SwipeSpacing.sm),
            itemBuilder: (context, index) => _AlbumCard(album: albums[index]),
          ),
        ),
      ],
    );
  }
}

class _AlbumCard extends StatelessWidget {
  const _AlbumCard({required this.album});

  final GalleryAlbum album;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return SizedBox(
      width: 118,
      child: InkWell(
        borderRadius: BorderRadius.circular(SwipeRadius.tile),
        onTap: () => context.push(AppRoutes.albumDetails(album.id)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _AlbumCover(album: album),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(SwipeRadius.tile),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.78),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: SwipeSpacing.sm,
              right: SwipeSpacing.sm,
              bottom: SwipeSpacing.sm,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    l.albumPhotoCount(album.photoCount),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontWeight: FontWeight.w600,
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

class _AlbumCover extends ConsumerWidget {
  const _AlbumCover({required this.album});

  final GalleryAlbum album;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final cover = album.coverPhoto;
    Widget placeholder() => ColoredBox(
      color: scheme.surfaceContainerHighest,
      child: Icon(Icons.photo_library_outlined, color: scheme.onSurfaceVariant),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(SwipeRadius.tile),
      child: cover == null
          ? placeholder()
          : ref
                .watch(thumbnailProvider(cover.id))
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w900,
      letterSpacing: -0.25,
    ),
  );
}

class _AccessChip extends StatelessWidget {
  const _AccessChip({required this.label, required this.canRead});

  final String label;
  final bool canRead;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: SwipePixPalette.of(context).glassStrong,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.16),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              canRead ? Icons.check_circle_outline : Icons.info_outline,
              size: 16,
              color: canRead
                  ? SwipePixPalette.of(context).keep
                  : scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryHeader extends StatelessWidget {
  const _LibraryHeader({
    required this.count,
    required this.sort,
    required this.enabled,
    required this.onSortChanged,
  });

  final int count;
  final GallerySort sort;
  final bool enabled;
  final ValueChanged<GallerySort> onSortChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final label = switch (sort) {
      GallerySort.newest => l.newestFirst,
      GallerySort.oldest => l.oldestFirst,
      GallerySort.largest => l.largestFirst,
    };
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(title: l.recentPhotos),
              Text(
                l.photoSummary(count),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        Tooltip(
          message: l.sortBy,
          child: _SortChip(
            label: label,
            enabled: enabled,
            onTap: enabled
                ? () async {
                    final selected = await _showSortSheet(context, sort);
                    if (selected != null) onSortChanged(selected);
                  }
                : null,
          ),
        ),
      ],
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedOpacity(
      duration: SwipeMotion.quick,
      opacity: enabled ? 1 : 0.54,
      child: Material(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(SwipeRadius.chip),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SwipeRadius.chip),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.4),
              ),
              borderRadius: BorderRadius.circular(SwipeRadius.chip),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: SwipeSpacing.md,
              vertical: SwipeSpacing.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sort_outlined, size: 18),
                const SizedBox(width: SwipeSpacing.xs),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: SwipeSpacing.xxs),
                const Icon(Icons.expand_more_rounded, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<GallerySort?> _showSortSheet(BuildContext context, GallerySort current) {
  final l = AppLocalizations.of(context)!;
  return showModalBottomSheet<GallerySort>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          SwipeSpacing.lg,
          0,
          SwipeSpacing.lg,
          SwipeSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.sortBy,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: SwipeSpacing.sm),
            _SortOption(
              icon: Icons.schedule_rounded,
              label: l.newestFirst,
              selected: current == GallerySort.newest,
              onTap: () => Navigator.pop(context, GallerySort.newest),
            ),
            _SortOption(
              icon: Icons.history_rounded,
              label: l.oldestFirst,
              selected: current == GallerySort.oldest,
              onTap: () => Navigator.pop(context, GallerySort.oldest),
            ),
            _SortOption(
              icon: Icons.sd_storage_outlined,
              label: l.largestFirst,
              selected: current == GallerySort.largest,
              onTap: () => Navigator.pop(context, GallerySort.largest),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SortOption extends StatelessWidget {
  const _SortOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = SwipePixPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: SwipeSpacing.xs),
      child: Material(
        color: selected
            ? palette.accentLow.withValues(alpha: 0.7)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(SwipeRadius.control),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SwipeRadius.control),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SwipeSpacing.md,
              vertical: SwipeSpacing.md,
            ),
            child: Row(
              children: [
                Icon(icon, color: selected ? palette.accent : null),
                const SizedBox(width: SwipeSpacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                    ),
                  ),
                ),
                if (selected)
                  Icon(Icons.check_rounded, color: palette.accent)
                else
                  Icon(
                    Icons.chevron_right_rounded,
                    color: scheme.onSurfaceVariant,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContinueCleanupCard extends StatelessWidget {
  const _ContinueCleanupCard({required this.state, required this.onContinue});

  final CleanupState state;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final palette = SwipePixPalette.of(context);
    final current = state.index.clamp(0, state.photos.length).toInt();
    final progress = state.photos.isEmpty ? 0.0 : current / state.photos.length;
    return Material(
      color: palette.glass,
      borderRadius: BorderRadius.circular(SwipeRadius.card),
      child: InkWell(
        onTap: onContinue,
        borderRadius: BorderRadius.circular(SwipeRadius.card),
        child: Container(
          padding: const EdgeInsets.all(SwipeSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SwipeRadius.card),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.16),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [palette.accent, palette.accentHigh],
                  ),
                  borderRadius: BorderRadius.circular(SwipeRadius.control),
                ),
                child: Icon(Icons.bookmark_border_rounded, color: Colors.white),
              ),
              const SizedBox(width: SwipeSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.continueCleanup,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: SwipeSpacing.xs),
                    Text(
                      l.reviewedShort(current, state.photos.length),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: SwipeSpacing.sm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 5,
                        value: progress,
                        backgroundColor: scheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(palette.accentHigh),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: SwipeSpacing.sm),
              Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: color),
      const SizedBox(width: 8),
      Expanded(child: Text(text)),
    ],
  );
}

class PhotoTile extends ConsumerWidget {
  const PhotoTile({super.key, required this.photo});

  final Photo photo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final size = photo.sizeBytes == null
        ? null
        : formatFileSize(photo.sizeBytes!);
    final label = [
      l.photo,
      MaterialLocalizations.of(context).formatMediumDate(photo.createdAt),
      ?size,
    ].join(' · ');
    final preview = ref.watch(thumbnailProvider(photo.id));
    Widget unavailable() => Center(
      child: Tooltip(
        message: l.thumbnailError,
        child: const Icon(Icons.broken_image_outlined),
      ),
    );
    return Semantics(
      label: label,
      image: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SwipeRadius.tile),
        child: ColoredBox(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Stack(
            fit: StackFit.expand,
            children: [
              preview.when(
                data: (bytes) => bytes == null
                    ? unavailable()
                    : Image.memory(
                        bytes,
                        fit: BoxFit.cover,
                        excludeFromSemantics: true,
                        errorBuilder: (_, _, _) => unavailable(),
                      ),
                error: (_, _) => unavailable(),
                loading: () => const Center(
                  child: SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              if (size != null)
                Positioned(
                  left: 6,
                  bottom: 6,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.68),
                      borderRadius: BorderRadius.circular(SwipeRadius.chip),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      child: Text(
                        size,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String formatFileSize(int bytes) {
  if (bytes >= 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  if (bytes >= 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  if (bytes >= 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
  return '$bytes B';
}

String _formatCount(BuildContext context, int count) =>
    NumberFormat.decimalPattern(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(count);
