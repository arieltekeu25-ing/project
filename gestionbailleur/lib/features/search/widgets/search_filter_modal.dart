import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/cameroon_cities.dart';
import '../../../shared/design_system/spacing/ds_spacing.dart';
import '../models/search_filter_model.dart';
import '../models/search_options_model.dart';
import '../providers/search_provider.dart';

/// Modal de filtres de recherche ultra-professionnel avec UI/UX moderne
class SearchFilterModal extends ConsumerStatefulWidget {
  final SearchFilterModel initialFilters;
  final SearchOptionsModel options;

  const SearchFilterModal({
    super.key,
    required this.initialFilters,
    required this.options,
  });

  static Future<void> show(BuildContext context, WidgetRef ref) async {
    final searchState = ref.read(searchProvider);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SearchFilterModal(
        initialFilters: searchState.filters,
        options: searchState.options,
      ),
    );
  }

  @override
  ConsumerState<SearchFilterModal> createState() => _SearchFilterModalState();
}

class _SearchFilterModalState extends ConsumerState<SearchFilterModal> {
  late SearchFilterModel _currentFilters;

  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;
  late TextEditingController _minSurfaceController;

  @override
  void initState() {
    super.initState();
    _currentFilters = widget.initialFilters;

    _minPriceController = TextEditingController(
      text: _currentFilters.minPrice != null
          ? _currentFilters.minPrice!.toStringAsFixed(0)
          : '',
    );
    _maxPriceController = TextEditingController(
      text: _currentFilters.maxPrice != null
          ? _currentFilters.maxPrice!.toStringAsFixed(0)
          : '',
    );
    _minSurfaceController = TextEditingController(
      text: _currentFilters.minSurface != null
          ? _currentFilters.minSurface!.toStringAsFixed(0)
          : '',
    );

    // Ajouter des listeners pour la recherche en temps réel sur le budget
    _minPriceController.addListener(_onPriceChanged);
    _maxPriceController.addListener(_onPriceChanged);
  }

  void _onPriceChanged() {
    final double? minP = double.tryParse(_minPriceController.text.trim());
    final double? maxP = double.tryParse(_maxPriceController.text.trim());
    
    // Mettre à jour les filtres en temps réel
    setState(() {
      _currentFilters = _currentFilters.copyWith(
        minPrice: minP,
        maxPrice: maxP,
        clearPrice: minP == null && maxP == null,
      );
    });
    
    // Recherche en temps réel avec debounce
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        final updated = _currentFilters.copyWith(
          minPrice: minP,
          maxPrice: maxP,
          clearPrice: minP == null && maxP == null,
        );
        ref.read(searchProvider.notifier).applyFilters(updated);
      }
    });
  }

  @override
  void dispose() {
    _minPriceController.removeListener(_onPriceChanged);
    _maxPriceController.removeListener(_onPriceChanged);
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _minSurfaceController.dispose();
    super.dispose();
  }

  void _apply() {
    final double? minP = double.tryParse(_minPriceController.text.trim());
    final double? maxP = double.tryParse(_maxPriceController.text.trim());
    final double? minS = double.tryParse(_minSurfaceController.text.trim());

    final updated = _currentFilters.copyWith(
      minPrice: minP,
      maxPrice: maxP,
      minSurface: minS,
      clearPrice: minP == null && maxP == null,
      clearSurface: minS == null,
    );

    ref.read(searchProvider.notifier).applyFilters(updated);
    Navigator.of(context).pop();
  }

  void _reset() {
    setState(() {
      _currentFilters = const SearchFilterModel();
      _minPriceController.clear();
      _maxPriceController.clear();
      _minSurfaceController.clear();
    });
  }

  void _setPresetBudget(double? min, double? max) {
    setState(() {
      _currentFilters = _currentFilters.copyWith(
        minPrice: min,
        maxPrice: max,
        clearPrice: min == null && max == null,
      );
      _minPriceController.text = min != null ? min.toStringAsFixed(0) : '';
      _maxPriceController.text = max != null ? max.toStringAsFixed(0) : '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searchState = ref.watch(searchProvider);
    final resultCount = searchState.results.length;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Drag Handle
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Header Modal
              Padding(
                padding: const EdgeInsets.fromLTRB(DSSpacing.lg, 12, DSSpacing.lg, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Filtres de recherche',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Affinez vos critères pour trouver le logement idéal',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: _reset,
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text('Réinit.'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Contenu principal défilant
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(DSSpacing.lg),
                  children: [
                    // Bannière Assistant IA dans la modal de filtres
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/chatbot');
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: DSSpacing.lg),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [theme.colorScheme.primary, const Color(0xFF00796B)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.auto_awesome, color: Colors.amber, size: 24),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Recherche guidée par IA',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  Text(
                                    'Posez votre demande en langage naturel à l\'Assistant GestBailleur',
                                    style: TextStyle(color: Colors.white70, fontSize: 11.5),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                          ],
                        ),
                      ),
                    ),

                    // 1. Géolocalisation GPS
                    _buildSectionContainer(
                      theme: theme,
                      child: _buildGPSSection(theme, searchState),
                    ),
                    const SizedBox(height: DSSpacing.lg),

                    // 2. Localisation (Ville & Quartier)
                    _buildSectionContainer(
                      theme: theme,
                      title: 'Localisation',
                      icon: Icons.location_on_rounded,
                      child: Column(
                        children: [
                          _buildCityDropdown(theme),
                          if (widget.options.districts.isNotEmpty) ...[
                            const SizedBox(height: DSSpacing.md),
                            _buildDistrictDropdown(theme),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: DSSpacing.lg),

                    // 3. Type de logement
                    _buildSectionContainer(
                      theme: theme,
                      title: 'Type de bien',
                      icon: Icons.apartment_rounded,
                      child: _buildPropertyTypeChips(theme),
                    ),
                    const SizedBox(height: DSSpacing.lg),

                    // 4. Budget Mensuel (FCFA)
                    _buildSectionContainer(
                      theme: theme,
                      title: 'Budget mensuel (FCFA)',
                      icon: Icons.payments_rounded,
                      child: _buildBudgetSection(theme),
                    ),
                    const SizedBox(height: DSSpacing.lg),

                    // 5. Chambres & Surface
                    _buildSectionContainer(
                      theme: theme,
                      title: 'Pièces & Caractéristiques',
                      icon: Icons.single_bed_rounded,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBedroomsChips(theme),
                          const SizedBox(height: DSSpacing.lg),
                          _buildSurfaceField(theme),
                          const SizedBox(height: DSSpacing.md),
                          _buildFurnishedSwitch(theme),
                        ],
                      ),
                    ),
                    const SizedBox(height: DSSpacing.lg),

                    // 6. Tri & Pertinence
                    _buildSectionContainer(
                      theme: theme,
                      title: 'Trier les résultats',
                      icon: Icons.swap_vert_rounded,
                      child: _buildOrderingSelector(theme),
                    ),
                    const SizedBox(height: DSSpacing.xl),
                  ],
                ),
              ),

              // Sticky Bottom Action Bar
              Container(
                padding: const EdgeInsets.all(DSSpacing.lg),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final applyLabel =
                          'Voir $resultCount résultat${resultCount > 1 ? 's' : ''}';
                      return Row(
                        children: [
                          if (_currentFilters.hasActiveFilters) ...[
                            Expanded(
                              flex: 2,
                              child: OutlinedButton(
                                onPressed: _reset,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  'Effacer',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const SizedBox(width: DSSpacing.sm),
                          ],
                          Expanded(
                            flex: 3,
                            child: ElevatedButton(
                              onPressed: _apply,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 8,
                                ),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                applyLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionContainer({
    required ThemeData theme,
    required Widget child,
    String? title,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.md),
          ],
          child,
        ],
      ),
    );
  }

  Widget _buildGPSSection(ThemeData theme, SearchState searchState) {
    final hasLocation = _currentFilters.userLatitude != null;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: hasLocation
                ? Colors.green.withValues(alpha: 0.15)
                : theme.colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            hasLocation ? Icons.gps_fixed : Icons.my_location,
            color: hasLocation ? Colors.green.shade800 : theme.colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: DSSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hasLocation ? 'Autour de moi (GPS Actif)' : 'Rechercher par proximité GPS',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                hasLocation
                    ? 'Affiche les logements proches de votre position'
                    : 'Utilise la position réelle de votre appareil',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        if (searchState.isLocating)
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          )
        else if (hasLocation)
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.grey),
            onPressed: () {
              ref.read(searchProvider.notifier).clearLocation();
              setState(() {
                _currentFilters = _currentFilters.copyWith(clearLocation: true);
              });
            },
          )
        else
          Flexible(
            child: ElevatedButton(
              onPressed: () async {
                await ref.read(searchProvider.notifier).requestGPSLocationAndSearch();
                final updatedState = ref.read(searchProvider);
                setState(() {
                  _currentFilters = updatedState.filters;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Activer', maxLines: 1),
            ),
          ),
      ],
    );
  }

  Widget _buildCityDropdown(ThemeData theme) {
    return DropdownButtonFormField<String?>(
      key: ValueKey('city_${_currentFilters.city}'),
      decoration: InputDecoration(
        labelText: 'Ville',
        hintText: 'Toutes les villes',
        prefixIcon: const Icon(Icons.location_city_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      initialValue: _currentFilters.city,
      items: [
        const DropdownMenuItem<String?>(
          value: null,
          child: Text('Toutes les villes'),
        ),
        ...CameroonCities.allCities.map((city) => DropdownMenuItem<String?>(
              value: city,
              child: Text(city),
            )),
      ],
      onChanged: (val) {
        setState(() {
          _currentFilters = _currentFilters.copyWith(
            city: val,
            district: null, // Réinitialiser le quartier quand la ville change
            clearCity: val == null,
          );
        });
      },
    );
  }

  Widget _buildDistrictDropdown(ThemeData theme) {
    // Si une ville est sélectionnée, utiliser ses quartiers
    List<String> districts = widget.options.districts;
    if (_currentFilters.city != null && CameroonCities.citiesAndDistricts.containsKey(_currentFilters.city)) {
      districts = CameroonCities.getDistricts(_currentFilters.city!);
    } else {
      districts = CameroonCities.allDistricts;
    }

    // Éliminer les doublons
    final uniqueDistricts = districts.toSet().toList();

    return StatefulBuilder(
      builder: (context, setModalState) {
        return DropdownButtonFormField<String?>(
          key: ValueKey('district_${_currentFilters.district}'),
          decoration: InputDecoration(
            labelText: 'Quartier / Zone',
            hintText: 'Tous les quartiers',
            prefixIcon: const Icon(Icons.map_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          initialValue: _currentFilters.district,
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('Tous les quartiers'),
            ),
            ...uniqueDistricts.map((d) => DropdownMenuItem<String?>(
                  value: d,
                  child: Text(d),
                )),
          ],
          onChanged: (val) {
            setModalState(() {
              _currentFilters = _currentFilters.copyWith(
                district: val,
                clearDistrict: val == null,
              );
            });
          },
        );
      },
    );
  }

  Widget _buildPropertyTypeChips(ThemeData theme) {
    final typesInDb = widget.options.propertyTypes;
    final fallbackTypes = CameroonCities.propertyTypes;

    final typeLabels = {
      'APARTMENT': '🏢 Appartement',
      'HOUSE': '🏡 Maison',
      'STUDIO': '🛋️ Studio',
      'LOFT': '🏭 Loft',
      'VILLA': '🏰 Villa',
      'TERRACE': '🌿 Terrasse',
      'OTHER': '🏠 Autre',
    };

    // Utiliser les types du backend ou ceux par défaut du Cameroun
    final typesToShow = typesInDb.isNotEmpty ? typesInDb : fallbackTypes;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          label: const Text('Tous les types'),
          selected: _currentFilters.propertyType == null,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _currentFilters = _currentFilters.copyWith(clearPropertyType: true);
              });
            }
          },
          selectedColor: theme.colorScheme.primary.withValues(alpha: 0.15),
          checkmarkColor: theme.colorScheme.primary,
        ),
        ...typesToShow.map((typeKey) {
          final label = typeLabels[typeKey] ?? typeKey;
          final isSel = _currentFilters.propertyType == typeKey;
          return FilterChip(
            label: Text(label),
            selected: isSel,
            onSelected: (selected) {
              setState(() {
                _currentFilters = _currentFilters.copyWith(
                  propertyType: selected ? typeKey : null,
                  clearPropertyType: !selected,
                );
              });
            },
            selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
            checkmarkColor: theme.colorScheme.primary,
          );
        }),
      ],
    );
  }

  Widget _buildBudgetSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Raccourcis budget
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildBudgetPresetChip('0 - 50k', 0, 50000, theme),
              const SizedBox(width: 6),
              _buildBudgetPresetChip('100k - 250k', 100000, 250000, theme),
              const SizedBox(width: 6),
              _buildBudgetPresetChip('250k - 750k', 250000, 750000, theme),
              const SizedBox(width: 6),
              _buildBudgetPresetChip('750k+', 750000, null, theme),
            ],
          ),
        ),
        const SizedBox(height: DSSpacing.md),

        // Saisie manuelle Min - Max
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _minPriceController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Minimum',
                  hintText: '0',
                  suffixText: 'FCFA',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _maxPriceController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Maximum',
                  hintText: 'Sans limite',
                  suffixText: 'FCFA',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBudgetPresetChip(String label, double? min, double? max, ThemeData theme) {
    final isSelected = _currentFilters.minPrice == min && _currentFilters.maxPrice == max;

    return ActionChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      backgroundColor: isSelected
          ? theme.colorScheme.primary.withValues(alpha: 0.15)
          : theme.colorScheme.surface,
      side: BorderSide(
        color: isSelected ? theme.colorScheme.primary : theme.dividerColor.withValues(alpha: 0.5),
      ),
      onPressed: () => _setPresetBudget(min, max),
    );
  }

  Widget _buildBedroomsChips(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nombre de chambres minimales',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: const Text('Indifférent'),
              selected: _currentFilters.bedrooms == null,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _currentFilters = _currentFilters.copyWith(clearBedrooms: true);
                  });
                }
              },
            ),
            ...[1, 2, 3, 4].map((count) {
              final isSel = _currentFilters.bedrooms == count;
              return FilterChip(
                label: Text('$count+'),
                selected: isSel,
                onSelected: (selected) {
                  setState(() {
                    _currentFilters = _currentFilters.copyWith(
                      bedrooms: selected ? count : null,
                      clearBedrooms: !selected,
                    );
                  });
                },
                selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                checkmarkColor: theme.colorScheme.primary,
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildSurfaceField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Surface minimale',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _minSurfaceController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: 'ex: 50',
            suffixText: 'm²',
            prefixIcon: const Icon(Icons.aspect_ratio_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildFurnishedSwitch(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
      ),
      child: SwitchListTile(
        title: const Text('Meublé uniquement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: const Text('Afficher seulement les logements meublés', style: TextStyle(fontSize: 12)),
        value: _currentFilters.furnished ?? false,
        onChanged: (val) {
          setState(() {
            _currentFilters = _currentFilters.copyWith(furnished: val);
          });
        },
      ),
    );
  }

  Widget _buildOrderingSelector(ThemeData theme) {
    final options = [
      {'val': '-created_at', 'label': '⚡ Plus récents en premier', 'icon': Icons.flash_on_rounded},
      {'val': 'rent_price', 'label': '💵 Prix croissant (moins cher)', 'icon': Icons.arrow_upward_rounded},
      {'val': '-rent_price', 'label': '💰 Prix décroissant (plus cher)', 'icon': Icons.arrow_downward_rounded},
      {'val': 'distance', 'label': '📍 Proximité géolocalisée (GPS)', 'icon': Icons.near_me_rounded},
      {'val': '-views_count', 'label': '🔥 Les plus consultés', 'icon': Icons.local_fire_department_rounded},
    ];

    return Column(
      children: options.map((opt) {
        final isSel = _currentFilters.ordering == opt['val'];
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            color: isSel
                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSel ? theme.colorScheme.primary : theme.dividerColor.withValues(alpha: 0.3),
            ),
          ),
          child: ListTile(
            dense: true,
            leading: Icon(
              opt['icon'] as IconData,
              color: isSel ? theme.colorScheme.primary : Colors.grey,
            ),
            title: Text(
              opt['label'] as String,
              style: TextStyle(
                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                color: isSel ? theme.colorScheme.primary : theme.colorScheme.onSurface,
              ),
            ),
            trailing: isSel ? Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 20) : null,
            onTap: () {
              setState(() {
                _currentFilters = _currentFilters.copyWith(ordering: opt['val'] as String);
              });
            },
          ),
        );
      }).toList(),
    );
  }
}
