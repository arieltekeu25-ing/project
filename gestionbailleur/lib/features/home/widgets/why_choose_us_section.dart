import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../constants/app_strings.dart';
import '../data/mock_benefits.dart';
import '../models/benefit_model.dart';
import 'section_title.dart';

/// Section Pourquoi nous choisir avec avantages
class WhyChooseUsSection extends StatelessWidget {
  const WhyChooseUsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final benefits = MockBenefits.getAll();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppConstants.spacingXXLarge,
        horizontal: AppConstants.spacingLarge,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
      ),
      child: Column(
        children: [
          SectionTitle(
            title: AppStrings.whyChooseUs,
            subtitle: 'Les avantages de notre plateforme',
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > AppConstants.breakpointTablet) {
                return _buildDesktopLayout(context, benefits);
              } else {
                return _buildMobileLayout(context, benefits);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, List<BenefitModel> benefits) {
    return Row(
      children: benefits.map((benefit) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMedium),
            child: _buildBenefitCard(context, benefit),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMobileLayout(BuildContext context, List<BenefitModel> benefits) {
    return Column(
      children: benefits.map((benefit) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.spacingLarge),
          child: _buildBenefitCard(context, benefit),
        );
      }).toList(),
    );
  }

  Widget _buildBenefitCard(BuildContext context, BenefitModel benefit) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingMedium),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconForBenefit(benefit.icon),
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            Text(
              benefit.title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              benefit.description,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForBenefit(String icon) {
    switch (icon) {
      case 'search':
        return Icons.search;
      case 'verified':
        return Icons.verified_user;
      case 'support_agent':
        return Icons.support_agent;
      case 'chat':
        return Icons.chat;
      default:
        return Icons.star;
    }
  }
}
