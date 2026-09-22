// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SwipePix';

  @override
  String get welcome => 'Make room for what matters';

  @override
  String get intro =>
      'Start by connecting your photo library. Your photos stay on your device; SwipePix never uploads them.';

  @override
  String get safety =>
      'You stay in control. Swiping will only mark photos. Deletion will require a separate review and confirmation.';

  @override
  String get connect => 'Explore my photos';

  @override
  String get gallery => 'Your photo library';

  @override
  String get libraryTitle => 'Library';

  @override
  String get recentPhotos => 'Recent photos';

  @override
  String photoSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos',
      one: '1 photo',
      zero: 'No photos yet',
    );
    return '$_temp0';
  }

  @override
  String get galleryHeroTitle => 'Ready to clean';

  @override
  String get permissionIntro =>
      'Allow photo access to see your library. You can grant access to selected photos only.';

  @override
  String get allow => 'Allow photo access';

  @override
  String get settings => 'Settings';

  @override
  String get openSettings => 'Open device settings';

  @override
  String get limited => 'Selected photos only';

  @override
  String get authorized => 'Full photo access';

  @override
  String get denied =>
      'Photo access is denied. You can try again or change it in device settings.';

  @override
  String get restricted => 'Photo access is restricted by this device.';

  @override
  String get unsupported =>
      'Open SwipePix on Android or iOS to access your photos.';

  @override
  String get manage => 'Change selected photos';

  @override
  String get empty =>
      'No accessible photos. If access is limited, try selecting more photos.';

  @override
  String get error => 'Could not load your photos. Check access and try again.';

  @override
  String get retry => 'Try again';

  @override
  String get refresh => 'Refresh library';

  @override
  String get more => 'Load more photos';

  @override
  String get loadingMorePhotos => 'Loading more photos…';

  @override
  String get readOnly =>
      'Swiping only marks photos; deletion always requires review and confirmation.';

  @override
  String get language => 'Language';

  @override
  String get system => 'System default';

  @override
  String get theme => 'Appearance';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get thumbnailError => 'Preview unavailable';

  @override
  String get photo => 'Photo';

  @override
  String get sessionSettings => 'These preferences are saved on this device.';

  @override
  String get startCleanup => 'Start reviewing';

  @override
  String get quickCleanup => 'Quick cleanup';

  @override
  String get allPhotos => 'All';

  @override
  String get largePhotos => 'Large';

  @override
  String get oldestPhotos => 'Oldest';

  @override
  String get albums => 'Albums';

  @override
  String get chooseWhatToClean => 'Choose what to clean';

  @override
  String get seeAll => 'See all';

  @override
  String albumPhotoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos',
      one: '1 photo',
    );
    return '$_temp0';
  }

  @override
  String get noAlbums => 'Albums will appear here when the device shares them.';

  @override
  String get albumNotFound => 'This album is no longer available.';

  @override
  String get startAlbumCleanup => 'Start cleanup in this album';

  @override
  String reviewedShort(int current, int total) {
    return '$current of $total reviewed';
  }

  @override
  String loadedSessionCount(int count) {
    return 'You will review the $count loaded photos.';
  }

  @override
  String get cleanupTitle => 'Review photos';

  @override
  String get swipeHint => 'Swipe left to delete · right to keep';

  @override
  String get mark => 'Mark';

  @override
  String get keep => 'Keep';

  @override
  String get deleteAction => 'Delete';

  @override
  String get deleteOverlay => 'DELETE';

  @override
  String get keepOverlay => 'KEEP';

  @override
  String photoMetadata(String date, String size) {
    return '$date  •  $size';
  }

  @override
  String get undo => 'Undo';

  @override
  String reviewProgress(int current, int total) {
    return '$current of $total';
  }

  @override
  String cleanupProgressSummary(int reviewed, int remaining, int marked) {
    return 'Reviewed: $reviewed · Remaining: $remaining · Marked: $marked';
  }

  @override
  String markedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count marked',
      one: '1 marked',
      zero: 'None marked',
    );
    return '$_temp0';
  }

  @override
  String get reviewMarked => 'Review marked photos';

  @override
  String get sessionComplete => 'You finished this round';

  @override
  String get sessionCompleteBody =>
      'Review the marked photos before deciding whether to delete them.';

  @override
  String get nothingMarked => 'You did not mark any photos for deletion.';

  @override
  String get continueNextBatch => 'Continue with the next batch';

  @override
  String get loadingNextBatch => 'Looking for more photos…';

  @override
  String get noMorePhotos => 'There are no new photos left to review';

  @override
  String get backToGallery => 'Back to library';

  @override
  String get deleteReviewTitle => 'Review before deleting';

  @override
  String get deleteReviewSafety =>
      'These photos have not been deleted yet. Remove any photo you want to keep.';

  @override
  String get removeFromDelete => 'Keep this photo';

  @override
  String get deleteSelected => 'Delete selected photos';

  @override
  String deleteReviewedPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete $count reviewed photos',
      one: 'Delete 1 reviewed photo',
    );
    return '$_temp0';
  }

  @override
  String get deleting => 'Waiting for system confirmation…';

  @override
  String get confirmDeleteTitle => 'Delete permanently?';

  @override
  String confirmDeleteBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos',
      one: '1 photo',
    );
    return 'SwipePix will request deletion of $_temp0 from the device. The system may ask for another confirmation.';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get confirmDelete => 'Confirm deletion';

  @override
  String deleteSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos were deleted',
      one: '1 photo was deleted',
    );
    return '$_temp0.';
  }

  @override
  String get deletePartial =>
      'Some photos were not deleted or confirmation was canceled. They remain in the list.';

  @override
  String get deleteAccessLost =>
      'Could not delete. Check photo access and try again.';

  @override
  String get previewUnavailable => 'This photo could not be loaded.';

  @override
  String get sortBy => 'Sort by';

  @override
  String get newestFirst => 'Newest first';

  @override
  String get oldestFirst => 'Oldest first';

  @override
  String get largestFirst => 'Largest first';

  @override
  String get calculatingSizes => 'Calculating library sizes…';

  @override
  String get continueCleanup => 'Continue cleanup';

  @override
  String continueCleanupDetail(int current, int total) {
    return 'Saved progress: $current of $total';
  }

  @override
  String get restoringSession => 'Checking photos…';

  @override
  String get sessionUnavailable =>
      'Could not restore the session. Check photo access.';

  @override
  String get startNewCleanup => 'Start a new cleanup';

  @override
  String get replaceSessionTitle => 'Replace the saved session?';

  @override
  String get replaceSessionBody =>
      'Progress and marked photos from the previous session will be lost. No photos will be deleted.';

  @override
  String get viewIntroduction => 'View introduction';

  @override
  String get savedCleanupTitle => 'Cleanup session';

  @override
  String get noSavedCleanup =>
      'There is no cleanup in progress. Start a new one to save your progress.';

  @override
  String get youWillFree => 'You\'ll free approximately:';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get swipeToOrganize => 'Swipe to organize';

  @override
  String get skip => 'Skip';

  @override
  String get aboutSwipePix => 'About SwipePix';

  @override
  String get aboutSwipePixBody =>
      'SwipePix helps you review your photo library quickly and safely. Photos stay on your device, and swiping only marks photos for review. Nothing is deleted until you confirm it.';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicyBody =>
      'SwipePix requests access to your photo library only to show photos, organize review sessions, and request deletion from the device when you confirm. SwipePix does not upload, sell, or share your photos. Your review progress and preferences are stored locally on this device.';

  @override
  String get termsConditions => 'Terms & Conditions';

  @override
  String get termsConditionsBody =>
      'SwipePix is provided to help you review and manage your own photos. You are responsible for confirming which photos should be deleted. Deletion requests are handled by the device system and may require an additional confirmation.';

  @override
  String get legalUpdated => 'Last updated: September 21, 2026';
}
