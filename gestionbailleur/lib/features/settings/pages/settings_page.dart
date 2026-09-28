import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/design_system/spacing/ds_spacing.dart';
import '../../../core/providers/theme_provider.dart';

/// Page de paramètres avec toggle dark/light mode
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Paramètres',
      showBackButton: true,
      body: ListView(
        padding: const EdgeInsets.all(DSSpacing.lg),
        children: [
          // Mode sombre
          Card(
            child: SwitchListTile(
              title: const Text('Mode sombre'),
              subtitle: const Text('Activer le thème sombre de l\'application'),
              value: themeState.isDarkMode,
              onChanged: (value) {
                ref.read(themeProvider.notifier).setDarkMode(value);
              },
              secondary: Icon(
                themeState.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: theme.colorScheme.primary,
              ),
            ),
          ),

          const SizedBox(height: DSSpacing.md),

          // Thème système
          Card(
            child: ListTile(
              title: const Text('Thème système'),
              subtitle: const Text('Utiliser le thème du système'),
              leading: const Icon(Icons.phone_android),
              trailing: Icon(
                themeState.themeMode == ThemeMode.system
                    ? Icons.check_circle
                    : Icons.circle_outlined,
                color: themeState.themeMode == ThemeMode.system
                    ? Colors.green
                    : Colors.grey,
              ),
              onTap: () {
                ref.read(themeProvider.notifier).resetToSystem();
              },
            ),
          ),

          const SizedBox(height: DSSpacing.lg),

          // Section informations
          Card(
            child: Padding(
              padding: const EdgeInsets.all(DSSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informations',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: DSSpacing.sm),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('Version de l\'application'),
                    subtitle: const Text('1.0.0'),
                    dense: true,
                  ),
                  ListTile(
                    leading: const Icon(Icons.policy_outlined),
                    title: const Text('Politique de confidentialité'),
                    dense: true,
                    onTap: () => context.push('/terms'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: const Text('Contrat de Licence & CGU'),
                    dense: true,
                    onTap: () => context.push('/terms'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
