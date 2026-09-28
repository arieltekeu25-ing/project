import 'package:flutter/material.dart';
import '../radius/ds_radius.dart';
import '../spacing/ds_spacing.dart';
import '../shadows/ds_shadows.dart';

/// Carte standard du Design System
class DSCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final double? borderRadius;
  final Border? border;

  const DSCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.width,
    this.height,
    this.backgroundColor,
    this.boxShadow,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final card = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius ?? DSRadius.md),
        boxShadow: boxShadow ?? DSShadows.sm,
        border: border,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(DSSpacing.md),
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius ?? DSRadius.md),
        child: card,
      );
    }

    return card;
  }
}
