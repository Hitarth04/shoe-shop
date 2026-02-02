import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String image;
  final String price;
  final String description;
  bool isWishlisted;

  Product({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.description,
    this.isWishlisted = false,
  });

  // Factory constructor to create a Product from Firestore data
  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      // If the image path is broken, fallback to a placeholder or the first image
      image: data['image'] ?? 'assets/images/shoes.png',
      price: data['price'] ?? '₹0',
      description: data['description'] ?? '',
      isWishlisted:
          false, // Default to false, we'll handle this with WishlistService later
    );
  }
}
