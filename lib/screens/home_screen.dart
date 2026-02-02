import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';
import '../services/wishlist_service.dart';
import '../widgets/product_card.dart';
import 'product_details_screen.dart';
import '../utils/constants.dart';

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
  String _searchQuery = ""; // Store the search query

  final CartService cartService = CartService();
  final WishlistService wishlistService = WishlistService();

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
              Text(
                "Hello, ${widget.userName} 👋",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
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
              _buildProductGrid(), // Now dynamic!
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
    // 1. Listen to the 'products' collection from Firestore
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        // 2. Loading State
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Expanded(
            child: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF5B5FDC),
              ),
            ),
          );
        }

        // 3. Error State
        if (snapshot.hasError) {
          return const Expanded(
            child: Center(child: Text("Something went wrong loading products")),
          );
        }

        // 4. Data Processing
        final docs = snapshot.data?.docs ?? [];

        // Convert Firestore docs to Product objects and filter by search query
        final products = docs
            .map((doc) => Product.fromFirestore(doc))
            .where(
                (product) => product.name.toLowerCase().contains(_searchQuery))
            .toList();

        // 5. Empty State
        if (products.isEmpty) {
          return const Expanded(
            child: Center(child: Text("No shoes found")),
          );
        }

        // 6. Display Grid
        return Expanded(
          child: GridView.builder(
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
