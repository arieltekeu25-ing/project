import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/hero_section.dart';
import '../widgets/search_bar_section.dart';
import '../widgets/categories_section.dart';
import '../widgets/properties_section.dart';
import '../widgets/why_choose_us_section.dart';
import '../widgets/how_it_works_section.dart';
import '../widgets/chatbot_section.dart';
import '../widgets/latest_listings_section.dart';
import '../widgets/testimonials_section.dart';
import '../widgets/home_footer.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../authentication/models/enums/role_utilisateur.dart';
import '../providers/property_provider.dart';
import '../models/property_model.dart';
import '../../../shared/design_system/spacing/ds_spacing.dart';
import '../../search/providers/search_provider.dart';
import '../../favorites/providers/favorites_provider.dart';
import 'dart:async';

/// Page d'accueil principale intégrant toutes les sections
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    // Charger les options de recherche au démarrage
    Future.microtask(() {
      ref.read(searchProvider.notifier).loadFilterOptions();
      
      // Charger les logements du bailleur si connecté
      final authState = ref.read(authProvider);
      if (authState.estAuthentifie) {
        ref.read(favoritesProvider.notifier).loadFavorites();
        if (authState.utilisateur?.role == RoleUtilisateur.bailleur) {
          ref.read(propertyProvider.notifier).loadLandlordProperties(authState.utilisateur!.id);
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final utilisateur = authState.utilisateur;
    final isLandlord = utilisateur?.role == RoleUtilisateur.bailleur;
    final propertyState = ref.watch(propertyProvider);

    return Scaffold(
      appBar: HomeAppBar(
        onSearchTap: null,
        onChatbotTap: null,
        onLoginTap: null,
        onMenuTap: null,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const HeroSection(),
                SizedBox(height: isSmallMobile ? AppConstants.spacingLarge : AppConstants.spacingXXLarge),
                
                // Section publications du bailleur connecté
                if (isLandlord) ...[
                  _buildLandlordPublications(context, utilisateur!, propertyState),
                  SizedBox(height: isSmallMobile ? AppConstants.spacingLarge : AppConstants.spacingXXLarge),
                ],
                
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallMobile ? AppConstants.spacingMedium : AppConstants.spacingLarge,
                  ),
                  child: const SearchBarSection(),
                ),
                const CategoriesSection(),
                const PropertiesSection(),
                const WhyChooseUsSection(),
                const HowItWorksSection(),
                const ChatbotSection(),
                const LatestListingsSection(),
                const TestimonialsSection(),
                const HomeFooter(),
              ],
            ),
          ),
          // const NotificationPopup(), // Désactivé temporairement pour corriger les crashes
        ],
      ),
    );
  }

  Widget _buildLandlordPublications(BuildContext context, dynamic utilisateur, PropertyState propertyState) {
    final theme = Theme.of(context);
    final properties = propertyState.landlordProperties;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(DSSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.08),
            theme.colorScheme.primary.withValues(alpha: 0.02),
          ],
        ),
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go(AppConstants.routeProfile),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: theme.colorScheme.primary,
                      backgroundImage: utilisateur?.photoUrl != null && utilisateur!.photoUrl!.isNotEmpty
                          ? CachedNetworkImageProvider(utilisateur.photoUrl!)
                          : null,
                      child: utilisateur?.photoUrl == null || utilisateur!.photoUrl!.isEmpty
                          ? Text(
                              utilisateur?.prenom.isNotEmpty == true 
                                  ? utilisateur.prenom[0].toUpperCase() 
                                  : 'B',
                              style: const TextStyle(
                                color: Colors.white, 
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            )
                          : null,
                    ),
                  ),
                  SizedBox(width: DSSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mes publications',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        '${properties.length} logement(s) en ligne',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextButton.icon(
                  onPressed: () => context.go('/properties/publish'),
                  icon: const Icon(Icons.add, color: Colors.white, size: 20),
                  label: const Text('Publier', style: TextStyle(color: Colors.white)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: DSSpacing.lg),
          
          if (propertyState.isLoading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (properties.isEmpty)
            Container(
              padding: EdgeInsets.all(DSSpacing.xl),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.home_work_outlined,
                    size: 48,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  SizedBox(height: DSSpacing.md),
                  Text(
                    'Aucun logement publié',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  SizedBox(height: DSSpacing.sm),
                  Text(
                    'Commencez par publier votre premier logement',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            )
          else
            ...properties.map((property) => Padding(
              padding: EdgeInsets.only(bottom: DSSpacing.md),
              child: _buildLandlordPropertyCard(context, theme, property),
            )),
        ],
      ),
    );
  }

  Widget _buildLandlordPropertyCard(BuildContext context, ThemeData theme, PropertyModel property) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallMobile = constraints.maxWidth < 400;
        final imageWidth = isSmallMobile ? 70.0 : 90.0;
        final imageHeight = isSmallMobile ? 70.0 : 75.0;
        
        return InkWell(
          onTap: () => context.go('/property/${property.id}'),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(DSSpacing.lg),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Image du logement
                Container(
                  width: imageWidth,
                  height: imageHeight,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: property.mainPhoto != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: property.mainPhoto!,
                            fit: BoxFit.cover,
                            width: imageWidth,
                            height: imageHeight,
                            placeholder: (context, url) => const Icon(Icons.home, size: 32, color: Colors.grey),
                            errorWidget: (context, url, error) => const Icon(Icons.home, size: 32, color: Colors.grey),
                            maxWidthDiskCache: 150,
                            maxHeightDiskCache: 150,
                          ),
                        )
                      : const Icon(Icons.home, size: 32, color: Colors.grey),
                ),
                SizedBox(width: DSSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: DSSpacing.xs),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 14, color: theme.colorScheme.primary),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${property.city}, ${property.district}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: DSSpacing.xs),
                      Wrap(
                        spacing: DSSpacing.sm,
                        runSpacing: 2,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bed_outlined, size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                              SizedBox(width: 4),
                              Text('${property.bedrooms}', style: theme.textTheme.bodySmall),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bathtub_outlined, size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                              SizedBox(width: 4),
                              Text('${property.bathrooms}', style: theme.textTheme.bodySmall),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.square_foot, size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                              SizedBox(width: 4),
                              Text(property.formattedSurface, style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: DSSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      property.formattedPrice,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '/mois',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: DSSpacing.sm),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.edit_outlined, size: 18, color: theme.colorScheme.primary),
                        onPressed: () {
                          // Prevent event bubbling to parent InkWell
                          // Navigate to edit page
                          context.go('/properties/${property.id}/edit');
                        },
                        tooltip: 'Modifier',
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                    SizedBox(width: DSSpacing.xs),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.bar_chart_outlined, size: 18, color: theme.colorScheme.primary),
                        onPressed: () {
                          // Prevent event bubbling to parent InkWell
                          // Navigate to landlord dashboard which shows statistics
                          context.go(AppConstants.routeLandlordDashboard);
                        },
                        tooltip: 'Statistiques',
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool get isSmallMobile => MediaQuery.of(context).size.width < 400;
}
