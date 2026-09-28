import 'package:flutter/material.dart';
import '../radius/ds_radius.dart';
import '../spacing/ds_spacing.dart';

/// Chip du Design System
class DSChip extends StatefulWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final IconData? icon;
  final bool deletable;
  final VoidCallback? onDeleted;
  final Color? selectedColor;
  final Color? unselectedColor;

  const DSChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onSelected,
    this.icon,
    this.deletable = false,
    this.onDeleted,
    this.selectedColor,
    this.unselectedColor,
  });

  @override
  State<DSChip> createState() => _DSChipState();
}

class _DSChipState extends State<DSChip> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final backgroundColor = widget.selected
        ? (widget.selectedColor ?? theme.colorScheme.primary)
        : (widget.unselectedColor ?? theme.colorScheme.surface);

    final textColor = widget.selected
        ? Colors.white
        : theme.colorScheme.onSurface;

    return FilterChip(
      label: Text(widget.label),
      selected: widget.selected,
      onSelected: widget.onSelected,
      avatar: widget.icon != null
          ? Icon(
              widget.icon,
              size: 18,
              color: textColor,
            )
          : null,
      deleteIcon: widget.deletable
          ? Icon(
              Icons.close,
              size: 18,
              color: textColor,
            )
          : null,
      onDeleted: widget.deletable ? widget.onDeleted : null,
      backgroundColor: backgroundColor,
      selectedColor: backgroundColor,
      checkmarkColor: textColor,
      labelStyle: TextStyle(
        color: textColor,
        fontWeight: widget.selected ? FontWeight.w600 : FontWeight.w400,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: DSRadius.xsRadius,
        side: BorderSide(
          color: theme.dividerColor,
          width: widget.selected ? 0 : 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.xs,
      ),
    );
  }
}
