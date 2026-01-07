import 'package:flutter/material.dart';
import 'product_model.dart';
import 'wishlist_model.dart';
import 'product_details_screen.dart';
import 'cart_model.dart';
import 'product_manager.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: const Text("My Wishlist"),
        centerTitle: true,
        actions: [
          if (Wishlist.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _showClearWishlistDialog,
              tooltip: "Clear wishlist",
            ),
        ],
      ),
      body: Wishlist.items.isEmpty
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
              backgroundColor: const Color(0xFF5B5FDC),
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
        // Wishlist Count
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey.shade50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${Wishlist.count} items",
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

        // Wishlist Items List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: Wishlist.items.length,
            itemBuilder: (context, index) {
              final product = Wishlist.items[index];
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
              builder: (_) => ProductDetailsScreen(
                product: ProductManager.getProductByName(product.name),
                onWishlistChanged: () {
                  setState(() {});
                  if (widget.onWishlistUpdated != null) {
                    widget.onWishlistUpdated!();
                  }
                },
              ),
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
          child: Image.asset(
            product.image,
            fit: BoxFit.contain,
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
                color: Color(0xFF5B5FDC),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Add to Cart Button
            IconButton(
              icon: const Icon(Icons.add_shopping_cart, size: 20),
              color: const Color(0xFF5B5FDC),
              onPressed: () {
                Cart.addToCart(product);
                if (widget.onCartUpdated != null) {
                  widget.onCartUpdated!();
                }
              },
            ),

            // Remove from Wishlist Button
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: Colors.red,
              onPressed: () {
                setState(() {
                  Wishlist.removeFromWishlist(product);
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
                Wishlist.clear();
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
              backgroundColor: const Color(0xFF5B5FDC),
            ),
            child: const Text(
              "Clear All",
              style: TextStyle(
                color: Colors.white,
              ),
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
