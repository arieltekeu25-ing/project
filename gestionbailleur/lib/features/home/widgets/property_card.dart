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
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image avec badge et bouton favori
            SizedBox(
              height: 180,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: _buildPropertyImage(property),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _buildStatusBadge(property.status, theme),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
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
            // Contenu de la carte
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Prix
                        Text(
                          property.formattedPrice,
                          style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Titre
                        Text(
                          property.title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        // Localisation
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                property.city.isNotEmpty
                                    ? '${property.city}${property.district.isNotEmpty ? ", " + property.district : ""}'
                                    : (property.district.isNotEmpty ? property.district : 'Emplacement non spécifié'),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[700],
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Caractéristiques
                        Row(
                          children: [
                            _buildFeature(Icons.bed, '${property.bedrooms} chb'),
                            const SizedBox(width: 12),
                            _buildFeature(Icons.bathtub, '${property.bathrooms} sdb'),
                            const SizedBox(width: 12),
                            _buildFeature(Icons.square_foot, property.formattedSurface),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Bouton voir détails
                    SizedBox(
                      width: double.infinity,
                      height: 36,
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          AppStrings.viewDetails,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(fontSize: 11, color: Colors.grey[700], fontWeight: FontWeight.w500),
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
