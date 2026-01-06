import 'package:flutter/material.dart';
import 'product_model.dart';
import 'product_details_screen.dart';
import 'cart_model.dart';
import 'wishlist_model.dart';

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
  late List<Product> filteredProducts;

  @override
  void initState() {
    super.initState();
    filteredProducts = products;
  }

  void refreshCart() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      filteredProducts = products
          .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
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

              /// 👋 Greeting
              Text(
                "Hello, ${widget.userName} 👋",
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Text(
                "Find your perfect shoes",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),

              /// 🔍 Search
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: "Search shoes",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5B5FDC),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.tune, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              /// 🛒 Product Grid
              Expanded(
                child: GridView.builder(
                  itemCount: filteredProducts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    ProductDetailsScreen(product: product),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            transitionDuration:
                                const Duration(milliseconds: 500),
                          ),
                        );
                      },
                      child: _productCard(product),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 👟 Product Card
  Widget _productCard(Product product) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.onCartUpdated != null) {
        widget.onCartUpdated!();
      }
    });

    void _modifyCart() {
      if (widget.onCartUpdated != null) {
        widget.onCartUpdated!();
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  ProductDetailsScreen(product: product),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            var begin = const Offset(0.0, 1.0);
                            var end = Offset.zero;
                            var curve = Curves.easeInOut;

                            var tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));
                            var offsetAnimation = animation.drive(tween);

                            return SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 600),
                        ),
                      );
                    },
                    child: Hero(
                      tag: 'product_${product.name}',
                      child: Image.asset(
                        product.image,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  product.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  product.price,
                  style: const TextStyle(
                      color: Color(0xFF5B5FDC), fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ElevatedButton(
                  onPressed: () {
                    Cart.addToCart(product);
                    _modifyCart();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B5FDC),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: const Text(
                    "Add to Cart",
                    style: TextStyle(
                      color: Colors.white,
                    ),
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
              onTap: () {
                setState(
                  () {
                    Wishlist.toggleWishlist(product);
                    if (widget.onWishlistUpdated != null) {
                      widget.onWishlistUpdated!();
                    }
                  },
                );
              },
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
                  Wishlist.contains(product)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: Wishlist.contains(product) ? Colors.red : Colors.grey,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final List<Product> products = [
  Product(
      name: "Nike Air Max",
      image: "assets/images/shoes.png",
      price: "₹8,999",
      description:
          'Dynamic Air unit system: Features dual-pressure tubes with varied pressure in the heel and midfoot for a reactive and smooth stepping sensation.'),
  Product(
      name: "Adidas Ultraboost",
      image: "assets/images/shoes2.png",
      price: "₹11,499",
      description:
          'Balanced cushioning and flexibility: These shoes offer a perfect equilibrium between cushioning for soft landings and flexibility for a natural running motion.'),
  Product(
      name: "Puma RS-X",
      image: "assets/images/shoes3.png",
      price: "₹7,999",
      description:
          "RS-X is back. This future-retro silhouette made waves when it dropped in 2018, celebrated for its disruptive design, fresh material mixes, and bold colours. Today, RS-X returns for a new generation of consumers who live to express their individuality. It's here to start a revolution of self-expression. This version features a mesh upper, synthetic overlays, and reflective details."),
  Product(
      name: "New Balance 574",
      image: "assets/images/shoes4.png",
      price: "₹9,299",
      description:
          "The most New Balance shoe ever’ says it all, right? No, actually. The 574 might be our unlikeliest icon. The 574 was built to be a reliable shoe that could do a lot of different things well rather than as a platform for revolutionary technology, or as a premium materials showcase. This unassuming, unpretentious versatility is exactly what launched the 574 into the ranks of all-time greats."),
  Product(
      name: "Nike Air Max",
      image: "assets/images/shoes.png",
      price: "₹8,999",
      description:
          'Dynamic Air unit system: Features dual-pressure tubes with varied pressure in the heel and midfoot for a reactive and smooth stepping sensation.'),
  Product(
      name: "Adidas Ultraboost",
      image: "assets/images/shoes2.png",
      price: "₹11,499",
      description:
          'Balanced cushioning and flexibility: These shoes offer a perfect equilibrium between cushioning for soft landings and flexibility for a natural running motion.'),
  Product(
      name: "Puma RS-X",
      image: "assets/images/shoes3.png",
      price: "₹7,999",
      description:
          "RS-X is back. This future-retro silhouette made waves when it dropped in 2018, celebrated for its disruptive design, fresh material mixes, and bold colours. Today, RS-X returns for a new generation of consumers who live to express their individuality. It's here to start a revolution of self-expression. This version features a mesh upper, synthetic overlays, and reflective details."),
  Product(
      name: "New Balance 574",
      image: "assets/images/shoes4.png",
      price: "₹9,299",
      description:
          "The most New Balance shoe ever’ says it all, right? No, actually. The 574 might be our unlikeliest icon. The 574 was built to be a reliable shoe that could do a lot of different things well rather than as a platform for revolutionary technology, or as a premium materials showcase. This unassuming, unpretentious versatility is exactly what launched the 574 into the ranks of all-time greats."),
];
