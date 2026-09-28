import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../constants/app_strings.dart';
import '../data/mock_steps.dart';
import '../models/step_model.dart';
import 'section_title.dart';

/// Section Comment ça marche avec 4 étapes
class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = MockSteps.getAll()..sort((a, b) => a.order.compareTo(b.order));

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppConstants.spacingXXLarge,
        horizontal: AppConstants.spacingLarge,
      ),
      child: Column(
        children: [
          SectionTitle(
            title: AppStrings.howItWorks,
            subtitle: 'Trouvez votre logement en 4 étapes simples',
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > AppConstants.breakpointTablet) {
                return _buildDesktopLayout(context, steps);
              } else {
                return _buildMobileLayout(context, steps);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, List<StepModel> steps) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        return Expanded(
          child: _buildStepCard(context, step, index, steps.length),
        );
      }).toList(),
    );
  }

  Widget _buildMobileLayout(BuildContext context, List<StepModel> steps) {
    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.spacingLarge),
          child: _buildStepCard(context, step, index, steps.length),
        );
      }).toList(),
    );
  }

  Widget _buildStepCard(BuildContext context, StepModel step, int index, int totalSteps) {
    final isLast = index == totalSteps - 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Numéro de l'étape
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${step.order}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppConstants.spacingMedium),
        // Contenu
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: _buildIconForStep(step.icon, Theme.of(context)),
              ),
              const SizedBox(height: AppConstants.spacingSmall),
              Text(
                step.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppConstants.spacingXSmall),
              Text(
                step.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        // Ligne de connexion (desktop uniquement)
        if (!isLast) ...[
          const SizedBox(width: AppConstants.spacingMedium),
          Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildIconForStep(String icon, ThemeData theme) {
    switch (icon) {
      case 'search':
        return Icon(Icons.search, color: theme.colorScheme.primary);
      case 'favorite':
        return const Icon(Icons.favorite, color: Colors.pink);
      case 'chat':
        return Icon(Icons.chat, color: theme.colorScheme.primary);
      case 'home':
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assetes/images/logo.png',
            width: 24,
            height: 24,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.home);
            },
          ),
        );
      default:
        return const Icon(Icons.check_circle);
    }
  }
}
