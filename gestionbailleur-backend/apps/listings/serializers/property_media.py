from rest_framework import serializers
from ..models import PropertyMedia


class PropertyMediaSerializer(serializers.ModelSerializer):
    class Meta:
        model = PropertyMedia
        fields = [
            'id',
            'property',
            'cloudinary_public_id',
            'secure_url',
            'resource_type',
            'format',
            'width',
            'height',
            'duration',
            'file_size',
            'order',
            'is_primary',
            'created_at',
            'updated_at',
        ]
        read_only_fields = [
            'id',
            'property',
            'cloudinary_public_id',
            'secure_url',
            'resource_type',
            'format',
            'width',
            'height',
            'duration',
            'file_size',
            'created_at',
            'updated_at',
        ]
