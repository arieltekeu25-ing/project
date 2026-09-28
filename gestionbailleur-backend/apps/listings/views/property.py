from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, IsAuthenticatedOrReadOnly
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema, OpenApiParameter

from ..serializers import PropertySerializer, PropertyCreateSerializer, PropertyUpdateSerializer
from ..models import Property


@extend_schema(
    tags=['Logements'],
    summary='Lister les logements',
    description='Récupérer la liste des logements (filtrables par statut, type, propriétaire)',
    responses={200: PropertySerializer(many=True)},
)
@api_view(['GET'])
@permission_classes([IsAuthenticatedOrReadOnly])
def property_list_view(request):
    queryset = Property.objects.filter(is_deleted=False)
    
    # Filtres
    status_filter = request.query_params.get('status')
    if status_filter:
        queryset = queryset.filter(status=status_filter)
    
    type_filter = request.query_params.get('type')
    if type_filter:
        queryset = queryset.filter(property_type=type_filter)
    
    landlord_filter = request.query_params.get('landlord')
    if landlord_filter:
        queryset = queryset.filter(landlord_id=landlord_filter)
    
    # Ne plus filtrer automatiquement pour les bailleurs - ils doivent voir tous les logements
    # Le filtrage se fait uniquement via le paramètre landlord explicite
    
    serializer = PropertySerializer(queryset, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)


@extend_schema(
    tags=['Logements'],
    summary='Créer un logement',
    description='Créer un nouveau logement (réservé aux bailleurs)',
    request=PropertyCreateSerializer,
    responses={201: PropertySerializer},
)
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def property_create_view(request):
    # Vérifier que l'utilisateur est un bailleur
    from apps.accounts.models import UserRole
    is_landlord = UserRole.objects.filter(
        user=request.user,
        role__code='BAILLEUR',
        actif=True,
        is_deleted=False
    ).exists()
    
    if not is_landlord:
        return Response(
            {'error': 'Seuls les bailleurs peuvent créer des logements'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    # Vérifier que le compte du bailleur est actif (approuvé par l'admin)
    if request.user.etat_compte != 'ACTIF':
        return Response(
            {'error': 'Votre compte doit être approuvé par l\'administrateur avant de pouvoir publier des logements'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    serializer = PropertyCreateSerializer(
        data=request.data,
        context={'request': request}
    )
    if serializer.is_valid():
        property = serializer.save()
        return Response(
            PropertySerializer(property).data,
            status=status.HTTP_201_CREATED
        )
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@extend_schema(
    tags=['Logements'],
    summary='Détails d\'un logement',
    description='Récupérer les détails d\'un logement spécifique',
    responses={200: PropertySerializer},
)
@api_view(['GET'])
@permission_classes([IsAuthenticatedOrReadOnly])
def property_detail_view(request, property_id):
    try:
        property = Property.objects.get(id=property_id, is_deleted=False)
        
        # Incrémenter le compteur de vues
        property.views_count += 1
        property.save(update_fields=['views_count'])
        
        serializer = PropertySerializer(property)
        return Response(serializer.data, status=status.HTTP_200_OK)
    except Property.DoesNotExist:
        return Response(
            {'error': 'Logement non trouvé'},
            status=status.HTTP_404_NOT_FOUND
        )


@extend_schema(
    tags=['Logements'],
    summary='Mettre à jour un logement',
    description='Mettre à jour un logement (réservé au propriétaire)',
    request=PropertyUpdateSerializer,
    responses={200: PropertySerializer},
)
@api_view(['PUT', 'PATCH'])
@permission_classes([IsAuthenticated])
def property_update_view(request, property_id):
    try:
        property = Property.objects.get(id=property_id, is_deleted=False)
        
        # Vérifier que l'utilisateur est le propriétaire
        if property.landlord != request.user:
            return Response(
                {'error': 'Vous n\'êtes pas autorisé à modifier ce logement'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        # Vérifier que le compte du bailleur est actif
        if request.user.etat_compte != 'ACTIF':
            return Response(
                {'error': 'Votre compte doit être approuvé par l\'administrateur avant de pouvoir modifier des logements'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        serializer = PropertyUpdateSerializer(
            property,
            data=request.data,
            partial=request.method == 'PATCH'
        )
        if serializer.is_valid():
            property = serializer.save()
            return Response(
                PropertySerializer(property).data,
                status=status.HTTP_200_OK
            )
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    except Property.DoesNotExist:
        return Response(
            {'error': 'Logement non trouvé'},
            status=status.HTTP_404_NOT_FOUND
        )


@extend_schema(
    tags=['Logements'],
    summary='Supprimer un logement',
    description='Supprimer un logement (réservé au propriétaire)',
    responses={204: None},
)
@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def property_delete_view(request, property_id):
    try:
        property = Property.objects.get(id=property_id, is_deleted=False)
        
        # Vérifier que l'utilisateur est le propriétaire
        if property.landlord != request.user:
            return Response(
                {'error': 'Vous n\'êtes pas autorisé à supprimer ce logement'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        property.soft_delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
    except Property.DoesNotExist:
        return Response(
            {'error': 'Logement non trouvé'},
            status=status.HTTP_404_NOT_FOUND
        )


@extend_schema(
    tags=['Logements'],
    summary='Publier un logement',
    description='Changer le statut d\'un logement en PUBLISHED',
    responses={200: PropertySerializer},
)
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def property_publish_view(request, property_id):
    try:
        property = Property.objects.get(id=property_id, is_deleted=False)
        
        # Vérifier que l'utilisateur est le propriétaire
        if property.landlord != request.user:
            return Response(
                {'error': 'Vous n\'êtes pas autorisé à publier ce logement'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        # Vérifier que le compte du bailleur est actif
        if request.user.etat_compte != 'ACTIF':
            return Response(
                {'error': 'Votre compte doit être approuvé par l\'administrateur avant de pouvoir publier des logements'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        property.status = 'PUBLISHED'
        property.save()
        
        return Response(
            PropertySerializer(property).data,
            status=status.HTTP_200_OK
        )
    except Property.DoesNotExist:
        return Response(
            {'error': 'Logement non trouvé'},
            status=status.HTTP_404_NOT_FOUND
        )


import math
from django.db.models import Q, Min, Max


def calculate_haversine_km(lat1, lon1, lat2, lon2):
    R = 6371.0
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = math.sin(dlat / 2.0)**2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon / 2.0)**2
    c = 2.0 * math.atan2(math.sqrt(a), math.sqrt(1.0 - a))
    return R * c


@extend_schema(
    tags=['Logements'],
    summary='Recherche avancée et géolocalisée de logements',
    description='Filtrer les logements par mot-clé, ville, quartier, type, loyer, surface, équipements et coordonnées GPS réelles',
)
@api_view(['GET'])
@permission_classes([IsAuthenticatedOrReadOnly])
def property_search_view(request):
    try:
        queryset = Property.objects.filter(is_deleted=False)

        # Statut (par défaut les logements publiés / disponibles)
        status_param = request.query_params.get('status')
        if status_param:
            queryset = queryset.filter(status=status_param)
        else:
            # Par défaut, montrer uniquement les logements PUBLISHED pour la recherche publique
            queryset = queryset.filter(status='PUBLISHED')

        # Recherche textuelle générale (q ou search)
        search_query = request.query_params.get('q') or request.query_params.get('search')
        if search_query:
            search_query = search_query.strip()
            queryset = queryset.filter(
                Q(title__icontains=search_query) |
                Q(description__icontains=search_query) |
                Q(address__city__nom__icontains=search_query) |
                Q(address__district__nom__icontains=search_query) |
                Q(address__neighborhood__nom__icontains=search_query) |
                Q(address__ligne_1__icontains=search_query)
            )

        # Filtre par Ville
        city = request.query_params.get('city')
        if city:
            queryset = queryset.filter(
                Q(address__city__nom__icontains=city) | Q(address__city__name__icontains=city)
            )

        # Filtre par Quartier / Arrondissement
        district = request.query_params.get('district')
        if district:
            queryset = queryset.filter(
                Q(address__district__nom__icontains=district) |
                Q(address__neighborhood__nom__icontains=district)
            )

        # Type de logement
        prop_type = request.query_params.get('property_type') or request.query_params.get('type')
        if prop_type:
            queryset = queryset.filter(property_type=prop_type)

        # Budget (Loyer min / max)
        min_price = request.query_params.get('min_price')
        if min_price:
            try:
                queryset = queryset.filter(rent_price__gte=float(min_price))
            except ValueError:
                pass

        max_price = request.query_params.get('max_price')
        if max_price:
            try:
                queryset = queryset.filter(rent_price__lte=float(max_price))
            except ValueError:
                pass

        # Surface (min / max)
        min_surface = request.query_params.get('min_surface')
        if min_surface:
            try:
                queryset = queryset.filter(surface__gte=float(min_surface))
            except ValueError:
                pass

        max_surface = request.query_params.get('max_surface')
        if max_surface:
            try:
                queryset = queryset.filter(surface__lte=float(max_surface))
            except ValueError:
                pass

        # Chambres / Pièces
        bedrooms = request.query_params.get('bedrooms')
        if bedrooms:
            try:
                queryset = queryset.filter(bedrooms__gte=int(bedrooms))
            except ValueError:
                pass

        rooms = request.query_params.get('rooms')
        if rooms:
            try:
                queryset = queryset.filter(rooms__gte=int(rooms))
            except ValueError:
                pass

        # Équipements
        furnished = request.query_params.get('furnished')
        if furnished in ['true', 'True', '1']:
            queryset = queryset.filter(furnished=True)

        # Géolocalisation & Recherche à proximité (latitude, longitude, radius_km)
        lat_param = request.query_params.get('latitude') or request.query_params.get('lat')
        lng_param = request.query_params.get('longitude') or request.query_params.get('lng')
        radius_param = request.query_params.get('radius_km') or request.query_params.get('radius') or '50'

        user_lat = float(lat_param) if lat_param else None
        user_lng = float(lng_param) if lng_param else None
        max_radius_km = float(radius_param) if radius_param else 50.0

        properties_list = list(queryset.select_related('address', 'address__city', 'address__district', 'address__country', 'landlord'))

        filtered_by_distance = []
        for prop in properties_list:
            if user_lat is not None and user_lng is not None and prop.address and prop.address.latitude is not None and prop.address.longitude is not None:
                dist_km = calculate_haversine_km(
                    user_lat,
                    user_lng,
                    float(prop.address.latitude),
                    float(prop.address.longitude)
                )
                prop.distance_km = dist_km
                if dist_km <= max_radius_km:
                    filtered_by_distance.append(prop)
            else:
                prop.distance_km = None
                if lat_param is None or lng_param is None:
                    filtered_by_distance.append(prop)

        # Tri
        ordering = request.query_params.get('ordering')
        if ordering == 'rent_price':
            filtered_by_distance.sort(key=lambda p: p.rent_price)
        elif ordering == '-rent_price':
            filtered_by_distance.sort(key=lambda p: p.rent_price, reverse=True)
        elif ordering == 'distance' and user_lat is not None:
            filtered_by_distance.sort(key=lambda p: p.distance_km if p.distance_km is not None else 999999)
        elif ordering == 'views_count' or ordering == '-views_count':
            filtered_by_distance.sort(key=lambda p: p.views_count, reverse=True)
        else:
            filtered_by_distance.sort(key=lambda p: p.created_at, reverse=True)

        serializer = PropertySerializer(filtered_by_distance, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    except Exception as e:
        # En cas d'erreur, retourner une liste vide plutôt qu'une erreur serveur
        # Log l'erreur pour debugging
        import logging
        logger = logging.getLogger(__name__)
        logger.error(f"Error in property_search_view: {str(e)}", exc_info=True)
        
        # Retourner une liste vide avec HTTP 200
        return Response([], status=status.HTTP_200_OK)


@extend_schema(
    tags=['Logements'],
    summary='Obtenir les options dynamiques de filtrage réelles depuis la base de données',
    description='Retourne les villes réelles, quartiers réels, types de logements et plage de prix réelle issue de PostgreSQL',
)
@api_view(['GET'])
@permission_classes([IsAuthenticatedOrReadOnly])
def property_filter_options_view(request):
    active_props = Property.objects.filter(is_deleted=False)

    # Extrait les villes réelles uniques (avec fallback sur name si nom est null)
    cities = list(
        active_props.filter(address__city__isnull=False)
        .values_list('address__city__nom', flat=True)
        .distinct()
    )
    # Fallback si nom est vide
    if not cities:
        cities = list(
            active_props.filter(address__city__isnull=False)
            .values_list('address__city__name', flat=True)
            .distinct()
        )

    # Extrait les quartiers réels uniques (avec fallback sur neighborhood)
    districts = list(
        active_props.filter(address__district__isnull=False)
        .values_list('address__district__nom', flat=True)
        .distinct()
    )
    # Fallback si nom est vide
    if not districts:
        districts = list(
            active_props.filter(address__neighborhood__isnull=False)
            .values_list('address__neighborhood__nom', flat=True)
            .distinct()
        )

    # Types de logements uniques présents
    types_in_db = list(active_props.values_list('property_type', flat=True).distinct())

    # Plage de loyers réels
    min_price_agg = active_props.aggregate(Min('rent_price'))['rent_price__min']
    max_price_agg = active_props.aggregate(Max('rent_price'))['rent_price__max']

    min_price = float(min_price_agg) if min_price_agg is not None else 0.0
    max_price = float(max_price_agg) if max_price_agg is not None else 0.0

    # Si aucune ville/quartier mais des logements existent, retourner au moins les types et prix
    return Response({
        'cities': [c for c in cities if c],
        'districts': [d for d in districts if d],
        'property_types': [t for t in types_in_db if t],
        'min_price': min_price,
        'max_price': max_price,
    }, status=status.HTTP_200_OK)

