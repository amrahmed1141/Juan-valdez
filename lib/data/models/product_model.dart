import 'package:flutter/material.dart';

class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imagePath,
    required this.pastelColor,
    this.category = 'Juan Valdez',
    this.highlight,
    this.isFavorite = false,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final String imagePath;
  final Color pastelColor;
  final String category;
  final String? highlight;
  final bool isFavorite;

  String get formattedPrice => 'EGP ${price.toStringAsFixed(0)}';

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imagePath,
    Color? pastelColor,
    String? category,
    String? highlight,
    bool? isFavorite,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imagePath: imagePath ?? this.imagePath,
      pastelColor: pastelColor ?? this.pastelColor,
      category: category ?? this.category,
      highlight: highlight ?? this.highlight,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
