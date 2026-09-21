import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';
import 'design_system.dart';
import '../l10n/app_localizations.dart';
import '../features/settings/application/preferences.dart';
import '../features/settings/presentation/legal_info_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/onboarding/presentation/welcome_screen.dart';
import '../features/gallery/presentation/gallery_screen.dart';
import '../features/gallery/presentation/album_screen.dart';
import '../features/cleanup/presentation/cleanup_screen.dart';
import '../features/cleanup/presentation/delete_review_screen.dart';
import '../features/onboarding/application/onboarding_controller.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: ref.read(onboardingProvider)
        ? AppRoutes.gallery
        : AppRoutes.onboardingRoot,
    routes: [
      GoRoute(
        path: AppRoutes.onboardingRoot,
        builder: (_, _) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, _) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.gallery,
        builder: (_, _) => const GalleryScreen(),
      ),
      GoRoute(path: AppRoutes.albums, builder: (_, _) => const AlbumsScreen()),
      GoRoute(
        path: AppRoutes.album,
        builder: (_, state) =>
            AlbumScreen(albumId: state.pathParameters['albumId']!),
      ),
      GoRoute(
        path: AppRoutes.cleanup,
        builder: (_, _) => const CleanupScreen(),
      ),
      GoRoute(
        path: AppRoutes.cleanupReview,
        builder: (_, _) => const DeleteReviewScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, _) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsAbout,
        builder: (_, _) => const AboutSwipePixScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsPrivacy,
        builder: (_, _) => const LegalInfoScreen(type: LegalInfoType.privacy),
      ),
      GoRoute(
        path: AppRoutes.settingsTerms,
        builder: (_, _) => const LegalInfoScreen(type: LegalInfoType.terms),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

class SwipePixApp extends ConsumerWidget {
  const SwipePixApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    title: 'SwipePix',
    debugShowCheckedModeBanner: false,
    routerConfig: ref.watch(routerProvider),
    locale: ref.watch(localeProvider),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    themeMode: ref.watch(themeProvider),
    theme: _theme(Brightness.light),
    darkTheme: _theme(Brightness.dark),
  );
  ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final palette = SwipePixPalette.fromBrightness(brightness);
    final scheme = ColorScheme.fromSeed(
      seedColor: palette.accent,
      brightness: brightness,
      primary: const Color(0xff2bb99e),
      surface: dark ? const Color(0xff061010) : const Color(0xfff8faf7),
      error: palette.delete,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      extensions: [palette],
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 21,
          letterSpacing: -0.4,
          fontWeight: FontWeight.w900,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: dark ? const Color(0xff0c1717) : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SwipeRadius.card),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: dark
            ? const Color(0xff121d1d)
            : const Color(0xffeef2ee),
        selectedColor: palette.accentLow,
        disabledColor: scheme.surfaceContainerHighest,
        labelStyle: TextStyle(
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
        secondaryLabelStyle: TextStyle(
          color: scheme.onSurface,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: IconThemeData(color: scheme.onSurface, size: 18),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.42)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SwipeRadius.control),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.accent,
          foregroundColor: const Color(0xff05201b),
          minimumSize: const Size.fromHeight(46),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SwipeRadius.control),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(44),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SwipeRadius.control),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
