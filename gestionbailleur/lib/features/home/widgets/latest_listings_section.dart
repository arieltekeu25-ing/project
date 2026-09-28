import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../constants/app_strings.dart';
import '../providers/property_provider.dart';
import 'property_card.dart';
import 'section_title.dart';

/// Section Dernières annonces — carrousel horizontal avec flèches
class LatestListingsSection extends ConsumerStatefulWidget {
  const LatestListingsSection({super.key});

  @override
  ConsumerState<LatestListingsSection> createState() =>
      _LatestListingsSectionState();
}

class _LatestListingsSectionState extends ConsumerState<LatestListingsSection> {
  final ScrollController _scrollController = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateArrowState);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateArrowState());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateArrowState);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateArrowState() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final canLeft = position.pixels > 8;
    final canRight = position.pixels < position.maxScrollExtent - 8;
    if (canLeft != _canScrollLeft || canRight != _canScrollRight) {
      setState(() {
        _canScrollLeft = canLeft;
        _canScrollRight = canRight;
      });
    }
  }

  Future<void> _scrollBy(double delta) async {
    if (!_scrollController.hasClients) return;
    final target = (_scrollController.offset + delta).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    await _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final propertyState = ref.watch(propertyProvider);
    final properties = propertyState.properties;

    if (properties.isEmpty && !propertyState.isLoading) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppConstants.spacingXXLarge,
        horizontal: AppConstants.spacingLarge,
      ),
      child: Column(
        children: [
          SectionTitle(
            title: AppStrings.latestProperties,
            subtitle: 'Les dernières annonces réelles ajoutées',
          ),
          if (propertyState.isLoading)
            const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (properties.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text('Aucune nouvelle annonce pour le moment.'),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final isSmallMobile = constraints.maxWidth < 400;
                final isDesktop = constraints.maxWidth > AppConstants.breakpointTablet;
                final cardWidth = isSmallMobile
                    ? (constraints.maxWidth * 0.85).clamp(240.0, 300.0)
                    : isDesktop
                        ? 320.0
                        : 280.0;
                final cardHeight = isSmallMobile ? 380.0 : 430.0;
                final scrollStep = cardWidth + AppConstants.spacingMedium;

                WidgetsBinding.instance.addPostFrameCallback((_) => _updateArrowState());

                return SizedBox(
                  height: cardHeight,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ListView.builder(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 44 : 36,
                        ),
                        itemCount: properties.length,
                        itemBuilder: (context, index) {
                          final property = properties[index];
                          return Container(
                            width: cardWidth,
                            margin: EdgeInsets.only(
                              right: index == properties.length - 1
                                  ? 0
                                  : AppConstants.spacingMedium,
                            ),
                            child: PropertyCard(
                              property: property,
                              onTap: () {
                                context.go(
                                  AppConstants.routePropertyDetails
                                      .replaceFirst(':id', property.id),
                                );
                              },
                              onFavoriteToggle: () {
                                ref
                                    .read(propertyProvider.notifier)
                                    .toggleFavorite(property.id);
                              },
                            ),
                          );
                        },
                      ),
                      if (_canScrollLeft)
                        Positioned(
                          left: 0,
                          child: _CarouselArrow(
                            icon: Icons.chevron_left,
                            onPressed: () => _scrollBy(-scrollStep),
                          ),
                        ),
                      if (_canScrollRight)
                        Positioned(
                          right: 0,
                          child: _CarouselArrow(
                            icon: Icons.chevron_right,
                            onPressed: () => _scrollBy(scrollStep),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _CarouselArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CarouselArrow({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 3,
      color: theme.colorScheme.surface,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
      ),
    );
  }
}
