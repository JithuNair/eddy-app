import 'package:flutter/material.dart';
import '../theme/color_tokens.dart';
import 'eddy_swirl_logo.dart';

/// Section header used on every main screen (Regulate / Focus / Momentum).
///
/// Structure:
///   EddyBrandMark  (swirl logo + "eddy" wordmark, tinted by [accentColor])
///   ──────────────
///   [title]        (displayLarge)
///   [subtitle]     (bodyLarge, textMuted)   — optional
///
/// The right-padding default (72 px) clears the owl/eagle theme toggle that
/// lives in AppShell's top-right corner.
class EddyHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color accentColor;
  final EdgeInsetsGeometry padding;

  const EddyHeader({
    super.key,
    required this.title,
    required this.accentColor,
    this.subtitle,
    this.padding = const EdgeInsets.fromLTRB(24, 48, 72, 0),
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand mark: swirl logo + "eddy" wordmark
          EddyBrandMark(accentColor: accentColor, size: 26),

          const SizedBox(height: 18),

          // Screen title
          Text(title, style: Theme.of(context).textTheme.displayLarge),

          // Optional subtitle / section tagline
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: c.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}
