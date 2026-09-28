"""
Service pour la gestion des téléversements et suppressions sur Cloudinary.
Architecture des dossiers :
- gestbailleur/properties/{property_id}/images/
- gestbailleur/properties/{property_id}/videos/
- gestbailleur/profiles/{user_id}/
"""
import logging
import cloudinary
import cloudinary.uploader

logger = logging.getLogger(__name__)


def upload_property_media(file_obj, property_id, resource_type='image'):
    """
    Téléverse un fichier média (image ou vidéo) pour un logement sur Cloudinary.
    """
    if resource_type == 'video':
        folder_path = f"gestbailleur/properties/{property_id}/videos"
    else:
        folder_path = f"gestbailleur/properties/{property_id}/images"

    try:
        response = cloudinary.uploader.upload(
            file_obj,
            folder=folder_path,
            resource_type=resource_type,
            overwrite=True,
        )

        return {
            'public_id': response.get('public_id'),
            'secure_url': response.get('secure_url'),
            'resource_type': resource_type,
            'format': response.get('format', ''),
            'width': response.get('width'),
            'height': response.get('height'),
            'duration': response.get('duration'),
            'bytes': response.get('bytes'),
        }
    except Exception as e:
        logger.error(f"Erreur lors de l'upload Cloudinary (Property {property_id}): {str(e)}")
        raise e


def upload_profile_photo(file_obj, user_id):
    """
    Téléverse une photo de profil utilisateur sur Cloudinary.
    """
    folder_path = f"gestbailleur/profiles/{user_id}"

    try:
        response = cloudinary.uploader.upload(
            file_obj,
            folder=folder_path,
            resource_type='image',
            overwrite=True,
        )

        return {
            'public_id': response.get('public_id'),
            'secure_url': response.get('secure_url'),
            'format': response.get('format', ''),
            'width': response.get('width'),
            'height': response.get('height'),
            'bytes': response.get('bytes'),
        }
    except Exception as e:
        logger.error(f"Erreur lors de l'upload de photo de profil Cloudinary (User {user_id}): {str(e)}")
        raise e


def delete_cloudinary_media(public_id, resource_type='image'):
    """
    Supprime un média de Cloudinary par son public_id.
    """
    if not public_id:
        return True

    try:
        res = cloudinary.uploader.destroy(public_id, resource_type=resource_type)
        result_status = res.get('result')
        if result_status not in ['ok', 'not found']:
            logger.warning(f"Statut inattendu lors de la suppression Cloudinary ({public_id}): {result_status}")
        return True
    except Exception as e:
        logger.error(f"Échec de suppression du média Cloudinary ({public_id}): {str(e)}")
        raise e
