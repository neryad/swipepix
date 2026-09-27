import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../../app/design_system.dart';
import '../../../l10n/app_localizations.dart';
import '../application/gallery_controller.dart';
import '../domain/gallery_repository.dart';
import 'media_widgets.dart';

Future<void> showMediaVideoPreview(
  BuildContext context,
  MediaAsset media,
) async {
  if (!media.isVideo) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => MediaVideoPreviewSheet(media: media),
  );
}

class MediaVideoPreviewSheet extends ConsumerWidget {
  const MediaVideoPreviewSheet({super.key, required this.media});

  final MediaAsset media;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final file = ref.watch(mediaFileProvider(media.id));
    return Padding(
      padding: const EdgeInsets.all(SwipeSpacing.md),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.22),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  SwipeSpacing.lg,
                  SwipeSpacing.md,
                  SwipeSpacing.sm,
                  SwipeSpacing.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l.videoPreviewTitle,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ),
                    MediaVideoBadge(duration: media.duration),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: AspectRatio(
                  aspectRatio: 9 / 16,
                  child: ColoredBox(
                    color: Colors.black,
                    child: file.when(
                      data: (value) => value == null
                          ? _VideoMessage(text: l.videoPreviewUnavailable)
                          : _LocalVideoPlayer(file: value),
                      error: (_, _) =>
                          _VideoMessage(text: l.videoPreviewUnavailable),
                      loading: () =>
                          _VideoMessage(text: l.loadingVideo, loading: true),
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

class _VideoMessage extends StatelessWidget {
  const _VideoMessage({required this.text, this.loading = false});

  final String text;
  final bool loading;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (loading)
          const CircularProgressIndicator(color: Colors.white)
        else
          const Icon(
            Icons.smart_display_outlined,
            color: Colors.white,
            size: 42,
          ),
        const SizedBox(height: SwipeSpacing.md),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _LocalVideoPlayer extends StatefulWidget {
  const _LocalVideoPlayer({required this.file});

  final File file;

  @override
  State<_LocalVideoPlayer> createState() => _LocalVideoPlayerState();
}

class _LocalVideoPlayerState extends State<_LocalVideoPlayer> {
  late final VideoPlayerController _controller;
  late final Future<void> _initialize;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file);
    _initialize = _controller.initialize().then((_) async {
      await _controller.setLooping(true);
      await _controller.play();
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return FutureBuilder<void>(
      future: _initialize,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _VideoMessage(text: l.loadingVideo, loading: true);
        }
        if (snapshot.hasError || !_controller.value.isInitialized) {
          return _VideoMessage(text: l.videoPreviewUnavailable);
        }
        return GestureDetector(
          onTap: () {
            setState(() {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            });
          },
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              ),
              if (!_controller.value.isPlaying)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.28),
                    shape: BoxShape.circle,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(18),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 54,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
