from rest_framework import serializers
from ..models import Conversation, Message
from .message import MessageSerializer
from apps.listings.serializers import PropertySerializer


class ConversationSerializer(serializers.ModelSerializer):
    property = PropertySerializer(read_only=True)
    other_participant = serializers.SerializerMethodField()
    last_message = serializers.SerializerMethodField()
    unread_count = serializers.SerializerMethodField()

    class Meta:
        model = Conversation
        fields = [
            'id',
            'client',
            'landlord',
            'property',
            'other_participant',
            'last_message',
            'unread_count',
            'created_at',
            'updated_at',
            'last_message_at',
        ]
        read_only_fields = ['id', 'client', 'landlord', 'created_at', 'updated_at', 'last_message_at']

    def get_other_participant(self, obj):
        request = self.context.get('request')
        if not request or not request.user:
            user = obj.landlord
        elif request.user == obj.client:
            user = obj.landlord
        else:
            user = obj.client

        avatar = None
        if hasattr(user, 'profile') and user.profile and getattr(user.profile, 'avatar', None):
            avatar = user.profile.avatar.url

        role = 'BAILLEUR' if getattr(user, 'role', '') == 'BAILLEUR' else 'CLIENT'

        return {
            'id': str(user.id),
            'name': user.nom_complet() or user.email,
            'email': user.email,
            'avatar': avatar,
            'role': role,
        }

    def get_last_message(self, obj):
        last_msg = obj.messages.order_by('-created_at').first()
        if last_msg:
            return MessageSerializer(last_msg, context=self.context).data
        return None

    def get_unread_count(self, obj):
        request = self.context.get('request')
        if request and request.user:
            return obj.messages.filter(recipient=request.user, is_read=False).count()
        return 0
