"""
Module visits.views
"""
from .visit import (
    my_visits_view,
    landlord_visits_view,
    visit_detail_view,
    visit_create_view,
    visit_update_view,
    visit_cancel_view,
    visit_accept_reschedule_view,
)

__all__ = [
    'my_visits_view',
    'landlord_visits_view',
    'visit_detail_view',
    'visit_create_view',
    'visit_update_view',
    'visit_cancel_view',
    'visit_accept_reschedule_view',
]
