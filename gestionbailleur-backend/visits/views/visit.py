from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema, OpenApiParameter

from ..models import Visit
from ..serializers import VisitSerializer, VisitCreateSerializer, VisitUpdateSerializer


@extend_schema(
    tags=['Visites'],
    summary='Lister les demandes de visite du client',
    description='Récupérer la liste des demandes de visite de l\'utilisateur connecté (client)',
    responses={200: VisitSerializer(many=True)},
)
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def my_visits_view(request):
    visits = Visit.objects.filter(
        client=request.user,
        is_deleted=False
    ).order_by('-created_at')
    
    serializer = VisitSerializer(visits, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)


@extend_schema(
    tags=['Visites'],
    summary='Lister les demandes de visite reçues (bailleur)',
    description='Récupérer la liste des demandes de visite pour les logements du bailleur',
    responses={200: VisitSerializer(many=True)},
)
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def landlord_visits_view(request):
    visits = Visit.objects.filter(
        landlord=request.user,
        is_deleted=False
    ).order_by('-created_at')
    
    serializer = VisitSerializer(visits, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)


@extend_schema(
    tags=['Visites'],
    summary='Détails d\'une demande de visite',
    description='Récupérer les détails d\'une demande de visite spécifique',
    responses={200: VisitSerializer},
)
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def visit_detail_view(request, visit_id):
    try:
        visit = Visit.objects.get(id=visit_id, is_deleted=False)
        
        # Check if user is either client or landlord
        if visit.client != request.user and visit.landlord != request.user:
            return Response(
                {'error': 'Vous n\'avez pas accès à cette demande de visite'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        serializer = VisitSerializer(visit)
        return Response(serializer.data, status=status.HTTP_200_OK)
        
    except Visit.DoesNotExist:
        return Response(
            {'error': 'Demande de visite non trouvée'},
            status=status.HTTP_404_NOT_FOUND
        )


@extend_schema(
    tags=['Visites'],
    summary='Créer une demande de visite',
    description='Créer une nouvelle demande de visite pour un logement',
    request=VisitCreateSerializer,
    responses={201: VisitSerializer},
)
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def visit_create_view(request):
    serializer = VisitCreateSerializer(
        data=request.data,
        context={'request': request}
    )
    
    if serializer.is_valid():
        visit = serializer.save()
        
        # Create notification for landlord
        from notifications.models import Notification
        Notification.objects.create(
            user=visit.landlord,
            title='Nouvelle demande de visite',
            message=f'{visit.client.nom_complet()} souhaite visiter {visit.property.title} le {visit.requested_date} à {visit.requested_time}',
            notification_type='VISIT_REQUEST',
            related_id=str(visit.id)
        )
        
        return Response(
            VisitSerializer(visit).data,
            status=status.HTTP_201_CREATED
        )
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@extend_schema(
    tags=['Visites'],
    summary='Mettre à jour une demande de visite',
    description='Mettre à jour le statut ou reprogrammer une visite (réservé au bailleur)',
    request=VisitUpdateSerializer,
    responses={200: VisitSerializer},
)
@api_view(['PUT', 'PATCH'])
@permission_classes([IsAuthenticated])
def visit_update_view(request, visit_id):
    try:
        visit = Visit.objects.get(id=visit_id, is_deleted=False)
        
        # Only landlord can update
        if visit.landlord != request.user:
            return Response(
                {'error': 'Seul le bailleur peut modifier cette demande'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        serializer = VisitUpdateSerializer(
            visit,
            data=request.data,
            partial=request.method == 'PATCH'
        )
        
        if serializer.is_valid():
            updated_visit = serializer.save()
            
            # Create notification for client based on status
            from notifications.models import Notification
            
            if updated_visit.status == 'ACCEPTED':
                Notification.objects.create(
                    user=updated_visit.client,
                    title='Visite acceptée',
                    message=f'Votre demande de visite pour {updated_visit.property.title} a été acceptée pour le {updated_visit.requested_date} à {updated_visit.requested_time}',
                    notification_type='VISIT_ACCEPTED',
                    related_id=str(updated_visit.id)
                )
            elif updated_visit.status == 'REJECTED':
                Notification.objects.create(
                    user=updated_visit.client,
                    title='Visite refusée',
                    message=f'Votre demande de visite pour {updated_visit.property.title} a été refusée. {updated_visit.landlord_response or ""}',
                    notification_type='VISIT_REJECTED',
                    related_id=str(updated_visit.id)
                )
            elif updated_visit.status == 'RESCHEDULED':
                Notification.objects.create(
                    user=updated_visit.client,
                    title='Visite reprogrammée',
                    message=f'Le bailleur a proposé une nouvelle date pour la visite de {updated_visit.property.title}: {updated_visit.rescheduled_date} à {updated_visit.rescheduled_time}. {updated_visit.rescheduled_message or ""}',
                    notification_type='VISIT_RESCHEDULED',
                    related_id=str(updated_visit.id)
                )
            
            return Response(
                VisitSerializer(updated_visit).data,
                status=status.HTTP_200_OK
            )
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
    except Visit.DoesNotExist:
        return Response(
            {'error': 'Demande de visite non trouvée'},
            status=status.HTTP_404_NOT_FOUND
        )


@extend_schema(
    tags=['Visites'],
    summary='Annuler une demande de visite',
    description='Annuler une demande de visite (réservé au client)',
    responses={200: VisitSerializer},
)
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def visit_cancel_view(request, visit_id):
    try:
        visit = Visit.objects.get(id=visit_id, is_deleted=False)
        
        # Only client can cancel
        if visit.client != request.user:
            return Response(
                {'error': 'Seul le client peut annuler cette demande'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        # Can only cancel pending or rescheduled visits
        if visit.status not in ['PENDING', 'RESCHEDULED']:
            return Response(
                {'error': 'Cette demande ne peut plus être annulée'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        visit.status = 'CANCELLED'
        visit.save()
        
        # Notify landlord
        from notifications.models import Notification
        Notification.objects.create(
            user=visit.landlord,
            title='Visite annulée',
            message=f'{visit.client.nom_complet()} a annulé sa demande de visite pour {visit.property.title}',
            notification_type='VISIT_CANCELLED',
            related_id=str(visit.id)
        )
        
        return Response(
            VisitSerializer(visit).data,
            status=status.HTTP_200_OK
        )
        
    except Visit.DoesNotExist:
        return Response(
            {'error': 'Demande de visite non trouvée'},
            status=status.HTTP_404_NOT_FOUND
        )


@extend_schema(
    tags=['Visites'],
    summary='Accepter une proposition de reprogrammation',
    description='Client accepte une nouvelle date proposée par le bailleur',
    responses={200: VisitSerializer},
)
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def visit_accept_reschedule_view(request, visit_id):
    try:
        visit = Visit.objects.get(id=visit_id, is_deleted=False)
        
        # Only client can accept
        if visit.client != request.user:
            return Response(
                {'error': 'Seul le client peut accepter cette reprogrammation'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        # Must be in rescheduled status
        if visit.status != 'RESCHEDULED':
            return Response(
                {'error': 'Cette visite n\'est pas en attente de reprogrammation'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Update visit with rescheduled date/time
        visit.requested_date = visit.rescheduled_date
        visit.requested_time = visit.rescheduled_time
        visit.status = 'ACCEPTED'
        visit.rescheduled_date = None
        visit.rescheduled_time = None
        visit.rescheduled_message = None
        visit.save()
        
        # Notify landlord
        from notifications.models import Notification
        Notification.objects.create(
            user=visit.landlord,
            title='Reprogrammation acceptée',
            message=f'{visit.client.nom_complet()} a accepté la nouvelle date pour la visite de {visit.property.title}',
            notification_type='VISIT_RESCHEDULE_ACCEPTED',
            related_id=str(visit.id)
        )
        
        return Response(
            VisitSerializer(visit).data,
            status=status.HTTP_200_OK
        )
        
    except Visit.DoesNotExist:
        return Response(
            {'error': 'Demande de visite non trouvée'},
            status=status.HTTP_404_NOT_FOUND
        )
