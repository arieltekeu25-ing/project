from rest_framework import serializers
from ..models import Favorite
from apps.listings.serializers import PropertySerializer
from apps.listings.models import Property


class FavoriteSerializer(serializers.ModelSerializer):
    property_details = PropertySerializer(source='property', read_only=True)
    property_id = serializers.UUIDField(write_only=True)

    class Meta:
        model = Favorite
        fields = ['id', 'user', 'property_id', 'property_details', 'created_at']
        read_only_fields = ['id', 'user', 'created_at']

    def create(self, validated_data):
        user = self.context['request'].user
        property_id = validated_data['property_id']

        try:
            target_property = Property.objects.get(id=property_id, is_deleted=False)
        except Property.DoesNotExist:
            raise serializers.ValidationError({'property_id': 'Logement non trouvé ou supprimé'})

        favorite, created = Favorite.objects.get_or_create(
            user=user,
            property=target_property
        )
        return favorite
