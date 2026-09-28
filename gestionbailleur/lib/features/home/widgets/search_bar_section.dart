import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../search/models/search_filter_model.dart';
import '../../search/providers/search_provider.dart';
import 'custom_button.dart';

/// Barre de recherche moderne sur la page d'accueil alimentée dynamiquement par PostgreSQL
class SearchBarSection extends ConsumerStatefulWidget {
  const SearchBarSection({super.key});

  @override
  ConsumerState<SearchBarSection> createState() => _SearchBarSectionState();
}

class _SearchBarSectionState extends ConsumerState<SearchBarSection> {
  String? _selectedCity;
  String? _selectedDistrict;
  String? _selectedPropertyType;
  String? _selectedBudget;
  List<String> _filteredDistricts = [];

  final Map<String, String> _typeLabels = const {
    'APARTMENT': 'Appartement',
    'HOUSE': 'Maison',
    'STUDIO': 'Studio',
    'VILLA': 'Villa',
    'LOFT': 'Loft',
    'TERRACE': 'Terrasse',
    'OTHER': 'Autre',
  };

  @override
  void initState() {
    super.initState();
    // Charger les options de recherche si elles ne sont pas déjà chargées
    Future.microtask(() {
      final searchState = ref.read(searchProvider);
      if (searchState.options.cities.isEmpty && 
          searchState.options.districts.isEmpty && 
          searchState.options.propertyTypes.isEmpty) {
        ref.read(searchProvider.notifier).loadFilterOptions();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final options = searchState.options;

    final cities = options.cities;
    // Filtrer les districts en fonction de la ville sélectionnée
    final districts = _filteredDistricts.isEmpty ? options.districts : _filteredDistricts;
    final dbTypes = options.propertyTypes;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingXLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusXLarge),
        boxShadow: AppConstants.shadowLarge,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > AppConstants.breakpointTablet) {
            return _buildDesktopLayout(context, cities, districts, dbTypes);
          } else {
            return _buildMobileLayout(context, cities, districts, dbTypes);
          }
        },
      ),
    );
  }

  Widget _buildDesktopLayout(
      BuildContext context, List<String> cities, List<String> districts, List<String> dbTypes) {
    return Row(
      children: [
        Expanded(
          child: _buildDropdownField(
            label: 'Ville',
            value: _selectedCity,
            items: cities,
            onChanged: (value) {
              setState(() {
                _selectedCity = value;
                _selectedDistrict = null;
                _filteredDistricts = [];
              });
              // Filtrer les districts en fonction de la ville sélectionnée
              if (value != null && value.isNotEmpty) {
                final searchState = ref.read(searchProvider);
                final allDistricts = searchState.options.districts;
                // Ici on pourrait filtrer les districts par ville si l'API fournit cette relation
                // Pour l'instant, on garde tous les districts
                _filteredDistricts = allDistricts;
              }
            },
          ),
        ),
        const SizedBox(width: AppConstants.spacingMedium),
        Expanded(
          child: _buildDropdownField(
            label: 'Quartier',
            value: _selectedDistrict,
            items: districts,
            onChanged: (value) => setState(() => _selectedDistrict = value),
          ),
        ),
        const SizedBox(width: AppConstants.spacingMedium),
        Expanded(
          child: _buildDropdownField(
            label: 'Type de bien',
            value: _selectedPropertyType,
            items: dbTypes.map((t) => _typeLabels[t] ?? t).toList(),
            onChanged: (value) => setState(() => _selectedPropertyType = value),
          ),
        ),
        const SizedBox(width: AppConstants.spacingMedium),
        Expanded(
          child: _buildBudgetDropdown(),
        ),
        const SizedBox(width: AppConstants.spacingMedium),
        CustomButton(
          text: 'Rechercher',
          icon: Icons.search,
          onPressed: _handleSearch,
          height: 56,
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
      BuildContext context, List<String> cities, List<String> districts, List<String> dbTypes) {
    return Column(
      children: [
        _buildDropdownField(
          label: 'Ville',
          value: _selectedCity,
          items: cities,
          onChanged: (value) {
            setState(() {
              _selectedCity = value;
              _selectedDistrict = null;
              _filteredDistricts = [];
            });
            // Filtrer les districts en fonction de la ville sélectionnée
            if (value != null && value.isNotEmpty) {
              final searchState = ref.read(searchProvider);
              final allDistricts = searchState.options.districts;
              _filteredDistricts = allDistricts;
            }
          },
        ),
        const SizedBox(height: AppConstants.spacingMedium),
        _buildDropdownField(
          label: 'Quartier',
          value: _selectedDistrict,
          items: districts,
          onChanged: (value) => setState(() => _selectedDistrict = value),
        ),
        const SizedBox(height: AppConstants.spacingMedium),
        _buildDropdownField(
          label: 'Type de bien',
          value: _selectedPropertyType,
          items: dbTypes.map((t) => _typeLabels[t] ?? t).toList(),
          onChanged: (value) => setState(() => _selectedPropertyType = value),
        ),
        const SizedBox(height: AppConstants.spacingMedium),
        _buildBudgetDropdown(),
        const SizedBox(height: AppConstants.spacingMedium),
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: 'Rechercher',
            icon: Icons.search,
            onPressed: _handleSearch,
            height: 56,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppConstants.spacingXSmall),
        DropdownButtonFormField<String?>(
          initialValue: value,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: 'Tous ($label)',
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingMedium,
              vertical: AppConstants.spacingSmall,
            ),
          ),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text('Tous ($label)'),
            ),
            ...items.map((String item) {
              return DropdownMenuItem<String?>(
                value: item,
                child: Text(item, overflow: TextOverflow.ellipsis),
              );
            }),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildBudgetDropdown() {
    // Plages de budget FCFA fixes et uniques — pas de génération dynamique
    // qui peut produire des doublons et faire crasher le DropdownButton Flutter.
    const List<String> budgets = [
      '0 - 50 000 FCFA',
      '50 000 - 100 000 FCFA',
      '100 000 - 250 000 FCFA',
      '250 000 - 500 000 FCFA',
      '500 000 - 1 000 000 FCFA',
      '1 000 000 FCFA+',
    ];

    // Réinitialiser la sélection si elle ne correspond plus à une valeur valide
    if (_selectedBudget != null && !budgets.contains(_selectedBudget)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedBudget = null);
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Budget',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppConstants.spacingXSmall),
        DropdownButtonFormField<String?>(
          key: const ValueKey('budget_dropdown'),
          value: (budgets.contains(_selectedBudget)) ? _selectedBudget : null,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: 'Tous les budgets',
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingMedium,
              vertical: AppConstants.spacingSmall,
            ),
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('Tous les budgets'),
            ),
            ...budgets.map((b) => DropdownMenuItem<String?>(
                  value: b,
                  child: Text(b, overflow: TextOverflow.ellipsis),
                )),
          ],
          onChanged: (val) => setState(() => _selectedBudget = val),
        ),
      ],
    );
  }

  /// Parse une plage de budget affichée ("50000 - 100000 FCFA" ou "500000 FCFA+")
  ({double? min, double? max}) _parseBudget(String? budget) {
    if (budget == null || budget.isEmpty) return (min: null, max: null);

    final cleaned = budget
        .replaceAll('FCFA', '')
        .replaceAll(' ', '')
        .replaceAll('\u00A0', '')
        .trim();

    if (cleaned.endsWith('+')) {
      final min = double.tryParse(cleaned.replaceAll('+', '').replaceAll(',', ''));
      return (min: min, max: null);
    }

    final parts = cleaned.split('-');
    if (parts.length >= 2) {
      final min = double.tryParse(parts[0].replaceAll(',', ''));
      final max = double.tryParse(parts[1].replaceAll(',', ''));
      return (min: min, max: max);
    }

    final single = double.tryParse(cleaned.replaceAll(',', ''));
    return (min: single, max: single);
  }

  void _handleSearch() {
    String? typeEnum;
    if (_selectedPropertyType != null && _selectedPropertyType!.isNotEmpty) {
      _typeLabels.forEach((key, value) {
        if (value == _selectedPropertyType) {
          typeEnum = key;
        }
      });
      typeEnum ??= _selectedPropertyType;
    }

    final budget = _parseBudget(_selectedBudget);

    final newFilters = SearchFilterModel(
      city: _selectedCity,
      district: _selectedDistrict,
      propertyType: typeEnum,
      minPrice: budget.min,
      maxPrice: budget.max,
    );

    ref.read(searchProvider.notifier).applyFilters(newFilters);
    ref.read(searchProvider.notifier).performSearch();
    context.go(AppConstants.routeSearch);
  }
}
