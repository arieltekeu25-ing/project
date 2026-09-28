import 'package:flutter/material.dart';
import '../radius/ds_radius.dart';
import '../spacing/ds_spacing.dart';
import '../../../core/theme/app_colors.dart';

/// Type de badge du Design System
enum DSBadgeType {
  available,
  occupied,
  new_,
  verified,
  premium,
  urgent,
  pending,
  rejected,
  approved,
}

/// Badge du Design System
class DSBadge extends StatelessWidget {
  final String text;
  final DSBadgeType type;
  final double? fontSize;

  const DSBadge({
    super.key,
    required this.text,
    required this.type,
    this.fontSize,
  });

  Color _getBackgroundColor() {
    switch (type) {
      case DSBadgeType.available:
        return AppColors.badgeAvailable.withValues(alpha: 0.1);
      case DSBadgeType.occupied:
        return AppColors.error.withValues(alpha: 0.1);
      case DSBadgeType.new_:
        return AppColors.badgeNew.withValues(alpha: 0.1);
      case DSBadgeType.verified:
        return AppColors.success.withValues(alpha: 0.1);
      case DSBadgeType.premium:
        return AppColors.badgePremium.withValues(alpha: 0.1);
      case DSBadgeType.urgent:
        return AppColors.error.withValues(alpha: 0.1);
      case DSBadgeType.pending:
        return AppColors.warning.withValues(alpha: 0.1);
      case DSBadgeType.rejected:
        return AppColors.error.withValues(alpha: 0.1);
      case DSBadgeType.approved:
        return AppColors.success.withValues(alpha: 0.1);
    }
  }

  Color _getTextColor() {
    switch (type) {
      case DSBadgeType.available:
        return AppColors.badgeAvailable;
      case DSBadgeType.occupied:
        return AppColors.error;
      case DSBadgeType.new_:
        return AppColors.badgeNew;
      case DSBadgeType.verified:
        return AppColors.success;
      case DSBadgeType.premium:
        return AppColors.badgePremium;
      case DSBadgeType.urgent:
        return AppColors.error;
      case DSBadgeType.pending:
        return AppColors.warning;
      case DSBadgeType.rejected:
        return AppColors.error;
      case DSBadgeType.approved:
        return AppColors.success;
    }
  }

  IconData? _getIcon() {
    switch (type) {
      case DSBadgeType.verified:
        return Icons.verified;
      case DSBadgeType.premium:
        return Icons.star;
      case DSBadgeType.new_:
        return Icons.new_releases;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = _getIcon();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: icon != null ? DSSpacing.sm : DSSpacing.md,
        vertical: DSSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: DSRadius.xxsRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: fontSize != null ? fontSize! * 1.2 : 14,
              color: _getTextColor(),
            ),
            const SizedBox(width: DSSpacing.xxs),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize ?? 12,
              fontWeight: FontWeight.w600,
              color: _getTextColor(),
            ),
          ),
        ],
      ),
    );
  }
}
