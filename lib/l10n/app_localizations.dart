import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SwipePix'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Make room for what matters'**
  String get welcome;

  /// No description provided for @intro.
  ///
  /// In en, this message translates to:
  /// **'Start by connecting your library. Your photos and videos stay on your device; SwipePix never uploads them.'**
  String get intro;

  /// No description provided for @safety.
  ///
  /// In en, this message translates to:
  /// **'You stay in control. Swiping only marks items. Deleting requires a separate review and confirmation.'**
  String get safety;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Explore my photos'**
  String get connect;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Your library'**
  String get gallery;

  /// No description provided for @libraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryTitle;

  /// No description provided for @recentPhotos.
  ///
  /// In en, this message translates to:
  /// **'Recent media'**
  String get recentPhotos;

  /// No description provided for @photoSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No media yet} =1{1 item} other{{count} items}}'**
  String photoSummary(int count);

  /// No description provided for @galleryHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to clean'**
  String get galleryHeroTitle;

  /// No description provided for @permissionIntro.
  ///
  /// In en, this message translates to:
  /// **'Allow access to view your library. You can share only the photos and videos you choose.'**
  String get permissionIntro;

  /// No description provided for @allow.
  ///
  /// In en, this message translates to:
  /// **'Allow photo and video access'**
  String get allow;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open device settings'**
  String get openSettings;

  /// No description provided for @limited.
  ///
  /// In en, this message translates to:
  /// **'Only selected photos and videos'**
  String get limited;

  /// No description provided for @authorized.
  ///
  /// In en, this message translates to:
  /// **'Full photo and video access'**
  String get authorized;

  /// No description provided for @denied.
  ///
  /// In en, this message translates to:
  /// **'Photo and video access is denied. You can try again or change it in device settings.'**
  String get denied;

  /// No description provided for @restricted.
  ///
  /// In en, this message translates to:
  /// **'Photo and video access is restricted by this device.'**
  String get restricted;

  /// No description provided for @unsupported.
  ///
  /// In en, this message translates to:
  /// **'Open SwipePix on Android or iOS to access your library.'**
  String get unsupported;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Change selected media'**
  String get manage;

  /// No description provided for @empty.
  ///
  /// In en, this message translates to:
  /// **'No accessible photos or videos. If access is limited, try selecting more media.'**
  String get empty;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Could not load your library. Check access and try again.'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh library'**
  String get refresh;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'Load more photos'**
  String get more;

  /// No description provided for @loadingMorePhotos.
  ///
  /// In en, this message translates to:
  /// **'Loading more media…'**
  String get loadingMorePhotos;

  /// No description provided for @readOnly.
  ///
  /// In en, this message translates to:
  /// **'Swiping only marks items; deletion always requires review and confirmation.'**
  String get readOnly;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get system;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get theme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @thumbnailError.
  ///
  /// In en, this message translates to:
  /// **'Preview unavailable'**
  String get thumbnailError;

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// No description provided for @sessionSettings.
  ///
  /// In en, this message translates to:
  /// **'These preferences are saved on this device.'**
  String get sessionSettings;

  /// No description provided for @startCleanup.
  ///
  /// In en, this message translates to:
  /// **'Start reviewing'**
  String get startCleanup;

  /// No description provided for @quickCleanup.
  ///
  /// In en, this message translates to:
  /// **'Quick cleanup'**
  String get quickCleanup;

  /// No description provided for @allPhotos.
  ///
  /// In en, this message translates to:
  /// **'All media'**
  String get allPhotos;

  /// No description provided for @largePhotos.
  ///
  /// In en, this message translates to:
  /// **'Large files'**
  String get largePhotos;

  /// No description provided for @oldestPhotos.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get oldestPhotos;

  /// No description provided for @albums.
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get albums;

  /// No description provided for @chooseWhatToClean.
  ///
  /// In en, this message translates to:
  /// **'Choose what to clean'**
  String get chooseWhatToClean;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @albumPhotoCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String albumPhotoCount(int count);

  /// No description provided for @noAlbums.
  ///
  /// In en, this message translates to:
  /// **'Albums will appear here when the device shares them.'**
  String get noAlbums;

  /// No description provided for @albumNotFound.
  ///
  /// In en, this message translates to:
  /// **'This album is no longer available.'**
  String get albumNotFound;

  /// No description provided for @startAlbumCleanup.
  ///
  /// In en, this message translates to:
  /// **'Start cleanup in this album'**
  String get startAlbumCleanup;

  /// No description provided for @reviewedShort.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total} reviewed'**
  String reviewedShort(int current, int total);

  /// No description provided for @loadedSessionCount.
  ///
  /// In en, this message translates to:
  /// **'You will review the {count} loaded items.'**
  String loadedSessionCount(int count);

  /// No description provided for @cleanupTitle.
  ///
  /// In en, this message translates to:
  /// **'Review media'**
  String get cleanupTitle;

  /// No description provided for @swipeHint.
  ///
  /// In en, this message translates to:
  /// **'Swipe left to delete · right to keep'**
  String get swipeHint;

  /// No description provided for @mark.
  ///
  /// In en, this message translates to:
  /// **'Mark'**
  String get mark;

  /// No description provided for @keep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get keep;

  /// No description provided for @deleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// No description provided for @deleteOverlay.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get deleteOverlay;

  /// No description provided for @keepOverlay.
  ///
  /// In en, this message translates to:
  /// **'KEEP'**
  String get keepOverlay;

  /// No description provided for @photoMetadata.
  ///
  /// In en, this message translates to:
  /// **'{date}  •  {size}'**
  String photoMetadata(String date, String size);

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @reviewProgress.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String reviewProgress(int current, int total);

  /// No description provided for @cleanupProgressSummary.
  ///
  /// In en, this message translates to:
  /// **'Reviewed: {reviewed} · Remaining: {remaining} · Marked: {marked}'**
  String cleanupProgressSummary(int reviewed, int remaining, int marked);

  /// No description provided for @markedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{None marked} =1{1 marked} other{{count} marked}}'**
  String markedCount(int count);

  /// No description provided for @reviewMarked.
  ///
  /// In en, this message translates to:
  /// **'Review marked photos'**
  String get reviewMarked;

  /// No description provided for @sessionComplete.
  ///
  /// In en, this message translates to:
  /// **'You finished this round'**
  String get sessionComplete;

  /// No description provided for @sessionCompleteBody.
  ///
  /// In en, this message translates to:
  /// **'Review the marked items before deciding whether to delete them.'**
  String get sessionCompleteBody;

  /// No description provided for @nothingMarked.
  ///
  /// In en, this message translates to:
  /// **'You did not mark anything for deletion.'**
  String get nothingMarked;

  /// No description provided for @continueNextBatch.
  ///
  /// In en, this message translates to:
  /// **'Continue with the next batch'**
  String get continueNextBatch;

  /// No description provided for @loadingNextBatch.
  ///
  /// In en, this message translates to:
  /// **'Looking for more media…'**
  String get loadingNextBatch;

  /// No description provided for @noMorePhotos.
  ///
  /// In en, this message translates to:
  /// **'There are no new items left to review'**
  String get noMorePhotos;

  /// No description provided for @backToGallery.
  ///
  /// In en, this message translates to:
  /// **'Back to library'**
  String get backToGallery;

  /// No description provided for @deleteReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review before deleting'**
  String get deleteReviewTitle;

  /// No description provided for @deleteReviewSafety.
  ///
  /// In en, this message translates to:
  /// **'These items have not been deleted yet. Remove anything you want to keep.'**
  String get deleteReviewSafety;

  /// No description provided for @removeFromDelete.
  ///
  /// In en, this message translates to:
  /// **'Keep this item'**
  String get removeFromDelete;

  /// No description provided for @deleteSelected.
  ///
  /// In en, this message translates to:
  /// **'Delete selected items'**
  String get deleteSelected;

  /// No description provided for @deleteReviewedPhotos.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete 1 reviewed item} other{Delete {count} reviewed items}}'**
  String deleteReviewedPhotos(int count);

  /// No description provided for @deleting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for system confirmation…'**
  String get deleting;

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently?'**
  String get confirmDeleteTitle;

  /// No description provided for @confirmDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'SwipePix will request deletion of {count, plural, =1{1 item} other{{count} items}} from the device. The system may ask for another confirmation.'**
  String confirmDeleteBody(int count);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion'**
  String get confirmDelete;

  /// No description provided for @deleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item was deleted} other{{count} items were deleted}}.'**
  String deleteSuccess(int count);

  /// No description provided for @deletePartial.
  ///
  /// In en, this message translates to:
  /// **'Some items were not deleted or confirmation was canceled. They remain in the list.'**
  String get deletePartial;

  /// No description provided for @deleteAccessLost.
  ///
  /// In en, this message translates to:
  /// **'Could not delete. Check library access and try again.'**
  String get deleteAccessLost;

  /// No description provided for @previewUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This item could not be loaded.'**
  String get previewUnavailable;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @newestFirst.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get newestFirst;

  /// No description provided for @oldestFirst.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get oldestFirst;

  /// No description provided for @largestFirst.
  ///
  /// In en, this message translates to:
  /// **'Largest first'**
  String get largestFirst;

  /// No description provided for @calculatingSizes.
  ///
  /// In en, this message translates to:
  /// **'Calculating library sizes…'**
  String get calculatingSizes;

  /// No description provided for @continueCleanup.
  ///
  /// In en, this message translates to:
  /// **'Continue cleanup'**
  String get continueCleanup;

  /// No description provided for @continueCleanupDetail.
  ///
  /// In en, this message translates to:
  /// **'Saved progress: {current} of {total}'**
  String continueCleanupDetail(int current, int total);

  /// No description provided for @restoringSession.
  ///
  /// In en, this message translates to:
  /// **'Checking media…'**
  String get restoringSession;

  /// No description provided for @sessionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Could not restore the session. Check library access.'**
  String get sessionUnavailable;

  /// No description provided for @startNewCleanup.
  ///
  /// In en, this message translates to:
  /// **'Start a new cleanup'**
  String get startNewCleanup;

  /// No description provided for @replaceSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace the saved session?'**
  String get replaceSessionTitle;

  /// No description provided for @replaceSessionBody.
  ///
  /// In en, this message translates to:
  /// **'Progress and marked items from the previous session will be lost. Nothing will be deleted.'**
  String get replaceSessionBody;

  /// No description provided for @viewIntroduction.
  ///
  /// In en, this message translates to:
  /// **'View introduction'**
  String get viewIntroduction;

  /// No description provided for @savedCleanupTitle.
  ///
  /// In en, this message translates to:
  /// **'Cleanup session'**
  String get savedCleanupTitle;

  /// No description provided for @noSavedCleanup.
  ///
  /// In en, this message translates to:
  /// **'There is no cleanup in progress. Start a new one to save your progress.'**
  String get noSavedCleanup;

  /// No description provided for @youWillFree.
  ///
  /// In en, this message translates to:
  /// **'You\'ll free approximately:'**
  String get youWillFree;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @swipeToOrganize.
  ///
  /// In en, this message translates to:
  /// **'Swipe to organize'**
  String get swipeToOrganize;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @aboutSwipePix.
  ///
  /// In en, this message translates to:
  /// **'About SwipePix'**
  String get aboutSwipePix;

  /// No description provided for @aboutSwipePixBody.
  ///
  /// In en, this message translates to:
  /// **'SwipePix helps you review your photo and video library quickly and safely. Media stays on your device, and swiping only marks items for review. Nothing is deleted until you confirm it.'**
  String get aboutSwipePixBody;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicyBody.
  ///
  /// In en, this message translates to:
  /// **'SwipePix is designed as a local photo and video review tool. The app requests access to your media library only to show photos and videos, create review sessions, calculate file-size metadata when available, and ask the device operating system to delete selected items after you confirm.\n\nPhotos and videos are not uploaded by SwipePix. SwipePix does not sell or share your photos or videos. SwipePix does not use advertising SDKs, analytics SDKs, tracking pixels, crash-reporting SDKs, accounts, or cloud storage in the current production app.\n\nData stored on this device may include your language, appearance, sort preference, onboarding state, cleanup-session progress, media identifiers needed to resume a session, and limited metadata such as dates, durations, or file sizes. This data is stored locally through the device app storage and is used only for app functionality.\n\nPlatform services may process your media library permission, selected-media access, and deletion confirmation according to Apple or Google/Android system behavior. If your device uses services such as iCloud Photos or Google Photos, those services are controlled by the device/account provider, not by SwipePix.\n\nSwipePix does not knowingly collect personal information from children and is not directed to children.\n\nPrivacy choices: you can revoke or limit media access in the device settings. You can remove local app data by deleting the app from your device. If the app later adds analytics, accounts, cloud sync, ads, payments, or any off-device processing, this policy and the store privacy disclosures must be updated before release.\n\nContact: use the developer contact listed on the App Store or Google Play listing. Before public release, replace this sentence with the legal entity name and a dedicated privacy contact email.'**
  String get privacyPolicyBody;

  /// No description provided for @termsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsConditions;

  /// No description provided for @termsConditionsBody.
  ///
  /// In en, this message translates to:
  /// **'These Terms govern your use of SwipePix. If you do not agree, do not use the app.\n\nService. SwipePix helps you review photos and videos on your own device. Swiping left only marks an item for deletion review. Items are not deleted until you review the marked items and ask the device operating system to delete them. The system may show an additional confirmation.\n\nYour responsibility. You are responsible for deciding which photos or videos to keep or delete and for maintaining backups of important media before using cleanup features. SwipePix cannot guarantee recovery of media after the operating system completes deletion.\n\nNo professional advice. SwipePix is provided as a utility tool and does not provide legal, storage-management, archival, security, or professional advice.\n\nAcceptable use. You may use SwipePix only for lawful purposes and only with photos and videos you have the right to access and manage. You may not attempt to reverse engineer, abuse, disrupt, or misuse the app or related services.\n\nPrivacy. The Privacy Policy explains what data is processed and stored. In the current production app, SwipePix is intended to process photos and videos locally and not upload, sell, or share them.\n\nDisclaimer. SwipePix is provided “as is” and “as available,” without warranties of any kind to the fullest extent permitted by law. We do not warrant that the app will be uninterrupted, error-free, or compatible with every device, library configuration, or operating-system version.\n\nLimitation of liability. To the fullest extent permitted by law, SwipePix and its developer will not be liable for indirect, incidental, special, consequential, exemplary, or punitive damages, or for lost data, lost media, lost profits, or business interruption arising from or related to your use of the app.\n\nArbitration & Class Action Waiver. Any dispute, claim, or controversy arising out of or relating to these Terms or SwipePix will be resolved by final and binding individual arbitration, rather than in court, except that either party may bring an individual claim in small claims court if it qualifies. You and SwipePix waive any right to a jury trial and any right to participate in a class, collective, consolidated, private attorney general, or representative action. The arbitration will be administered by the American Arbitration Association (AAA) under its applicable consumer arbitration rules unless the parties agree otherwise. The arbitrator may award relief only on an individual basis. This section does not prevent either party from seeking injunctive or equitable relief for misuse of intellectual property or unauthorized access.\n\nChanges. These Terms may be updated before or after release. If a material change is made, update the in-app notice and public Terms page.'**
  String get termsConditionsBody;

  /// No description provided for @legalUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: September 25, 2026'**
  String get legalUpdated;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

  /// No description provided for @media.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get media;

  /// No description provided for @videoDuration.
  ///
  /// In en, this message translates to:
  /// **'{duration}'**
  String videoDuration(String duration);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
