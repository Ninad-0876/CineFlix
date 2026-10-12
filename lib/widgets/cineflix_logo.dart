import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CineflixLogo extends StatelessWidget {
  final double fontSize;

  const CineflixLogo({
    super.key,
    this.fontSize = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'CINEFLIX',
          style: TextStyle(
            color: AppTheme.primaryRed,
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.8),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
