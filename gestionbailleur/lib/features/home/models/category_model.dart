import 'package:flutter/material.dart';

/// Modèle de données pour une catégorie
class CategoryModel {
  final String id;
  final String title;
  final String icon;
  final int propertyCount;
  final Color backgroundColor;
  final String? backgroundImageUrl; // URL de l'image de fond depuis Cloudinary

  CategoryModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.propertyCount,
    required this.backgroundColor,
    this.backgroundImageUrl,
  });

  CategoryModel copyWith({
    String? id,
    String? title,
    String? icon,
    int? propertyCount,
    Color? backgroundColor,
    String? backgroundImageUrl,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      propertyCount: propertyCount ?? this.propertyCount,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backgroundImageUrl: backgroundImageUrl ?? this.backgroundImageUrl,
    );
  }
}
