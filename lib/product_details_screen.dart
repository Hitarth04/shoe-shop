import 'package:flutter/material.dart';
import 'product_model.dart';
import 'cart_model.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(widget.product.name)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                widget.product.image,
                height: 220,
              ),
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
                color: Color(0xFF5B5FDC),
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              widget.product.description,
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 25),

            /// Quantity Selector
            Row(
              children: [
                const Text(
                  "Quantity: ",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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

            const Spacer(),

            /// Buttons
            Row(
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
                      // Navigate to cart after adding
                      // You might want to add navigation here
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              "Added ${quantity}x ${widget.product.name} to cart"),
                          action: SnackBarAction(
                            label: 'View Cart',
                            onPressed: () {
                              // Navigate to cart screen
                              // This depends on your navigation structure
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
          ],
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

  // NEW METHOD: Add to cart with selected quantity
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

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Added ${quantity}x ${widget.product.name} to cart"),
        duration: const Duration(seconds: 2),
      ),
    );

    // Reset quantity to 1 for next time
    setState(() {
      quantity = 1;
    });
  }
}
