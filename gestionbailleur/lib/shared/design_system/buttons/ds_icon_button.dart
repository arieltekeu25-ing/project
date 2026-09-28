import 'package:flutter/material.dart';
import '../radius/ds_radius.dart';

/// Bouton icône du Design System
class DSIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final String? tooltip;
  final bool isLoading;

  const DSIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.backgroundColor,
    this.size = 48,
    this.tooltip,
    this.isLoading = false,
  });

  @override
  State<DSIconButton> createState() => _DSIconButtonState();
}

class _DSIconButtonState extends State<DSIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    final theme = Theme.of(context);

    final iconColor = widget.color ?? theme.colorScheme.onSurface;
    final bgColor = widget.backgroundColor ?? Colors.transparent;

    Widget child;
    if (widget.isLoading) {
      child = SizedBox(
        width: widget.size * 0.5,
        height: widget.size * 0.5,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(iconColor),
        ),
      );
    } else {
      child = Icon(
        widget.icon,
        size: widget.size * 0.5,
        color: iconColor,
      );
    }

    final button = GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: isEnabled ? widget.onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: _isPressed && isEnabled
              ? bgColor.withValues(alpha: 0.8)
              : bgColor,
          borderRadius: DSRadius.circleRadius,
        ),
        child: Center(
          child: Opacity(
            opacity: isEnabled ? 1.0 : 0.5,
            child: child,
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}
