import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipepix/app/app.dart';
import 'package:swipepix/features/gallery/application/gallery_controller.dart';
import 'package:swipepix/features/gallery/domain/gallery_repository.dart';
import 'package:swipepix/features/settings/application/preferences.dart';
import 'package:swipepix/features/cleanup/application/cleanup_controller.dart';
import 'package:swipepix/core/data/local_store.dart';
import 'package:swipepix/features/onboarding/application/onboarding_controller.dart';
import 'gallery_controller_test.dart' show FakeGallery;

void main() {
  testWidgets('Spanish onboarding, navigation and denied access recovery', (
    tester,
  ) async {
    final repo = FakeGallery()..permission = GalleryAccess.denied;
    final container = ProviderContainer(
      overrides: [galleryRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    container.read(localeProvider.notifier).select(const Locale('es'));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const SwipePixApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Haz espacio para lo que importa'), findsOneWidget);
    expect(repo.requests, 0);
    await tester.scrollUntilVisible(find.text('Explorar mis fotos'), 200);
    await tester.tap(find.text('Explorar mis fotos'));
    await tester.pumpAndSettle();
    expect(find.text('Abrir ajustes del dispositivo'), findsOneWidget);
    expect(repo.reads, 0);
    await tester.tap(find.text('Permitir acceso a fotos'));
    await tester.pumpAndSettle();
    expect(repo.requests, 1);
    container.read(localeProvider.notifier).select(const Locale('en'));
    container.read(themeProvider.notifier).select(ThemeMode.dark);
    await tester.pumpAndSettle();
    expect(find.text('SwipePix'), findsOneWidget);
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('limited empty library offers selection recovery', (
    tester,
  ) async {
    final repo = FakeGallery()
      ..permission = GalleryAccess.limited
      ..fetch = (_) async => [];
    final container = ProviderContainer(
      overrides: [galleryRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    container.read(localeProvider.notifier).select(const Locale('en'));
    container.read(routerProvider).go('/gallery');
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const SwipePixApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Change selected photos'), findsOneWidget);
    expect(find.textContaining('No accessible photos.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('gallery sort selector changes the requested order', (
    tester,
  ) async {
    final repo = FakeGallery();
    final container = ProviderContainer(
      overrides: [galleryRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    container.read(localeProvider.notifier).select(const Locale('en'));
    container.read(routerProvider).go('/gallery');
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const SwipePixApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Recent photos'), findsOneWidget);
    expect(find.text('Cleanup session'), findsNothing);

    await tester.tap(find.byTooltip('Sort by'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Oldest first').last);
    await tester.pumpAndSettle();

    expect(container.read(galleryProvider).sort, GallerySort.oldest);
    expect(repo.requestedSorts.last, GallerySort.oldest);
  });

  testWidgets('gallery automatically loads another page near the end', (
    tester,
  ) async {
    final repo = FakeGallery()
      ..fetch = (page) async => page == 0
          ? List.generate(
              GalleryController.pageSize,
              (index) => Photo(id: '$index', createdAt: DateTime(2026)),
            )
          : [Photo(id: '60', createdAt: DateTime(2026))];
    final container = ProviderContainer(
      overrides: [galleryRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    container.read(localeProvider.notifier).select(const Locale('en'));
    container.read(routerProvider).go('/gallery');
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const SwipePixApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(repo.reads, 1);

    await tester.fling(
      find.byType(CustomScrollView),
      const Offset(0, -10000),
      2000,
    );
    await tester.pumpAndSettle();

    expect(repo.reads, 2);
    expect(container.read(galleryProvider).photos, hasLength(61));
  });

  testWidgets('settings can reopen onboarding after it was completed', (
    tester,
  ) async {
    final store = MemoryLocalStore();
    await store.setBool(LocalStoreKeys.onboardingComplete, true);
    await store.setString(LocalStoreKeys.locale, 'en');
    final repo = FakeGallery();
    final container = ProviderContainer(
      overrides: [
        localStoreProvider.overrideWithValue(store),
        galleryRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const SwipePixApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View introduction'));
    await tester.pumpAndSettle();

    expect(find.text('Make room for what matters'), findsOneWidget);
    expect(find.text('Explore my photos'), findsOneWidget);
  });

  testWidgets('completed onboarding opens gallery and resumes saved cleanup', (
    tester,
  ) async {
    final store = MemoryLocalStore();
    final repo = FakeGallery();
    final seed = ProviderContainer(
      overrides: [
        localStoreProvider.overrideWithValue(store),
        galleryRepositoryProvider.overrideWithValue(repo),
      ],
    );
    seed.read(onboardingProvider.notifier).complete();
    final seedCleanup = seed.read(cleanupProvider.notifier);
    seedCleanup.start([
      Photo(id: 'one', createdAt: DateTime(2026, 1, 1)),
      Photo(id: 'two', createdAt: DateTime(2026, 1, 2)),
    ]);
    seedCleanup.markForDeletion();
    await seedCleanup.flushPersistence();
    seed.dispose();

    final container = ProviderContainer(
      overrides: [
        localStoreProvider.overrideWithValue(store),
        galleryRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const SwipePixApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('SwipePix'), findsOneWidget);
    expect(find.text('Make room for what matters'), findsNothing);
    await tester.tap(find.text('Continue cleanup'));
    await tester.pumpAndSettle();

    expect(find.text('SwipePix'), findsOneWidget);
    expect(container.read(cleanupProvider).current?.id, 'two');
  });

  testWidgets('swipe flow marks, reviews, and deletes after review action', (
    tester,
  ) async {
    final repo = FakeGallery()
      ..fetch = (_) async => [
        Photo(id: 'one', createdAt: DateTime(2026, 1, 1)),
        Photo(id: 'two', createdAt: DateTime(2026, 1, 2)),
      ];
    final container = ProviderContainer(
      overrides: [galleryRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    container.read(localeProvider.notifier).select(const Locale('en'));
    container.read(routerProvider).go('/gallery');
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const SwipePixApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start reviewing'));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const ValueKey('active-photo-one')),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();
    expect(container.read(cleanupProvider).pendingDeletion, {'one'});
    expect(repo.deleteCalls, 0);
    await tester.tap(find.byTooltip('1 marked'));
    await tester.pumpAndSettle();
    expect(find.text('Review before deleting'), findsOneWidget);
    expect(find.text('Delete permanently?'), findsNothing);
    expect(repo.deleteCalls, 0);
    await tester.tap(find.text('Delete 1 reviewed photo'));
    await tester.pumpAndSettle();
    expect(repo.deleteCalls, 1);
    expect(container.read(cleanupProvider).pendingDeletion, isEmpty);
    expect(container.read(cleanupProvider).current?.id, 'two');
    expect(find.text('SwipePix'), findsOneWidget);
  });
}
