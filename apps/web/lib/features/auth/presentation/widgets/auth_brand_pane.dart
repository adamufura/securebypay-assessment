import 'package:flutter/material.dart';

/// Right-hand brand panel for auth screens.
///
/// Uses the Figma dotted world-map PNG as a responsive cover background.
/// Headline/subtext are drawn in Flutter so sign-in and sign-up can differ,
/// and so copy scales cleanly across breakpoints.
class AuthBrandPane extends StatelessWidget {
  const AuthBrandPane({
    super.key,
    required this.headline,
    required this.subtext,
  });

  final String headline;
  final String subtext;

  /// Matches the PNG panel fill so edges never flash a different purple.
  static const Color _panelPurple = Color(0xFF6B75C4);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _panelPurple,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/auth_world_map.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              filterQuality: FilterQuality.medium,
            ),
          ),
          // Soften the lower third and cover the baked-in PNG headline
          // so we can render page-specific copy on top.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 320,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _panelPurple.withValues(alpha: 0),
                    _panelPurple.withValues(alpha: 0.85),
                    _panelPurple,
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(40, 40, 48, 56),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      headline,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 32,
                            height: 1.2,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      subtext,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.92),
                            fontSize: 15,
                            height: 1.5,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
