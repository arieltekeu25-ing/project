import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/design_system/spacing/ds_spacing.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../home/widgets/property_card.dart';
import '../models/search_filter_model.dart';
import '../providers/search_provider.dart';
import '../widgets/search_filter_modal.dart';
import '../widgets/search_map_view.dart';

/// Page principale de recherche avancée et géolocalisée de logements réels
class SearchPage extends ConsumerStatefulWidget {
  final String? initialQuery;

  const SearchPage({
    super.key,
    this.initialQuery,
  });

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      Future.microtask(() {
        if (mounted) {
          ref.read(searchProvider.notifier).updateQuery(widget.initialQuery!);
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searchState = ref.watch(searchProvider);
    final filters = searchState.filters;

    return AppScaffold(
      title: 'Recherche de logements',
      showBackButton: true,
      onBackPressed: () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          context.go(AppConstants.routeHome);
        }
      },
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Actualiser',
          onPressed: () {
            ref.read(searchProvider.notifier).performSearch();
          },
        ),
        const SizedBox(width: 8),
      ],
      body: Column(
        children: [
          // 1. En-tête de recherche moderne (Hero Search Bar)
          Container(
            padding: const EdgeInsets.all(DSSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Champ de recherche + Bouton Filtres pro
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.dividerColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(fontSize: 15),
                          decoration: InputDecoration(
                            hintText: 'Ville, quartier, mot-clé...',
                            hintStyle: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: theme.colorScheme.primary,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded, size: 20),
                                    onPressed: () {
                                      _searchController.clear();
                                      ref.read(searchProvider.notifier).updateQuery('');
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          onChanged: (val) {
                            setState(() {});
                            ref.read(searchProvider.notifier).updateQuery(val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: DSSpacing.sm),

                    // Bouton Filtres avec badge actif
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => SearchFilterModal.show(context, ref),
                          icon: const Icon(Icons.tune_rounded, size: 20),
                          label: const Text(
                            'Filtres',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: filters.hasActiveFilters
                                ? theme.colorScheme.primary
                                : theme.colorScheme.primaryContainer,
                            foregroundColor: filters.hasActiveFilters
                                ? Colors.white
                                : theme.colorScheme.onPrimaryContainer,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: filters.hasActiveFilters ? 2 : 0,
                          ),
                        ),
                        if (filters.hasActiveFilters)
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${filters.activeFiltersCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: DSSpacing.md),

                // Mode de recherche & Selecteur de vue (Liste / Grille / Carte)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Modes de recherche (Simple / Avancée / IA)
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SegmentedButton<SearchMode>(
                          segments: const [
                            ButtonSegment(
                              value: SearchMode.manual,
                              label: Text('Simple'),
                              icon: Icon(Icons.search, size: 16),
                            ),
                            ButtonSegment(
                              value: SearchMode.advanced,
                              label: Text('Avancée'),
                              icon: Icon(Icons.tune, size: 16),
                            ),
                            ButtonSegment(
                              value: SearchMode.ai,
                              label: Text('IA'),
                              icon: Icon(Icons.auto_awesome, size: 16),
                            ),
                          ],
                          selected: {filters.mode},
                          onSelectionChanged: (newSelection) {
                            final selectedMode = newSelection.first;
                            if (selectedMode == SearchMode.ai) {
                              context.push('/chatbot');
                            } else {
                              ref.read(searchProvider.notifier).setSearchMode(selectedMode);
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Commutateur de vue (Liste / Grille / Carte)
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.view_list_rounded,
                              size: 20,
                              color: searchState.viewMode == SearchViewMode.list
                                  ? theme.colorScheme.primary
                                  : Colors.grey,
                            ),
                            onPressed: () => ref.read(searchProvider.notifier).setViewMode(SearchViewMode.list),
                            tooltip: 'Vue Liste',
                            visualDensity: VisualDensity.compact,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.grid_view_rounded,
                              size: 20,
                              color: searchState.viewMode == SearchViewMode.grid
                                  ? theme.colorScheme.primary
                                  : Colors.grey,
                            ),
                            onPressed: () => ref.read(searchProvider.notifier).setViewMode(SearchViewMode.grid),
                            tooltip: 'Vue Grille',
                            visualDensity: VisualDensity.compact,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.map_rounded,
                              size: 20,
                              color: searchState.viewMode == SearchViewMode.map
                                  ? theme.colorScheme.primary
                                  : Colors.grey,
                            ),
                            onPressed: () => ref.read(searchProvider.notifier).setViewMode(SearchViewMode.map),
                            tooltip: 'Vue Carte',
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Pilules / Chips des filtres actifs
          if (filters.hasActiveFilters) _buildActiveFilterPills(context, theme, filters),

          // 3. En-tête des résultats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DSSpacing.lg, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    searchState.isLoading
                        ? 'Recherche des biens...'
                        : '${searchState.results.length} logement${searchState.results.length > 1 ? 's' : ''} disponible${searchState.results.length > 1 ? 's' : ''}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (filters.userLatitude != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.gps_fixed, size: 12, color: Colors.blue),
                        SizedBox(width: 4),
                        Text(
                          'Proximité GPS',
                          style: TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // 4. Zone Principale des résultats (Liste / Grille / Carte / Skeleton)
          Expanded(
            child: searchState.isLoading
                ? _buildSkeletonLoading()
                : searchState.errorMessage != null
                    ? _buildErrorState(context, theme, searchState.errorMessage!)
                    : searchState.results.isEmpty
                        ? _buildEmptyState(context, theme)
                        : searchState.viewMode == SearchViewMode.map
                            ? SearchMapView(
                                properties: searchState.results,
                                userLatitude: filters.userLatitude,
                                userLongitude: filters.userLongitude,
                              )
                            : LayoutBuilder(
                                builder: (context, constraints) {
                                  final isDesktop = constraints.maxWidth > AppConstants.breakpointTablet;
                                  final useGrid = searchState.viewMode == SearchViewMode.grid || isDesktop;

                                  if (useGrid) {
                                    int crossAxisCount = constraints.maxWidth > AppConstants.breakpointDesktop ? 3 : 2;
                                    return GridView.builder(
                                      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.lg, vertical: DSSpacing.md),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        childAspectRatio: 0.75,
                                        crossAxisSpacing: DSSpacing.md,
                                        mainAxisSpacing: DSSpacing.md,
                                      ),
                                      itemCount: searchState.results.length,
                                      itemBuilder: (context, index) {
                                        final property = searchState.results[index];
                                        return SizedBox(
                                          height: 280,
                                          child: PropertyCard(
                                            property: property,
                                            onTap: () => context.push(
                                              AppConstants.routePropertyDetails.replaceFirst(':id', property.id),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  } else {
                                    return ListView.builder(
                                      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.lg, vertical: DSSpacing.md),
                                      itemCount: searchState.results.length,
                                      itemBuilder: (context, index) {
                                        final property = searchState.results[index];
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: DSSpacing.md),
                                          child: SizedBox(
                                            height: 280,
                                            child: PropertyCard(
                                              property: property,
                                              onTap: () => context.push(
                                                AppConstants.routePropertyDetails.replaceFirst(':id', property.id),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
          ),
        ],
      ),
    );
  }

  /// Barre horizontale de filtres actifs sous forme de chips détachables
  Widget _buildActiveFilterPills(BuildContext context, ThemeData theme, SearchFilterModel filters) {
    final List<Widget> pills = [];

    if (filters.city != null && filters.city!.isNotEmpty) {
      pills.add(InputChip(
        label: Text('Ville: ${filters.city}'),
        onDeleted: () {
          ref.read(searchProvider.notifier).applyFilters(filters.copyWith(clearCity: true));
        },
      ));
    }

    if (filters.district != null && filters.district!.isNotEmpty) {
      pills.add(InputChip(
        label: Text('Quartier: ${filters.district}'),
        onDeleted: () {
          ref.read(searchProvider.notifier).applyFilters(filters.copyWith(clearDistrict: true));
        },
      ));
    }

    if (filters.propertyType != null && filters.propertyType!.isNotEmpty) {
      pills.add(InputChip(
        label: Text('Type: ${filters.propertyType}'),
        onDeleted: () {
          ref.read(searchProvider.notifier).applyFilters(filters.copyWith(clearPropertyType: true));
        },
      ));
    }

    if (filters.minPrice != null || filters.maxPrice != null) {
      final minStr = filters.minPrice != null ? '${filters.minPrice!.toStringAsFixed(0)} FCFA' : '0';
      final maxStr = filters.maxPrice != null ? '${filters.maxPrice!.toStringAsFixed(0)} FCFA' : '∞';
      pills.add(InputChip(
        label: Text('Prix: $minStr - $maxStr'),
        onDeleted: () {
          ref.read(searchProvider.notifier).applyFilters(filters.copyWith(clearPrice: true));
        },
      ));
    }

    if (filters.userLatitude != null) {
      pills.add(InputChip(
        avatar: const Icon(Icons.gps_fixed, size: 14, color: Colors.blue),
        label: const Text('Autour de moi'),
        onDeleted: () {
          ref.read(searchProvider.notifier).clearLocation();
        },
      ));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.lg, vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ...pills.map((pill) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: pill,
                )),
            TextButton(
              onPressed: () {
                ref.read(searchProvider.notifier).resetFilters();
              },
              child: const Text('Tout effacer', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(DSSpacing.lg),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          height: 280,
          margin: const EdgeInsets.only(bottom: DSSpacing.md),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Aucun logement ne correspond à votre recherche.",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Essayez de modifier vos critères de filtrage ou élargissez votre périmètre géographique.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(searchProvider.notifier).resetFilters();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Réinitialiser la recherche'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ThemeData theme, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              'Erreur de recherche',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(searchProvider.notifier).performSearch();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
