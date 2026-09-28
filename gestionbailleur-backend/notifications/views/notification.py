from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema

from ..models import Notification
from ..serializers import NotificationSerializer


@extend_schema(
    tags=['Notifications'],
    summary='Lister les notifications de l\'utilisateur',
)
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def notifications_list_view(request):
    notifications = Notification.objects.filter(
        user=request.user,
        is_deleted=False
    ).order_by('-created_at')

    serializer = NotificationSerializer(notifications, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)


@extend_schema(
    tags=['Notifications'],
    summary='Nombre de notifications non lues',
)
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def unread_notifications_count_view(request):
    count = Notification.objects.filter(
        user=request.user,
        is_read=False,
        is_deleted=False
    ).count()
    return Response({'unread_count': count}, status=status.HTTP_200_OK)


@extend_schema(
    tags=['Notifications'],
    summary='Marquer toutes les notifications comme lues',
)
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def mark_notifications_read_view(request):
    updated = Notification.objects.filter(
        user=request.user,
        is_read=False
    ).update(is_read=True)
    return Response({'message': 'Notifications marquées comme lues', 'read_count': updated}, status=status.HTTP_200_OK)
