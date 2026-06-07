import 'package:flutter/material.dart';
import '../theme/color_tokens.dart';
import '../theme/eddy_theme.dart';

class EddyCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? accentGradient;
  final bool elevated;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const EddyCard({
    super.key,
    required this.child,
    this.padding,
    this.accentGradient,
    this.elevated = false,
    this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final decoration = elevated
        ? EddyCardStyle.elevated(c)
        : EddyCardStyle.base(c, gradient: accentGradient);
    final radius = borderRadius ?? EddyRadius.card;

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Ink(
            decoration: decoration.copyWith(
                borderRadius: radius),
            child: Padding(
              padding: padding ?? EddySpacing.card,
              child: child,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: decoration.copyWith(borderRadius: radius),
      padding: padding ?? EddySpacing.card,
      child: child,
    );
  }
}
