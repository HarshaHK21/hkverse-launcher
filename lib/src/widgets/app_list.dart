import 'package:flutter/material.dart';

import '../models/app_info.dart';
import '../theme.dart';

/// A single scrollable row: [icon] + [name], with a subtle ink ripple on tap.
class AppListItem extends StatelessWidget {
  const AppListItem({super.key, required this.app, required this.onTap});

  final AppInfo app;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      splashColor: AppColors.accent.withValues(alpha: 0.16),
      highlightColor: AppColors.accent.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
        child: Row(
          children: [
            _AppIcon(app: app),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                app.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: AppTypography.body,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  letterSpacing: 0.2,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Slightly rounded app icon with graceful fallback to the initial letter.
class _AppIcon extends StatelessWidget {
  const _AppIcon({required this.app});

  final AppInfo app;

  @override
  Widget build(BuildContext context) {
    final iconBytes = app.icon;
    final fallback = Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Text(
        app.name.isEmpty ? '?' : app.name[0].toUpperCase(),
        style: const TextStyle(
          fontFamily: AppTypography.display,
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: AppColors.textMuted,
        ),
      ),
    );

    if (iconBytes == null || iconBytes.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: fallback,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.memory(
        iconBytes,
        width: 46,
        height: 46,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        cacheWidth: 96,
        cacheHeight: 96,
        errorBuilder: (_, _, _) => fallback,
      ),
    );
  }
}