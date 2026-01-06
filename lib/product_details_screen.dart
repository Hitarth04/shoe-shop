import 'package:flutter/material.dart';
import 'product_model.dart';
import 'cart_model.dart';
import 'wishlist_model.dart'; // Add this import

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  final VoidCallback? onWishlistChanged; // Add this callback

  const ProductDetailsScreen({
    super.key,
    required this.product,
    this.onWishlistChanged, // Add this
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.product.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Wishlist Icon in AppBar
          IconButton(
            icon: Icon(
              Wishlist.contains(widget.product)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color:
                  Wishlist.contains(widget.product) ? Colors.red : Colors.white,
            ),
            onPressed: () {
              setState(() {
                Wishlist.toggleWishlist(widget.product);
                if (widget.onWishlistChanged != null) {
                  widget.onWishlistChanged!();
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      Wishlist.contains(widget.product)
                          ? "Added to wishlist"
                          : "Removed from wishlist",
                    ),
                    backgroundColor: Wishlist.contains(widget.product)
                        ? Colors.green
                        : Colors.orange,
                    duration: const Duration(seconds: 1),
                  ),
                );
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Wishlist Heart
            Stack(
              children: [
                Center(
                  child: Hero(
                    tag: 'product_${widget.product.name}',
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

                // Wishlist Heart on Image
                Positioned(
                  top: 10,
                  right: 20,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        Wishlist.toggleWishlist(widget.product);
                        if (widget.onWishlistChanged != null) {
                          widget.onWishlistChanged!();
                        }
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
                        Wishlist.contains(widget.product)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Wishlist.contains(widget.product)
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
                // Add to Wishlist Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Wishlist.toggleWishlist(widget.product);
                      if (widget.onWishlistChanged != null) {
                        widget.onWishlistChanged!();
                      }

                      setState(() {});
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF5B5FDC)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Wishlist.contains(widget.product)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Wishlist.contains(widget.product)
                              ? Colors.red
                              : const Color(0xFF5B5FDC),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          Wishlist.contains(widget.product)
                              ? "Wishlisted"
                              : "Wishlist",
                          style: TextStyle(
                            color: Wishlist.contains(widget.product)
                                ? Colors.red
                                : const Color(0xFF5B5FDC),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Add to Cart Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _addToCartWithQuantity();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B5FDC),
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
    final existingItemIndex = Cart.items.indexWhere(
      (item) => item.product.name == widget.product.name,
    );

    if (existingItemIndex >= 0) {
      Cart.items[existingItemIndex].quantity += quantity;
    } else {
      Cart.items.add(CartItem(product: widget.product, quantity: quantity));
    }

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
