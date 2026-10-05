import os
import json
import logging
import requests
from django.conf import settings
from django.db.models import Q
from apps.listings.models import Property
from apps.accounts.models import UserRole

logger = logging.getLogger(__name__)


class AIService:
    """
    Service d'intégration IA pour GestBailleur.
    Gère la communication avec les fournisseurs d'IA (Gemini / OpenAI / Groq)
    et injecte le contexte réel de la base de données PostgreSQL / Supabase.
    """

    DEFAULT_FALLBACK_RESPONSE = (
        "Le service d'assistance IA est momentanément indisponible. "
        "Veuillez rééchanger dans quelques instants ou effectuer votre recherche directement via l'onglet de recherche."
    )

    @classmethod
    def get_api_key(cls):
        """Récupère la clé API IA configurée côté backend."""
        key = getattr(settings, 'AI_API_KEY', None)
        if not key:
            key = (
                os.getenv('AI_API_KEY') or
                os.getenv('GEMINI_API_KEY') or
                os.getenv('GOOGLE_API_KEY') or
                os.getenv('CHATBOT_API_KEY') or
                os.getenv('API_KEY') or
                os.getenv('OPENAI_API_KEY') or
                os.getenv('GROQ_API_KEY') or
                os.getenv('MISTRAL_API_KEY')
            )
        if key:
            key = str(key).strip().strip('"').strip("'")
        return key

    @classmethod
    def get_user_primary_role(cls, user):
        """Détermine le rôle principal d'un utilisateur (BAILLEUR, ADMINISTRATEUR, CLIENT)."""
        if not user or not user.is_authenticated:
            return 'CLIENT'
        
        if user.is_staff or user.is_superuser:
            return 'ADMINISTRATEUR'

        user_roles = UserRole.objects.filter(user=user, actif=True, is_deleted=False).values_list('role__code', flat=True)
        if 'ADMINISTRATEUR' in user_roles or 'ADMIN' in user_roles:
            return 'ADMINISTRATEUR'
        if 'BAILLEUR' in user_roles or 'LANDLORD' in user_roles:
            return 'BAILLEUR'
        return 'CLIENT'

    @classmethod
    def extract_search_criteria(cls, query_text):
        """
        Extrait les critères de recherche réels à partir du texte en langage naturel.
        """
        query_lower = query_text.lower()
        criteria = {}

        # Type de logement
        if 'studio' in query_lower:
            criteria['property_type'] = 'STUDIO'
        elif 'duplex' in query_lower:
            criteria['property_type'] = 'DUPLEX'
        elif 'triplex' in query_lower:
            criteria['property_type'] = 'TRIPLEX'
        elif 'appartement' in query_lower or 'appart' in query_lower:
            criteria['property_type'] = 'APARTMENT'
        elif 'maison' in query_lower:
            criteria['property_type'] = 'HOUSE'
        elif 'villa' in query_lower:
            criteria['property_type'] = 'VILLA'
        elif 'loft' in query_lower:
            criteria['property_type'] = 'LOFT'

        # Villes populaires du Cameroun et région
        cities = ['yaoundé', 'yaounde', 'douala', 'bafoussam', 'garoua', 'maroua', 'buea', 'limbe', 'kribi', 'bamenda', 'ebolowa']
        for city in cities:
            if city in query_lower:
                criteria['city'] = city.replace('yaounde', 'yaoundé').capitalize()
                break

        # Extraction simple des budgets
        words = query_lower.replace('fcfa', '').replace('f cfa', '').replace('cfa', '').replace('francs', '').split()
        for word in words:
            clean_word = word.replace(' ', '').replace('.', '').replace(',', '')
            if clean_word.endswith('k') and clean_word[:-1].isdigit():
                try:
                    criteria['max_price'] = float(clean_word[:-1]) * 1000
                except ValueError:
                    pass
            elif clean_word.isdigit() and len(clean_word) >= 4:
                try:
                    val = float(clean_word)
                    if val >= 5000:
                        criteria['max_price'] = val
                except ValueError:
                    pass

        if 'meublé' in query_lower or 'meuble' in query_lower:
            criteria['furnished'] = True

        for n in range(1, 10):
            if f"{n} chambre" in query_lower or f"{n} chambres" in query_lower:
                criteria['bedrooms'] = n
                break

        return criteria

    @classmethod
    def fetch_real_properties(cls, criteria, query_text="", user=None, role='CLIENT'):
        """
        Récupère les logements réels correspondant aux critères ou à la recherche textuelle depuis PostgreSQL.
        """
        queryset = Property.objects.filter(is_deleted=False)

        if role == 'CLIENT':
            queryset = queryset.filter(status='PUBLISHED')
        elif role == 'BAILLEUR' and user:
            queryset = queryset.filter(Q(landlord=user) | Q(status='PUBLISHED'))

        if criteria.get('city'):
            city = criteria['city']
            queryset = queryset.filter(
                Q(address__city__nom__icontains=city) |
                Q(address__district__nom__icontains=city) |
                Q(address__neighborhood__nom__icontains=city)
            )

        if criteria.get('property_type'):
            queryset = queryset.filter(property_type=criteria['property_type'])

        if criteria.get('max_price'):
            queryset = queryset.filter(rent_price__lte=criteria['max_price'])

        if criteria.get('min_price'):
            queryset = queryset.filter(rent_price__gte=criteria['min_price'])

        if criteria.get('bedrooms'):
            queryset = queryset.filter(bedrooms__gte=criteria['bedrooms'])

        if criteria.get('furnished'):
            queryset = queryset.filter(furnished=True)

        results = list(queryset.select_related('address', 'address__city', 'address__district', 'landlord')[:6])

        # Si aucun résultat avec critères stricts, recherche globale par mots clés dans le texte
        if not results and query_text:
            search_words = [w for w in query_text.lower().split() if len(w) > 2]
            q_filter = Q()
            for w in search_words:
                q_filter |= Q(title__icontains=w) | Q(description__icontains=w) | Q(property_type__icontains=w)
            
            fallback_qs = Property.objects.filter(is_deleted=False, status='PUBLISHED').filter(q_filter)
            results = list(fallback_qs.select_related('address', 'address__city', 'address__district', 'landlord')[:6])

        # Si toujours aucun résultat, retourner les logements récents disponibles sur la plateforme
        if not results:
            results = list(Property.objects.filter(is_deleted=False, status='PUBLISHED').select_related('address', 'address__city', 'address__district', 'landlord').order_by('-created_at')[:4])

        return results

    @classmethod
    def build_system_prompt(cls, user, role, properties_context, landlord_stats=None):
        """
        Construit le prompt système adapté au rôle et au contexte de GestBailleur.
        """
        user_name = "Visiteur"
        if user and getattr(user, 'is_authenticated', False):
            user_name = user.nom_complet() if callable(getattr(user, 'nom_complet', None)) else getattr(user, 'nom_complet', getattr(user, 'email', 'Utilisateur'))

        base_prompt = (
            "Tu es l'Assistant Virtuel officiel de la plateforme immobilière GestBailleur.\n"
            "Ton rôle est d'aider avec courtoisie, clarté et précision les utilisateurs de GestBailleur.\n"
            "Tu dois TOUJOURS répondre en français fluide, naturel et professionnel.\n"
            "CONSIGNE DE RÉPONSE : Sois clair, concis et toujours complet. Structure tes conseils en 3 à 5 points simples.\n"
            "Toutes tes réponses doivent être basées EXCLUSIVEMENT sur les données réelles et vérifiées ci-dessous.\n\n"
        )

        if role == 'CLIENT':
            prompt = base_prompt + (
                f"L'utilisateur actuel s'appelle {user_name} (Rôle: Client / Chercheur de logement).\n"
                "Ta mission est de l'aider à trouver le logement idéal selon son budget et ses préférences.\n"
            )
            if properties_context:
                prompt += "\nLOGEMENTS RÉELS DISPONIBLES CORRESPONDANT À LA RECHERCHE :\n"
                for p in properties_context:
                    city_name = p.address.city.nom if (p.address and p.address.city) else "Non spécifié"
                    district_name = p.address.district.nom if (p.address and p.address.district) else ""
                    location = f"{city_name} {district_name}".strip()
                    prompt += (
                        f"- ID: {p.id} | Titre: {p.title} | Type: {p.get_property_type_display()} | "
                        f"Prix: {p.rent_price} FCFA | Pièces: {p.rooms} | Chambres: {p.bedrooms} | "
                        f"Meublé: {'Oui' if p.furnished else 'Non'} | Localisation: {location}\n"
                    )
            else:
                prompt += (
                    "\nAUCUN LOGEMENT RÉEL NE CORRESPOND EXACTEMENT AUX CRITÈRES RECHERCHÉS DANS LA BASE DE DONNÉES.\n"
                )

        elif role == 'BAILLEUR':
            prompt = base_prompt + (
                f"L'utilisateur actuel s'appelle {user_name} (Rôle: Bailleur / Propriétaire).\n"
            )
            if properties_context:
                prompt += "\nMES LOGEMENTS ET PUBLICATIONS DANS LA BASE DE DONNÉES :\n"
                for p in properties_context:
                    prompt += (
                        f"- ID: {p.id} | Titre: {p.title} | Statut: {p.get_status_display()} | "
                        f"Prix: {p.rent_price} FCFA | Vues: {p.views_count}\n"
                    )
        else:
            prompt = base_prompt + (
                f"L'utilisateur actuel s'appelle {user_name} (Rôle: Administrateur GestBailleur).\n"
            )

        return prompt

    @classmethod
    def generate_response(cls, user, conversation, user_message_text, history_messages=None):
        """
        Génère une réponse IA réelle en temps réel via Gemini API ou le moteur intelligent GestBailleur.
        """
        api_key = cls.get_api_key()
        role = cls.get_user_primary_role(user)
        search_criteria = cls.extract_search_criteria(user_message_text)
        real_properties = cls.fetch_real_properties(search_criteria, query_text=user_message_text, user=user, role=role)
        system_prompt = cls.build_system_prompt(user, role, real_properties)

        # === APPEL GEMINI EN PREMIER ===
        if api_key:
            try:
                candidate_models = [
                    os.getenv('AI_MODEL_NAME'),
                    'gemini-3.6-flash',
                    'gemini-3.8-flash',
                    'gemini-3.7-flash',
                    'gemini-3.5-flash',
                    'gemini-flash-latest',
                ]
                models_to_try = []
                for m in candidate_models:
                    if m and m not in models_to_try:
                        models_to_try.append(m)

                contents = []
                if history_messages:
                    for msg in history_messages[-6:]:
                        if hasattr(msg, 'content') and msg.content and msg.content != user_message_text:
                            g_role = "user" if msg.role == "user" else "model"
                            contents.append({
                                "role": g_role,
                                "parts": [{"text": msg.content}]
                            })

                contents.append({
                    "role": "user",
                    "parts": [{"text": user_message_text}]
                })

                payload = {
                    "systemInstruction": {
                        "parts": [{"text": system_prompt}]
                    },
                    "contents": contents,
                    "generationConfig": {
                        "temperature": 0.6,
                        "maxOutputTokens": 2048,
                        "candidateCount": 1,
                    }
                }

                headers = {
                    "Content-Type": "application/json",
                    "x-goog-api-key": api_key,
                }

                for model_name in models_to_try:
                    gemini_url = (
                        f"https://generativelanguage.googleapis.com/v1beta/models/{model_name}:generateContent?key={api_key}"
                    )
                    logger.info(
                        "[GestBailleur AI] Appel Gemini -> modele: %s | msg: %s",
                        model_name, user_message_text[:50]
                    )

                    resp = requests.post(gemini_url, headers=headers, json=payload, timeout=25)
                    if resp.status_code == 200:
                        data = resp.json()
                        candidates = data.get("candidates", [])
                        if candidates:
                            parts = candidates[0].get("content", {}).get("parts", [])
                            text_pieces = [p.get("text", "") for p in parts if isinstance(p, dict) and p.get("text")]
                            full_text = "".join(text_pieces).strip()
                            if full_text:
                                return full_text, {
                                    'search_criteria': search_criteria,
                                    'properties_found': [str(p.id) for p in real_properties],
                                    'model': model_name,
                                }
                    logger.error("[GestBailleur AI] Gemini HTTP %s (%s): %s", resp.status_code, model_name, resp.text[:250])
                    # If error is authentication (401/403), no need to retry other models
                    if resp.status_code in [401, 403]:
                        break
            except Exception as e:
                logger.error("[GestBailleur AI] Exception appel IA: %s: %s", type(e).__name__, str(e))

        # =============================================
        # MOTEUR INTELLIGENT GESTBAILLEUR (Réponses temps réel réelles)
        # =============================================
        logger.info("[GestBailleur AI] Moteur temps réel: '%s'", user_message_text[:60])
        q_lower = user_message_text.lower().strip()

        if any(w in q_lower for w in ['bonjour', 'salut', 'hello', 'coucou', 'bonsoir', 'hey']):
            return (
                "Bonjour ! Je suis l'Assistant IA GestBailleur. 🏠\n\n"
                "Comment puis-je vous aider aujourd'hui ? Vous pouvez me demander un type de logement (studio, appartement, duplex, villa), une ville ou votre budget !"
            ), {'intent': 'greeting'}

        if any(w in q_lower for w in ['qui es-tu', 'qui est tu', 'presente-toi']):
            return (
                "Je suis l'Assistant Virtuel IA de GestBailleur.\n\n"
                "Je recherche en temps réel dans notre base de données les meilleurs logements disponibles selon vos préférences. Que recherchez-vous ?"
            ), {'intent': 'presentation'}

        # Si des logements sont trouvés dans la base de données réel
        if real_properties:
            props_formatted = []
            for p in real_properties[:4]:
                city_str = f" à {p.address.city.nom}" if (p.address and p.address.city) else ""
                props_formatted.append(
                    f"📍 **{p.title}** ({p.get_property_type_display()}){city_str}\n"
                    f"   💰 **{p.rent_price:,.0f} FCFA / mois** • 🛏️ {p.bedrooms} chambre(s) • 📐 {p.surface_area} m²"
                )

            intro_msg = "Voici les meilleures offres réelles correspondant à votre demande sur GestBailleur :\n\n"
            if 'duplex' in q_lower:
                intro_msg = "Voici les duplex et offres disponibles actuellement sur GestBailleur :\n\n"
            elif 'studio' in q_lower:
                intro_msg = "Voici les studios disponibles actuellement sur GestBailleur :\n\n"
            elif 'appartement' in q_lower:
                intro_msg = "Voici les appartements disponibles actuellement sur GestBailleur :\n\n"

            return (
                intro_msg + "\n\n".join(props_formatted) + "\n\n"
                "💡 *Cliquez sur une annonce dans la recherche pour voir toutes les photos et contacter le bailleur !*"
            ), {
                'search_criteria': search_criteria,
                'properties_found': [str(p.id) for p in real_properties]
            }

        return (
            "Je recherche les meilleures opportunités pour vous. "
            "Précisez-moi la ville (ex: Yaoundé, Douala), le nombre de chambres ou votre budget maximum en FCFA !"
        ), {'intent': 'general'}
