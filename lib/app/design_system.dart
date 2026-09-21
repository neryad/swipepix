import 'package:flutter/material.dart';

@immutable
class SwipePixPalette extends ThemeExtension<SwipePixPalette> {
  const SwipePixPalette({
    required this.accent,
    required this.accentHigh,
    required this.accentLow,
    required this.keep,
    required this.delete,
    required this.glass,
    required this.glassStrong,
    required this.photoScrim,
  });

  final Color accent;
  final Color accentHigh;
  final Color accentLow;
  final Color keep;
  final Color delete;
  final Color glass;
  final Color glassStrong;
  final Color photoScrim;

  static SwipePixPalette of(BuildContext context) =>
      Theme.of(context).extension<SwipePixPalette>()!;

  static SwipePixPalette fromBrightness(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return SwipePixPalette(
      accent: const Color(0xff70e4ca),
      accentHigh: const Color(0xff9cf4df),
      accentLow: dark ? const Color(0xff10362f) : const Color(0xffd8f7ef),
      keep: const Color(0xff11b981),
      delete: const Color(0xfff43f3f),
      glass: dark
          ? const Color(0x141be0c2)
          : const Color(0xffffffff).withValues(alpha: 0.78),
      glassStrong: dark
          ? const Color(0x1fffffff)
          : const Color(0xffffffff).withValues(alpha: 0.92),
      photoScrim: Colors.black.withValues(alpha: 0.62),
    );
  }

  @override
  SwipePixPalette copyWith({
    Color? accent,
    Color? accentHigh,
    Color? accentLow,
    Color? keep,
    Color? delete,
    Color? glass,
    Color? glassStrong,
    Color? photoScrim,
  }) => SwipePixPalette(
    accent: accent ?? this.accent,
    accentHigh: accentHigh ?? this.accentHigh,
    accentLow: accentLow ?? this.accentLow,
    keep: keep ?? this.keep,
    delete: delete ?? this.delete,
    glass: glass ?? this.glass,
    glassStrong: glassStrong ?? this.glassStrong,
    photoScrim: photoScrim ?? this.photoScrim,
  );

  @override
  SwipePixPalette lerp(ThemeExtension<SwipePixPalette>? other, double t) {
    if (other is! SwipePixPalette) return this;
    return SwipePixPalette(
      accent: Color.lerp(accent, other.accent, t)!,
      accentHigh: Color.lerp(accentHigh, other.accentHigh, t)!,
      accentLow: Color.lerp(accentLow, other.accentLow, t)!,
      keep: Color.lerp(keep, other.keep, t)!,
      delete: Color.lerp(delete, other.delete, t)!,
      glass: Color.lerp(glass, other.glass, t)!,
      glassStrong: Color.lerp(glassStrong, other.glassStrong, t)!,
      photoScrim: Color.lerp(photoScrim, other.photoScrim, t)!,
    );
  }
}

abstract final class SwipeSpacing {
  static const double xxs = 4;
  static const double xs = 6;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
}

abstract final class SwipeRadius {
  static const double chip = 14;
  static const double control = 16;
  static const double tile = 18;
  static const double card = 22;
  static const double sheet = 28;
}

abstract final class SwipeMotion {
  static const Duration quick = Duration(milliseconds: 160);
  static const Duration regular = Duration(milliseconds: 240);
  static const Curve ease = Curves.easeOutCubic;
}
