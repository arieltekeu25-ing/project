from rest_framework import serializers
from ..models import Property, PropertyMedia
from .property_media import PropertyMediaSerializer


class PropertySerializer(serializers.ModelSerializer):
    landlord_name = serializers.SerializerMethodField()
    landlord_email = serializers.SerializerMethodField()
    landlord_photo = serializers.SerializerMethodField()
    address_details = serializers.SerializerMethodField()
    distance_km = serializers.SerializerMethodField()
    distance_meters = serializers.SerializerMethodField()
    media = PropertyMediaSerializer(many=True, read_only=True)
    images = serializers.SerializerMethodField()
    video_url = serializers.SerializerMethodField()

    class Meta:
        model = Property
        fields = [
            'id',
            'title',
            'description',
            'property_type',
            'status',
            'rent_price',
            'charges',
            'deposit',
            'surface',
            'rooms',
            'bedrooms',
            'bathrooms',
            'floor',
            'furnished',
            'parking',
            'balcony',
            'terrace',
            'elevator',
            'garden',
            'pool',
            'air_conditioning',
            'heating',
            'address',
            'address_details',
            'distance_km',
            'distance_meters',
            'landlord',
            'landlord_name',
            'landlord_email',
            'landlord_photo',
            'available_from',
            'minimum_rent_duration',
            'main_photo',
            'media',
            'images',
            'video_url',
            'views_count',
            'inquiries_count',
            'created_at',
            'updated_at',
        ]
        read_only_fields = [
            'id',
            'views_count',
            'inquiries_count',
            'created_at',
            'updated_at',
        ]

    def get_landlord_photo(self, obj):
        if hasattr(obj.landlord, 'profile') and obj.landlord.profile:
            return obj.landlord.profile.photo
        return None

    def get_images(self, obj):
        try:
            media_qs = obj.media.filter(resource_type='image', is_deleted=False).order_by('order', 'created_at')
            urls = [m.secure_url for m in media_qs if m.secure_url]
            if not urls and obj.main_photo:
                urls.append(obj.main_photo)
            return urls
        except Exception:
            return []

    def get_video_url(self, obj):
        try:
            video = obj.media.filter(resource_type='video', is_deleted=False).order_by('order', 'created_at').first()
            return video.secure_url if video else None
        except Exception:
            return None


    def get_landlord_name(self, obj):
        return f"{obj.landlord.prenom} {obj.landlord.nom}".strip()

    def get_landlord_email(self, obj):
        return obj.landlord.email

    def get_address_details(self, obj):
        if obj.address:
            addr = obj.address
            city_name = getattr(addr.city, 'nom', None) or getattr(addr.city, 'name', None) if addr.city else None
            district_name = getattr(addr.district, 'nom', None) or getattr(addr.district, 'name', None) if addr.district else None
            country_name = getattr(addr.country, 'nom', None) or getattr(addr.country, 'name', None) if addr.country else None
            street_name = getattr(addr, 'ligne_1', None) or getattr(addr, 'street', None) or ''

            lat = float(addr.latitude) if getattr(addr, 'latitude', None) is not None else None
            lng = float(addr.longitude) if getattr(addr, 'longitude', None) is not None else None

            return {
                'street': street_name,
                'city': city_name,
                'district': district_name,
                'country': country_name,
                'postal_code': getattr(addr, 'code_postal', None) or getattr(addr, 'postal_code', None),
                'latitude': lat,
                'longitude': lng,
            }
        return None

    def get_distance_km(self, obj):
        if hasattr(obj, 'distance_km') and obj.distance_km is not None:
            return round(float(obj.distance_km), 2)
        return None

    def get_distance_meters(self, obj):
        if hasattr(obj, 'distance_km') and obj.distance_km is not None:
            return int(float(obj.distance_km) * 1000)
        return None


class PropertyCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Property
        fields = [
            'title',
            'description',
            'property_type',
            'rent_price',
            'charges',
            'deposit',
            'surface',
            'rooms',
            'bedrooms',
            'bathrooms',
            'floor',
            'furnished',
            'parking',
            'balcony',
            'terrace',
            'elevator',
            'garden',
            'pool',
            'air_conditioning',
            'heating',
            'address',
            'available_from',
            'minimum_rent_duration',
            'main_photo',
        ]

    def create(self, validated_data):
        validated_data['landlord'] = self.context['request'].user
        validated_data['status'] = 'DRAFT'
        return Property.objects.create(**validated_data)


class PropertyUpdateSerializer(serializers.ModelSerializer):
    images = serializers.ListField(
        child=serializers.CharField(),
        required=False,
        allow_empty=True
    )

    class Meta:
        model = Property
        fields = [
            'title',
            'description',
            'property_type',
            'status',
            'rent_price',
            'charges',
            'deposit',
            'surface',
            'rooms',
            'bedrooms',
            'bathrooms',
            'floor',
            'furnished',
            'parking',
            'balcony',
            'terrace',
            'elevator',
            'garden',
            'pool',
            'air_conditioning',
            'heating',
            'address',
            'available_from',
            'minimum_rent_duration',
            'main_photo',
            'images',
        ]

    def update(self, instance, validated_data):
        images_data = validated_data.pop('images', None)
        
        # Mise à jour des champs de base
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        
        # Gestion des images
        if images_data is not None:
            # Mettre à jour main_photo avec la première image si fournie
            if images_data and len(images_data) > 0:
                instance.main_photo = images_data[0]
            
            # Ici on pourrait aussi synchroniser avec PropertyMedia si nécessaire
            # Pour l'instant, on garde main_photo comme référence principale
        
        instance.save()
        return instance
