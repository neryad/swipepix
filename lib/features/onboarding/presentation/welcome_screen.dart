import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_routes.dart';
import '../../../app/design_system.dart';
import '../../../l10n/app_localizations.dart';
import '../application/onboarding_controller.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final palette = SwipePixPalette.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.appTitle),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
            tooltip: l.settings,
          ),
        ],
      ),
      body: SafeArea(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.2,
              colors: [
                palette.accentLow.withValues(
                  alpha: scheme.brightness == Brightness.dark ? 0.3 : 0.44,
                ),
                scheme.surface,
              ],
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  SwipeSpacing.lg,
                  SwipeSpacing.sm,
                  SwipeSpacing.lg,
                  SwipeSpacing.lg,
                ),
                children: [
                  const SizedBox(height: SwipeSpacing.xs),
                  const _SwipeDemoCard(),
                  const SizedBox(height: SwipeSpacing.lg),
                  Text(
                    l.swipeToOrganize,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: SwipeSpacing.xs),
                  Text(
                    l.welcome,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: SwipeSpacing.sm),
                  Text(
                    l.intro,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: SwipeSpacing.sm),
                  Text(
                    l.safety,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: SwipeSpacing.lg),
                  FilledButton(
                    onPressed: () {
                      ref.read(onboardingProvider.notifier).complete();
                      context.go(AppRoutes.gallery);
                    },
                    child: Text(l.connect),
                  ),
                  const SizedBox(height: SwipeSpacing.sm),
                  TextButton(
                    onPressed: () {
                      ref.read(onboardingProvider.notifier).complete();
                      context.go(AppRoutes.gallery);
                    },
                    child: Text(l.skip),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SwipeDemoCard extends StatefulWidget {
  const _SwipeDemoCard();

  @override
  State<_SwipeDemoCard> createState() => _SwipeDemoCardState();
}

class _SwipeDemoCardState extends State<_SwipeDemoCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || MediaQuery.disableAnimationsOf(context)) return;
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final palette = SwipePixPalette.of(context);
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final t = _animation.value;
        final phase = t < 0.5 ? t / 0.5 : (t - 0.5) / 0.5;
        final direction = t < 0.5 ? -1.0 : 1.0;
        final wave = Curves.easeInOut.transform(
          phase < 0.5 ? phase * 2 : (1 - phase) * 2,
        );
        final dx = direction * 48 * wave;
        final angle = direction * 0.08 * wave;
        final deleteOpacity = direction < 0 ? wave : 0.0;
        final keepOpacity = direction > 0 ? wave : 0.0;
        return SizedBox(
          height: 164,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 26,
                child: _DemoActionPill(
                  icon: Icons.delete_outline_rounded,
                  label: l.deleteOverlay,
                  color: palette.delete,
                  opacity: deleteOpacity,
                ),
              ),
              Positioned(
                right: 26,
                child: _DemoActionPill(
                  icon: Icons.check_rounded,
                  label: l.keepOverlay,
                  color: palette.keep,
                  opacity: keepOpacity,
                ),
              ),
              Transform.translate(
                offset: Offset(dx, 0),
                child: Transform.rotate(
                  angle: angle,
                  child: Container(
                    width: 124,
                    height: 152,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 28,
                          offset: const Offset(0, 14),
                        ),
                      ],
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xfff97316),
                          Color(0xff7c3aed),
                          Color(0xff0f766e),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withValues(alpha: 0.12),
                                  Colors.black.withValues(alpha: 0.28),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Icon(
                            Icons.photo_outlined,
                            color: Colors.white.withValues(alpha: 0.82),
                            size: 38,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Text(
                  l.swipeHint,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DemoActionPill extends StatelessWidget {
  const _DemoActionPill({
    required this.icon,
    required this.label,
    required this.color,
    required this.opacity,
  });

  final IconData icon;
  final String label;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: opacity.clamp(0.0, 1.0),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(SwipeRadius.card),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SwipeSpacing.md,
          vertical: SwipeSpacing.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: SwipeSpacing.xs),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
