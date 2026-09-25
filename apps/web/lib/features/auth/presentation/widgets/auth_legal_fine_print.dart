import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';

class AuthLegalFinePrint extends StatelessWidget {
  const AuthLegalFinePrint({super.key});

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondary,
          fontSize: 12,
          height: 1.4,
        );
    final linkStyle = baseStyle?.copyWith(
      color: AppColors.linkBlue,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.linkBlue,
    );

    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          const TextSpan(text: 'By clicking on create account you agree to our '),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: () => context.go('/privacy'),
              child: Text('privacy policy', style: linkStyle),
            ),
          ),
          const TextSpan(text: ' and '),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: () => context.go('/terms'),
              child: Text('terms of use', style: linkStyle),
            ),
          ),
        ],
      ),
    );
  }
}
