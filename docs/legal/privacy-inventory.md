# SwipePix Privacy Inventory

Last reviewed: 2026-09-25

This inventory should be reviewed before each App Store / Google Play submission and whenever dependencies, permissions, analytics, ads, payments, accounts, cloud sync, or backend services are added.

## Current production data posture

SwipePix is currently designed as a local-only photo review utility. No production backend, account system, advertising SDK, analytics SDK, crash-reporting SDK, payment SDK, or cloud-sync feature is present in the reviewed repo.

## Data transmitted off-device

None known in the current production app.

Development builds may use Flutter tooling permissions or local development network behavior. Do not base store privacy answers on debug/profile tooling; review the release build.

## Data processed locally

| Data | Source | Purpose | Stored by SwipePix? | Leaves device? |
| --- | --- | --- | --- | --- |
| Photo thumbnails/previews | `photo_manager` / OS photo library | Gallery grid, albums, swipe review, delete review | No app copy intentionally retained | No known app transmission |
| Photo identifiers | `photo_manager` | Resume cleanup sessions and pending-deletion review | Yes, local app storage | No known app transmission |
| Photo dates and file sizes | `photo_manager` | Sort, metadata display, estimated storage freeing | Limited session/local state as needed | No known app transmission |
| Language/theme/sort/onboarding preferences | User/app settings | App functionality | Yes, local app storage | No known app transmission |
| App version/build | `package_info_plus` | Display version in Settings | No | No known app transmission |

## SDK / package inventory

| Package / SDK | Purpose | Data risk | Store declaration notes |
| --- | --- | --- | --- |
| `photo_manager` | Native photo library access, thumbnails/previews, metadata, limited library management, deletion request | Accesses user photos locally | Declare photo permission. If no off-device transmission occurs, this is local processing rather than collection under Apple/Google definitions. |
| `shared_preferences` | Local settings and session persistence | Stores local preferences/photo IDs | Local-only; not collected if not transmitted. |
| `package_info_plus` | Reads package version/build | No user data | No data collection. |
| `flutter_riverpod` | State management | No user data collection by itself | No data collection. |
| `go_router` | Navigation | No user data collection by itself | No data collection. |
| `intl` / `flutter_localizations` | Localization | No user data collection by itself | No data collection. |
| `cupertino_icons` / bundled fonts | UI assets | No user data | No data collection. |

## Native permissions

### Android

Declared in `android/app/src/main/AndroidManifest.xml`:

- `READ_EXTERNAL_STORAGE` with `maxSdkVersion=32`.
- `READ_MEDIA_IMAGES`.
- `READ_MEDIA_VISUAL_USER_SELECTED`.

### iOS

Declared in `ios/Runner/Info.plist`:

- `NSPhotoLibraryUsageDescription`.
- `PHPhotoLibraryPreventAutomaticLimitedAccessAlert`.

## App Store Connect App Privacy draft

If the release build remains local-only:

- Tracking: No.
- Data collected: No data collected by the developer.
- Photos/videos: accessed and processed locally for app functionality; not transmitted to the developer or third parties by SwipePix.
- Diagnostics: No third-party crash or analytics SDK currently present.

Apple still requires a public Privacy Policy URL. Publish a web version before submission.

## Google Play Data Safety draft

If the release build remains local-only:

- Does the app collect or share user data? No, based on current code and no off-device transmission.
- Data processed on device: photos and local preferences for app functionality.
- Data shared: No known sharing by SwipePix.
- Account creation: No.
- User data deletion request mechanism: local data can be removed by deleting the app; add a public support contact before release.
- Privacy policy: required even if no user data is collected.

## CCPA / CPRA assessment

Current code does not sell or share personal information for cross-context behavioral advertising and has no ad/analytics SDKs. A “Do Not Sell or Share My Personal Information” link does not appear required for the current app behavior.

Reassess CCPA if any of these become true:

- Annual gross revenue exceeds the applicable California threshold.
- The business buys, sells, or shares personal information of 100,000+ California consumers or households.
- 50% or more of annual revenue comes from selling or sharing personal information.
- Ads, analytics, data brokers, cross-context behavioral advertising, or third-party tracking are added.

## Release blockers

Before public release:

- Replace in-app privacy contact placeholder with legal entity name and dedicated privacy email.
- Publish Privacy Policy URL.
- Complete App Store Connect App Privacy.
- Complete Google Play Data Safety.
- Recheck release build permissions and SDK list.
