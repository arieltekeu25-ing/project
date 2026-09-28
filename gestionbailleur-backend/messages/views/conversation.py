from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.db.models import Q, Count
from drf_spectacular.utils import extend_schema

from ..models import Conversation, Message
from ..serializers import ConversationSerializer
from apps.listings.models import Property


@extend_schema(
    tags=['Messagerie'],
    summary='Lister ou créer des conversations',
    description='Récupérer toutes les conversations de l\'utilisateur connecté ou en démarrer une nouvelle pour un logement',
)
@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def conversations_list_create_view(request):
    if request.method == 'GET':
        conversations = Conversation.objects.filter(
            Q(client=request.user) | Q(landlord=request.user),
            is_deleted=False
        ).select_related('client', 'landlord', 'property').order_by('-last_message_at')

        serializer = ConversationSerializer(conversations, many=True, context={'request': request})
        return Response(serializer.data, status=status.HTTP_200_OK)

    elif request.method == 'POST':
        property_id = request.data.get('property_id') or request.data.get('id')
        if not property_id:
            return Response(
                {'error': 'L\'identifiant du logement (property_id) est requis'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            target_property = Property.objects.get(id=property_id, is_deleted=False)
        except Property.DoesNotExist:
            return Response(
                {'error': 'Logement introuvable'},
                status=status.HTTP_404_NOT_FOUND
            )

        landlord = target_property.landlord
        if not landlord:
            return Response(
                {'error': 'Ce logement n\'a pas de propriétaire assigné'},
                status=status.HTTP_400_BAD_REQUEST
            )

        if request.user == landlord:
            return Response(
                {'error': 'Vous êtes le propriétaire de ce logement'},
                status=status.HTTP_400_BAD_REQUEST
            )

        conversation, created = Conversation.objects.get_or_create(
            client=request.user,
            landlord=landlord,
            property=target_property,
        )

        serializer = ConversationSerializer(conversation, context={'request': request})
        status_code = status.HTTP_201_CREATED if created else status.HTTP_200_OK
        return Response(serializer.data, status=status_code)


@extend_schema(
    tags=['Messagerie'],
    summary='Obtenir les détails d\'une conversation',
)
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def conversation_detail_view(request, conversation_id):
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

    serializer = ConversationSerializer(conversation, context={'request': request})
    return Response(serializer.data, status=status.HTTP_200_OK)


@extend_schema(
    tags=['Messagerie'],
    summary='Nombre total de messages non lus',
)
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def unread_messages_count_view(request):
    count = Message.objects.filter(
        recipient=request.user,
        is_read=False,
        is_deleted=False
    ).count()
    return Response({'unread_count': count}, status=status.HTTP_200_OK)
