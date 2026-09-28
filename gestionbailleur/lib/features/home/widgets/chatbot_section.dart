import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../constants/app_strings.dart';

/// Section Chatbot avec carte moderne
class ChatbotSection extends StatelessWidget {
  const ChatbotSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppConstants.spacingXXLarge,
        horizontal: AppConstants.spacingLarge,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppConstants.spacingXLarge),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusXLarge),
          boxShadow: AppConstants.shadowLarge,
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
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingMedium),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.smart_toy,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppConstants.spacingMedium),
              Text(
                AppStrings.chatbotTitle,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppConstants.spacingSmall),
              SizedBox(
                width: 500,
                child: Text(
                  AppStrings.chatbotSubtitle,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppConstants.spacingXXLarge),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: () {
              context.push('/chatbot');
            },
            icon: const Icon(Icons.chat_bubble, color: Colors.blue, size: 20),
            label: const Text(
              AppStrings.askQuestion,
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppConstants.spacingMedium),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.smart_toy,
            size: 48,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: AppConstants.spacingMedium),
        Text(
          AppStrings.chatbotTitle,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.spacingSmall),
        Text(
          AppStrings.chatbotSubtitle,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.spacingLarge),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                context.push('/chatbot');
              },
              icon: const Icon(Icons.chat_bubble, color: Colors.blue, size: 20),
              label: const Text(
                AppStrings.askQuestion,
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                ),
                elevation: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
