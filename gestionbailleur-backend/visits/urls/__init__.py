from django.urls import path
from ..views import (
    my_visits_view,
    landlord_visits_view,
    visit_detail_view,
    visit_create_view,
    visit_update_view,
    visit_cancel_view,
    visit_accept_reschedule_view,
)

urlpatterns = [
    # Client visits
    path('my/', my_visits_view, name='my_visits'),
    # Landlord visits
    path('landlord/', landlord_visits_view, name='landlord_visits'),
    # Visit details
    path('<uuid:visit_id>/', visit_detail_view, name='visit_detail'),
    # Create visit
    path('create/', visit_create_view, name='visit_create'),
    # Update visit (landlord actions)
    path('<uuid:visit_id>/update/', visit_update_view, name='visit_update'),
    # Cancel visit (client action)
    path('<uuid:visit_id>/cancel/', visit_cancel_view, name='visit_cancel'),
    # Accept reschedule (client action)
    path('<uuid:visit_id>/accept-reschedule/', visit_accept_reschedule_view, name='visit_accept_reschedule'),
]
