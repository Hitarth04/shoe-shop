import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';
import '../services/wishlist_service.dart';
import '../widgets/product_card.dart';
import 'product_details_screen.dart';
import '../utils/constants.dart';
import 'admin/admin_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final VoidCallback? onCartUpdated;
  final VoidCallback? onWishlistUpdated;

  const HomeScreen({
    super.key,
    required this.userName,
    this.onCartUpdated,
    this.onWishlistUpdated,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController searchController = TextEditingController();
  String _searchQuery = "";

  final CartService cartService = CartService();
  final WishlistService wishlistService = WishlistService();

  // FIX 1: Define the stream variable here
  late Stream<QuerySnapshot> _productsStream;

  @override
  void initState() {
    super.initState();
    // FIX 1: Initialize the stream once.
    // This prevents the connection from resetting when you click "Add to Cart"
    _productsStream =
        FirebaseFirestore.instance.collection('products').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              GestureDetector(
                onLongPress: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AdminDashboardScreen()),
                  );
                },
                child: Text(
                  "Hello, ${widget.userName} 👋",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "Find your perfect shoes",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              _buildSearchBar(),
              const SizedBox(height: 25),
              _buildProductGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
            decoration: InputDecoration(
              hintText: "Search shoes",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: AppConstants.primaryColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.tune, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildProductGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: _productsStream, // FIX 1: Use the persistent stream variable
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Expanded(
            child: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF5B5FDC),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return const Expanded(
            child: Center(child: Text("Something went wrong loading products")),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        final products = docs
            .map((doc) => Product.fromFirestore(doc))
            .where(
                (product) => product.name.toLowerCase().contains(_searchQuery))
            .toList();

        if (products.isEmpty) {
          return const Expanded(
            child: Center(child: Text("No shoes found")),
          );
        }

        return Expanded(
          child: GridView.builder(
            // FIX 2: Add a PageStorageKey.
            // This explicitly tells Flutter to remember the scroll position of this list.
            key: const PageStorageKey('product_grid'),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                product: product,
                onAddToCart: () async {
                  await cartService.addToCart(product);
                  widget.onCartUpdated?.call();
                  setState(() {});
                },
                onWishlistToggle: () {
                  wishlistService.toggleWishlist(product);
                  widget.onWishlistUpdated?.call();
                  setState(() {});
                },
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductDetailsScreen(product: product),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
