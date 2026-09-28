import uuid
import os
from django.utils import timezone
from django.conf import settings
from rest_framework import status, viewsets
from rest_framework.decorators import api_view, permission_classes, action
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema, OpenApiParameter

from ..models import ChatbotConversation, ChatbotMessage
from ..serializers import (
    ChatbotConversationSerializer,
    ChatbotMessageSerializer,
    SendMessageSerializer
)
from ..services import AIService


class ChatbotConversationViewSet(viewsets.ModelViewSet):
    """
    ViewSet pour la gestion des conversations et l'interaction avec l'IA.
    """
    serializer_class = ChatbotConversationSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return ChatbotConversation.objects.filter(
            user=self.request.user,
            is_deleted=False
        ).order_by('-updated_at')

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    def destroy(self, request, *args, **kwargs):
        conversation = self.get_object()
        conversation.soft_delete()
        return Response({'detail': 'Conversation supprimée avec succès.'}, status=status.HTTP_200_OK)

    @extend_schema(
        summary="Lister les messages d'une conversation",
        responses={200: ChatbotMessageSerializer(many=True)}
    )
    @action(detail=True, methods=['get'], url_path='messages')
    def list_messages(self, request, pk=None):
        conversation = self.get_object()
        messages = conversation.messages.filter(is_deleted=False).order_by('created_at')
        serializer = ChatbotMessageSerializer(messages, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)


@extend_schema(
    tags=['Chatbot IA'],
    summary="Envoyer un message à l'IA",
    description="Envoie un message utilisateur à l'IA, crée/récupère la conversation et renvoie la réponse générée par l'IA.",
    request=SendMessageSerializer
)
@api_view(['POST'])
@permission_classes([AllowAny])
def send_message_view(request):
    serializer = SendMessageSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    user_text = serializer.validated_data['message'].strip()
    conversation_id = serializer.validated_data.get('conversation_id')

    # Cas 1 : Utilisateur connecté
    if request.user and request.user.is_authenticated:
        conversation = None
        if conversation_id:
            try:
                conversation = ChatbotConversation.objects.get(
                    id=conversation_id,
                    user=request.user,
                    is_deleted=False
                )
            except ChatbotConversation.DoesNotExist:
                pass

        if not conversation:
            title_text = user_text[:35] + ("..." if len(user_text) > 35 else "")
            conversation = ChatbotConversation.objects.create(
                user=request.user,
                title=title_text
            )

        # 1. Enregistrer le message de l'utilisateur
        user_msg = ChatbotMessage.objects.create(
            conversation=conversation,
            sender=request.user,
            role='user',
            content=user_text
        )

        # 2. Récupérer l'historique récent de la conversation
        history_messages = list(
            conversation.messages.filter(is_deleted=False).order_by('created_at')
        )

        # 3. Générer la réponse de l'IA (contexte utilisateur & données réelles PostgreSQL)
        ai_reply_text, metadata = AIService.generate_response(
            user=request.user,
            conversation=conversation,
            user_message_text=user_text,
            history_messages=history_messages
        )

        # 4. Enregistrer la réponse de l'IA
        ai_msg = ChatbotMessage.objects.create(
            conversation=conversation,
            sender=None,
            role='assistant',
            content=ai_reply_text,
            metadata=metadata
        )

        conversation.save()

        return Response({
            'conversation': ChatbotConversationSerializer(conversation).data,
            'user_message': ChatbotMessageSerializer(user_msg).data,
            'ai_message': ChatbotMessageSerializer(ai_msg).data
        }, status=status.HTTP_200_OK)

    # Cas 2 : Visiteur invité (non connecté)
    else:
        ai_reply_text, metadata = AIService.generate_response(
            user=None,
            conversation=None,
            user_message_text=user_text,
            history_messages=[]
        )

        guest_conv_id = conversation_id or str(uuid.uuid4())
        now_str = timezone.now().isoformat()

        return Response({
            'conversation': {
                'id': guest_conv_id,
                'titre': user_text[:35],
                'utilisateur_id': '',
                'nombre_messages': 2,
                'statut': 'ACTIF',
                'date_creation': now_str,
                'date_derniere_interaction': now_str,
                'date_modification': now_str,
            },
            'user_message': {
                'id': str(uuid.uuid4()),
                'conversation_id': guest_conv_id,
                'role': 'user',
                'contenu': user_text,
                'donnees': {},
                'statut': 'ENVOYE',
                'date_creation': now_str,
                'date_modification': now_str,
            },
            'ai_message': {
                'id': str(uuid.uuid4()),
                'conversation_id': guest_conv_id,
                'role': 'assistant',
                'contenu': ai_reply_text,
                'donnees': metadata,
                'statut': 'ENVOYE',
                'date_creation': now_str,
                'date_modification': now_str,
            }
        }, status=status.HTTP_200_OK)


@api_view(['GET'])
@permission_classes([AllowAny])
def chatbot_health_view(request):
    """
    Endpoint de diagnostic pour vérifier la configuration IA sur le serveur.
    Ne révèle PAS la clé réelle - seulement si elle est configurée et ses 8 premiers caractères.
    """
    from ..services import AIService

    api_key = AIService.get_api_key()
    model_name = os.getenv('AI_MODEL_NAME', getattr(settings, 'AI_MODEL_NAME', 'gemini-3.6-flash'))

    key_configured = bool(api_key)
    key_preview = f"{api_key[:8]}..." if api_key else "NON CONFIGURE"
    key_source = "inconnue"

    if api_key:
        if os.getenv('AI_API_KEY') == api_key:
            key_source = "AI_API_KEY"
        elif os.getenv('GEMINI_API_KEY') == api_key:
            key_source = "GEMINI_API_KEY"
        elif getattr(settings, 'AI_API_KEY', None) == api_key:
            key_source = "settings.AI_API_KEY"

    # Test Gemini live depuis ce serveur
    gemini_test = None
    if key_configured and request.GET.get('test') == '1':
        import requests as req
        test_url = (
            "https://generativelanguage.googleapis.com/v1beta/models/"
            + model_name
            + ":generateContent?key="
            + api_key
        )
        test_payload = {
            "contents": [{"role": "user", "parts": [{"text": "Bonjour"}]}],
            "generationConfig": {"maxOutputTokens": 30}
        }
        try:
            test_resp = req.post(test_url, json=test_payload, timeout=15)
            if test_resp.status_code == 200:
                data = test_resp.json()
                parts = data.get("candidates", [{}])[0].get("content", {}).get("parts", [])
                text = parts[0].get("text", "") if parts else ""
                gemini_test = {"status": "OK", "http": 200, "reply": text[:100]}
            else:
                err = test_resp.json().get("error", {}).get("message", test_resp.text[:200])
                gemini_test = {"status": "FAILED", "http": test_resp.status_code, "error": err}
        except Exception as e:
            gemini_test = {"status": "EXCEPTION", "error": type(e).__name__ + ": " + str(e)[:200]}

    response_data = {
        'status': 'ok' if key_configured else 'warning',
        'ai_configured': key_configured,
        'api_key_preview': key_preview,
        'api_key_source': key_source,
        'model_name': model_name,
        'railway_vars': {
            'AI_API_KEY': 'SET' if os.getenv('AI_API_KEY') else 'MISSING',
            'GEMINI_API_KEY': 'SET' if os.getenv('GEMINI_API_KEY') else 'MISSING',
            'AI_MODEL_NAME': os.getenv('AI_MODEL_NAME', 'NOT SET'),
        },
        'message': 'API IA correctement configuree' if key_configured else 'CLE API MANQUANTE',
    }
    if gemini_test is not None:
        response_data['gemini_live_test'] = gemini_test

    return Response(response_data, status=status.HTTP_200_OK)
