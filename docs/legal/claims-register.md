# SwipePix Claims Register

Last reviewed: 2026-09-25

Use this register before publishing landing-page, App Store, Google Play, screenshot, ad, email, or social copy.

## Approved claims

These claims are supported by the current codebase and product behavior:

- SwipePix helps users review photos on their own device.
- Photos stay on the device in the current production app.
- Swipe gestures only mark photos for review.
- Deletion requires a separate review screen and a user action on the delete button.
- The operating system may request additional deletion confirmation.
- SwipePix does not currently use accounts, ads, analytics, tracking SDKs, cloud sync, or server upload.
- SwipePix stores preferences and cleanup-session progress locally on the device.

## Claims that require proof or product changes before use

Do not publish these unless the product actually supports them and the evidence is retained:

- “AI-powered” or “uses artificial intelligence.”
- “Automatically detects duplicates.”
- “Automatically finds blurry photos.”
- “99% accurate” or any numerical accuracy/performance claim.
- “Frees X GB on average” unless backed by documented measurement.
- “Never deletes by mistake” or other absolute safety guarantees.
- Testimonials, ratings, or reviews unless they are from real users and permissioned.
- AI-generated testimonials or reviews unless clearly disclosed as synthetic examples.

## Store listing review checklist

Before release, review and approve:

- App Store subtitle.
- App Store promotional text.
- App Store description.
- App Store screenshot text.
- Google Play short description.
- Google Play full description.
- Google Play screenshot text.
- Website or landing page.
- Any paid ads or influencer scripts.

## Evidence notes

- Current code references: `photo_manager`, `shared_preferences`, local Riverpod state, and system deletion APIs.
- No AI, analytics, ads, cloud, account, or backend SDK is present in the current dependency list.
- If AI features are added later, create a separate evidence file for each AI claim.
