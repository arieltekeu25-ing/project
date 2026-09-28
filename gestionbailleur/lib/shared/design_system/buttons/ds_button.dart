import 'package:flutter/material.dart';
import '../radius/ds_radius.dart';
import '../spacing/ds_spacing.dart';
import '../shadows/ds_shadows.dart';

/// Type de bouton du Design System
enum DSButtonType {
  primary,
  secondary,
  text,
  danger,
  success,
  icon,
}

/// Taille de bouton du Design System
enum DSButtonSize {
  small,
  medium,
  large,
}

/// Bouton principal du Design System
class DSButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final DSButtonType type;
  final DSButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final Widget? leading;
  final Widget? trailing;
  final String? loadingText;

  const DSButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = DSButtonType.primary,
    this.size = DSButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.leading,
    this.trailing,
    this.loadingText,
  });

  @override
  State<DSButton> createState() => _DSButtonState();
}

class _DSButtonState extends State<DSButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    final theme = Theme.of(context);

    // Configuration selon le type
    Color backgroundColor;
    Color foregroundColor;
    BorderSide? borderSide;

    switch (widget.type) {
      case DSButtonType.primary:
        backgroundColor = theme.colorScheme.primary;
        foregroundColor = Colors.white;
        borderSide = null;
        break;
      case DSButtonType.secondary:
        backgroundColor = theme.colorScheme.secondary;
        foregroundColor = Colors.white;
        borderSide = null;
        break;
      case DSButtonType.text:
        backgroundColor = Colors.transparent;
        foregroundColor = theme.colorScheme.primary;
        borderSide = null;
        break;
      case DSButtonType.danger:
        backgroundColor = theme.colorScheme.error;
        foregroundColor = Colors.white;
        borderSide = null;
        break;
      case DSButtonType.success:
        backgroundColor = theme.colorScheme.primary.withValues(alpha: 0.1);
        foregroundColor = theme.colorScheme.primary;
        borderSide = BorderSide(color: theme.colorScheme.primary);
        break;
      case DSButtonType.icon:
        backgroundColor = theme.colorScheme.surface;
        foregroundColor = theme.colorScheme.onSurface;
        borderSide = BorderSide(color: theme.dividerColor);
        break;
    }

    // Configuration selon la taille
    double paddingVertical;
    double paddingHorizontal;
    double fontSize;

    switch (widget.size) {
      case DSButtonSize.small:
        paddingVertical = DSSpacing.sm;
        paddingHorizontal = DSSpacing.md;
        fontSize = 14;
        break;
      case DSButtonSize.medium:
        paddingVertical = DSSpacing.md;
        paddingHorizontal = DSSpacing.lg;
        fontSize = 16;
        break;
      case DSButtonSize.large:
        paddingVertical = DSSpacing.lg;
        paddingHorizontal = DSSpacing.xl;
        fontSize = 18;
        break;
    }

    // Contenu du bouton
    Widget content;
    if (widget.isLoading) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: fontSize * 1.2,
            height: fontSize * 1.2,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          ),
          SizedBox(width: DSSpacing.sm),
          Text(
            widget.loadingText ?? 'Chargement...',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: foregroundColor,
            ),
          ),
        ],
      );
    } else if (widget.icon != null && widget.type == DSButtonType.icon) {
      content = Icon(widget.icon, size: fontSize * 1.2);
    } else {
      final children = <Widget>[];
      
      if (widget.leading != null) {
        children.add(widget.leading!);
        children.add(const SizedBox(width: DSSpacing.sm));
      }
      
      children.add(
        Text(
          widget.text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: foregroundColor,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      );
      
      if (widget.trailing != null) {
        children.add(const SizedBox(width: DSSpacing.sm));
        children.add(widget.trailing!);
      }
      
      if (widget.icon != null && widget.type != DSButtonType.icon) {
        children.add(const SizedBox(width: DSSpacing.sm));
        children.add(Icon(widget.icon, size: fontSize * 1.2));
      }
      
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      );
    }

    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: isEnabled ? widget.onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: paddingHorizontal,
          vertical: paddingVertical,
        ),
        decoration: BoxDecoration(
          color: _isPressed && isEnabled
              ? backgroundColor.withValues(alpha: 0.8)
              : backgroundColor,
          borderRadius: DSRadius.smRadius,
          border: borderSide != null
              ? Border.fromBorderSide(borderSide)
              : null,
          boxShadow: widget.type != DSButtonType.text && isEnabled
              ? DSShadows.xs
              : null,
        ),
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.5,
          child: Center(
            child: content,
          ),
        ),
      ),
    );
  }
}
