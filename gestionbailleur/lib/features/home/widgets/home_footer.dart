import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';
import '../constants/app_strings.dart';

/// Footer responsive avec présentation, navigation et contacts
class HomeFooter extends StatelessWidget {
  const HomeFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppConstants.spacingXXLarge,
        horizontal: AppConstants.spacingLarge,
      ),
      decoration: BoxDecoration(
        color: Colors.yellow[100],
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > AppConstants.breakpointTablet) {
            return _buildDesktopLayout(context);
          } else {
            return _buildMobileLayout(context);
          }
        },
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Présentation
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                          child: Image.asset(
                            'assetes/images/logo.png',
                            width: 24,
                            height: 24,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.home, color: Colors.white);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingSmall),
                      Text(
                        AppStrings.appName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingMedium),
                  Text(
                    AppStrings.aboutUsDescription,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppConstants.spacingXXLarge),
            // Navigation
            Expanded(
              child: _buildFooterColumn(
                context,
                'Navigation',
                [
                  AppStrings.home,
                  AppStrings.search,
                  AppStrings.favorites,
                  AppStrings.messages,
                ],
              ),
            ),
            const SizedBox(width: AppConstants.spacingXXLarge),
            // Contact
            Expanded(
              child: _buildFooterColumn(
                context,
                AppStrings.contact,
                [
                  'cabrelwilliam32@gmail.com',
                  '+237 652 71 57 05 / 690 32 05 13',
                  'Yaoundé, Bafoussam',
                ],
              ),
            ),
            const SizedBox(width: AppConstants.spacingXXLarge),
            // Réseaux sociaux
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.followUs,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingMedium),
                  Row(
                    children: [
                      _buildSocialIcon(context, Icons.facebook, Colors.blue, 'https://facebook.com'),
                      const SizedBox(width: AppConstants.spacingMedium),
                      _buildSocialIcon(context, Icons.music_note, Colors.black, 'https://tiktok.com'),
                      const SizedBox(width: AppConstants.spacingMedium),
                      _buildSocialIcon(context, Icons.chat, Colors.green, 'https://wa.me'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingXXLarge),
        // Copyright
        const Divider(),
        const SizedBox(height: AppConstants.spacingMedium),
        Text(
          '© 2026 ${AppStrings.appName}. ${AppStrings.rightsReserved}.',
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        // Logo et présentation
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                child: Image.asset(
                  'assetes/images/logo.png',
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.home, color: Colors.white);
                  },
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spacingSmall),
            Text(
              AppStrings.appName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingMedium),
        Text(
          AppStrings.aboutUsDescription,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.spacingLarge),
        // Navigation
        _buildFooterColumn(
          context,
          'Navigation',
          [
            AppStrings.home,
            AppStrings.search,
            AppStrings.favorites,
            AppStrings.messages,
          ],
        ),
        const SizedBox(height: AppConstants.spacingLarge),
        // Contact
        _buildFooterColumn(
          context,
          AppStrings.contact,
          [
            'cabrelwilliam32@gmail.com',
            '+237 652 71 57 05 / 690 32 05 13',
            'Yaoundé, Bafoussam',
          ],
        ),
        const SizedBox(height: AppConstants.spacingLarge),
        // Réseaux sociaux
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.followUs,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.black,
              ),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            Row(
              children: [
                _buildSocialIcon(context, Icons.facebook, Colors.blue, 'https://facebook.com'),
                const SizedBox(width: AppConstants.spacingMedium),
                _buildSocialIcon(context, Icons.music_note, Colors.black, 'https://tiktok.com'),
                const SizedBox(width: AppConstants.spacingMedium),
                _buildSocialIcon(context, Icons.chat, Colors.green, 'https://wa.me'),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingXXLarge),
        // Copyright
        const Divider(),
        const SizedBox(height: AppConstants.spacingMedium),
        Text(
          '© 2026 ${AppStrings.appName}. ${AppStrings.rightsReserved}.',
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFooterColumn(BuildContext context, String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.black,
          ),
        ),
        const SizedBox(height: AppConstants.spacingMedium),
        ...items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.spacingSmall),
            child: Text(
              item,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSocialIcon(BuildContext context, IconData icon, Color iconColor, String url) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      child: Container(
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(AppConstants.spacingSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
      ),
    );
  }
}
