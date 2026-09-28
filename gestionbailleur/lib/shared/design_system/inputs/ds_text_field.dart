import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../radius/ds_radius.dart';
import '../spacing/ds_spacing.dart';

/// Type de champ de texte du Design System
enum DSTextFieldType {
  text,
  email,
  password,
  search,
  phone,
  price,
  multiline,
}

/// Champ de texte du Design System
class DSTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final DSTextFieldType type;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final void Function()? onTap;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool readOnly;
  final bool showCounter;
  final TextInputAction? textInputAction;

  const DSTextField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.type = DSTextFieldType.text,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.readOnly = false,
    this.showCounter = false,
    this.textInputAction,
  });

  @override
  State<DSTextField> createState() => _DSTextFieldState();
}

class _DSTextFieldState extends State<DSTextField> {
  late bool _obscureText;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.type == DSTextFieldType.password;
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  TextInputType _getKeyboardType() {
    switch (widget.type) {
      case DSTextFieldType.email:
        return TextInputType.emailAddress;
      case DSTextFieldType.phone:
        return TextInputType.phone;
      case DSTextFieldType.price:
        return const TextInputType.numberWithOptions(decimal: true);
      case DSTextFieldType.multiline:
        return TextInputType.multiline;
      default:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter>? _getInputFormatters() {
    switch (widget.type) {
      case DSTextFieldType.phone:
        return [FilteringTextInputFormatter.digitsOnly];
      case DSTextFieldType.price:
        return [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))];
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: DSSpacing.xs),
        ],
        TextFormField(
          controller: widget.controller,
          initialValue: widget.controller == null ? widget.initialValue : null,
          obscureText: _obscureText,
          enabled: widget.enabled,
          maxLines: widget.type == DSTextFieldType.multiline ? widget.maxLines : 1,
          minLines: widget.type == DSTextFieldType.multiline ? widget.minLines : null,
          maxLength: widget.maxLength,
          keyboardType: _getKeyboardType(),
          textInputAction: widget.textInputAction,
          inputFormatters: _getInputFormatters(),
          validator: widget.validator,
          onChanged: widget.onChanged,
          onSaved: widget.onSaved,
          onTap: widget.onTap,
          readOnly: widget.readOnly,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.type == DSTextFieldType.password
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : widget.suffixIcon,
            filled: true,
            fillColor: widget.enabled
                ? theme.colorScheme.surface
                : theme.colorScheme.surface.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: DSRadius.smRadius,
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: DSRadius.smRadius,
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: DSRadius.smRadius,
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: DSRadius.smRadius,
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: DSRadius.smRadius,
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: DSRadius.smRadius,
              borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.md,
              vertical: DSSpacing.sm,
            ),
            counterText: widget.showCounter ? null : '',
          ),
        ),
      ],
    );
  }
}
