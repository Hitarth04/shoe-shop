import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String price;
  final String image;
  final String description;
  final String category;
  final List<String> sizes;
  final double rating;

  // --- NEW: Mutable field for UI state ---
  bool isWishlisted;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.description,
    required this.category,
    required this.sizes,
    this.rating = 0.0,
    this.isWishlisted = false, // Default to false
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Product(
      id: doc.id,
      name: data['name'] ?? 'Unknown',
      // Safe String conversion
      price: (data['price'] ?? '0').toString(),
      image: data['image'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'All',
      // Safe List parsing
      sizes: (data['sizes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      // Safe Rating parsing
      rating: (data['rating'] is int)
          ? (data['rating'] as int).toDouble()
          : (data['rating'] ?? 0.0),
      // Default to false when loading from DB (Wishlist status is usually loaded separately)
      isWishlisted: false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'image': image,
      'description': description,
      'category': category,
      'sizes': sizes,
      'rating': rating,
      // Note: We typically DO NOT save isWishlisted to the global products collection
    };
  }
}
