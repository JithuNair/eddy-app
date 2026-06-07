import 'package:flutter/material.dart';
import '../theme/color_tokens.dart';
import '../theme/eddy_theme.dart';

class EddyPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final double height;
  final Widget? icon;

  const EddyPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color,
    this.height = 56,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final bg = color ?? c.regulate;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: EddyRadius.button),
        ),
        child: icon != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon!,
                  const SizedBox(width: 8),
                  Text(label,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                ],
              )
            : Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 15)),
      ),
    );
  }
}

class EddyPillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final bool outlined;
  final Widget? icon;

  const EddyPillButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color,
    this.outlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final accent = color ?? c.regulate;

    if (outlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: BorderSide(color: accent.withOpacity(0.5)),
          shape:
              RoundedRectangleBorder(borderRadius: EddyRadius.pillButton),
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        child: icon != null
            ? Row(mainAxisSize: MainAxisSize.min, children: [
                icon!,
                const SizedBox(width: 6),
                Text(label,
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: accent)),
              ])
            : Text(label,
                style:
                    TextStyle(fontWeight: FontWeight.w600, color: accent)),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: accent.withOpacity(0.15),
        foregroundColor: accent,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: EddyRadius.pillButton),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: icon != null
          ? Row(mainAxisSize: MainAxisSize.min, children: [
              icon!,
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: accent)),
            ])
          : Text(label,
              style: TextStyle(fontWeight: FontWeight.w600, color: accent)),
    );
  }
}

class EddyGhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  const EddyGhostButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return TextButton(
      onPressed: onPressed,
      child: Text(label,
          style: TextStyle(
              color: color ?? c.textSecondary, fontWeight: FontWeight.w500)),
    );
  }
}
