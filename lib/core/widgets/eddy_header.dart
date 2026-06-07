import 'package:flutter/material.dart';
import '../theme/color_tokens.dart';

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
          Text(
            'eddy',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: accentColor,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(title, style: Theme.of(context).textTheme.displayLarge),
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
