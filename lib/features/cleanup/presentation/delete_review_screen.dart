import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_routes.dart';
import '../../../app/design_system.dart';
import '../../../app/empty_state.dart';
import '../../../l10n/app_localizations.dart';
import '../../gallery/application/gallery_controller.dart';
import '../../gallery/domain/gallery_repository.dart';
import '../application/cleanup_controller.dart';

class DeleteReviewScreen extends ConsumerWidget {
  const DeleteReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final state = ref.watch(cleanupProvider);
    final photos = state.pendingPhotos;
    final scheme = Theme.of(context).colorScheme;
    final palette = SwipePixPalette.of(context);
    final estimatedBytes = photos.fold<int?>(
      0,
      (sum, photo) => sum == null || photo.sizeBytes == null
          ? null
          : sum + photo.sizeBytes!,
    );
    return Scaffold(
      appBar: AppBar(title: Text(l.deleteReviewTitle)),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SwipeSpacing.lg,
                0,
                SwipeSpacing.lg,
                SwipeSpacing.md,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: palette.glass,
                  borderRadius: BorderRadius.circular(SwipeRadius.card),
                  border: Border.all(
                    color: palette.delete.withValues(alpha: 0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: palette.delete.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(SwipeSpacing.lg),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: palette.delete,
                          borderRadius: BorderRadius.circular(
                            SwipeRadius.control,
                          ),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: SwipeSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.markedCount(photos.length),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: SwipeSpacing.xs),
                            Text(
                              state.deleteFailed
                                  ? l.deletePartial
                                  : l.deleteReviewSafety,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: photos.isEmpty
                  ? AppEmptyState(
                      icon: Icons.fact_check_outlined,
                      title: l.nothingMarked,
                      body: l.safety,
                      actionLabel: l.backToGallery,
                      onAction: () => context.go(AppRoutes.gallery),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SwipeSpacing.lg,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 142,
                            mainAxisSpacing: SwipeSpacing.sm,
                            crossAxisSpacing: SwipeSpacing.sm,
                          ),
                      itemCount: photos.length,
                      itemBuilder: (context, index) => _PendingPhotoTile(
                        photo: photos[index],
                        disabled: state.deleting,
                        onKeep: () => ref
                            .read(cleanupProvider.notifier)
                            .unmark(photos[index].id),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SwipeSpacing.lg,
                SwipeSpacing.md,
                SwipeSpacing.lg,
                SwipeSpacing.lg,
              ),
              child: state.deleting
                  ? Column(
                      children: [
                        const LinearProgressIndicator(),
                        const SizedBox(height: SwipeSpacing.sm),
                        Text(l.deleting),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (estimatedBytes != null && estimatedBytes > 0) ...[
                          Text(
                            l.youWillFree,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: SwipeSpacing.xxs),
                          Text(
                            _formatFileSize(estimatedBytes),
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: SwipeSpacing.md),
                        ],
                        FilledButton.icon(
                          onPressed: photos.isEmpty
                              ? null
                              : () => _deleteReviewed(context, ref),
                          style: FilledButton.styleFrom(
                            backgroundColor: palette.delete,
                            foregroundColor: Colors.white,
                            shadowColor: palette.delete.withValues(alpha: 0.36),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.delete_forever_outlined),
                          label: Text(l.deleteReviewedPhotos(photos.length)),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteReviewed(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context)!;
    final outcome = await ref.read(cleanupProvider.notifier).deletePending();
    if (!context.mounted) return;
    if (outcome.deleted.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.deleteSuccess(outcome.deleted.length))),
      );
    }
    if (outcome.remaining.isEmpty) {
      final session = ref.read(cleanupProvider);
      context.go(session.hasUnreviewed ? AppRoutes.cleanup : AppRoutes.gallery);
    }
  }
}

class _PendingPhotoTile extends ConsumerWidget {
  const _PendingPhotoTile({
    required this.photo,
    required this.disabled,
    required this.onKeep,
  });

  final Photo photo;
  final bool disabled;
  final VoidCallback onKeep;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final preview = ref.watch(thumbnailProvider(photo.id));
    final palette = SwipePixPalette.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(SwipeRadius.tile),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: preview.when(
              data: (bytes) => bytes == null
                  ? const Icon(Icons.broken_image_outlined)
                  : Image.memory(
                      bytes,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.broken_image_outlined),
                    ),
              error: (_, _) => const Icon(Icons.broken_image_outlined),
              loading: () => const Center(
                child: SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          ),
          Positioned(
            top: SwipeSpacing.xs,
            right: SwipeSpacing.xs,
            child: IconButton.filled(
              onPressed: disabled ? null : onKeep,
              tooltip: l.removeFromDelete,
              style: IconButton.styleFrom(
                backgroundColor: palette.delete,
                foregroundColor: Colors.white,
                minimumSize: const Size.square(30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const Icon(Icons.remove_rounded, size: 18),
            ),
          ),
          Positioned(
            left: SwipeSpacing.sm,
            bottom: SwipeSpacing.sm,
            right: SwipeSpacing.sm,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.58),
                borderRadius: BorderRadius.circular(SwipeRadius.chip),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SwipeSpacing.sm,
                  vertical: SwipeSpacing.xs,
                ),
                child: Text(
                  MaterialLocalizations.of(
                    context,
                  ).formatMediumDate(photo.createdAt),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatFileSize(int bytes) {
  if (bytes >= 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  if (bytes >= 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  if (bytes >= 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
  return '$bytes B';
}
