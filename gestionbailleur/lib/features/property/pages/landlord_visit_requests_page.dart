import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/design_system/spacing/ds_spacing.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../domain/models/visite.dart';
import '../providers/visit_provider.dart';

/// Page de gestion des demandes de visite pour le bailleur
class LandlordVisitRequestsPage extends ConsumerStatefulWidget {
  const LandlordVisitRequestsPage({super.key});

  @override
  ConsumerState<LandlordVisitRequestsPage> createState() => _LandlordVisitRequestsPageState();
}

class _LandlordVisitRequestsPageState extends ConsumerState<LandlordVisitRequestsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(visitProvider.notifier).loadLandlordVisits();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visitState = ref.watch(visitProvider);

    return AppScaffold(
      title: 'Demandes de visite reçues',
      showBackButton: true,
      onBackPressed: () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          context.go(AppConstants.routeLandlordDashboard);
        }
      },
      body: visitState.isLoading && visitState.landlordVisits.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : visitState.landlordVisits.isEmpty && visitState.hasAttemptedFetch
              ? _buildEmptyState(context, theme)
              : RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(visitProvider.notifier).loadLandlordVisits(refresh: true);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(DSSpacing.lg),
                    itemCount: visitState.landlordVisits.length,
                    itemBuilder: (context, index) {
                      final visit = visitState.landlordVisits[index];
                      return _buildVisitCard(context, visit, theme);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: DSSpacing.md),
          Text(
            'Vous n\'avez reçu aucune demande de visite',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          Text(
            'Les demandes de visite pour vos logements apparaîtront ici',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitCard(BuildContext context, Visite visit, ThemeData theme) {
    final statusColor = _getStatusColor(visit.status, theme);
    final statusLabel = _getStatusLabel(visit.status);

    return Card(
      margin: const EdgeInsets.only(bottom: DSSpacing.md),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Property image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: theme.colorScheme.surfaceContainerHighest,
                  ),
                  child: visit.propertyMainPhoto != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            visit.propertyMainPhoto!,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => Icon(
                              Icons.home_work_outlined,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
                          ),
                        )
                      : Icon(
                          Icons.home_work_outlined,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                ),
                const SizedBox(width: DSSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visit.propertyTitle ?? 'Logement',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            visit.clientName ?? 'Client',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('dd/MM/yyyy').format(visit.requestedDate),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: DSSpacing.sm),
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            visit.requestedTime,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.md),
            if (visit.message != null && visit.message!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(DSSpacing.sm),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  visit.message!,
                  style: theme.textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: DSSpacing.md),
            ],
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DSSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(visit.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            // Actions based on status
            if (visit.status == 'PENDING') ...[
              const SizedBox(height: DSSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showAcceptDialog(context, visit),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Accepter'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showRejectDialog(context, visit),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Refuser'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showRescheduleDialog(context, visit),
                      icon: const Icon(Icons.event, size: 16),
                      label: const Text('Reprogrammer'),
                    ),
                  ),
                ],
              ),
            ],
            // Bouton de suppression pour tous les statuts
            const SizedBox(height: DSSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showDeleteDialog(context, visit),
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('Supprimer cet historique'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey,
                  side: const BorderSide(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'ACCEPTED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      case 'RESCHEDULED':
        return Colors.purple;
      case 'CANCELLED':
        return Colors.grey;
      case 'COMPLETED':
        return Colors.blue;
      default:
        return theme.colorScheme.onSurface;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'PENDING':
        return 'En attente';
      case 'ACCEPTED':
        return 'Acceptée';
      case 'REJECTED':
        return 'Refusée';
      case 'RESCHEDULED':
        return 'Reprogrammée';
      case 'CANCELLED':
        return 'Annulée';
      case 'COMPLETED':
        return 'Terminée';
      default:
        return status;
    }
  }

  void _showAcceptDialog(BuildContext context, Visite visit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Accepter la visite'),
        content: Text('Accepter la demande de visite pour "${visit.propertyTitle ?? 'ce logement'}" le ${DateFormat('dd/MM/yyyy').format(visit.requestedDate)} à ${visit.requestedTime}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref.read(visitProvider.notifier).updateVisit(
                visitId: visit.id,
                status: 'ACCEPTED',
              );
              if (!context.mounted) return;
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Visite acceptée avec succès'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                final error = ref.read(visitProvider).errorMessage;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error ?? 'Erreur lors de l\'acceptation'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Accepter'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, Visite visit) {
    final responseController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Refuser la visite'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Refuser la demande de visite pour "${visit.propertyTitle ?? 'ce logement'}"?'),
            const SizedBox(height: DSSpacing.md),
            TextField(
              controller: responseController,
              decoration: const InputDecoration(
                labelText: 'Raison (optionnel)',
                hintText: 'Expliquez pourquoi vous refusez...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref.read(visitProvider.notifier).updateVisit(
                visitId: visit.id,
                status: 'REJECTED',
                landlordResponse: responseController.text.trim().isEmpty ? null : responseController.text.trim(),
              );
              if (!context.mounted) return;
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Visite refusée'),
                    backgroundColor: Colors.orange,
                  ),
                );
              } else {
                final error = ref.read(visitProvider).errorMessage;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error ?? 'Erreur lors du refus'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Refuser'),
          ),
        ],
      ),
    );
  }

  void _showRescheduleDialog(BuildContext context, Visite visit) {
    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Reprogrammer la visite'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Proposer une nouvelle date pour "${visit.propertyTitle ?? 'ce logement'}"?'),
                  const SizedBox(height: DSSpacing.md),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(DSSpacing.md),
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).dividerColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: DSSpacing.sm),
                          Text(
                            selectedDate != null
                                ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                                : 'Sélectionner une date',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: DSSpacing.md),
                  InkWell(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: const TimeOfDay(hour: 9, minute: 0),
                      );
                      if (picked != null) {
                        setState(() => selectedTime = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(DSSpacing.md),
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).dividerColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time),
                          const SizedBox(width: DSSpacing.sm),
                          Text(
                            selectedTime != null
                                ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                                : 'Sélectionner une heure',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: DSSpacing.md),
                  TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      labelText: 'Message (optionnel)',
                      hintText: 'Ajoutez un message...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (selectedDate == null || selectedTime == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Veuillez sélectionner une date et une heure'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }
                  Navigator.pop(ctx);
                  final success = await ref.read(visitProvider.notifier).updateVisit(
                    visitId: visit.id,
                    status: 'RESCHEDULED',
                    rescheduledDate: selectedDate,
                    rescheduledTime: '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}',
                    rescheduledMessage: messageController.text.trim().isEmpty ? null : messageController.text.trim(),
                  );
                  if (!context.mounted) return;
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nouvelle date proposée'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    final error = ref.read(visitProvider).errorMessage;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(error ?? 'Erreur lors de la reprogrammation'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Proposer'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Visite visit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cet historique'),
        content: Text('Voulez-vous vraiment supprimer l\'historique de la demande de visite pour "${visit.propertyTitle ?? 'ce logement'}" du ${DateFormat('dd/MM/yyyy').format(visit.requestedDate)} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref.read(visitProvider.notifier).deleteVisit(visit.id);
              if (!context.mounted) return;
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Historique supprimé avec succès'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                final error = ref.read(visitProvider).errorMessage;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error ?? 'Erreur lors de la suppression'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
