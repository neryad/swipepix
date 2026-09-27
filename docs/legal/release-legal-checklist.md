# SwipePix Release Legal Checklist

Last reviewed: 2026-09-25

## Must complete before App Store / Google Play release

- [ ] Replace placeholder legal entity/contact language in Privacy Policy and Terms.
- [ ] Attorney review of Terms, especially arbitration, governing law, venue, and class-action waiver.
- [ ] Publish public Privacy Policy URL.
- [ ] Publish public Terms URL or ensure the in-app terms are available to users before purchase/download if required by store flow.
- [ ] Complete App Store Connect App Privacy.
- [ ] Complete Google Play Data Safety.
- [ ] Review App Store and Google Play marketing copy against `docs/legal/claims-register.md`.
- [ ] Confirm no analytics, ads, crash SDK, cloud SDK, payment SDK, or backend service was added after this review.
- [ ] Confirm release build permissions match `docs/legal/privacy-inventory.md`.
- [ ] Reassess CCPA if business thresholds or data sharing practices change.
- [ ] Reassess DMCA if any upload/hosting/sharing feature is added.

## Current legal posture summary

- AI claims: no AI claims in current repo; maintain claims register.
- Arbitration: draft clause added in app Terms, pending attorney/entity details.
- Privacy: local-only posture documented, pending public privacy URL and store declarations.
- DMCA: not applicable to current local-only app, pending reassessment if hosting/upload features are added.
