import 'package:flutter/material.dart';
import 'product_model.dart';
import 'cart_model.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen>
    with SingleTickerProviderStateMixin {
  int quantity = 1;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.product.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero animation for the image
              Center(
                child: Hero(
                  tag: 'product_${widget.product.name}',
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Image.asset(
                        widget.product.image,
                        height: 220,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Animated text entry
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
                  ),
                ),
                child: FadeTransition(
                  opacity: Tween<double>(begin: 0, end: 1).animate(
                    CurvedAnimation(
                      parent: _controller,
                      curve: const Interval(0.4, 0.7, curve: Curves.easeIn),
                    ),
                  ),
                  child: Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
                  ),
                ),
                child: FadeTransition(
                  opacity: Tween<double>(begin: 0, end: 1).animate(
                    CurvedAnimation(
                      parent: _controller,
                      curve: const Interval(0.5, 0.8, curve: Curves.easeIn),
                    ),
                  ),
                  child: Text(
                    widget.product.price,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Color(0xFF5B5FDC),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: const Interval(0.6, 0.9, curve: Curves.easeOut),
                  ),
                ),
                child: FadeTransition(
                  opacity: Tween<double>(begin: 0, end: 1).animate(
                    CurvedAnimation(
                      parent: _controller,
                      curve: const Interval(0.6, 0.9, curve: Curves.easeIn),
                    ),
                  ),
                  child: Text(
                    widget.product.description,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              /// Quantity Selector
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
                  ),
                ),
                child: FadeTransition(
                  opacity: Tween<double>(begin: 0, end: 1).animate(
                    CurvedAnimation(
                      parent: _controller,
                      curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        "Quantity: ",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 10),
                      _qtyButton(Icons.remove, () {
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
                      _qtyButton(Icons.add, () {
                        setState(() => quantity++);
                      }),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              /// Buttons
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
                  ),
                ),
                child: FadeTransition(
                  opacity: Tween<double>(begin: 0, end: 1).animate(
                    CurvedAnimation(
                      parent: _controller,
                      curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _addToCartWithQuantity();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text("Add to Cart"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _addToCartWithQuantity();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    "Added ${quantity}x ${widget.product.name} to cart"),
                                action: SnackBarAction(
                                  label: 'View Cart',
                                  onPressed: () {
                                    // Navigate to cart screen
                                  },
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5B5FDC),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            "Buy Now",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF5B5FDC)),
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFF5B5FDC).withOpacity(0.1),
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFF5B5FDC)),
        onPressed: onTap,
      ),
    );
  }

  void _addToCartWithQuantity() {
    // Check if product already exists in cart
    final existingItemIndex = Cart.items.indexWhere(
      (item) => item.product.name == widget.product.name,
    );

    if (existingItemIndex >= 0) {
      // If exists, increase quantity by selected amount
      Cart.items[existingItemIndex].quantity += quantity;
    } else {
      // If new, add with selected quantity
      Cart.items.add(CartItem(product: widget.product, quantity: quantity));
    }

    // Show confirmation with animation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Text("Added ${quantity}x ${widget.product.name} to cart"),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    // Reset quantity to 1 for next time
    setState(() {
      quantity = 1;
    });
  }
}
