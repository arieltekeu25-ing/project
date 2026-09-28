from rest_framework import serializers
from ..models import Message


class MessageSerializer(serializers.ModelSerializer):
    sender_name = serializers.SerializerMethodField()
    sender_avatar = serializers.SerializerMethodField()
    is_me = serializers.SerializerMethodField()

    class Meta:
        model = Message
        fields = [
            'id',
            'conversation',
            'sender',
            'sender_name',
            'sender_avatar',
            'recipient',
            'content',
            'is_read',
            'read_at',
            'created_at',
            'is_me',
        ]
        read_only_fields = ['id', 'sender', 'recipient', 'is_read', 'read_at', 'created_at']

    def get_sender_name(self, obj):
        return getattr(obj.sender, 'nom_complet', lambda: obj.sender.email)() or obj.sender.email

    def get_sender_avatar(self, obj):
        if hasattr(obj.sender, 'profile') and obj.sender.profile and getattr(obj.sender.profile, 'avatar', None):
            return obj.sender.profile.avatar.url
        return None

    def get_is_me(self, obj):
        request = self.context.get('request')
        if request and request.user:
            return obj.sender == request.user
        return False
