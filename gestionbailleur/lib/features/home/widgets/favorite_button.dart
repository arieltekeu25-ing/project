import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Bouton favori avec animation et feedback visuel
class FavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback? onToggle;
  final bool isLoading;

  const FavoriteButton({
    super.key,
    required this.isFavorite,
    this.onToggle,
    this.isLoading = false,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppConstants.animationDurationShort,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Animation quand l'état favori change
    if (oldWidget.isFavorite != widget.isFavorite) {
      _controller.forward().then((_) {
        _controller.reverse();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    if (widget.isLoading) return;
    widget.onToggle?.call();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: RotationTransition(
        turns: _rotationAnimation,
        child: IconButton(
          icon: widget.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: widget.isFavorite ? Colors.pink : Colors.grey,
                ),
          onPressed: _toggleFavorite,
          splashRadius: 24,
          tooltip: widget.isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
        ),
      ),
    );
  }
}
