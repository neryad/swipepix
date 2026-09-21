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
  /// **'Start by connecting your photo library. Your photos stay on your device; SwipePix never uploads them.'**
  String get intro;

  /// No description provided for @safety.
  ///
  /// In en, this message translates to:
  /// **'You stay in control. Swiping will only mark photos. Deletion will require a separate review and confirmation.'**
  String get safety;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Explore my photos'**
  String get connect;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Your photo library'**
  String get gallery;

  /// No description provided for @libraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryTitle;

  /// No description provided for @recentPhotos.
  ///
  /// In en, this message translates to:
  /// **'Recent photos'**
  String get recentPhotos;

  /// No description provided for @photoSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No photos yet} =1{1 photo} other{{count} photos}}'**
  String photoSummary(int count);

  /// No description provided for @galleryHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to clean'**
  String get galleryHeroTitle;

  /// No description provided for @permissionIntro.
  ///
  /// In en, this message translates to:
  /// **'Allow photo access to see your library. You can grant access to selected photos only.'**
  String get permissionIntro;

  /// No description provided for @allow.
  ///
  /// In en, this message translates to:
  /// **'Allow photo access'**
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
  /// **'Selected photos only'**
  String get limited;

  /// No description provided for @authorized.
  ///
  /// In en, this message translates to:
  /// **'Full photo access'**
  String get authorized;

  /// No description provided for @denied.
  ///
  /// In en, this message translates to:
  /// **'Photo access is denied. You can try again or change it in device settings.'**
  String get denied;

  /// No description provided for @restricted.
  ///
  /// In en, this message translates to:
  /// **'Photo access is restricted by this device.'**
  String get restricted;

  /// No description provided for @unsupported.
  ///
  /// In en, this message translates to:
  /// **'Open SwipePix on Android or iOS to access your photos.'**
  String get unsupported;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Change selected photos'**
  String get manage;

  /// No description provided for @empty.
  ///
  /// In en, this message translates to:
  /// **'No accessible photos. If access is limited, try selecting more photos.'**
  String get empty;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Could not load your photos. Check access and try again.'**
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
  /// **'Loading more photos…'**
  String get loadingMorePhotos;

  /// No description provided for @readOnly.
  ///
  /// In en, this message translates to:
  /// **'Swiping only marks photos; deletion always requires review and confirmation.'**
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
  /// **'All'**
  String get allPhotos;

  /// No description provided for @largePhotos.
  ///
  /// In en, this message translates to:
  /// **'Large'**
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
  /// **'{count, plural, =1{1 photo} other{{count} photos}}'**
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
  /// **'You will review the {count} loaded photos.'**
  String loadedSessionCount(int count);

  /// No description provided for @cleanupTitle.
  ///
  /// In en, this message translates to:
  /// **'Review photos'**
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
  /// **'Review the marked photos before deciding whether to delete them.'**
  String get sessionCompleteBody;

  /// No description provided for @nothingMarked.
  ///
  /// In en, this message translates to:
  /// **'You did not mark any photos for deletion.'**
  String get nothingMarked;

  /// No description provided for @continueNextBatch.
  ///
  /// In en, this message translates to:
  /// **'Continue with the next batch'**
  String get continueNextBatch;

  /// No description provided for @loadingNextBatch.
  ///
  /// In en, this message translates to:
  /// **'Looking for more photos…'**
  String get loadingNextBatch;

  /// No description provided for @noMorePhotos.
  ///
  /// In en, this message translates to:
  /// **'There are no new photos left to review'**
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
  /// **'These photos have not been deleted yet. Remove any photo you want to keep.'**
  String get deleteReviewSafety;

  /// No description provided for @removeFromDelete.
  ///
  /// In en, this message translates to:
  /// **'Keep this photo'**
  String get removeFromDelete;

  /// No description provided for @deleteSelected.
  ///
  /// In en, this message translates to:
  /// **'Delete selected photos'**
  String get deleteSelected;

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently?'**
  String get confirmDeleteTitle;

  /// No description provided for @confirmDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'SwipePix will request deletion of {count, plural, =1{1 photo} other{{count} photos}} from the device. The system may ask for another confirmation.'**
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

  /// No description provided for @deleting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for system confirmation…'**
  String get deleting;

  /// No description provided for @deleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 photo was deleted} other{{count} photos were deleted}}.'**
  String deleteSuccess(int count);

  /// No description provided for @deletePartial.
  ///
  /// In en, this message translates to:
  /// **'Some photos were not deleted or confirmation was canceled. They remain in the list.'**
  String get deletePartial;

  /// No description provided for @deleteAccessLost.
  ///
  /// In en, this message translates to:
  /// **'Could not delete. Check photo access and try again.'**
  String get deleteAccessLost;

  /// No description provided for @previewUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This photo could not be loaded.'**
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
  /// **'Checking photos…'**
  String get restoringSession;

  /// No description provided for @sessionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Could not restore the session. Check photo access.'**
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
  /// **'Progress and marked photos from the previous session will be lost. No photos will be deleted.'**
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
  /// **'SwipePix helps you review your photo library quickly and safely. Photos stay on your device, and swiping only marks photos for review. Nothing is deleted until you confirm it.'**
  String get aboutSwipePixBody;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicyBody.
  ///
  /// In en, this message translates to:
  /// **'SwipePix requests access to your photo library only to show photos, organize review sessions, and request deletion from the device when you confirm. SwipePix does not upload, sell, or share your photos. Your review progress and preferences are stored locally on this device.'**
  String get privacyPolicyBody;

  /// No description provided for @termsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsConditions;

  /// No description provided for @termsConditionsBody.
  ///
  /// In en, this message translates to:
  /// **'SwipePix is provided to help you review and manage your own photos. You are responsible for confirming which photos should be deleted. Deletion requests are handled by the device system and may require an additional confirmation.'**
  String get termsConditionsBody;

  /// No description provided for @legalUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: September 21, 2026'**
  String get legalUpdated;
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
