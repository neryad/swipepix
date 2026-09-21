abstract final class AppRoutes {
  static const onboardingRoot = '/';
  static const onboarding = '/onboarding';
  static const gallery = '/gallery';
  static const albums = '/albums';
  static const album = '/album/:albumId';
  static const cleanup = '/cleanup';
  static const cleanupReview = '/cleanup/review';
  static const settings = '/settings';
  static const settingsAbout = '/settings/about';
  static const settingsPrivacy = '/settings/privacy';
  static const settingsTerms = '/settings/terms';

  static String albumDetails(String albumId) =>
      '/album/${Uri.encodeComponent(albumId)}';
}
