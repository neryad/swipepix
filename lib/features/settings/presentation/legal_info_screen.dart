import 'package:flutter/material.dart';

import '../../../app/design_system.dart';
import '../../../l10n/app_localizations.dart';

enum LegalInfoType { privacy, terms }

class AboutSwipePixScreen extends StatelessWidget {
  const AboutSwipePixScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return _InfoPage(
      title: l.aboutSwipePix,
      icon: Icons.auto_awesome_rounded,
      body: l.aboutSwipePixBody,
      children: [
        const SizedBox(height: SwipeSpacing.md),
        _InfoHighlight(
          icon: Icons.lock_outline_rounded,
          title: l.privacyPolicy,
          body: l.privacyPolicyBody,
        ),
        const SizedBox(height: SwipeSpacing.sm),
        _InfoHighlight(
          icon: Icons.delete_outline_rounded,
          title: l.deleteReviewTitle,
          body: l.safety,
        ),
      ],
    );
  }
}

class LegalInfoScreen extends StatelessWidget {
  const LegalInfoScreen({required this.type, super.key});

  final LegalInfoType type;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isPrivacy = type == LegalInfoType.privacy;
    return _InfoPage(
      title: isPrivacy ? l.privacyPolicy : l.termsConditions,
      icon: isPrivacy ? Icons.privacy_tip_outlined : Icons.description_outlined,
      body: isPrivacy ? l.privacyPolicyBody : l.termsConditionsBody,
      footer: l.legalUpdated,
    );
  }
}

class _InfoPage extends StatelessWidget {
  const _InfoPage({
    required this.title,
    required this.icon,
    required this.body,
    this.children = const [],
    this.footer,
  });

  final String title;
  final IconData icon;
  final String body;
  final List<Widget> children;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = SwipePixPalette.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            SwipeSpacing.lg,
            0,
            SwipeSpacing.lg,
            SwipeSpacing.xxl,
          ),
          children: [
            Container(
              width: 58,
              height: 58,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: palette.accentLow,
                borderRadius: BorderRadius.circular(SwipeRadius.card),
              ),
              child: Icon(icon, color: palette.accent, size: 28),
            ),
            const SizedBox(height: SwipeSpacing.lg),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: SwipeSpacing.md),
            Text(
              body,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
            ...children,
            if (footer != null) ...[
              const SizedBox(height: SwipeSpacing.xl),
              Text(
                footer!,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoHighlight extends StatelessWidget {
  const _InfoHighlight({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(SwipeRadius.card),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.28),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(SwipeSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: SwipePixPalette.of(context).accent),
            const SizedBox(width: SwipeSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: SwipeSpacing.xs),
                  Text(
                    body,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
