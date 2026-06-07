import 'package:flutter/material.dart';
import '../theme/color_tokens.dart';

class EddySectionLabel extends StatelessWidget {
  final String text;
  final Color? color;

  const EddySectionLabel(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: color ?? c.textMuted,
        letterSpacing: 1.8,
      ),
    );
  }
}
