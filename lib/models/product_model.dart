import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String image;
  final String price;
  final String description;
  final String category; // <--- NEW FIELD
  bool isWishlisted;

  Product({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.description,
    required this.category, // <--- Add to constructor
    this.isWishlisted = false,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      image: data['image'] ?? 'assets/images/shoes.png',
      price: data['price'] ?? '₹0',
      description: data['description'] ?? '',
      // Default to 'Other' if category is missing in Firestore
      category: data['category'] ?? 'Other',
      isWishlisted: false,
    );
  }
}
