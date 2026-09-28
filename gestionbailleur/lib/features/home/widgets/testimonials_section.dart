import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../constants/app_strings.dart';
import '../models/testimonial_model.dart';
import 'section_title.dart';

/// Section Témoignages avec cartes élégantes et état vide réel
class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<TestimonialModel> testimonials = const []; // Aucun faux témoignage

    if (testimonials.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.spacingXXLarge,
          horizontal: AppConstants.spacingLarge,
        ),
        child: Column(
          children: [
            SectionTitle(
              title: AppStrings.testimonials,
              subtitle: 'Ce que disent nos utilisateurs réels',
            ),
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingXLarge),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: AppConstants.spacingMedium),
                  Text(
                    'Aucun témoignage disponible pour le moment.',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.spacingSmall),
                  Text(
                    'Les avis et témoignages certifiés de nos clients réels s\'afficheront ici.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppConstants.spacingXXLarge,
        horizontal: AppConstants.spacingLarge,
      ),
      child: Column(
        children: [
          SectionTitle(
            title: AppStrings.testimonials,
            subtitle: 'Ce que disent nos utilisateurs réels',
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > AppConstants.breakpointTablet) {
                return _buildDesktopLayout(context, testimonials);
              } else {
                return _buildMobileLayout(context, testimonials);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, List<TestimonialModel> testimonials) {
    return Row(
      children: testimonials.map((testimonial) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMedium),
            child: _buildTestimonialCard(context, testimonial),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMobileLayout(BuildContext context, List<TestimonialModel> testimonials) {
    return Column(
      children: testimonials.map((testimonial) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.spacingLarge),
          child: _buildTestimonialCard(context, testimonial),
        );
      }).toList(),
    );
  }

  Widget _buildTestimonialCard(BuildContext context, TestimonialModel testimonial) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < testimonial.rating.floor()
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.amber,
                  size: 20,
                );
              }),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            Text(
              '"${testimonial.content}"',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(testimonial.imageUrl),
                  child: testimonial.imageUrl.isEmpty
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: AppConstants.spacingMedium),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      testimonial.authorName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      testimonial.authorRole,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
