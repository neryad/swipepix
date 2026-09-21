import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../app/app_routes.dart';
import '../../../app/design_system.dart';
import '../../../l10n/app_localizations.dart';
import '../application/preferences.dart';

final packageInfoProvider = FutureProvider<PackageInfo>((ref) async {
  try {
    return await PackageInfo.fromPlatform();
  } on Exception {
    return PackageInfo(
      appName: 'SwipePix',
      packageName: 'swipepix',
      version: '1.0.0',
      buildNumber: '1',
    );
  }
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider)?.languageCode ?? 'system';
    final theme = ref.watch(themeProvider);
    final packageInfo = ref.watch(packageInfoProvider);
    final version = packageInfo.maybeWhen(
      data: (info) => '${info.version}+${info.buildNumber}',
      orElse: () => '—',
    );
    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          SwipeSpacing.lg,
          0,
          SwipeSpacing.lg,
          SwipeSpacing.xxl,
        ),
        children: [
          _SettingsGroup(
            children: [
              _SettingsRow(
                icon: Icons.language_rounded,
                title: l.language,
                value: _languageLabel(context, locale),
                onTap: () => _selectLanguage(context, ref),
              ),
              _SettingsRow(
                icon: Icons.dark_mode_outlined,
                title: l.theme,
                value: _themeLabel(context, theme),
                onTap: () => _selectTheme(context, ref),
              ),
            ],
          ),
          const SizedBox(height: SwipeSpacing.md),
          _SettingsGroup(
            children: [
              _SettingsRow(
                icon: Icons.info_outline_rounded,
                title: l.viewIntroduction,
                onTap: () => context.push(AppRoutes.onboarding),
              ),
            ],
          ),
          const SizedBox(height: SwipeSpacing.xl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SwipeSpacing.xs),
            child: Text(
              l.about,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: SwipeSpacing.sm),
          _SettingsGroup(
            children: [
              _SettingsRow(
                icon: Icons.info_outline_rounded,
                title: l.aboutSwipePix,
                onTap: () => context.push(AppRoutes.settingsAbout),
              ),
              _SettingsRow(
                icon: Icons.privacy_tip_outlined,
                title: l.privacyPolicy,
                onTap: () => context.push(AppRoutes.settingsPrivacy),
              ),
              _SettingsRow(
                icon: Icons.description_outlined,
                title: l.termsConditions,
                onTap: () => context.push(AppRoutes.settingsTerms),
              ),
              _SettingsRow(
                icon: Icons.verified_outlined,
                title: l.version,
                value: version,
                showChevron: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _languageLabel(BuildContext context, String value) {
    final l = AppLocalizations.of(context)!;
    return switch (value) {
      'es' => 'Español',
      'en' => 'English',
      _ => l.system,
    };
  }

  String _themeLabel(BuildContext context, ThemeMode value) {
    final l = AppLocalizations.of(context)!;
    return switch (value) {
      ThemeMode.light => l.light,
      ThemeMode.dark => l.dark,
      ThemeMode.system => l.system,
    };
  }

  Future<void> _selectLanguage(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context)!;
    final value = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l.system),
              onTap: () => Navigator.pop(context, 'system'),
            ),
            ListTile(
              title: const Text('Español'),
              onTap: () => Navigator.pop(context, 'es'),
            ),
            ListTile(
              title: const Text('English'),
              onTap: () => Navigator.pop(context, 'en'),
            ),
          ],
        ),
      ),
    );
    if (value == null) return;
    ref
        .read(localeProvider.notifier)
        .select(value == 'system' ? null : Locale(value));
  }

  Future<void> _selectTheme(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context)!;
    final value = await showModalBottomSheet<ThemeMode>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l.system),
              onTap: () => Navigator.pop(context, ThemeMode.system),
            ),
            ListTile(
              title: Text(l.light),
              onTap: () => Navigator.pop(context, ThemeMode.light),
            ),
            ListTile(
              title: Text(l.dark),
              onTap: () => Navigator.pop(context, ThemeMode.dark),
            ),
          ],
        ),
      ),
    );
    if (value != null) ref.read(themeProvider.notifier).select(value);
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    this.value,
    this.onTap,
    this.showChevron = true,
  });

  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = SwipePixPalette.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SwipeRadius.control),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SwipeSpacing.md,
          vertical: SwipeSpacing.md,
        ),
        child: Row(
          children: [
            Icon(icon, size: 21, color: palette.accent),
            const SizedBox(width: SwipeSpacing.md),
            Expanded(
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            if (value != null)
              Text(
                value!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (showChevron) ...[
              const SizedBox(width: SwipeSpacing.xs),
              Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
            ],
          ],
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index < children.length - 1)
              Divider(
                height: 1,
                indent: 48,
                color: scheme.outlineVariant.withValues(alpha: 0.32),
              ),
          ],
        ],
      ),
    );
  }
}
