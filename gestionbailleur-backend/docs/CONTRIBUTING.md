# Guide de Contribution

## Comment Contribuer

Nous apprécions votre contribution au projet GestionBailleur Backend !

## Processus de Contribution

### 1. Fork le Repository

Fork le repository sur GitHub et clonez votre fork localement.

### 2. Créer une Branche

Créez une branche pour votre fonctionnalité ou correction :

```bash
git checkout -b feature/nom-de-la-fonctionnalite
# ou
git checkout -b fix/nom-de-la-correction
```

### 3. Installer les Dépendances

```bash
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements/development.txt
```

### 4. Configurer l'Environnement

```bash
cp .env.example .env
# Éditer .env avec vos configurations
```

### 5. Exécuter les Migrations

```bash
python manage.py migrate
```

### 6. Lancer les Tests

Avant de soumettre, assurez-vous que tous les tests passent :

```bash
python manage.py test
```

### 7. Code Style

Le projet utilise :
- **Black** pour le formatage
- **Flake8** pour le linting
- **isort** pour l'ordre des imports

```bash
black .
flake8
isort .
```

### 8. Commit vos Changements

Suivez les conventions de commit :

```
feat: ajouter la fonctionnalité X
fix: corriger le bug Y
docs: mettre à jour la documentation
refactor: refactoriser le code Z
test: ajouter des tests
```

### 9. Push et Pull Request

Push vos changements et créez une Pull Request sur GitHub.

## Normes de Code

### Python

- Suivre PEP 8
- Utiliser des noms descriptifs
- Ajouter des docstrings aux fonctions et classes
- Limiter la complexité cyclomatique

### Django

- Utiliser les conventions Django
- Séparer la logique métier dans les services
- Utiliser les repositories pour l'accès aux données
- Valider les données dans les validators

### REST Framework

- Utiliser les serializers pour la validation
- Implémenter les permissions appropriées
- Documenter les endpoints avec drf-spectacular

## Structure de Branche

- `main` - Branche principale stable
- `develop` - Branche de développement
- `feature/*` - Nouvelles fonctionnalités
- `fix/*` - Corrections de bugs
- `hotfix/*` - Corrections urgentes en production

## Tests

### Écrire des Tests

- Chaque nouvelle fonctionnalité doit avoir des tests
- Couvrir les cas positifs et négatifs
- Tester les permissions et validations
- Viser une couverture de 80%+

### Types de Tests

- **Unit tests** - Tests isolés de fonctions/classes
- **Integration tests** - Tests d'intégration entre modules
- **API tests** - Tests des endpoints API

## Documentation

- Mettre à jour la documentation pour les changements
- Ajouter des docstrings au code
- Mettre à jour l'API guide pour les nouveaux endpoints

## Code Review

Les Pull Requests seront reviewées par l'équipe. Assurez-vous de :

- Répondre aux commentaires
- Faire les corrections demandées
- Mettre à jour les tests si nécessaire
- Garder la PR à jour avec la branche cible

## Questions

Pour toute question, contactez l'équipe de développement ou ouvrez une issue sur GitHub.

## Licence

En contribuant, vous acceptez que votre contribution soit sous la même licence que le projet.
