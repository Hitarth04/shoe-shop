import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';
import '../services/wishlist_service.dart';
import '../utils/constants.dart';
import '../../utils/constants.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final CartService cartService = CartService();
  final WishlistService wishlistService = WishlistService();

  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.product.name),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    // --- CHANGED: Smart Image Logic with Hero Animation ---
                    child: Hero(
                      tag: widget
                          .product.id, // Must match the tag in ProductCard
                      child: widget.product.image.startsWith('http')
                          ? Image.network(
                              widget.product.image,
                              height: 220,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image,
                                      size: 100, color: Colors.grey),
                            )
                          : Image.asset(
                              widget.product.image,
                              height: 220,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.image_not_supported,
                                      size: 100, color: Colors.grey),
                            ),
                    ),
                    // ----------------------------------------------------
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 40,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        wishlistService.toggleWishlist(widget.product);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
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
                        wishlistService.contains(widget.product)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: wishlistService.contains(widget.product)
                            ? Colors.red
                            : Colors.grey,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              widget.product.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.product.price,
              style: const TextStyle(
                fontSize: 20,
                color: AppConstants.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              widget.product.description,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                const Text(
                  "Quantity: ",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 10),
                _buildQuantityButton(Icons.remove, () {
                  if (quantity > 1) {
                    setState(() => quantity--);
                  }
                }),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    quantity.toString(),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildQuantityButton(Icons.add, () {
                  setState(() => quantity++);
                }),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      wishlistService.toggleWishlist(widget.product);
                      setState(() {});
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppConstants.primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          wishlistService.contains(widget.product)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: wishlistService.contains(widget.product)
                              ? Colors.red
                              : AppConstants.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          wishlistService.contains(widget.product)
                              ? "Wishlisted"
                              : "Wishlist",
                          style: TextStyle(
                            color: wishlistService.contains(widget.product)
                                ? Colors.red
                                : AppConstants.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addToCartWithQuantity,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      "Add to Cart",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppConstants.primaryColor),
        borderRadius: BorderRadius.circular(8),
        color: AppConstants.primaryColor.withOpacity(0.1),
      ),
      child: IconButton(
        icon: Icon(icon, color: AppConstants.primaryColor),
        onPressed: onTap,
      ),
    );
  }

  void _addToCartWithQuantity() {
    cartService.addToCart(widget.product, quantity: quantity);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Added ${quantity}x ${widget.product.name} to cart"),
        duration: const Duration(seconds: 2),
      ),
    );

    setState(() {
      quantity = 1;
    });
  }
}
