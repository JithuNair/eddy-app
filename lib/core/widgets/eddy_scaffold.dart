import 'package:flutter/material.dart';
import '../theme/color_tokens.dart';

class EddyScaffold extends StatelessWidget {
  final Widget body;
  final Color? accentColor;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const EddyScaffold({
    super.key,
    required this.body,
    this.accentColor,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.background,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: Stack(
        children: [
          // Subtle ambient glow in top-right — the “eddy” ripple signature
          if (accentColor != null)
            Positioned(
              top: -80,
              right: -80,
              child: IgnorePointer(
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accentColor!.withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          body,
        ],
      ),
    );
  }
}
