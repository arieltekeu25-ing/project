import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Titre de section réutilisable
class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;

  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppConstants.spacingXSmall),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
            ?action,
          ],
        ),
        const SizedBox(height: AppConstants.spacingLarge),
      ],
    );
  }
}
