import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../constants/app_strings.dart';
import '../models/category_model.dart';
import '../providers/property_provider.dart';
import 'category_card.dart';
import 'section_title.dart';

/// Section catégories avec grille responsive alimentée par les données réelles
class CategoriesSection extends ConsumerWidget {
  const CategoriesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertyState = ref.watch(propertyProvider);
    final properties = propertyState.properties;
    final theme = Theme.of(context);

    int countForType(String type) {
      return properties.where((p) => p.propertyType.toUpperCase() == type.toUpperCase()).length;
    }

    final categories = [
      CategoryModel(
        id: 'APARTMENT',
        title: 'Appartement',
        icon: 'apartment',
        propertyCount: countForType('APARTMENT'),
        backgroundColor: theme.colorScheme.primary,
        // backgroundImageUrl sera ajouté quand le backend supportera les images de catégorie
      ),
      CategoryModel(
        id: 'HOUSE',
        title: 'Maison',
        icon: 'home',
        propertyCount: countForType('HOUSE'),
        backgroundColor: Colors.teal.shade700,
      ),
      CategoryModel(
        id: 'STUDIO',
        title: 'Studio',
        icon: 'bed',
        propertyCount: countForType('STUDIO'),
        backgroundColor: theme.colorScheme.secondary,
      ),
      CategoryModel(
        id: 'VILLA',
        title: 'Villa',
        icon: 'villa',
        propertyCount: countForType('VILLA'),
        backgroundColor: Colors.deepPurple.shade600,
      ),
      CategoryModel(
        id: 'LOFT',
        title: 'Loft',
        icon: 'hotel',
        propertyCount: countForType('LOFT'),
        backgroundColor: Colors.orange.shade800,
      ),
      CategoryModel(
        id: 'OTHER',
        title: 'Autre',
        icon: 'store',
        propertyCount: countForType('OTHER'),
        backgroundColor: Colors.blueGrey.shade700,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppConstants.spacingXXLarge,
        horizontal: AppConstants.spacingLarge,
      ),
      child: Column(
        children: [
          SectionTitle(
            title: AppStrings.categories,
            subtitle: 'Explorez nos catégories de logements réels',
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount;
              double childAspectRatio;
              double crossAxisSpacing;
              double mainAxisSpacing;

              if (constraints.maxWidth > AppConstants.breakpointDesktop) {
                crossAxisCount = 4;
                childAspectRatio = 1.15;
                crossAxisSpacing = AppConstants.spacingMedium;
                mainAxisSpacing = AppConstants.spacingMedium;
              } else if (constraints.maxWidth > AppConstants.breakpointTablet) {
                crossAxisCount = 3;
                childAspectRatio = 1.15;
                crossAxisSpacing = AppConstants.spacingMedium;
                mainAxisSpacing = AppConstants.spacingMedium;
              } else if (constraints.maxWidth > 400) {
                crossAxisCount = 2;
                childAspectRatio = 1.15;
                crossAxisSpacing = AppConstants.spacingMedium;
                mainAxisSpacing = AppConstants.spacingMedium;
              } else {
                crossAxisCount = 2;
                childAspectRatio = 1.3;
                crossAxisSpacing = AppConstants.spacingSmall;
                mainAxisSpacing = AppConstants.spacingSmall;
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: childAspectRatio,
                  crossAxisSpacing: crossAxisSpacing,
                  mainAxisSpacing: mainAxisSpacing,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final count = countForType(category.id);
                  return CategoryCard(
                    category: category.copyWith(propertyCount: count),
                    onTap: () {
                      if (count > 0) {
                        // Naviguer vers la recherche avec le type de propriété comme paramètre
                        context.go('/search?type=${category.id}');
                      } else {
                        // Afficher un message si aucun logement pour cette catégorie
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Il n\'existe pas encore de logement pour la catégorie: ${category.title}'),
                            backgroundColor: Colors.orange,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
