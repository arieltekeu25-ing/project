from django.test import TestCase
from django.contrib.auth import get_user_model
from rest_framework.test import APIClient
from rest_framework import status

from apps.accounts.models import Role, UserRole
from apps.listings.models import Property
from apps.locations.models import Address, City, Country, Region
from chatbot.models import ChatbotConversation, ChatbotMessage
from chatbot.services import AIService

User = get_user_model()


class ChatbotAPITestCase(TestCase):
    def setUp(self):
        self.client = APIClient()

        # Création des rôles
        self.client_role, _ = Role.objects.get_or_create(
            code='CLIENT',
            defaults={'nom': 'Client'}
        )
        self.landlord_role, _ = Role.objects.get_or_create(
            code='BAILLEUR',
            defaults={'nom': 'Bailleur'}
        )

        # Utilisateur Client
        self.user_client = User.objects.create_user(
            email='client@test.com',
            telephone='+237690000001',
            password='password123',
            nom='Client',
            prenom='Test',
            etat_compte='ACTIF'
        )
        UserRole.objects.create(user=self.user_client, role=self.client_role, actif=True)

        # Utilisateur Bailleur
        self.user_landlord = User.objects.create_user(
            email='landlord@test.com',
            telephone='+237690000002',
            password='password123',
            nom='Bailleur',
            prenom='Test',
            etat_compte='ACTIF'
        )
        UserRole.objects.create(user=self.user_landlord, role=self.landlord_role, actif=True)

        self.country = Country.objects.create(
            nom='Cameroun',
            code_iso2='CM',
            code_iso3='CMR',
            indicatif_telephonique='+237',
            continent='AF'
        )
        self.region_centre = Region.objects.create(
            nom='Centre',
            code='CTR',
            country=self.country
        )
        self.city_yaounde = City.objects.create(
            nom='Yaoundé',
            code='YDE',
            region=self.region_centre
        )
        self.address = Address.objects.create(
            ligne_1='Bastos',
            city=self.city_yaounde,
            region=self.region_centre,
            country=self.country
        )
        self.property = Property.objects.create(
            landlord=self.user_landlord,
            title='Studio Moderne Bastos',
            description='Un superbe studio meublé à Bastos Yaoundé',
            property_type='STUDIO',
            status='PUBLISHED',
            rent_price=100000.00,
            surface=35.0,
            rooms=1,
            bedrooms=1,
            furnished=True,
            address=self.address
        )

    def test_unauthenticated_user_access_denied(self):
        """Un utilisateur anonyme peut chatter avec l'IA mais ne peut pas lister les conversations privées."""
        response = self.client.post('/api/v1/chatbot/send/', {'message': 'Bonjour'})
        self.assertEqual(response.status_code, status.HTTP_200_OK)

        response_conv = self.client.get('/api/v1/chatbot/conversations/')
        self.assertEqual(response_conv.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_authenticated_client_send_message(self):
        """Un client authentifié peut envoyer un message et recevoir une réponse de l'IA."""
        self.client.force_authenticate(user=self.user_client)

        response = self.client.post('/api/v1/chatbot/send/', {
            'message': 'Je cherche un studio à Yaoundé'
        })
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.json()

        self.assertIn('conversation', data)
        self.assertIn('user_message', data)
        self.assertIn('ai_message', data)

        self.assertEqual(data['user_message']['contenu'], 'Je cherche un studio à Yaoundé')
        self.assertEqual(data['ai_message']['role'], 'assistant')
        self.assertTrue(len(data['ai_message']['contenu']) > 0)

        # La réponse doit faire référence au logement réel de Yaoundé
        self.assertIn('Studio Moderne Bastos', data['ai_message']['contenu'])

    def test_search_criteria_extraction(self):
        """Vérifie que l'extraction des critères en langage naturel fonctionne correctement."""
        criteria = AIService.extract_search_criteria("Je cherche un appartement meublé à Douala pour 150000 FCFA")
        self.assertEqual(criteria.get('property_type'), 'APARTMENT')
        self.assertEqual(criteria.get('city'), 'Douala')
        self.assertEqual(criteria.get('max_price'), 150000.0)
        self.assertTrue(criteria.get('furnished'))

    def test_no_matching_real_property(self):
        """Quand aucun bien ne correspond aux critères, l'IA répond proprement sans inventer."""
        self.client.force_authenticate(user=self.user_client)

        response = self.client.post('/api/v1/chatbot/send/', {
            'message': 'Je cherche une villa à Maroua pour 5000 FCFA'
        })
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.json()
        content = data['ai_message']['contenu']

        self.assertTrue(
            "aucun" in content.lower() or "n'ai trouvé" in content.lower() or "modifier" in content.lower() or "élargir" in content.lower()
        )

    def test_conversation_history_management(self):
        """Test de la gestion de l'historique et de la suppression de conversation."""
        self.client.force_authenticate(user=self.user_client)

        # Créer une conversation spécifique
        conv = ChatbotConversation.objects.create(user=self.user_client, title='Test History Unique')
        ChatbotMessage.objects.create(conversation=conv, sender=self.user_client, role='user', content='Message 1')

        # Lister les conversations
        resp_list = self.client.get('/api/v1/chatbot/conversations/')
        self.assertEqual(resp_list.status_code, status.HTTP_200_OK)
        res_data = resp_list.json()
        results = res_data.get('results', res_data) if isinstance(res_data, dict) else res_data
        conv_ids = [c['id'] for c in results]
        self.assertIn(str(conv.id), conv_ids)

        # Supprimer la conversation
        resp_del = self.client.delete(f'/api/v1/chatbot/conversations/{conv.id}/')
        self.assertEqual(resp_del.status_code, status.HTTP_200_OK)

        # Vérifier qu'elle n'apparaît plus
        resp_list_after = self.client.get('/api/v1/chatbot/conversations/')
        res_data_after = resp_list_after.json()
        results_after = res_data_after.get('results', res_data_after) if isinstance(res_data_after, dict) else res_data_after
        conv_ids_after = [c['id'] for c in results_after]
        self.assertNotIn(str(conv.id), conv_ids_after)
