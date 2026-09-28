from rest_framework import serializers
from ..models import Visit


class VisitSerializer(serializers.ModelSerializer):
    property_title = serializers.CharField(source='property.title', read_only=True)
    property_address = serializers.SerializerMethodField()
    client_name = serializers.CharField(source='client.nom_complet', read_only=True)
    client_email = serializers.EmailField(source='client.email', read_only=True)
    landlord_name = serializers.CharField(source='landlord.nom_complet', read_only=True)
    landlord_email = serializers.EmailField(source='landlord.email', read_only=True)
    property_main_photo = serializers.URLField(source='property.main_photo', read_only=True)

    class Meta:
        model = Visit
        fields = [
            'id',
            'property',
            'property_title',
            'property_address',
            'property_main_photo',
            'client',
            'client_name',
            'client_email',
            'landlord',
            'landlord_name',
            'landlord_email',
            'requested_date',
            'requested_time',
            'message',
            'status',
            'landlord_response',
            'rescheduled_date',
            'rescheduled_time',
            'rescheduled_message',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

    def get_property_address(self, obj):
        if obj.property.address:
            return str(obj.property.address)
        return None


class VisitCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Visit
        fields = [
            'property',
            'requested_date',
            'requested_time',
            'message',
        ]

    def validate(self, data):
        property_obj = data['property']
        requested_date = data['requested_date']
        
        # Check if property is available
        if property_obj.status != 'PUBLISHED':
            raise serializers.ValidationError(
                "Ce logement n'est plus disponible pour les visites."
            )
        
        # Check if date is in the past
        from django.utils import timezone
        import datetime
        today = timezone.now().date()
        if requested_date < today:
            raise serializers.ValidationError(
                "La date de visite ne peut pas être dans le passé."
            )
        
        # Check for duplicate pending visit
        from django.db.models import Q
        existing_visit = Visit.objects.filter(
            property=property_obj,
            client=self.context['request'].user,
            requested_date=requested_date,
            requested_time=data['requested_time'],
            status='PENDING',
            is_deleted=False
        ).exists()
        
        if existing_visit:
            raise serializers.ValidationError(
                "Vous avez déjà une demande de visite en attente pour ce créneau."
            )
        
        return data

    def create(self, validated_data):
        request = self.context['request']
        property_obj = validated_data['property']
        
        # Set landlord from property
        validated_data['client'] = request.user
        validated_data['landlord'] = property_obj.landlord
        
        return super().create(validated_data)


class VisitUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Visit
        fields = [
            'status',
            'landlord_response',
            'rescheduled_date',
            'rescheduled_time',
            'rescheduled_message',
        ]

    def validate(self, data):
        status = data.get('status')
        
        # If rescheduling, require date and time
        if status == 'RESCHEDULED':
            if not data.get('rescheduled_date') or not data.get('rescheduled_time'):
                raise serializers.ValidationError(
                    "Pour reprogrammer, vous devez fournir une nouvelle date et heure."
                )
            
            # Check if rescheduled date is in the past
            from django.utils import timezone
            import datetime
            today = timezone.now().date()
            if data['rescheduled_date'] < today:
                raise serializers.ValidationError(
                    "La date reprogrammée ne peut pas être dans le passé."
                )
        
        return data
