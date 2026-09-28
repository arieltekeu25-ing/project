import 'package:flutter/material.dart';

/// Extensions sur Widget
extension WidgetExtensions on Widget {
  /// Ajouter du padding
  Widget paddingAll(double padding) {
    return Padding(padding: EdgeInsets.all(padding), child: this);
  }

  /// Ajouter du padding symétrique
  Widget paddingSymmetric({double horizontal = 0, double vertical = 0}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: this,
    );
  }

  /// Ajouter du padding seulement
  Widget paddingOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return Padding(
      padding: EdgeInsets.only(left: left, top: top, right: right, bottom: bottom),
      child: this,
    );
  }

  /// Ajouter une marge
  Widget marginAll(double margin) {
    return Container(margin: EdgeInsets.all(margin), child: this);
  }

  /// Ajouter une marge symétrique
  Widget marginSymmetric({double horizontal = 0, double vertical = 0}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: this,
    );
  }

  /// Ajouter une décoration
  Widget decorate({
    Color? color,
    BoxDecoration? decoration,
    double? width,
    double? height,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: decoration ?? BoxDecoration(color: color),
      child: this,
    );
  }

  /// Ajouter un geste
  Widget onTap(VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: this);
  }

  /// Ajouter un geste long
  Widget onLongPress(VoidCallback onLongPress) {
    return GestureDetector(onLongPress: onLongPress, child: this);
  }

  /// Rendre le widget cliquable avec effet ripple
  Widget clickable(VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: this,
    );
  }

  /// Ajouter une ombre
  Widget withShadow({
    Color? color,
    double blurRadius = 8,
    double spreadRadius = 0,
    Offset offset = Offset.zero,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: color ?? Colors.black.withValues(alpha: 0.1),
            blurRadius: blurRadius,
            spreadRadius: spreadRadius,
            offset: offset,
          ),
        ],
      ),
      child: this,
    );
  }

  /// Rendre le widget étendu
  Widget expand([int flex = 1]) {
    return Expanded(flex: flex, child: this);
  }

  /// Rendre le widget flexible
  Widget flexible([int flex = 1, FlexFit fit = FlexFit.loose]) {
    return Flexible(flex: flex, fit: fit, child: this);
  }

  /// Centrer le widget
  Widget center() {
    return Center(child: this);
  }

  /// Aligner le widget
  Widget align({AlignmentGeometry alignment = Alignment.center}) {
    return Align(alignment: alignment, child: this);
  }

  /// Rendre le widget visible ou invisible
  Widget visible(bool visible) {
    return Visibility(visible: visible, child: this);
  }

  /// Ajouter une opacité
  Widget opacity(double opacity) {
    return Opacity(opacity: opacity, child: this);
  }

  /// Ajouter une rotation
  Widget rotate(double angle) {
    return Transform.rotate(angle: angle, child: this);
  }

  /// Ajouter une échelle
  Widget scale(double scale) {
    return Transform.scale(scale: scale, child: this);
  }

  /// Ajouter une translation
  Widget translate({Offset offset = Offset.zero}) {
    return Transform.translate(offset: offset, child: this);
  }

  /// Ajouter un SafeArea
  Widget safeArea() {
    return SafeArea(child: this);
  }

  /// Ajouter une SingleChildScrollView
  Widget scrollable({Axis scrollDirection = Axis.vertical}) {
    return SingleChildScrollView(
      scrollDirection: scrollDirection,
      child: this,
    );
  }

  /// Ajouter une Card
  Widget card({EdgeInsets? margin, EdgeInsets? padding}) {
    return Card(
      margin: margin,
      child: Padding(padding: padding ?? EdgeInsets.zero, child: this),
    );
  }
}
