import 'package:flutter/material.dart';

import '../../../app/design_system.dart';

class MediaVideoBadge extends StatelessWidget {
  const MediaVideoBadge({super.key, this.duration, this.prominent = false});

  final Duration? duration;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final text = duration == null || duration == Duration.zero
        ? null
        : formatDuration(duration!);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(SwipeRadius.chip),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: prominent ? 9 : 7,
          vertical: prominent ? 5 : 4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: prominent ? 16 : 14,
            ),
            if (text != null) ...[
              SizedBox(width: prominent ? 3 : 2),
              Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: prominent ? 12 : 11,
                  fontWeight: prominent ? FontWeight.w900 : FontWeight.w800,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String formatDuration(Duration duration) {
  final totalSeconds = duration.inSeconds;
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  final hours = minutes ~/ 60;
  if (hours > 0) {
    final remainingMinutes = minutes % 60;
    return '$hours:${remainingMinutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
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
