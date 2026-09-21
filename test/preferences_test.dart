import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipepix/core/data/local_store.dart';
import 'package:swipepix/features/gallery/application/gallery_controller.dart';
import 'package:swipepix/features/gallery/domain/gallery_repository.dart';
import 'package:swipepix/features/onboarding/application/onboarding_controller.dart';
import 'package:swipepix/features/settings/application/preferences.dart';

import 'gallery_controller_test.dart' show FakeGallery;

void main() {
  test(
    'onboarding, language, theme, and sort survive a new container',
    () async {
      final store = MemoryLocalStore();
      final repository = FakeGallery();
      final first = ProviderContainer(
        overrides: [
          localStoreProvider.overrideWithValue(store),
          galleryRepositoryProvider.overrideWithValue(repository),
        ],
      );
      first.read(onboardingProvider.notifier).complete();
      first.read(localeProvider.notifier).select(const Locale('es'));
      first.read(themeProvider.notifier).select(ThemeMode.dark);
      await first.read(galleryProvider.notifier).selectSort(GallerySort.oldest);
      await Future<void>.delayed(Duration.zero);
      first.dispose();

      final second = ProviderContainer(
        overrides: [
          localStoreProvider.overrideWithValue(store),
          galleryRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(second.dispose);

      expect(second.read(onboardingProvider), isTrue);
      expect(second.read(localeProvider)?.languageCode, 'es');
      expect(second.read(themeProvider), ThemeMode.dark);
      expect(second.read(galleryProvider).sort, GallerySort.oldest);
    },
  );
}
