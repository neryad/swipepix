import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_routes.dart';
import '../../../app/design_system.dart';
import '../../../l10n/app_localizations.dart';
import '../../gallery/application/gallery_controller.dart';
import '../../gallery/domain/gallery_repository.dart';
import '../application/cleanup_controller.dart';

class CleanupScreen extends ConsumerWidget {
  const CleanupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final state = ref.watch(cleanupProvider);
    final gallery = ref.watch(galleryProvider);
    final controller = ref.read(cleanupProvider.notifier);
    final pendingCount = state.pendingDeletion.length;
    final sessionIds = state.photos.map((photo) => photo.id).toSet();
    final hasLoadedNext = gallery.photos.any(
      (photo) => !sessionIds.contains(photo.id),
    );
    final canLoadNext = hasLoadedNext || gallery.hasMore;
    final isActiveReview = state.photos.isNotEmpty && !state.isComplete;
    return Scaffold(
      appBar: isActiveReview
          ? null
          : AppBar(
              title: Text(l.cleanupTitle),
              actions: [
                TextButton.icon(
                  onPressed: pendingCount == 0
                      ? null
                      : () => context.push(AppRoutes.cleanupReview),
                  icon: const Icon(Icons.fact_check_outlined),
                  label: Text(l.markedCount(pendingCount)),
                ),
              ],
            ),
      body: SafeArea(
        child: state.photos.isEmpty
            ? _EmptySession(
                onBack: () {
                  controller.discardSession();
                  context.go(AppRoutes.gallery);
                },
              )
            : state.isComplete
            ? _CompletedSession(
                pendingCount: pendingCount,
                onReview: pendingCount == 0
                    ? null
                    : () => context.push(AppRoutes.cleanupReview),
                onUndo: state.canUndo ? controller.undo : null,
                loadingNextBatch: state.loadingNextBatch,
                canLoadNext: canLoadNext,
                reviewedCount: state.index,
                totalCount: state.photos.length,
                onLoadNext: canLoadNext
                    ? () async {
                        final added = await controller.loadNextBatch();
                        if (added == 0 && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l.noMorePhotos)),
                          );
                        }
                      }
                    : null,
                onBack: () {
                  controller.discardSession();
                  context.go(AppRoutes.gallery);
                },
              )
            : _ReviewDeck(
                state: state,
                onKeep: controller.keep,
                onMark: controller.markForDeletion,
                onUndo: state.canUndo ? controller.undo : null,
                onSettings: () => context.push(AppRoutes.settings),
                onPending: pendingCount == 0
                    ? null
                    : () => context.push(AppRoutes.cleanupReview),
              ),
      ),
    );
  }
}

class _ReviewDeck extends StatefulWidget {
  const _ReviewDeck({
    required this.state,
    required this.onKeep,
    required this.onMark,
    required this.onUndo,
    required this.onSettings,
    required this.onPending,
  });

  final CleanupState state;
  final VoidCallback onKeep;
  final VoidCallback onMark;
  final VoidCallback? onUndo;
  final VoidCallback onSettings;
  final VoidCallback? onPending;

  @override
  State<_ReviewDeck> createState() => _ReviewDeckState();
}

class _ReviewDeckState extends State<_ReviewDeck>
    with SingleTickerProviderStateMixin {
  static bool _hasShownSwipeTutorial = false;

  late final AnimationController _controller;
  Animation<Offset>? _offsetAnimation;
  final List<Timer> _timers = [];
  Offset _dragOffset = Offset.zero;
  bool _thresholdFeedbackSent = false;
  bool _tutorialStarted = false;
  bool _showHelperText = false;

  static const double _threshold = 120;
  static const Duration _snapDuration = Duration(milliseconds: 240);
  static const Duration _exitDuration = Duration(milliseconds: 220);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_tutorialStarted || _hasShownSwipeTutorial) return;
    _tutorialStarted = true;
    _hasShownSwipeTutorial = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.disableAnimationsOf(context)) {
        _brieflyShowHelperText();
      } else {
        _runSwipeTutorial();
      }
    });
  }

  @override
  void didUpdateWidget(covariant _ReviewDeck oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.current?.id != widget.state.current?.id) {
      _controller.stop();
      _controller.reset();
      _offsetAnimation = null;
      _dragOffset = Offset.zero;
      _thresholdFeedbackSent = false;
    }
  }

  @override
  void dispose() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _controller.dispose();
    super.dispose();
  }

  Future<void> _wait(Duration duration) {
    final completer = Completer<void>();
    late final Timer timer;
    timer = Timer(duration, () {
      _timers.remove(timer);
      if (!completer.isCompleted) completer.complete();
    });
    _timers.add(timer);
    return completer.future;
  }

  void _dismissTutorial() {
    if (!_showHelperText && !_controller.isAnimating) return;
    _controller.stop();
    setState(() {
      _showHelperText = false;
      _dragOffset = Offset.zero;
      _offsetAnimation = null;
    });
  }

  Future<void> _runSwipeTutorial() async {
    await _wait(const Duration(milliseconds: 500));
    if (!mounted || _dragOffset != Offset.zero || _controller.isAnimating) {
      return;
    }
    await _animateTo(const Offset(-56, 0), const Duration(milliseconds: 320));
    if (!mounted) return;
    await _animateTo(
      Offset.zero,
      const Duration(milliseconds: 380),
      curve: Curves.easeOutBack,
    );
    await _wait(const Duration(milliseconds: 180));
    if (!mounted) return;
    await _animateTo(const Offset(56, 0), const Duration(milliseconds: 320));
    if (!mounted) return;
    await _animateTo(
      Offset.zero,
      const Duration(milliseconds: 380),
      curve: Curves.easeOutBack,
    );
    if (!mounted) return;
    _brieflyShowHelperText();
  }

  void _brieflyShowHelperText() {
    if (!mounted) return;
    setState(() => _showHelperText = true);
    _wait(const Duration(milliseconds: 1800)).then((_) {
      if (mounted) setState(() => _showHelperText = false);
    });
  }

  void _setDragOffset(Offset value) {
    setState(() => _dragOffset = value);
    if (!_thresholdFeedbackSent && value.dx.abs() >= _threshold) {
      _thresholdFeedbackSent = true;
      HapticFeedback.selectionClick();
    } else if (value.dx.abs() < _threshold * 0.8) {
      _thresholdFeedbackSent = false;
    }
  }

  Future<void> _animateTo(
    Offset target,
    Duration duration, {
    Curve curve = Curves.easeOutCubic,
  }) async {
    _controller.stop();
    _controller.duration = duration;
    _offsetAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: target,
    ).animate(CurvedAnimation(parent: _controller, curve: curve));
    void tick() {
      setState(() => _dragOffset = _offsetAnimation!.value);
    }

    _controller
      ..addListener(tick)
      ..reset();
    try {
      await _controller.forward();
    } finally {
      _controller.removeListener(tick);
      _offsetAnimation = null;
    }
  }

  Future<void> _snapBack() async {
    await _animateTo(Offset.zero, _snapDuration, curve: Curves.easeOutBack);
    _thresholdFeedbackSent = false;
  }

  Future<void> _accept(int direction) async {
    _dismissTutorial();
    if (_controller.isAnimating) return;
    final width = MediaQuery.sizeOf(context).width;
    HapticFeedback.lightImpact();
    await _animateTo(Offset(direction * (width + 180), 24), _exitDuration);
    if (!mounted) return;
    if (direction < 0) {
      widget.onMark();
    } else {
      widget.onKeep();
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    _dismissTutorial();
    if (_controller.isAnimating) return;
    _setDragOffset(_dragOffset + details.delta);
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_controller.isAnimating) return;
    final velocity = details.velocity.pixelsPerSecond.dx;
    if (_dragOffset.dx <= -_threshold || velocity < -700) {
      _accept(-1);
    } else if (_dragOffset.dx >= _threshold || velocity > 700) {
      _accept(1);
    } else {
      _snapBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final state = widget.state;
    final photo = state.current!;
    final nextPhoto = state.index + 1 < state.photos.length
        ? state.photos[state.index + 1]
        : null;
    final scheme = Theme.of(context).colorScheme;
    final progress = (state.index + 1) / state.photos.length;
    final width = MediaQuery.sizeOf(context).width;
    final dragProgress = (_dragOffset.dx.abs() / _threshold).clamp(0.0, 1.0);
    final rotation = (_dragOffset.dx / width * 0.16).clamp(-0.16, 0.16);
    final palette = SwipePixPalette.of(context);
    final glowColor = _dragOffset.dx < 0 ? palette.delete : palette.keep;
    return DecoratedBox(
      decoration: BoxDecoration(color: scheme.surface),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              SwipeSpacing.lg,
              SwipeSpacing.sm,
              SwipeSpacing.lg,
              0,
            ),
            child: _ReviewHeader(
              progressText: l.reviewProgress(
                state.index + 1,
                state.photos.length,
              ),
              progress: progress,
              pendingText: l.markedCount(state.pendingDeletion.length),
              pendingCount: state.pendingDeletion.length,
              onSettings: widget.onSettings,
              onPending: widget.onPending,
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontal = width < 390 ? 12.0 : 18.0;
                final cardHeight = (constraints.maxHeight - 2).clamp(
                  360.0,
                  constraints.maxHeight,
                );
                return Center(
                  child: SizedBox(
                    height: cardHeight,
                    width: constraints.maxWidth,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_dragOffset.dx != 0)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: Opacity(
                                opacity: 0.12 + dragProgress * 0.22,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: RadialGradient(
                                      radius: 0.82,
                                      colors: [glowColor, Colors.transparent],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (nextPhoto != null)
                          Transform.translate(
                            offset: Offset(0, 18 + dragProgress * -10),
                            child: Transform.scale(
                              scale: 0.92 + dragProgress * 0.035,
                              child: Opacity(
                                opacity: 0.28 + dragProgress * 0.22,
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    horizontal + 18,
                                    SwipeSpacing.sm,
                                    horizontal + 18,
                                    0,
                                  ),
                                  child: _PhotoCard(
                                    photo: nextPhoto,
                                    showMetadata: false,
                                    isBackgroundCard: true,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        GestureDetector(
                          key: ValueKey('active-photo-${photo.id}'),
                          onPanUpdate: _handlePanUpdate,
                          onPanEnd: _handlePanEnd,
                          onPanCancel: _snapBack,
                          child: Transform.translate(
                            offset: _dragOffset,
                            child: Transform.rotate(
                              angle: rotation,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                  horizontal,
                                  0,
                                  horizontal,
                                  0,
                                ),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    _PhotoCard(photo: photo),
                                    _DecisionOverlay(
                                      alignment: Alignment.topRight,
                                      visible: _dragOffset.dx > 0,
                                      progress: _dragOffset.dx > 0
                                          ? dragProgress
                                          : 0,
                                      icon: Icons.check_rounded,
                                      label: l.keepOverlay,
                                      color: palette.keep,
                                    ),
                                    _DecisionOverlay(
                                      alignment: Alignment.topLeft,
                                      visible: _dragOffset.dx < 0,
                                      progress: _dragOffset.dx < 0
                                          ? dragProgress
                                          : 0,
                                      icon: Icons.delete_outline_rounded,
                                      label: l.deleteOverlay,
                                      color: palette.delete,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              SwipeSpacing.xxl,
              SwipeSpacing.xs,
              SwipeSpacing.xxl,
              SwipeSpacing.xs,
            ),
            child: SwipeActionBar(
              onUndo: widget.onUndo,
              onDelete: () => _accept(-1),
              onKeep: () => _accept(1),
            ),
          ),
          AnimatedSwitcher(
            duration: SwipeMotion.quick,
            child: Padding(
              key: ValueKey(_showHelperText),
              padding: const EdgeInsets.only(
                left: SwipeSpacing.lg,
                right: SwipeSpacing.lg,
                bottom: SwipeSpacing.md,
              ),
              child: Text(
                l.swipeHint,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: _showHelperText
                      ? palette.accent
                      : scheme.onSurfaceVariant,
                  fontWeight: _showHelperText
                      ? FontWeight.w900
                      : FontWeight.w700,
                  letterSpacing: _showHelperText ? 0.1 : 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewHeader extends StatelessWidget {
  const _ReviewHeader({
    required this.progressText,
    required this.progress,
    required this.pendingText,
    required this.pendingCount,
    required this.onSettings,
    required this.onPending,
  });

  final String progressText;
  final double progress;
  final String pendingText;
  final int pendingCount;
  final VoidCallback onSettings;
  final VoidCallback? onPending;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final palette = SwipePixPalette.of(context);
    return Column(
      children: [
        Row(
          children: [
            Text(
              l.appTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.35,
              ),
            ),
            const SizedBox(width: SwipeSpacing.md),
            Expanded(
              child: Text(
                progressText,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            _HeaderIconButton(
              onPressed: onSettings,
              tooltip: l.settings,
              icon: Icons.tune_rounded,
            ),
            const SizedBox(width: SwipeSpacing.xs),
            _PendingDeletionButton(
              count: pendingCount,
              tooltip: pendingText,
              onPressed: onPending,
            ),
          ],
        ),
        const SizedBox(height: 2),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 4,
            value: progress,
            backgroundColor: scheme.surfaceContainerHighest.withValues(
              alpha: 0.72,
            ),
            valueColor: AlwaysStoppedAnimation(palette.accent),
          ),
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.onPressed,
    required this.tooltip,
    required this.icon,
  });

  final VoidCallback onPressed;
  final String tooltip;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox.square(
      dimension: 40,
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        style: IconButton.styleFrom(
          backgroundColor: scheme.surfaceContainerLow.withValues(alpha: 0.86),
          foregroundColor: scheme.onSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SwipeRadius.chip),
          ),
        ),
        iconSize: 20,
        icon: Icon(icon),
      ),
    );
  }
}

class _PendingDeletionButton extends StatelessWidget {
  const _PendingDeletionButton({
    required this.count,
    required this.tooltip,
    required this.onPressed,
  });

  final int count;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = SwipePixPalette.of(context);
    final foreground = count > 0 ? Colors.white : scheme.onSurfaceVariant;
    final background = count > 0
        ? palette.delete.withValues(alpha: 0.92)
        : scheme.surfaceContainerLow.withValues(alpha: 0.86);
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(SwipeRadius.chip),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(SwipeRadius.chip),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: count > 0 ? SwipeSpacing.md : 10,
              vertical: 10,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.delete_outline_rounded, size: 20, color: foreground),
                if (count > 0) ...[
                  const SizedBox(width: SwipeSpacing.xs),
                  Text(
                    '$count',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SwipeActionBar extends StatelessWidget {
  const SwipeActionBar({
    super.key,
    required this.onUndo,
    required this.onDelete,
    required this.onKeep,
  });

  final VoidCallback? onUndo;
  final VoidCallback onDelete;
  final VoidCallback onKeep;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final palette = SwipePixPalette.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.glassStrong,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.14),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: scheme.brightness == Brightness.dark ? 0.34 : 0.12,
            ),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SwipeSpacing.sm,
          vertical: SwipeSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _CircleActionButton(
              size: 56,
              onPressed: onDelete,
              tooltip: l.deleteAction,
              icon: Icons.delete_outline_rounded,
              background: palette.delete,
              foreground: Colors.white,
            ),
            const SizedBox(width: SwipeSpacing.sm),
            _CircleActionButton(
              size: 44,
              onPressed: onUndo,
              tooltip: l.undo,
              icon: Icons.undo_rounded,
              background: scheme.surfaceContainerHigh.withValues(alpha: 0.9),
              foreground: scheme.onSurfaceVariant,
            ),
            const SizedBox(width: SwipeSpacing.sm),
            _CircleActionButton(
              size: 56,
              onPressed: onKeep,
              tooltip: l.keep,
              icon: Icons.check_rounded,
              background: palette.keep,
              foreground: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({
    required this.size,
    required this.onPressed,
    required this.tooltip,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final double size;
  final VoidCallback? onPressed;
  final String tooltip;
  final IconData icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedOpacity(
      duration: SwipeMotion.quick,
      opacity: onPressed == null ? 0.45 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: background.withValues(alpha: 0.28),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SizedBox.square(
          dimension: size,
          child: IconButton(
            onPressed: onPressed,
            tooltip: tooltip,
            style: IconButton.styleFrom(
              backgroundColor: background,
              foregroundColor: foreground,
              disabledBackgroundColor: scheme.surfaceContainerHighest,
              disabledForegroundColor: scheme.onSurfaceVariant.withValues(
                alpha: 0.4,
              ),
            ),
            iconSize: size >= 56 ? 27 : 22,
            icon: Icon(icon),
          ),
        ),
      ),
    );
  }
}

class _DecisionOverlay extends StatelessWidget {
  const _DecisionOverlay({
    required this.alignment,
    required this.visible,
    required this.progress,
    required this.icon,
    required this.label,
    required this.color,
  });

  final Alignment alignment;
  final bool visible;
  final double progress;
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    final intensity = Curves.easeOutCubic.transform(progress.clamp(0.0, 1.0));
    return Stack(
      fit: StackFit.expand,
      children: [
        Opacity(
          opacity: intensity * 0.22,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: alignment == Alignment.topLeft
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                end: alignment == Alignment.topLeft
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                colors: [Colors.transparent, color],
              ),
            ),
          ),
        ),
        Align(
          alignment: alignment,
          child: Padding(
            padding: const EdgeInsets.all(SwipeSpacing.xxl),
            child: Opacity(
              opacity: intensity,
              child: Transform.scale(
                scale: 0.86 + intensity * 0.16,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12 + intensity * 0.14),
                    border: Border.all(
                      color: color.withValues(alpha: 0.72 + intensity * 0.28),
                      width: 1.5 + intensity * 1.2,
                    ),
                    borderRadius: BorderRadius.circular(SwipeRadius.card),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.16 * intensity),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SwipeSpacing.md,
                      vertical: SwipeSpacing.sm,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, color: Colors.white, size: 24),
                        const SizedBox(width: SwipeSpacing.sm),
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PhotoCard extends ConsumerWidget {
  const _PhotoCard({
    required this.photo,
    this.showMetadata = true,
    this.isBackgroundCard = false,
  });

  final Photo photo;
  final bool showMetadata;
  final bool isBackgroundCard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final preview = ref.watch(photoPreviewProvider(photo.id));
    final date = MaterialLocalizations.of(
      context,
    ).formatMediumDate(photo.createdAt);
    final size = photo.sizeBytes == null
        ? null
        : _formatFileSize(photo.sizeBytes!);
    final metadata = size == null ? date : l.photoMetadata(date, size);
    final scheme = Theme.of(context).colorScheme;
    final palette = SwipePixPalette.of(context);
    return Semantics(
      label: '${l.photo} · $metadata',
      image: true,
      child: Material(
        elevation: isBackgroundCard ? 0 : 24,
        shadowColor: Colors.black.withValues(
          alpha: scheme.brightness == Brightness.dark ? 0.58 : 0.22,
        ),
        borderRadius: BorderRadius.circular(28),
        clipBehavior: Clip.antiAlias,
        child: ColoredBox(
          color: scheme.surfaceContainerHighest,
          child: Stack(
            fit: StackFit.expand,
            children: [
              preview.when(
                data: (bytes) => bytes == null
                    ? _PreviewUnavailable(message: l.previewUnavailable)
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.memory(
                            bytes,
                            fit: BoxFit.cover,
                            excludeFromSemantics: true,
                            opacity: const AlwaysStoppedAnimation(0.3),
                            errorBuilder: (_, _, _) => _PreviewUnavailable(
                              message: l.previewUnavailable,
                            ),
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.02),
                                  Colors.black.withValues(alpha: 0.24),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(isBackgroundCard ? 0 : 2),
                            child: Image.memory(
                              bytes,
                              fit: BoxFit.contain,
                              excludeFromSemantics: true,
                              errorBuilder: (_, _, _) => _PreviewUnavailable(
                                message: l.previewUnavailable,
                              ),
                            ),
                          ),
                        ],
                      ),
                error: (_, _) =>
                    _PreviewUnavailable(message: l.previewUnavailable),
                loading: () => Center(
                  child: SizedBox.square(
                    dimension: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.6,
                      color: palette.accent,
                    ),
                  ),
                ),
              ),
              if (showMetadata)
                Positioned(
                  left: SwipeSpacing.lg,
                  right: SwipeSpacing.lg,
                  bottom: SwipeSpacing.lg,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: palette.photoScrim,
                      borderRadius: BorderRadius.circular(SwipeRadius.control),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SwipeSpacing.md,
                        vertical: SwipeSpacing.sm,
                      ),
                      child: Text(
                        metadata,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
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

class _PreviewUnavailable extends StatelessWidget {
  const _PreviewUnavailable({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.broken_image_outlined,
            color: scheme.onSurfaceVariant,
            size: 34,
          ),
          const SizedBox(height: SwipeSpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
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

class _CompletedSession extends StatelessWidget {
  const _CompletedSession({
    required this.pendingCount,
    required this.onReview,
    required this.onUndo,
    required this.loadingNextBatch,
    required this.canLoadNext,
    required this.reviewedCount,
    required this.totalCount,
    required this.onLoadNext,
    required this.onBack,
  });

  final int pendingCount;
  final VoidCallback? onReview;
  final VoidCallback? onUndo;
  final bool loadingNextBatch;
  final bool canLoadNext;
  final int reviewedCount;
  final int totalCount;
  final Future<void> Function()? onLoadNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(28),
          children: [
            Align(
              alignment: Alignment.center,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Icon(
                    Icons.task_alt,
                    size: 54,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l.sessionComplete,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              pendingCount == 0 ? l.nothingMarked : l.sessionCompleteBody,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l.cleanupProgressSummary(
                reviewedCount,
                totalCount - reviewedCount,
                pendingCount,
              ),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _CompletionStat(
                    icon: Icons.visibility_outlined,
                    value: '$reviewedCount',
                    label: l.reviewMarked,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _CompletionStat(
                    icon: Icons.delete_outline,
                    value: '$pendingCount',
                    label: l.mark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: loadingNextBatch || !canLoadNext ? null : onLoadNext,
              icon: loadingNextBatch
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_photo_alternate_outlined),
              label: Text(
                loadingNextBatch
                    ? l.loadingNextBatch
                    : canLoadNext
                    ? l.continueNextBatch
                    : l.noMorePhotos,
              ),
            ),
            const SizedBox(height: 8),
            if (onReview != null)
              FilledButton.icon(
                onPressed: onReview,
                icon: const Icon(Icons.fact_check_outlined),
                label: Text(l.reviewMarked),
              ),
            TextButton.icon(
              onPressed: onUndo,
              icon: const Icon(Icons.undo),
              label: Text(l.undo),
            ),
            TextButton(onPressed: onBack, child: Text(l.backToGallery)),
          ],
        ),
      ),
    );
  }
}

class _CompletionStat extends StatelessWidget {
  const _CompletionStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Icon(icon, color: scheme.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySession extends StatelessWidget {
  const _EmptySession({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Center(
      child: FilledButton(onPressed: onBack, child: Text(l.backToGallery)),
    );
  }
}
