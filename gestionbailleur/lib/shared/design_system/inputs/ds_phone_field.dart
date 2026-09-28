import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../spacing/ds_spacing.dart';

/// Champ de saisie de téléphone avec préfixe +237 et drapeau Cameroun
class DSPhoneField extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final bool enabled;
  final int maxLength;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;

  const DSPhoneField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.errorText,
    this.enabled = true,
    this.maxLength = 9,
    this.onChanged,
    this.onTap,
    this.validator,
  });

  @override
  State<DSPhoneField> createState() => _DSPhoneFieldState();
}

class _DSPhoneFieldState extends State<DSPhoneField> {
  String? _errorText;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_validate);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_validate);
    super.dispose();
  }

  void _validate() {
    final error = widget.validator?.call(widget.controller.text);
    setState(() {
      _errorText = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayError = widget.errorText ?? _errorText;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: displayError != null
              ? theme.colorScheme.error
              : theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Drapeau Cameroun et préfixe (statique)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: DSSpacing.md,
              vertical: DSSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drapeau Cameroun
                Container(
                  width: 28,
                  height: 18,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: ColoredBox(color: Color(0xFF007A5E)), // Vert
                        ),
                        Expanded(
                          flex: 1,
                          child: ColoredBox(color: Color(0xFFFCD116)), // Jaune
                        ),
                        Expanded(
                          flex: 1,
                          child: ColoredBox(color: Color(0xFFCE1126)), // Rouge
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: DSSpacing.sm),
                Text(
                  '+237',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          // Champ de saisie du numéro (sans le préfixe)
          Expanded(
            child: TextField(
              controller: widget.controller,
              enabled: widget.enabled,
              maxLength: 11, // 9 chiffres + 2 espaces
              keyboardType: TextInputType.phone,
              inputFormatters: [
                _PhoneNumberFormatter(),
              ],
              onChanged: widget.onChanged,
              onTap: widget.onTap,
              decoration: InputDecoration(
                labelText: widget.labelText,
                hintText: widget.hintText ?? '6XX XXX XXX',
                errorText: displayError,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: DSSpacing.md,
                  vertical: DSSpacing.sm,
                ),
                counterText: '',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Formatter pour le numéro de téléphone camerounais
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Supprimer tous les caractères non numériques
    String text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Limiter à 9 chiffres
    if (text.length > 9) {
      text = text.substring(0, 9);
    }
    
    // Formater avec espaces: 6XX XXX XXX
    String formatted = text;
    if (text.length > 6) {
      formatted = '${text.substring(0, 3)} ${text.substring(3, 6)} ${text.substring(6)}';
    } else if (text.length > 3) {
      formatted = '${text.substring(0, 3)} ${text.substring(3)}';
    }
    
    // Calculer la position du curseur en fonction de la position originale
    int cursorOffset = 0;
    int selectionIndex = newValue.selection.end;
    
    // Compter les espaces avant la position du curseur dans le texte formaté
    for (int i = 0; i < selectionIndex && i < formatted.length; i++) {
      if (formatted[i] == ' ') cursorOffset++;
    }
    
    int cursorPosition = selectionIndex + cursorOffset;
    cursorPosition = cursorPosition.clamp(0, formatted.length);
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}
