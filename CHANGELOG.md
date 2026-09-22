# Changelog

## Unreleased

### Added

- Added SwipePix native launcher icons for Android and iOS.
- Added a native launch splash mark and neutral launch background.
- Added reusable `AppEmptyState` for polished empty/error states.
- Added improved empty states for Gallery, Albums, Album Details, and Pending Deletion Review.
- Added large-library validation guidance to `docs/device-validation.md`.
- Added reviewed-photo delete CTA copy with singular/plural localization.

### Changed

- Simplified the delete flow: the Review screen is now the in-app confirmation step, and the red delete button proceeds directly to the system deletion request.
- Updated delete review CTA from generic “Delete selected photos” to “Delete X reviewed photos”.
- Updated app copy, tests, and generated localization files for the simplified delete flow.
- Updated Android launch background resources to use valid drawable XML shapes.
- Updated Album Details navigation to use centralized app routes.

### Removed

- Removed duplicate generated Flutter/iOS files with numbered suffixes that had been accidentally tracked.
- Removed the extra in-app “Delete permanently?” dialog from the reviewed-delete flow.

### Verified

- `flutter analyze` passes with no issues.
- `flutter test` passes with 33 tests.
- `flutter build apk --debug` builds successfully.

### Notes

- Flutter still reports the known `photo_manager` Kotlin Gradle Plugin warning. It does not block the current debug build, but it should be monitored before release.
