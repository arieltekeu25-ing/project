import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/design_system/buttons/ds_button.dart';
import '../../../shared/design_system/spacing/ds_spacing.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../home/models/property_model.dart';
import '../../home/providers/property_provider.dart';
import '../../favorites/providers/favorites_provider.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../chat/providers/chat_provider.dart';
import '../widgets/cloudinary_video_player_widget.dart';
import '../widgets/visit_request_dialog.dart';

/// Page de détails d'un logement réel
class PropertyDetailsPage extends ConsumerStatefulWidget {
  final String propertyId;

  const PropertyDetailsPage({super.key, required this.propertyId});

  @override
  ConsumerState<PropertyDetailsPage> createState() => _PropertyDetailsPageState();
}

class _PropertyDetailsPageState extends ConsumerState<PropertyDetailsPage> {
  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(propertyProvider.notifier).loadPropertyById(widget.propertyId);
      ref.read(favoritesProvider.notifier).loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final propertyState = ref.watch(propertyProvider);
    final property = propertyState.selectedProperty;

    if (propertyState.isLoading && property == null) {
      return const AppScaffold(
        title: 'Détails du logement',
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (property == null || property.id != widget.propertyId) {
      // Chercher si le logement est déjà présent dans la liste globale
      final foundInList = propertyState.properties.where((p) => p.id == widget.propertyId).firstOrNull;
      if (foundInList != null) {
        return _buildContent(context, foundInList, theme);
      }

      return AppScaffold(
        title: 'Logement introuvable',
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.home_work_outlined, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
              const SizedBox(height: DSSpacing.md),
              Text(
                'Ce logement n\'est pas disponible ou a été retiré.',
                style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: DSSpacing.lg),
              ElevatedButton.icon(
                onPressed: () => context.go(AppConstants.routeHome),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Retour à l\'accueil'),
              ),
            ],
          ),
        ),
      );
    }

    return _buildContent(context, property, theme);
  }

  Widget _buildContent(BuildContext context, PropertyModel property, ThemeData theme) {
    final favState = ref.watch(favoritesProvider);
    final isFav = favState.favoriteIds.contains(property.id) || property.isFavorite;
    final allImages = property.images.isNotEmpty 
        ? property.images 
        : (property.mainPhoto != null && property.mainPhoto!.isNotEmpty ? [property.mainPhoto!] : <String>[]);

    return AppScaffold(
      title: property.title.isNotEmpty ? property.title : 'Détails du logement',
      showBackButton: true,
      onBackPressed: () {
        if (Navigator.of(context).canPop()) {
          context.pop();
        } else {
          context.go(AppConstants.routeHome);
        }
      },
      actions: [
        IconButton(
          icon: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assetes/images/logo.png',
              width: 24,
              height: 24,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.home_outlined);
              },
            ),
          ),
          tooltip: 'Accueil',
          onPressed: () => context.go(AppConstants.routeHome),
        ),
        IconButton(
          icon: const Icon(Icons.dashboard_outlined),
          tooltip: 'Mon Dashboard',
          onPressed: () => context.go(AppConstants.routeLandlordDashboard),
        ),
        const SizedBox(width: 8),
      ],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Photos
            if (allImages.isNotEmpty) ...[
              Container(
                height: 350,
                width: double.infinity,
                color: Colors.black,
                child: Stack(
                  children: [
                    // Image principale cliquable pour zoom
                    GestureDetector(
                      onTap: () => _openImageViewer(context, allImages, _selectedImageIndex.clamp(0, allImages.length - 1)),
                      child: Center(
                        child: CachedNetworkImage(
                          imageUrl: allImages[_selectedImageIndex.clamp(0, allImages.length - 1)],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 350,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (ctx, err, stack) => const Center(
                            child: Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
                          ),
                          memCacheWidth: 1200,
                          memCacheHeight: 800,
                          fadeInDuration: const Duration(milliseconds: 300),
                        ),
                      ),
                    ),
                    // Bouton zoom overlay
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.zoom_in, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            const Text('Cliquez pour zoomer', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    // Badge Favoris
                    Positioned(
                      top: 16,
                      right: 16,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.red : Colors.black87,
                          ),
                          onPressed: () {
                            ref.read(favoritesProvider.notifier).toggleFavorite(
                              property: property,
                              context: context,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (allImages.length > 1)
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: allImages.length,
                    itemBuilder: (context, index) {
                      final isSelected = index == _selectedImageIndex;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedImageIndex = index),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: CachedNetworkImage(
                              imageUrl: allImages[index],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.error, size: 20),
                              ),
                              memCacheWidth: 120,
                              memCacheHeight: 120,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ] else
              Container(
                height: 200,
                width: double.infinity,
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                child: Center(
                  child: Icon(Icons.home_work, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.4)),
                ),
              ),

            // Contenu principal
            Padding(
              padding: const EdgeInsets.all(DSSpacing.lg),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header : Titre + Prix
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  property.title,
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.location_on, size: 18, color: theme.colorScheme.primary),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${property.district.isNotEmpty ? '${property.district}, ' : ''}${property.city.isNotEmpty ? property.city : 'Emplacement certifié'}',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                property.formattedPrice,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('/ mois', style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: DSSpacing.xl),

                      // Grille des caractéristiques clés
                      Container(
                        padding: const EdgeInsets.all(DSSpacing.md),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildFeatureItem(context, Icons.square_foot, property.formattedSurface, 'Surface'),
                            _buildFeatureItem(context, Icons.meeting_room, '${property.rooms} pièces', 'Pièces'),
                            _buildFeatureItem(context, Icons.bed, '${property.bedrooms} chamb.', 'Chambres'),
                            _buildFeatureItem(context, Icons.bathtub, '${property.bathrooms} sdb.', 'Salles de bain'),
                          ],
                        ),
                      ),

                      const SizedBox(height: DSSpacing.xl),

                      // Description
                      Text('Description', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: DSSpacing.sm),
                      Text(
                        property.description.isNotEmpty ? property.description : 'Aucune description disponible.',
                        style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                      ),

                      const SizedBox(height: DSSpacing.xl),

                      // Équipements
                      Text('Équipements & Prestations', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: DSSpacing.md),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          if (property.furnished) _buildAmenityChip('Meublé', Icons.chair),
                          if (property.parking) _buildAmenityChip('Parking', Icons.local_parking),
                          if (property.balcony) _buildAmenityChip('Balcon', Icons.balcony),
                          if (property.terrace) _buildAmenityChip('Terrasse', Icons.deck),
                          if (property.elevator) _buildAmenityChip('Ascenseur', Icons.elevator),
                          if (property.garden) _buildAmenityChip('Jardin', Icons.park),
                          if (property.pool) _buildAmenityChip('Piscine', Icons.pool),
                          if (property.airConditioning) _buildAmenityChip('Climatisation', Icons.ac_unit),
                          if (!property.furnished && !property.parking && !property.balcony && !property.terrace && !property.elevator && !property.garden && !property.pool && !property.airConditioning)
                            const Text('Aucun équipement spécifique listé.'),
                        ],
                      ),

                      const SizedBox(height: DSSpacing.xl),

                      // Vidéo du logement si présente sur Cloudinary
                      if (property.videoUrl != null && property.videoUrl!.isNotEmpty) ...[
                        Text('Vidéo du logement (Cloudinary)', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: DSSpacing.md),
                        CloudinaryVideoPlayerWidget(videoUrl: property.videoUrl!),
                        const SizedBox(height: DSSpacing.xl),
                      ],

                      // Profil du Bailleur certifié
                      Text('Propriétaire / Bailleur', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: DSSpacing.md),
                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(DSSpacing.md),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: theme.colorScheme.primary,
                                backgroundImage: property.landlordPhoto != null ? NetworkImage(property.landlordPhoto!) : null,
                                child: property.landlordPhoto == null
                                    ? Text(
                                        property.landlordName.isNotEmpty ? property.landlordName[0].toUpperCase() : 'B',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: DSSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          property.landlordName.isNotEmpty ? property.landlordName : 'Bailleur Certifié',
                                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 6),
                                        if (property.landlordIsVerified)
                                          const Icon(Icons.verified, color: Colors.blue, size: 18),
                                      ],
                                    ),
                                    Text(
                                      property.landlordEmail,
                                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: DSSpacing.xl),

                      // Actions principales
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: DSSpacing.sm),
                        child: Column(
                          children: [
                            // Bouton Contacter le bailleur
                            SizedBox(
                              width: double.infinity,
                              child: DSButton(
                                text: 'Contacter le bailleur',
                                icon: Icons.chat,
                                onPressed: () {
                                  _showContactDialog(context, property);
                                },
                                isFullWidth: true,
                              ),
                            ),
                            const SizedBox(height: DSSpacing.md),
                            // Bouton Demander une visite
                            SizedBox(
                              width: double.infinity,
                              child: DSButton(
                                text: 'Demander une visite',
                                icon: Icons.calendar_today,
                                type: DSButtonType.secondary,
                                onPressed: () {
                                  _showVisitDialog(context, property);
                                },
                                isFullWidth: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: DSSpacing.xl),
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

  Widget _buildFeatureItem(BuildContext context, IconData icon, String value, String label) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }

  Widget _buildAmenityChip(String label, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
    );
  }

  void _showContactDialog(BuildContext context, PropertyModel property) {
    final authState = ref.read(authProvider);

    if (!authState.estAuthentifie) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Connectez-vous pour contacter le bailleur.'),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Se connecter',
            textColor: Colors.amber,
            onPressed: () {
              context.go(AppConstants.routeLogin);
            },
          ),
        ),
      );
      return;
    }

    final user = authState.utilisateur;
    if (user != null && property.landlordId != null && user.id == property.landlordId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous êtes le propriétaire de ce logement.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Contacter le bailleur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Démarrer une conversation avec ${property.landlordName.isNotEmpty ? property.landlordName : 'le propriétaire'} pour le logement :'),
            const SizedBox(height: 8),
            Text(
              property.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
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
              try {
                final conversation = await ref
                    .read(messagesProvider.notifier)
                    .getOrCreateConversationForProperty(property.id);

                if (conversation != null && context.mounted) {
                  context.push('/chat/${conversation.id}');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: ${e.toString().replaceAll("Exception: ", "")}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Démarrer la discussion'),
          ),
        ],
      ),
    );
  }

  void _showVisitDialog(BuildContext context, PropertyModel property) {
    final authState = ref.read(authProvider);

    if (!authState.estAuthentifie) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Connectez-vous pour demander une visite.'),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Se connecter',
            textColor: Colors.amber,
            onPressed: () {
              context.go(AppConstants.routeLogin);
            },
          ),
        ),
      );
      return;
    }

    final user = authState.utilisateur;
    if (user != null && property.landlordId != null && user.id == property.landlordId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous êtes le propriétaire de ce logement.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Check if property is available
    if (property.status != 'PUBLISHED' && property.status != 'published') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ce logement n\'est plus disponible pour les visites.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => VisitRequestDialog(
        propertyId: property.id,
        propertyTitle: property.title,
      ),
    );
  }

  void _openImageViewer(BuildContext context, List<String> images, int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => _ImageViewerPage(
          images: images,
          initialIndex: initialIndex,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

/// Page de visualisation d'images avec zoom et navigation
class _ImageViewerPage extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _ImageViewerPage({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<_ImageViewerPage> {
  late int _currentIndex;
  late TransformationController _transformationController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _transformationController = TransformationController();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _nextImage() {
    if (_currentIndex < widget.images.length - 1) {
      setState(() {
        _currentIndex++;
        _transformationController.value = Matrix4.identity();
      });
    }
  }

  void _previousImage() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _transformationController.value = Matrix4.identity();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Image avec zoom
          Center(
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 1.0,
              maxScale: 4.0,
              child: Image.network(
                widget.images[_currentIndex],
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.error, color: Colors.white, size: 50),
                  );
                },
              ),
            ),
          ),
          // Boutons de navigation
          if (widget.images.length > 1) ...[
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white, size: 40),
                  onPressed: _currentIndex > 0 ? _previousImage : null,
                ),
              ),
            ),
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white, size: 40),
                  onPressed: _currentIndex < widget.images.length - 1 ? _nextImage : null,
                ),
              ),
            ),
            // Indicateur de position
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.images.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
          // Bouton fermer
          Positioned(
            top: 40,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 32),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          // Instructions zoom
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Pincez pour zoomer • Glissez pour déplacer',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
