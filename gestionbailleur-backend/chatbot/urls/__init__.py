from django.urls import path, include
from rest_framework.routers import DefaultRouter
from ..views import ChatbotConversationViewSet, send_message_view, chatbot_health_view

router = DefaultRouter()
router.register(r'conversations', ChatbotConversationViewSet, basename='chatbot-conversations')

urlpatterns = [
    path('send/', send_message_view, name='chatbot-send'),
    path('health/', chatbot_health_view, name='chatbot-health'),
    path('', include(router.urls)),
]
