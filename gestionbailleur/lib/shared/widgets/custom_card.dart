import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// Carte personnalisée réutilisable
class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final double? borderRadius;

  const CustomCard({
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
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(borderRadius ?? AppConstants.borderRadiusLarge),
        boxShadow: boxShadow ?? AppConstants.shadowMedium,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppConstants.spacingMedium),
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius ?? AppConstants.borderRadiusLarge),
        child: card,
      );
    }

    return card;
  }
}
