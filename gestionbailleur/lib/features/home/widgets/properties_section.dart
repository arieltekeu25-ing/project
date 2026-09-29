import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../constants/app_strings.dart';
import '../models/property_model.dart';
import '../providers/property_provider.dart';
import 'property_card.dart';
import 'section_title.dart';

/// Section logements avec grille responsive
class PropertiesSection extends ConsumerStatefulWidget {
  const PropertiesSection({super.key});

  @override
  ConsumerState<PropertiesSection> createState() => _PropertiesSectionState();
}

class _PropertiesSectionState extends ConsumerState<PropertiesSection> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final propertyState = ref.watch(propertyProvider);
    final properties = propertyState.properties;
    final theme = Theme.of(context);

    // Charger les propriétés si pas encore chargées
    if (!propertyState.hasAttemptedFetch && !propertyState.isLoading) {
      Future.microtask(() => ref.read(propertyProvider.notifier).loadAllProperties());
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppConstants.spacingXXLarge,
        horizontal: AppConstants.spacingLarge,
      ),
      child: Column(
        children: [
          SectionTitle(
            title: AppStrings.properties,
            subtitle: 'Découvrez nos logements disponibles',
            action: TextButton(
              onPressed: () {
                context.go(AppConstants.routeSearch);
              },
              child: const Text('Voir tout'),
            ),
          ),
          if (propertyState.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(48.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (propertyState.errorMessage != null)
            Container(
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur de chargement',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    propertyState.errorMessage!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => ref.read(propertyProvider.notifier).loadAllProperties(refresh: true),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                  ),
                ],
              ),
            )
          else if (properties.isEmpty)
            Container(
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.home_work_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun logement disponible',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Revenez plus tard pour découvrir nos nouvelles offres',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.read(propertyProvider.notifier).loadAllProperties(refresh: true),
                    child: const Text('Actualiser'),
                  ),
                ],
              ),
            )
          else
            _buildPropertiesCarousel(context, ref, properties, theme),
        ],
      ),
    );
  }

  Widget _buildPropertiesCarousel(BuildContext context, WidgetRef ref, List<PropertyModel> properties, ThemeData theme) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWebDesktop = screenWidth >= 768;

    if (isWebDesktop) {
      // Version WEB / DESKTOP : Grille responsive avec max-width 1200px
      final crossAxisCount = screenWidth >= 1100 ? 3 : 2;
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: properties.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 24,
              crossAxisSpacing: 24,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              final property = properties[index];
              return PropertyCard(
                property: property,
                onTap: () {
                  context.go(AppConstants.routePropertyDetails.replaceFirst(':id', property.id));
                },
                onFavoriteToggle: () {
                  ref.read(propertyProvider.notifier).toggleFavorite(property.id);
                },
              );
            },
          ),
        ),
      );
    }

    // Version MOBILE : Carousel horizontal avec cartes de largeur fixe 300px
    return SizedBox(
      height: 380,
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: properties.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final property = properties[index];
                return SizedBox(
                  width: 300,
                  child: PropertyCard(
                    property: property,
                    onTap: () {
                      context.go(AppConstants.routePropertyDetails.replaceFirst(':id', property.id));
                    },
                    onFavoriteToggle: () {
                      ref.read(propertyProvider.notifier).toggleFavorite(property.id);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
