import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_constants.dart';
import '../constants/app_strings.dart';
import '../models/property_model.dart';
import 'favorite_button.dart';
import '../../favorites/providers/favorites_provider.dart';

/// Carte de logement réutilisable avec synchronisation globale du statut favori
class PropertyCard extends ConsumerWidget {
  final PropertyModel property;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;

  const PropertyCard({
    super.key,
    required this.property,
    this.onTap,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final favState = ref.watch(favoritesProvider);
    final isFavoriteGlobal = favState.favoriteIds.contains(property.id) || property.isFavorite;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image avec badge et bouton favori
            SizedBox(
              height: 150,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppConstants.borderRadiusLarge),
                      ),
                      child: _buildPropertyImage(property),
                    ),
                  ),
                  Positioned(
                    top: AppConstants.spacingSmall,
                    left: AppConstants.spacingSmall,
                    child: _buildStatusBadge(property.status, theme),
                  ),
                  Positioned(
                    top: AppConstants.spacingSmall,
                    right: AppConstants.spacingSmall,
                    child: FavoriteButton(
                      isFavorite: isFavoriteGlobal,
                      isLoading: ref.watch(favoritesProvider).actionPropertyIdLoading == property.id,
                      onToggle: onFavoriteToggle ?? () {
                        ref.read(favoritesProvider.notifier).toggleFavorite(
                          property: property,
                          context: context,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Contenu
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingXSmall),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Prix
                      Text(
                        property.formattedPrice,
                        style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      // Titre
                      Text(
                        property.title,
                        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      // Description (tronquée)
                      if (property.description.isNotEmpty) ...[
                        Text(
                          property.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                      ],
                      // Localisation
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 10, color: Colors.grey),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              property.city.isNotEmpty ? '${property.city}, ${property.district}' : property.district,
                              style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Caractéristiques
                      Row(
                        children: [
                          Expanded(
                            child: _buildFeature(
                              Icons.bed,
                              '${property.bedrooms}',
                            ),
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: _buildFeature(
                              Icons.bathtub,
                              '${property.bathrooms}',
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: _buildFeature(
                              Icons.square_foot,
                              property.formattedSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Bouton voir détails
                      SizedBox(
                        width: double.infinity,
                        height: 24,
                        child: OutlinedButton(
                          onPressed: onTap,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(AppStrings.viewDetails, style: TextStyle(fontSize: 10)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 10, color: Colors.grey[600]),
        const SizedBox(width: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 9, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildPropertyImage(PropertyModel property) {
    // Priorité: mainPhoto -> première image de images -> première image de mediaList -> fallback
    String? imageUrl;
    
    if (property.mainPhoto != null && property.mainPhoto!.isNotEmpty) {
      imageUrl = property.mainPhoto;
    } else if (property.images.isNotEmpty) {
      imageUrl = property.images.first;
    } else if (property.mediaList.isNotEmpty) {
      final firstImage = property.mediaList.firstWhere(
        (m) => m.isImage,
        orElse: () => property.mediaList.first,
      );
      if (firstImage.isImage) {
        imageUrl = firstImage.secureUrl;
      }
    }
    
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 150,
          color: Colors.grey[300],
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) {
          // Log l'erreur pour debugging
          debugPrint('Error loading image: $error for URL: $imageUrl');
          return _buildFallbackImage(property);
        },
        maxWidthDiskCache: 800,
        maxHeightDiskCache: 600,
        memCacheWidth: 400,
        memCacheHeight: 300,
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 300),
      );
    }
    
    return _buildFallbackImage(property);
  }

  Widget _buildFallbackImage(PropertyModel property) {
    return Container(
      height: 150,
      width: double.infinity,
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getPropertyTypeIcon(property.propertyType),
            size: 50,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 8),
          Text(
            _getPropertyTypeLabel(property.propertyType),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPropertyTypeIcon(String propertyType) {
    switch (propertyType.toUpperCase()) {
      case 'APARTMENT':
        return Icons.apartment;
      case 'HOUSE':
        return Icons.home;
      case 'STUDIO':
        return Icons.weekend;
      case 'VILLA':
        return Icons.villa;
      case 'LOFT':
        return Icons.domain;
      default:
        return Icons.home_work;
    }
  }

  String _getPropertyTypeLabel(String propertyType) {
    switch (propertyType.toUpperCase()) {
      case 'APARTMENT':
        return 'Appartement';
      case 'HOUSE':
        return 'Maison';
      case 'STUDIO':
        return 'Studio';
      case 'VILLA':
        return 'Villa';
      case 'LOFT':
        return 'Loft';
      default:
        return 'Logement';
    }
  }

  Widget _buildStatusBadge(String status, ThemeData theme) {
    String badgeText;
    Color badgeColor;
    
    switch (status) {
      case 'AVAILABLE':
      case 'PUBLISHED':
        badgeText = 'Disponible';
        badgeColor = Colors.green;
        break;
      case 'RENTED':
        badgeText = 'Loué';
        badgeColor = Colors.orange;
        break;
      case 'DRAFT':
        badgeText = 'Brouillon';
        badgeColor = Colors.grey;
        break;
      default:
        badgeText = status;
        badgeColor = Colors.blue;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSmall,
        vertical: AppConstants.spacingXSmall,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      child: Text(
        badgeText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
