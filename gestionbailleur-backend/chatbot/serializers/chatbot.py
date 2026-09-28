from rest_framework import serializers
from ..models import ChatbotConversation, ChatbotMessage


class ChatbotMessageSerializer(serializers.ModelSerializer):
    conversation_id = serializers.UUIDField(source='conversation.id', read_only=True)
    contenu = serializers.CharField(source='content')
    donnees = serializers.JSONField(source='metadata', read_only=True)
    date_creation = serializers.DateTimeField(source='created_at', read_only=True)
    date_modification = serializers.DateTimeField(source='updated_at', read_only=True)

    class Meta:
        model = ChatbotMessage
        fields = [
            'id',
            'conversation_id',
            'contenu',
            'role',
            'donnees',
            'date_creation',
            'date_modification',
        ]
        read_only_fields = ['id', 'conversation_id', 'role', 'donnees', 'date_creation', 'date_modification']


class ChatbotConversationSerializer(serializers.ModelSerializer):
    utilisateur_id = serializers.UUIDField(source='user.id', read_only=True)
    titre = serializers.CharField(source='title', required=False)
    contexte = serializers.CharField(source='context', required=False, allow_null=True, allow_blank=True)
    date_derniere_interaction = serializers.DateTimeField(source='updated_at', read_only=True)
    nombre_messages = serializers.SerializerMethodField()
    statut = serializers.SerializerMethodField()
    date_creation = serializers.DateTimeField(source='created_at', read_only=True)
    date_modification = serializers.DateTimeField(source='updated_at', read_only=True)

    class Meta:
        model = ChatbotConversation
        fields = [
            'id',
            'utilisateur_id',
            'titre',
            'contexte',
            'date_derniere_interaction',
            'nombre_messages',
            'statut',
            'date_creation',
            'date_modification',
        ]
        read_only_fields = ['id', 'utilisateur_id', 'date_derniere_interaction', 'nombre_messages', 'statut', 'date_creation', 'date_modification']

    def get_nombre_messages(self, obj):
        return obj.messages.filter(is_deleted=False).count()

    def get_statut(self, obj):
        return 'ACTIF' if not obj.is_deleted else 'ARCHIVÉ'


class SendMessageSerializer(serializers.Serializer):
    message = serializers.CharField(required=True, min_length=1, max_length=2000)
    conversation_id = serializers.UUIDField(required=False, allow_null=True)
