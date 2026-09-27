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
      'Start by connecting your library. Your photos and videos stay on your device; SwipePix never uploads them.';

  @override
  String get safety =>
      'You stay in control. Swiping only marks items. Deleting requires a separate review and confirmation.';

  @override
  String get connect => 'Explore my photos';

  @override
  String get gallery => 'Your library';

  @override
  String get libraryTitle => 'Library';

  @override
  String get recentPhotos => 'Recent media';

  @override
  String photoSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'No media yet',
    );
    return '$_temp0';
  }

  @override
  String get galleryHeroTitle => 'Ready to clean';

  @override
  String get permissionIntro =>
      'Allow access to view your library. You can share only the photos and videos you choose.';

  @override
  String get allow => 'Allow photo and video access';

  @override
  String get settings => 'Settings';

  @override
  String get openSettings => 'Open device settings';

  @override
  String get limited => 'Only selected photos and videos';

  @override
  String get authorized => 'Full photo and video access';

  @override
  String get denied =>
      'Photo and video access is denied. You can try again or change it in device settings.';

  @override
  String get restricted =>
      'Photo and video access is restricted by this device.';

  @override
  String get unsupported =>
      'Open SwipePix on Android or iOS to access your library.';

  @override
  String get manage => 'Change selected media';

  @override
  String get empty =>
      'No accessible photos or videos. If access is limited, try selecting more media.';

  @override
  String get error =>
      'Could not load your library. Check access and try again.';

  @override
  String get retry => 'Try again';

  @override
  String get refresh => 'Refresh library';

  @override
  String get more => 'Load more photos';

  @override
  String get loadingMorePhotos => 'Loading more media…';

  @override
  String get readOnly =>
      'Swiping only marks items; deletion always requires review and confirmation.';

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
  String get allPhotos => 'All media';

  @override
  String get largePhotos => 'Large files';

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
      other: '$count items',
      one: '1 item',
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
    return 'You will review the $count loaded items.';
  }

  @override
  String get cleanupTitle => 'Review media';

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
      'Review the marked items before deciding whether to delete them.';

  @override
  String get nothingMarked => 'You did not mark anything for deletion.';

  @override
  String get continueNextBatch => 'Continue with the next batch';

  @override
  String get loadingNextBatch => 'Looking for more media…';

  @override
  String get noMorePhotos => 'There are no new items left to review';

  @override
  String get backToGallery => 'Back to library';

  @override
  String get deleteReviewTitle => 'Review before deleting';

  @override
  String get deleteReviewSafety =>
      'These items have not been deleted yet. Remove anything you want to keep.';

  @override
  String get removeFromDelete => 'Keep this item';

  @override
  String get deleteSelected => 'Delete selected items';

  @override
  String deleteReviewedPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete $count reviewed items',
      one: 'Delete 1 reviewed item',
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
      other: '$count items',
      one: '1 item',
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
      other: '$count items were deleted',
      one: '1 item was deleted',
    );
    return '$_temp0.';
  }

  @override
  String get deletePartial =>
      'Some items were not deleted or confirmation was canceled. They remain in the list.';

  @override
  String get deleteAccessLost =>
      'Could not delete. Check library access and try again.';

  @override
  String get previewUnavailable => 'This item could not be loaded.';

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
  String get restoringSession => 'Checking media…';

  @override
  String get sessionUnavailable =>
      'Could not restore the session. Check library access.';

  @override
  String get startNewCleanup => 'Start a new cleanup';

  @override
  String get replaceSessionTitle => 'Replace the saved session?';

  @override
  String get replaceSessionBody =>
      'Progress and marked items from the previous session will be lost. Nothing will be deleted.';

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
      'SwipePix helps you review your photo and video library quickly and safely. Media stays on your device, and swiping only marks items for review. Nothing is deleted until you confirm it.';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicyBody =>
      'SwipePix is designed as a local photo and video review tool. The app requests access to your media library only to show photos and videos, create review sessions, calculate file-size metadata when available, and ask the device operating system to delete selected items after you confirm.\n\nPhotos and videos are not uploaded by SwipePix. SwipePix does not sell or share your photos or videos. SwipePix does not use advertising SDKs, analytics SDKs, tracking pixels, crash-reporting SDKs, accounts, or cloud storage in the current production app.\n\nData stored on this device may include your language, appearance, sort preference, onboarding state, cleanup-session progress, media identifiers needed to resume a session, and limited metadata such as dates, durations, or file sizes. This data is stored locally through the device app storage and is used only for app functionality.\n\nPlatform services may process your media library permission, selected-media access, and deletion confirmation according to Apple or Google/Android system behavior. If your device uses services such as iCloud Photos or Google Photos, those services are controlled by the device/account provider, not by SwipePix.\n\nSwipePix does not knowingly collect personal information from children and is not directed to children.\n\nPrivacy choices: you can revoke or limit media access in the device settings. You can remove local app data by deleting the app from your device. If the app later adds analytics, accounts, cloud sync, ads, payments, or any off-device processing, this policy and the store privacy disclosures must be updated before release.\n\nContact: use the developer contact listed on the App Store or Google Play listing. Before public release, replace this sentence with the legal entity name and a dedicated privacy contact email.';

  @override
  String get termsConditions => 'Terms & Conditions';

  @override
  String get termsConditionsBody =>
      'These Terms govern your use of SwipePix. If you do not agree, do not use the app.\n\nService. SwipePix helps you review photos and videos on your own device. Swiping left only marks an item for deletion review. Items are not deleted until you review the marked items and ask the device operating system to delete them. The system may show an additional confirmation.\n\nYour responsibility. You are responsible for deciding which photos or videos to keep or delete and for maintaining backups of important media before using cleanup features. SwipePix cannot guarantee recovery of media after the operating system completes deletion.\n\nNo professional advice. SwipePix is provided as a utility tool and does not provide legal, storage-management, archival, security, or professional advice.\n\nAcceptable use. You may use SwipePix only for lawful purposes and only with photos and videos you have the right to access and manage. You may not attempt to reverse engineer, abuse, disrupt, or misuse the app or related services.\n\nPrivacy. The Privacy Policy explains what data is processed and stored. In the current production app, SwipePix is intended to process photos and videos locally and not upload, sell, or share them.\n\nDisclaimer. SwipePix is provided “as is” and “as available,” without warranties of any kind to the fullest extent permitted by law. We do not warrant that the app will be uninterrupted, error-free, or compatible with every device, library configuration, or operating-system version.\n\nLimitation of liability. To the fullest extent permitted by law, SwipePix and its developer will not be liable for indirect, incidental, special, consequential, exemplary, or punitive damages, or for lost data, lost media, lost profits, or business interruption arising from or related to your use of the app.\n\nArbitration & Class Action Waiver. Any dispute, claim, or controversy arising out of or relating to these Terms or SwipePix will be resolved by final and binding individual arbitration, rather than in court, except that either party may bring an individual claim in small claims court if it qualifies. You and SwipePix waive any right to a jury trial and any right to participate in a class, collective, consolidated, private attorney general, or representative action. The arbitration will be administered by the American Arbitration Association (AAA) under its applicable consumer arbitration rules unless the parties agree otherwise. The arbitrator may award relief only on an individual basis. This section does not prevent either party from seeking injunctive or equitable relief for misuse of intellectual property or unauthorized access.\n\nChanges. These Terms may be updated before or after release. If a material change is made, update the in-app notice and public Terms page.';

  @override
  String get legalUpdated => 'Last updated: September 25, 2026';

  @override
  String get video => 'Video';

  @override
  String get media => 'Media';

  @override
  String videoDuration(String duration) {
    return '$duration';
  }
}
