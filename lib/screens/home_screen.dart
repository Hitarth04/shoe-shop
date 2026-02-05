import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';
import '../services/wishlist_service.dart';
import '../widgets/product_card.dart';
import 'product_details_screen.dart';
import '../utils/constants.dart';
import 'admin/admin_dashboard_screen.dart';
import '../widgets/size_selector.dart';

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

  // --- FILTER STATE VARIABLES ---
  String _selectedCategory = 'All';
  // Increased max range to 50,000 to ensure new products aren't hidden
  RangeValues _priceRange = const RangeValues(0, 50000);
  String _sortOption = 'Newest';

  final CartService cartService = CartService();
  final WishlistService wishlistService = WishlistService();

  late Stream<QuerySnapshot> _productsStream;

  @override
  void initState() {
    super.initState();
    _productsStream =
        FirebaseFirestore.instance.collection('products').snapshots();
  }

  // --- NEW HELPER: Size Pop-up ---
  void _showSizeSelectionDialog(Product product) {
    // Sort available sizes numerically
    final sortedAvailable = List<String>.from(product.sizes)
      ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

    String? selectedSize =
        sortedAvailable.isNotEmpty ? sortedAvailable.first : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text("Select Size for ${product.name}"),
            content: SizedBox(
              width: double.maxFinite,
              // Use the reusable SizeSelector widget
              child: SizeSelector(
                availableSizes: product.sizes,
                selectedSize: selectedSize,
                onSizeSelected: (size) {
                  setDialogState(() => selectedSize = size);
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: selectedSize == null
                    ? null
                    : () async {
                        await cartService.addToCart(product, selectedSize!);
                        widget.onCartUpdated?.call();

                        if (mounted) Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                "Added ${product.name} (Size $selectedSize) to Cart"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.secondaryColor,
                ),
                child: const Text("Add to Cart",
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
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

              // Active Filters Display
              if (_selectedCategory != 'All' || _sortOption != 'Newest')
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (_selectedCategory != 'All')
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Chip(
                              label: Text(_selectedCategory),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () =>
                                  setState(() => _selectedCategory = 'All'),
                              backgroundColor:
                                  AppConstants.primaryColor.withOpacity(0.1),
                            ),
                          ),
                        if (_sortOption != 'Newest')
                          Chip(
                            label: Text(_sortOption),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () =>
                                setState(() => _sortOption = 'Newest'),
                            backgroundColor: Colors.orange.withOpacity(0.1),
                          ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 15),
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
        GestureDetector(
          onTap: _showFilterBottomSheet,
          child: Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: AppConstants.primaryColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.tune, color: Colors.white),
          ),
        ),
      ],
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Filter & Sort",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  // Categories
                  const Text("Category",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: ["All", "Sneakers", "Formal", "Sports", "Loafers"]
                        .map((category) {
                      final isSelected = _selectedCategory == category;
                      return ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        selectedColor: AppConstants.primaryColor,
                        labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black),
                        onSelected: (selected) {
                          setModalState(() => _selectedCategory = category);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Price Range (Updated to 50k)
                  Text(
                      "Price Range: ₹${_priceRange.start.round()} - ₹${_priceRange.end.round()}",
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 50000,
                    divisions: 100,
                    activeColor: AppConstants.primaryColor,
                    labels: RangeLabels("₹${_priceRange.start.round()}",
                        "₹${_priceRange.end.round()}"),
                    onChanged: (values) {
                      setModalState(() => _priceRange = values);
                    },
                  ),
                  const SizedBox(height: 20),

                  // Sort Options
                  const Text("Sort By",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: [
                      "Newest",
                      "Price: Low to High",
                      "Price: High to Low"
                    ].map((option) {
                      final isSelected = _sortOption == option;
                      return ChoiceChip(
                        label: Text(option),
                        selected: isSelected,
                        selectedColor: AppConstants.secondaryColor,
                        labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black),
                        onSelected: (selected) {
                          setModalState(() => _sortOption = option);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {});
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text("Apply Filters",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProductGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: _productsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Expanded(
              child: Center(
                  child: CircularProgressIndicator(
                      color: AppConstants.primaryColor)));
        }

        if (snapshot.hasError) {
          return const Expanded(
              child:
                  Center(child: Text("Something went wrong loading products")));
        }

        final docs = snapshot.data?.docs ?? [];

        // --- FILTERING LOGIC ---
        var products =
            docs.map((doc) => Product.fromFirestore(doc)).where((product) {
          // 1. Search Query
          final matchesSearch =
              product.name.toLowerCase().contains(_searchQuery);

          // 2. Category Filter
          final matchesCategory = _selectedCategory == 'All' ||
              product.category.toLowerCase() == _selectedCategory.toLowerCase();

          // 3. Price Filter (Clean string '₹2500' -> 2500.0)
          double priceVal = 0.0;
          try {
            String cleanPrice =
                product.price.replaceAll(RegExp(r'[^0-9.]'), '');
            priceVal = double.parse(cleanPrice);
          } catch (e) {
            priceVal =
                0.0; // Show items with invalid price at min range, instead of crashing
          }
          final matchesPrice =
              priceVal >= _priceRange.start && priceVal <= _priceRange.end;

          return matchesSearch && matchesCategory && matchesPrice;
        }).toList();

        // --- SORTING LOGIC ---
        if (_sortOption == 'Price: Low to High') {
          products.sort((a, b) {
            double pA =
                double.tryParse(a.price.replaceAll(RegExp(r'[^0-9.]'), '')) ??
                    0;
            double pB =
                double.tryParse(b.price.replaceAll(RegExp(r'[^0-9.]'), '')) ??
                    0;
            return pA.compareTo(pB);
          });
        } else if (_sortOption == 'Price: High to Low') {
          products.sort((a, b) {
            double pA =
                double.tryParse(a.price.replaceAll(RegExp(r'[^0-9.]'), '')) ??
                    0;
            double pB =
                double.tryParse(b.price.replaceAll(RegExp(r'[^0-9.]'), '')) ??
                    0;
            return pB.compareTo(pA);
          });
        }

        // Sync Wishlist status
        for (var product in products) {
          product.isWishlisted = wishlistService.contains(product);
        }

        if (products.isEmpty) {
          return const Expanded(
              child:
                  Center(child: Text("No shoes found matching your filters")));
        }

        return Expanded(
          child: GridView.builder(
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
                onAddToCart: () => _showSizeSelectionDialog(product),
                onWishlistToggle: () {
                  wishlistService.toggleWishlist(product);
                  widget.onWishlistUpdated?.call();
                  setState(() {});
                },
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductDetailsScreen(product: product),
                    ),
                  );
                  if (mounted) {
                    setState(() {});
                    widget.onWishlistUpdated?.call();
                    widget.onCartUpdated?.call();
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}
