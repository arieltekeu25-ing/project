import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_constants.dart';
import '../../home/models/property_model.dart';

/// Vue cartographique basée sur flutter_map (OpenStreetMap) affichant tous les logements réels
class SearchMapView extends StatefulWidget {
  final List<PropertyModel> properties;
  final double? userLatitude;
  final double? userLongitude;

  const SearchMapView({
    super.key,
    required this.properties,
    this.userLatitude,
    this.userLongitude,
  });

  @override
  State<SearchMapView> createState() => _SearchMapViewState();
}

class _SearchMapViewState extends State<SearchMapView> {
  PropertyModel? _selectedProperty;

  /// Coordonnées par défaut des principales villes pour positionner tous les biens
  static final Map<String, LatLng> _cityCoordinates = {
    'yaounde': const LatLng(3.8480, 11.5021),
    'yaoundé': const LatLng(3.8480, 11.5021),
    'douala': const LatLng(4.0511, 9.7679),
    'bafoussam': const LatLng(5.4778, 10.4176),
    'kribi': const LatLng(2.9392, 9.9095),
    'buea': const LatLng(4.1550, 9.2435),
    'limbe': const LatLng(4.0244, 9.2049),
    'garoua': const LatLng(9.3011, 13.3970),
    'bamenda': const LatLng(5.9631, 10.1591),
  };

  LatLng _getCoordinatesForProperty(PropertyModel property, int index) {
    if (property.effectiveLatitude != null && property.effectiveLongitude != null) {
      return LatLng(property.effectiveLatitude!, property.effectiveLongitude!);
    }

    final cityKey = property.city.toLowerCase().trim();
    final baseCoords = _cityCoordinates[cityKey] ?? const LatLng(3.8480, 11.5021);

    // Petit décalage pseudo-aléatoire basé sur l'index pour étaler les marqueurs sans GPS
    final offsetLat = ((index * 37) % 100 - 50) * 0.0003;
    final offsetLng = ((index * 73) % 100 - 50) * 0.0003;

    return LatLng(baseCoords.latitude + offsetLat, baseCoords.longitude + offsetLng);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calculer le centre initial de la carte
    LatLng initialCenter = const LatLng(3.8480, 11.5021); // Yaoundé fallback par défaut
    if (widget.userLatitude != null && widget.userLongitude != null) {
      initialCenter = LatLng(widget.userLatitude!, widget.userLongitude!);
    } else if (widget.properties.isNotEmpty) {
      initialCenter = _getCoordinatesForProperty(widget.properties.first, 0);
    }

    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: initialCenter,
            initialZoom: 13.0,
            onTap: (tapPosition, point) {
              setState(() {
                _selectedProperty = null;
              });
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.gestbailleur.app',
            ),
            MarkerLayer(
              markers: [
                // Marqueur Position Utilisateur (si active)
                if (widget.userLatitude != null && widget.userLongitude != null)
                  Marker(
                    point: LatLng(widget.userLatitude!, widget.userLongitude!),
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Marqueurs de tous les logements réels
                ...widget.properties.asMap().entries.map((entry) {
                  final index = entry.key;
                  final property = entry.value;
                  final coords = _getCoordinatesForProperty(property, index);
                  final isSelected = _selectedProperty?.id == property.id;

                  return Marker(
                    point: coords,
                    width: isSelected ? 120 : 90,
                    height: isSelected ? 50 : 40,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedProperty = property;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.primary,
                            width: 2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.home,
                              size: 16,
                              color: isSelected ? Colors.white : theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                property.formattedPrice,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),

        // Carte de prévisualisation du logement sélectionné
        if (_selectedProperty != null)
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _selectedProperty!.mainPhoto != null &&
                              _selectedProperty!.mainPhoto!.isNotEmpty
                          ? Image.network(
                              _selectedProperty!.mainPhoto!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) => Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[300],
                                child: const Icon(Icons.home, size: 32),
                              ),
                            )
                          : Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[300],
                              child: const Icon(Icons.home, size: 32),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedProperty!.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_selectedProperty!.district.isNotEmpty ? '${_selectedProperty!.district}, ' : ''}${_selectedProperty!.city}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                _selectedProperty!.formattedPrice,
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              if (_selectedProperty!.distanceKm != null) ...[
                                const Spacer(),
                                Icon(Icons.near_me, size: 14, color: theme.colorScheme.primary),
                                const SizedBox(width: 2),
                                Text(
                                  _selectedProperty!.formattedDistance,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: 18),
                      onPressed: () {
                        context.push(
                          AppConstants.routePropertyDetails.replaceFirst(':id', _selectedProperty!.id),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
