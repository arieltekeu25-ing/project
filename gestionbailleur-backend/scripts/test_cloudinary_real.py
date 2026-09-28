"""
Script de validation d'upload et de suppression réelle sur Cloudinary
Utilise les identifiants configurés dans .env
"""
import os
import sys
from pathlib import Path
import io
from PIL import Image

# Configurer l'environnement Django
BASE_DIR = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(BASE_DIR))

import django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.test')
django.setup()

from apps.listings.services import upload_property_media, delete_cloudinary_media, upload_profile_photo


def create_sample_jpeg_stream():
    img = Image.new('RGB', (400, 300), color='#1E88E5')
    buf = io.BytesIO()
    img.save(buf, format='JPEG')
    buf.seek(0)
    buf.name = 'sample_property_photo.jpg'
    return buf


def test_cloudinary_real_flow():
    print("=== TEST REAL CLOUDINARY UPLOAD & CLEANUP ===")
    
    # 1. Générer une vraie image JPEG valide de test
    img_stream = create_sample_jpeg_stream()
    test_property_id = "00000000-0000-0000-0000-000000000001"
    
    print("[1/3] Uploading real JPEG image to Cloudinary folder gestbailleur/properties...")
    res = upload_property_media(img_stream, property_id=test_property_id, resource_type='image')
    
    public_id = res.get('public_id')
    secure_url = res.get('secure_url')
    
    print(f" -> Success! Public ID: {public_id}")
    print(f" -> Secure URL: {secure_url}")
    
    if not secure_url or not secure_url.startswith("https://res.cloudinary.com"):
        raise ValueError("L'URL Cloudinary retournée n'est pas un HTTPS valide!")
        
    print("[2/3] Uploading real profile photo to Cloudinary folder gestbailleur/profiles...")
    prof_stream = create_sample_jpeg_stream()
    prof_res = upload_profile_photo(prof_stream, user_id="test_user_99")
    prof_pub_id = prof_res.get('public_id')
    prof_url = prof_res.get('secure_url')
    print(f" -> Success! Profile Public ID: {prof_pub_id}")
    print(f" -> Profile Secure URL: {prof_url}")

    print("[3/3] Cleaning up Cloudinary test files...")
    delete_cloudinary_media(public_id, resource_type='image')
    delete_cloudinary_media(prof_pub_id, resource_type='image')
    print(" -> Cleanup finished successfully!")
    print("=== REAL CLOUDINARY TEST PASSED ===")


if __name__ == '__main__':
    test_cloudinary_real_flow()
