import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/visit_provider.dart';
import '../../../shared/design_system/buttons/ds_button.dart';
import '../../../shared/design_system/inputs/ds_text_field.dart';
import '../../../shared/design_system/spacing/ds_spacing.dart';

class VisitRequestDialog extends ConsumerStatefulWidget {
  final String propertyId;
  final String propertyTitle;

  const VisitRequestDialog({
    super.key,
    required this.propertyId,
    required this.propertyTitle,
  });

  @override
  ConsumerState<VisitRequestDialog> createState() => _VisitRequestDialogState();
}

class _VisitRequestDialogState extends ConsumerState<VisitRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    try {
      final now = DateTime.now();
      final firstDate = now;
      final lastDate = DateTime(now.year + 1);

      final picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate ?? now.add(const Duration(days: 1)),
        firstDate: firstDate,
        lastDate: lastDate,
        locale: const Locale('fr', 'FR'),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Theme.of(context).colorScheme.primary,
                brightness: Theme.of(context).brightness,
              ),
            ),
            child: Builder(
              builder: (context) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                  child: child!,
                );
              },
            ),
          );
        },
      );

      if (picked != null && mounted) {
        setState(() {
          _selectedDate = picked;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection de la date: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectTime() async {
    try {
      final picked = await showTimePicker(
        context: context,
        initialTime: _selectedTime ?? const TimeOfDay(hour: 9, minute: 0),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme,
              timePickerTheme: TimePickerThemeData(
                backgroundColor: Theme.of(context).colorScheme.surface,
                hourMinuteColor: WidgetStateColor.resolveWith((states) =>
                  states.contains(WidgetState.selected)
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface),
              ),
            ),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: child!,
            ),
          );
        },
      );

      if (picked != null && mounted) {
        setState(() {
          _selectedTime = picked;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection de l\'heure: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une date et une heure'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final visitState = ref.read(visitProvider);
    if (visitState.isSubmitting) return;

    final success = await ref.read(visitProvider.notifier).createVisit(
      propertyId: widget.propertyId,
      requestedDate: _selectedDate!,
      requestedTime: '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
      message: _messageController.text.trim().isEmpty ? null : _messageController.text.trim(),
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Votre demande de visite a été envoyée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        final error = ref.read(visitProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Erreur lors de l\'envoi de la demande'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final visitState = ref.watch(visitProvider);
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(DSSpacing.xl),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.calendar_month_rounded,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: DSSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Demander une visite',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.propertyTitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DSSpacing.xl),

              // Date selection
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(DSSpacing.md),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _selectedDate != null
                          ? theme.colorScheme.primary
                          : theme.dividerColor,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        color: _selectedDate != null
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: DSSpacing.md),
                      Expanded(
                        child: Text(
                          _selectedDate != null
                              ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                              : 'Sélectionner une date',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: _selectedDate != null
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: DSSpacing.md),

              // Time selection
              InkWell(
                onTap: _selectTime,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(DSSpacing.md),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _selectedTime != null
                          ? theme.colorScheme.primary
                          : theme.dividerColor,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        color: _selectedTime != null
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: DSSpacing.md),
                      Expanded(
                        child: Text(
                          _selectedTime != null
                              ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                              : 'Sélectionner une heure',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: _selectedTime != null
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: DSSpacing.md),

              // Message field
              DSTextField(
                label: 'Message (optionnel)',
                hint: 'Ajoutez un message pour le bailleur...',
                controller: _messageController,
                maxLines: 3,
              ),
              const SizedBox(height: DSSpacing.xl),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: DSButton(
                  text: visitState.isSubmitting
                      ? 'Envoi en cours...'
                      : 'Envoyer ma demande',
                  icon: Icons.send_rounded,
                  onPressed: visitState.isSubmitting ? null : _submit,
                  isFullWidth: true,
                ),
              ),
              const SizedBox(height: DSSpacing.md),

              // Cancel button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: visitState.isSubmitting
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
