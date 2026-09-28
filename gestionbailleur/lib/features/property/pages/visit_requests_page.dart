import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/design_system/spacing/ds_spacing.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../domain/models/visite.dart';
import '../providers/visit_provider.dart';

/// Page des demandes de visite du client
class VisitRequestsPage extends ConsumerStatefulWidget {
  const VisitRequestsPage({super.key});

  @override
  ConsumerState<VisitRequestsPage> createState() => _VisitRequestsPageState();
}

class _VisitRequestsPageState extends ConsumerState<VisitRequestsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(visitProvider.notifier).loadMyVisits();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visitState = ref.watch(visitProvider);

    return AppScaffold(
      title: 'Mes demandes de visite',
      showBackButton: true,
      onBackPressed: () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          context.go(AppConstants.routeHome);
        }
      },
      body: visitState.isLoading && visitState.myVisits.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : visitState.myVisits.isEmpty && visitState.hasAttemptedFetch
              ? _buildEmptyState(context, theme)
              : RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(visitProvider.notifier).loadMyVisits(refresh: true);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(DSSpacing.lg),
                    itemCount: visitState.myVisits.length,
                    itemBuilder: (context, index) {
                      final visit = visitState.myVisits[index];
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
            Icons.calendar_month_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: DSSpacing.md),
          Text(
            'Vous n\'avez aucune demande de visite',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          Text(
            'Parcourez les logements et demandez une visite',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: DSSpacing.xl),
          ElevatedButton.icon(
            onPressed: () => context.go(AppConstants.routeHome),
            icon: const Icon(Icons.search),
            label: const Text('Explorer les logements'),
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
      child: InkWell(
        onTap: () => _showVisitDetailDialog(context, visit, theme),
        borderRadius: BorderRadius.circular(16),
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
                        if (visit.propertyAddress != null)
                          Text(
                            visit.propertyAddress!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 8),
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
              // Actions for cancellable visits
              if (visit.status == 'PENDING' || visit.status == 'RESCHEDULED') ...[
                const SizedBox(height: DSSpacing.md),
                OutlinedButton.icon(
                  onPressed: () => _showCancelDialog(context, visit),
                  icon: const Icon(Icons.cancel, size: 16),
                  label: const Text('Annuler'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ],
            ],
          ),
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

  void _showVisitDetailDialog(BuildContext context, Visite visit, ThemeData theme) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Détails de la demande'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Logement', visit.propertyTitle ?? 'N/A'),
              _buildDetailRow('Date demandée', DateFormat('dd/MM/yyyy').format(visit.requestedDate)),
              _buildDetailRow('Heure demandée', visit.requestedTime),
              if (visit.message != null && visit.message!.isNotEmpty)
                _buildDetailRow('Message', visit.message!),
              _buildDetailRow('Statut', _getStatusLabel(visit.status)),
              if (visit.landlordResponse != null && visit.landlordResponse!.isNotEmpty)
                _buildDetailRow('Réponse du bailleur', visit.landlordResponse!),
              if (visit.rescheduledDate != null)
                _buildDetailRow('Nouvelle date', DateFormat('dd/MM/yyyy').format(visit.rescheduledDate!)),
              if (visit.rescheduledTime != null)
                _buildDetailRow('Nouvelle heure', visit.rescheduledTime!),
              if (visit.rescheduledMessage != null && visit.rescheduledMessage!.isNotEmpty)
                _buildDetailRow('Message de reprogrammation', visit.rescheduledMessage!),
              const SizedBox(height: DSSpacing.md),
              Text(
                'Créée le ${DateFormat('dd/MM/yyyy à HH:mm').format(visit.createdAt)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, Visite visit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Annuler la demande'),
        content: Text('Voulez-vous vraiment annuler votre demande de visite pour "${visit.propertyTitle ?? 'ce logement'}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref.read(visitProvider.notifier).cancelVisit(visit.id);
              if (!context.mounted) return;
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Demande annulée avec succès'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                final error = ref.read(visitProvider).errorMessage;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error ?? 'Erreur lors de l\'annulation'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
  }
}
