import 'package:flutter/material.dart';

/// Taille d'avatar du Design System
enum DSAvatarSize {
  xxs,
  xs,
  sm,
  md,
  lg,
  xl,
  xxl,
}

/// Avatar du Design System
class DSAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final DSAvatarSize size;
  final VoidCallback? onTap;

  const DSAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = DSAvatarSize.md,
    this.onTap,
  });

  double _getSize() {
    switch (size) {
      case DSAvatarSize.xxs:
        return 24;
      case DSAvatarSize.xs:
        return 32;
      case DSAvatarSize.sm:
        return 40;
      case DSAvatarSize.md:
        return 48;
      case DSAvatarSize.lg:
        return 64;
      case DSAvatarSize.xl:
        return 80;
      case DSAvatarSize.xxl:
        return 96;
    }
  }

  String _getInitials() {
    if (name == null || name!.isEmpty) return '?';
    final parts = name!.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name![0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarSize = _getSize();

    Widget avatar;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatar = CircleAvatar(
        radius: avatarSize / 2,
        backgroundImage: NetworkImage(imageUrl!),
        onBackgroundImageError: (exception, stackTrace) {
          // Fallback si l'image ne charge pas
        },
        child: null,
      );
    } else {
      avatar = CircleAvatar(
        radius: avatarSize / 2,
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
        child: Text(
          _getInitials(),
          style: TextStyle(
            fontSize: avatarSize * 0.4,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }
}
