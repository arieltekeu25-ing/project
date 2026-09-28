"""
Configuration des URLs API v1
"""
from django.urls import path, include

urlpatterns = [
    # Authentication
    path('auth/', include('apps.accounts.urls')),
    
    # Users & Profiles
    path('profiles/', include('apps.profiles.urls')),
    path('users/', include('apps.profiles.urls')),
    
    # Listings/Properties
    path('properties/', include('apps.listings.urls')),
    path('listings/', include('apps.listings.urls')),

    # Favorites
    path('favorites/', include('favorites.urls')),

    # Messages & Notifications
    path('messages/', include('messages.urls')),
    path('notifications/', include('notifications.urls')),

    # Visits
    path('visits/', include('visits.urls')),

    # Chatbot IA
    path('chatbot/', include('chatbot.urls')),
]

