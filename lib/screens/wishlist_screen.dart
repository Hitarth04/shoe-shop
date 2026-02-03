import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/wishlist_service.dart';
import '../services/cart_service.dart';
import 'product_details_screen.dart';
import '../utils/constants.dart';

class WishlistScreen extends StatefulWidget {
  final VoidCallback? onWishlistUpdated;
  final VoidCallback? onCartUpdated;
  final VoidCallback? onBrowseProducts;

  const WishlistScreen({
    super.key,
    this.onWishlistUpdated,
    this.onCartUpdated,
    this.onBrowseProducts,
  });

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final WishlistService wishlistService = WishlistService();
  final CartService cartService = CartService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Wishlist"),
        centerTitle: true,
        actions: [
          if (wishlistService.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _showClearWishlistDialog,
              tooltip: "Clear wishlist",
            ),
        ],
      ),
      body: wishlistService.items.isEmpty
          ? _buildEmptyWishlist()
          : _buildWishlistItems(),
    );
  }

  Widget _buildEmptyWishlist() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          const Text(
            "Your wishlist is empty",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Add products you love to your wishlist",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _navigateToHomeTab,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            child: const Text(
              "Browse Products",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistItems() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey.shade50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${wishlistService.count} items",
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              GestureDetector(
                onTap: _showClearWishlistDialog,
                child: const Text(
                  "Clear All",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: wishlistService.items.length,
            itemBuilder: (context, index) {
              final product = wishlistService.items[index];
              return _buildWishlistItem(product);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWishlistItem(Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailsScreen(product: product),
            ),
          );
        },
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: product.image.startsWith('http')
              ? Image.network(
                  product.image,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, color: Colors.grey),
                )
              : Image.asset(
                  product.image,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              product.price,
              style: const TextStyle(
                color: AppConstants.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.add_shopping_cart, size: 20),
              color: AppConstants.primaryColor,
              onPressed: () async {
                await cartService.addToCart(product);
                if (widget.onCartUpdated != null) {
                  widget.onCartUpdated!();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: Colors.red,
              onPressed: () {
                setState(() {
                  wishlistService.removeFromWishlist(product);
                  if (widget.onWishlistUpdated != null) {
                    widget.onWishlistUpdated!();
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showClearWishlistDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear Wishlist"),
        content: const Text(
            "Are you sure you want to remove all items from your wishlist?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                wishlistService.clear();
                if (widget.onWishlistUpdated != null) {
                  widget.onWishlistUpdated!();
                }
              });
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Wishlist cleared"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
            ),
            child: const Text(
              "Clear All",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToHomeTab() {
    if (widget.onBrowseProducts != null) {
      widget.onBrowseProducts!();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Switch to Home tab to continue shopping"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
