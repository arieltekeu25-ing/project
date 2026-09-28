from unittest.mock import patch
from django.test import TestCase
from django.contrib.auth import get_user_model
from rest_framework.test import APIClient
from rest_framework import status
from django.core.files.uploadedfile import SimpleUploadedFile

from apps.accounts.models import Role, UserRole
from apps.listings.models import Property, PropertyMedia

User = get_user_model()


class PropertyMediaTestCase(TestCase):
    def setUp(self):
        self.client = APIClient()

        # Utilisateur Bailleur actif
        self.landlord = User.objects.create_user(
            email='landlord@test.com',
            password='Password123!',
            telephone='+2250102030405',
            nom='Bailleur',
            prenom='Test',
            etat_compte='ACTIF'
        )
        self.role_landlord = Role.objects.create(code='BAILLEUR', nom='Bailleur')
        UserRole.objects.create(user=self.landlord, role=self.role_landlord, actif=True)

        # Autre bailleur
        self.other_landlord = User.objects.create_user(
            email='other@test.com',
            password='Password123!',
            telephone='+2250102030406',
            nom='Autre',
            prenom='Bailleur',
            etat_compte='ACTIF'
        )
        UserRole.objects.create(user=self.other_landlord, role=self.role_landlord, actif=True)

        # Logement de test
        self.property = Property.objects.create(
            landlord=self.landlord,
            title='Studio Moderne',
            description='Magnifique studio',
            property_type='STUDIO',
            rent_price=150000,
            surface=35.0,
            rooms=1
        )

    def test_unauthenticated_upload_denied(self):
        url = f'/api/v1/properties/{self.property.id}/media/'
        response = self.client.post(url, {})
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    @patch('apps.listings.views.property_media.upload_property_media')
    def test_other_landlord_cannot_upload_media(self, mock_upload):
        self.client.force_authenticate(user=self.other_landlord)
        url = f'/api/v1/properties/{self.property.id}/media/'
        
        dummy_file = SimpleUploadedFile("test.jpg", b"fake_image_bytes", content_type="image/jpeg")
        response = self.client.post(url, {'files': dummy_file}, format='multipart')
        
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
        mock_upload.assert_not_called()

    @patch('apps.listings.views.property_media.upload_property_media')
    def test_authorized_landlord_upload_success(self, mock_upload):
        mock_upload.return_value = {
            'public_id': 'gestbailleur/properties/test_123',
            'secure_url': 'https://res.cloudinary.com/demo/image/upload/v1234/test.jpg',
            'resource_type': 'image',
            'format': 'jpg',
            'width': 800,
            'height': 600,
            'duration': None,
            'bytes': 1024,
        }

        self.client.force_authenticate(user=self.landlord)
        url = f'/api/v1/properties/{self.property.id}/media/'

        dummy_file = SimpleUploadedFile("facade.jpg", b"fake_image_bytes", content_type="image/jpeg")
        response = self.client.post(url, {'files': dummy_file}, format='multipart')

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]['secure_url'], 'https://res.cloudinary.com/demo/image/upload/v1234/test.jpg')

        # Vérifier en DB
        media_db = PropertyMedia.objects.filter(property=self.property).first()
        self.assertIsNotNone(media_db)
        self.assertTrue(media_db.is_primary)

    @patch('apps.listings.views.property_media.delete_cloudinary_media')
    def test_delete_media_success(self, mock_delete):
        mock_delete.return_value = True

        media = PropertyMedia.objects.create(
            property=self.property,
            cloudinary_public_id='test_pub_id',
            secure_url='https://res.cloudinary.com/demo/image/upload/test.jpg',
            resource_type='image',
            is_primary=True
        )

        self.client.force_authenticate(user=self.landlord)
        url = f'/api/v1/properties/{self.property.id}/media/{media.id}/'
        response = self.client.delete(url)

        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
        self.assertFalse(PropertyMedia.objects.filter(id=media.id).exists())
        mock_delete.assert_called_once_with('test_pub_id', resource_type='image')
