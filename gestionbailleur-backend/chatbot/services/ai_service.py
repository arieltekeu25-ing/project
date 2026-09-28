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
                os.getenv('OPENAI_API_KEY') or
                os.getenv('GROQ_API_KEY') or
                os.getenv('MISTRAL_API_KEY')
            )
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
        elif 'appartement' in query_lower or 'appart' in query_lower:
            criteria['property_type'] = 'APARTMENT'
        elif 'maison' in query_lower:
            criteria['property_type'] = 'HOUSE'
        elif 'villa' in query_lower:
            criteria['property_type'] = 'VILLA'
        elif 'loft' in query_lower:
            criteria['property_type'] = 'LOFT'

        # Villes populaires du Cameroun et région
        cities = ['yaoundé', 'yaounde', 'douala', 'bafoussam', 'garoua', 'maroua', 'buea', 'limbe', 'kribi', 'bamenda']
        for city in cities:
            if city in query_lower:
                # Capitalize nicely
                criteria['city'] = city.replace('yaounde', 'yaoundé').capitalize()
                break

        # Extraction simple des budgets (ex: 150000, 150 000, 100k, 150k, 100000 fcfa)
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
                    if val >= 5000:  # filtre prix raisonnable loyer
                        criteria['max_price'] = val
                except ValueError:
                    pass

        # Meublé
        if 'meublé' in query_lower or 'meuble' in query_lower:
            criteria['furnished'] = True

        # Chambres
        for n in range(1, 10):
            if f"{n} chambre" in query_lower or f"{n} chambres" in query_lower:
                criteria['bedrooms'] = n
                break

        return criteria

    @classmethod
    def fetch_real_properties(cls, criteria, user=None, role='CLIENT'):
        """
        Récupère les logements réels correspondant aux critères depuis PostgreSQL.
        """
        queryset = Property.objects.filter(is_deleted=False)

        if role == 'CLIENT':
            # Les clients ne voient que les logements publiés
            queryset = queryset.filter(status='PUBLISHED')
        elif role == 'BAILLEUR' and user:
            # Pour un bailleur, on peut cibler ses propres logements ou l'ensemble
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

        return list(queryset.select_related('address', 'address__city', 'address__district', 'landlord')[:5])

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
            "CONSIGNE DE RÉPONSE : Sois clair, concis et toujours complet. Structure tes conseils en 3 à 5 points simples et ne laisse jamais une phrase inachevée.\n"
            "Toutes tes réponses doivent être basées EXCLUSIVEMENT sur les données réelles et vérifiées ci-dessous.\n"
            "Ne jamais inventer des logements fictifs, des prix imaginaires ou des quartiers non existants.\n\n"
        )

        if role == 'CLIENT':
            prompt = base_prompt + (
                f"L'utilisateur actuel s'appelle {user_name} (Rôle: Client / Chercheur de logement).\n"
                "Ta mission est de l'aider à trouver le logement idéal selon son budget et ses préférences, "
                "de comparer les caractéristiques des offres réelles et de répondre à ses questions sur la location.\n"
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
                        f"Meublé: {'Oui' if p.furnished else 'Non'} | Localisation: {location} | "
                        f"Description: {p.description[:150]}...\n"
                    )
            else:
                prompt += (
                    "\nAUCUN LOGEMENT RÉEL NE CORRESPOND EXACTEMENT AUX CRITÈRES RECHERCHÉS DANS LA BASE DE DONNÉES.\n"
                    "Informe poliment l'utilisateur qu'aucun logement ne correspond exactement à sa requête, "
                    "puis suggère-lui d'élargir ses critères (ex: augmenter le budget, choisir une autre ville ou un autre type de bien).\n"
                )

        elif role == 'BAILLEUR':
            prompt = base_prompt + (
                f"L'utilisateur actuel s'appelle {user_name} (Rôle: Bailleur / Propriétaire).\n"
                "Ta mission est de l'aider à maximiser la visibilité de ses annonces, à rédiger des titres et descriptions attrayants, "
                "à analyser ses statistiques de publication et à lui conseiller les meilleures pratiques de gestion immobilière.\n"
            )
            if properties_context:
                prompt += "\nMES LOGEMENTS ET PUBLICATIONS DANS LA BASE DE DONNÉES :\n"
                for p in properties_context:
                    prompt += (
                        f"- ID: {p.id} | Titre: {p.title} | Statut: {p.get_status_display()} | "
                        f"Prix: {p.rent_price} FCFA | Vues: {p.views_count} | Demandes de visites/infos: {p.inquiries_count}\n"
                    )
        else:
            prompt = base_prompt + (
                f"L'utilisateur actuel s'appelle {user_name} (Rôle: Administrateur GestBailleur).\n"
                "Ta mission est de fournir une assistance administrative générale sur l'utilisation et la supervision de GestBailleur.\n"
            )

        return prompt

    @classmethod
    def generate_response(cls, user, conversation, user_message_text, history_messages=None):
        """
        Genere une reponse IA via Gemini API.
        Gemini est TOUJOURS appele en premier pour TOUS les messages.
        Le fallback local est utilise UNIQUEMENT si l appel API echoue.
        """
        api_key = cls.get_api_key()
        role = cls.get_user_primary_role(user)
        search_criteria = cls.extract_search_criteria(user_message_text)
        real_properties = cls.fetch_real_properties(search_criteria, user=user, role=role)
        system_prompt = cls.build_system_prompt(user, role, real_properties)

        # === APPEL GEMINI EN PREMIER (pour TOUS les messages) ===
        if api_key:
            try:
                is_gemini_key = (
                    api_key.startswith('AIza') or
                    api_key.startswith('AQ') or
                    bool(os.getenv('GEMINI_API_KEY'))
                )
                is_gemini_model = 'gemini' in os.getenv('AI_MODEL_NAME', 'gemini').lower()

                if is_gemini_key or is_gemini_model:
                    model_name = os.getenv('AI_MODEL_NAME', 'gemini-3.6-flash')
                    deprecated_models = [
                        'gemini', 'gemini-flash',
                        'gemini-1.5-flash', 'gemini-1.5-pro',
                        'gemini-2.0-flash', 'gemini-2.5-flash',
                    ]
                    if model_name in deprecated_models:
                        model_name = 'gemini-3.6-flash'

                    gemini_url = (
                        "https://generativelanguage.googleapis.com/v1beta/models/"
                        + model_name
                        + ":generateContent?key="
                        + api_key
                    )
                    logger.info(
                        "[GestBailleur AI] Appel Gemini -> modele: %s | cle: %s... | msg: %s",
                        model_name, api_key[:8], user_message_text[:50]
                    )

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

                    resp = requests.post(gemini_url, json=payload, timeout=30)
                    logger.info("[GestBailleur AI] Reponse Gemini -> HTTP %s", resp.status_code)

                    if resp.status_code == 200:
                        data = resp.json()
                        candidates = data.get("candidates", [])
                        if candidates:
                            parts = candidates[0].get("content", {}).get("parts", [])
                            # Concaténer TOUTES les parties de texte pour que la réponse ne soit JAMAIS tronquée
                            text_pieces = [p.get("text", "") for p in parts if isinstance(p, dict) and p.get("text")]
                            full_text = "".join(text_pieces).strip()
                            if full_text:
                                logger.info(
                                    "[GestBailleur AI] Gemini a répondu (complet): %d chars", len(full_text)
                                )
                                return full_text, {
                                    'search_criteria': search_criteria,
                                    'properties_found': [str(p.id) for p in real_properties],
                                    'model': model_name,
                                }
                            logger.warning("[GestBailleur AI] Gemini: aucun texte dans les parts")
                        else:
                            block = data.get("promptFeedback", {}).get("blockReason", "inconnu")
                            logger.warning("[GestBailleur AI] Gemini: 0 candidats. blockReason=%s", block)
                    else:
                        err = resp.json().get("error", {}).get("message", resp.text[:300])
                        logger.error("[GestBailleur AI] Gemini HTTP %s: %s", resp.status_code, err)

                elif api_key.startswith('sk-') or os.getenv('GROQ_API_KEY'):
                    openai_url = (
                        "https://api.groq.com/openai/v1/chat/completions"
                        if os.getenv('GROQ_API_KEY')
                        else "https://api.openai.com/v1/chat/completions"
                    )
                    headers = {
                        "Authorization": "Bearer " + api_key,
                        "Content-Type": "application/json"
                    }
                    messages_payload = [{"role": "system", "content": system_prompt}]
                    if history_messages:
                        for msg in history_messages[-6:]:
                            o_role = "user" if msg.role == "user" else "assistant"
                            messages_payload.append({"role": o_role, "content": msg.content})
                    messages_payload.append({"role": "user", "content": user_message_text})
                    payload = {
                        "model": getattr(settings, 'AI_MODEL_NAME', 'gpt-3.5-turbo'),
                        "messages": messages_payload,
                        "temperature": 0.7,
                        "max_tokens": 1024,
                    }
                    resp = requests.post(openai_url, headers=headers, json=payload, timeout=20)
                    if resp.status_code == 200:
                        choices = resp.json().get("choices", [])
                        if choices and "message" in choices[0]:
                            reply = choices[0]["message"]["content"].strip()
                            return reply, {
                                'search_criteria': search_criteria,
                                'properties_found': [str(p.id) for p in real_properties],
                            }
                    logger.error("[GestBailleur AI] OpenAI/Groq HTTP %s", resp.status_code)

            except Exception as e:
                logger.error("[GestBailleur AI] Exception appel IA: %s: %s", type(e).__name__, str(e))
        else:
            logger.warning("[GestBailleur AI] Aucune cle API - fallback local")

        # =============================================
        # FALLBACK LOCAL - Uniquement si Gemini a echoue
        # =============================================
        logger.info("[GestBailleur AI] Fallback local: '%s'", user_message_text[:60])
        q_lower = user_message_text.lower().strip()

        if any(w in q_lower for w in ['bonjour', 'salut', 'hello', 'coucou', 'bonsoir', 'hey']):
            return (
                "Bonjour ! Je suis l'Assistant GestBailleur.\n\n"
                "Dites-moi votre ville, votre budget ou le type de logement recherche !"
            ), {'intent': 'greeting'}

        if any(w in q_lower for w in ['qui es-tu', 'qui est tu', 'presente-toi']):
            return (
                "Je suis l'Assistant Virtuel de GestBailleur !\n\n"
                "Je vous aide a trouver le logement ideal. Posez-moi une question !"
            ), {'intent': 'presentation'}

        has_search_intent = (
            bool(search_criteria) or
            any(w in q_lower for w in [
                'logement', 'appartement', 'studio', 'villa', 'maison',
                'chambre', 'louer', 'location', 'cherche', 'budget', 'prix', 'loyer', 'fcfa'
            ])
        )

        if has_search_intent and real_properties and role == 'CLIENT':
            props_summary = "\n".join([
                "* **" + p.title + "** (" + p.get_property_type_display() + ") - " 
                + "{:,.0f}".format(p.rent_price) + " FCFA/mois"
                for p in real_properties[:4]
            ])
            return (
                "Voici les logements disponibles sur GestBailleur :\n\n" + props_summary + "\n\n"
                "Consultez les details complets dans l'application."
            ), {'search_criteria': search_criteria, 'properties_found': [str(p.id) for p in real_properties]}

        if has_search_intent and role == 'CLIENT':
            return (
                "Aucun logement ne correspond a vos criteres actuellement. "
                "Essayez d'elargir votre budget ou de choisir une autre ville."
            ), {'search_criteria': search_criteria, 'properties_found': []}

        return (
            "Je suis a votre ecoute ! Indiquez-moi votre ville, votre budget ou le type de logement, "
            "et je vous trouverai les meilleures offres sur GestBailleur."
        ), {'intent': 'general'}
