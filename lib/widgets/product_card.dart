import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../utils/constants.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;
  final VoidCallback onWishlistToggle;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
    required this.onWishlistToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Hero(
                      tag: product.id,
                      child: product.image.startsWith('http')
                          ? Image.network(
                              product.image,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image,
                                      size: 50, color: Colors.grey),
                            )
                          : Image.asset(
                              product.image,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.image_not_supported,
                                      size: 50, color: Colors.grey),
                            ),
                    ),
                  ),
                ),

                // Product Info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    product.price,
                    style: const TextStyle(
                      color: AppConstants.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Add to Cart Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ElevatedButton(
                    onPressed: onAddToCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.secondaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Add to Cart",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),

            // Wishlist Heart Icon
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: onWishlistToggle,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    product.isWishlisted
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: product.isWishlisted ? Colors.red : Colors.grey,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
