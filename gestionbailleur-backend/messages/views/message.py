from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.utils import timezone
from drf_spectacular.utils import extend_schema

from ..models import Conversation, Message
from ..serializers import MessageSerializer
from notifications.models import Notification


@extend_schema(
    tags=['Messagerie'],
    summary='Lister ou envoyer des messages dans une conversation',
)
@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def messages_list_create_view(request, conversation_id):
    try:
        conversation = Conversation.objects.get(
            id=conversation_id,
            is_deleted=False
        )
    except Conversation.DoesNotExist:
        return Response(
            {'error': 'Conversation non trouvée'},
            status=status.HTTP_404_NOT_FOUND
        )

    if request.user != conversation.client and request.user != conversation.landlord:
        return Response(
            {'error': 'Accès refusé à cette conversation'},
            status=status.HTTP_403_FORBIDDEN
        )

    if request.method == 'GET':
        messages = Message.objects.filter(
            conversation=conversation,
            is_deleted=False
        ).select_related('sender', 'recipient').order_by('created_at')

        serializer = MessageSerializer(messages, many=True, context={'request': request})
        return Response(serializer.data, status=status.HTTP_200_OK)

    elif request.method == 'POST':
        content = request.data.get('content', '').strip()
        if not content:
            return Response(
                {'error': 'Le contenu du message ne peut pas être vide'},
                status=status.HTTP_400_BAD_REQUEST
            )

        recipient = conversation.landlord if request.user == conversation.client else conversation.client

        message = Message.objects.create(
            conversation=conversation,
            sender=request.user,
            recipient=recipient,
            content=content,
        )

        conversation.last_message_at = timezone.now()
        conversation.save(update_fields=['last_message_at', 'updated_at'])

        # Générer une notification réelle pour le destinataire
        sender_name = request.user.nom_complet or request.user.email
        Notification.objects.create(
            user=recipient,
            title=f"Nouveau message de {sender_name}",
            message=content[:100],
            notification_type='MESSAGE',
            related_id=str(conversation.id)
        )

        serializer = MessageSerializer(message, context={'request': request})
        return Response(serializer.data, status=status.HTTP_201_CREATED)


@extend_schema(
    tags=['Messagerie'],
    summary='Marquer tous les messages d\'une conversation comme lus',
)
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def mark_conversation_read_view(request, conversation_id):
    try:
        conversation = Conversation.objects.get(
            id=conversation_id,
            is_deleted=False
        )
    except Conversation.DoesNotExist:
        return Response(
            {'error': 'Conversation non trouvée'},
            status=status.HTTP_404_NOT_FOUND
        )

    if request.user != conversation.client and request.user != conversation.landlord:
        return Response(
            {'error': 'Accès refusé à cette conversation'},
            status=status.HTTP_403_FORBIDDEN
        )

    unread_messages = Message.objects.filter(
        conversation=conversation,
        recipient=request.user,
        is_read=False
    )
    count = unread_messages.count()
    unread_messages.update(is_read=True, read_at=timezone.now())

    # Marquer également les notifications de cette conversation comme lues
    Notification.objects.filter(
        user=request.user,
        related_id=str(conversation.id),
        is_read=False
    ).update(is_read=True)

    return Response(
        {
            'message': 'Messages marqués comme lus',
            'read_count': count
        },
        status=status.HTTP_200_OK
    )
