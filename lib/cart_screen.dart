import 'package:flutter/material.dart';
import 'cart_model.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  final VoidCallback? onContinueShopping;
  final VoidCallback? onCartUpdated;

  const CartScreen({
    super.key,
    this.onContinueShopping,
    this.onCartUpdated,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    // You could add a listener here if needed
  }

  void refreshCart() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.onCartUpdated != null) {
        widget.onCartUpdated!();
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Cart"),
        automaticallyImplyLeading: false,
      ),
      body: Cart.items.isEmpty ? _buildEmptyCart() : _buildCartWithItems(),
    );
  }

  // In all cart modification methods, call the callback:
  void _modifyCart() {
    if (widget.onCartUpdated != null) {
      widget.onCartUpdated!();
    }
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          const Text(
            "Your cart is empty",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Add some products to get started!",
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
              "Continue Shopping",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartWithItems() {
    return Column(
      children: [
        // Cart Items List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: Cart.items.length,
            itemBuilder: (context, index) {
              final item = Cart.items[index];
              return _buildCartItem(item);
            },
          ),
        ),

        // Checkout Button (instead of summary)
        _buildCheckoutButton(),
      ],
    );
  }

  Widget _buildCartItem(CartItem item) {
    final price = _parsePrice(item.product.price);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Image.asset(
          item.product.image,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        ),
        title: Text(item.product.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.product.price),
            Text(
              "Total: ₹${(price * item.quantity).toStringAsFixed(2)}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF5B5FDC),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove, size: 20),
              onPressed: () {
                setState(() {
                  if (item.quantity > 1) {
                    Cart.decreaseQty(item.product);
                    _modifyCart();
                  } else {
                    Cart.removeItem(item.product);
                    _modifyCart();
                  }
                });
              },
            ),
            Text(
              item.quantity.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, size: 20),
              onPressed: () {
                setState(() {
                  Cart.increaseQty(item.product);
                  _modifyCart();
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () {
                setState(() {
                  Cart.removeItem(item.product);
                  _modifyCart();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Cart Total (simple version)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "₹${(Cart.totalPrice + (Cart.totalPrice > 0 ? 30 : 0)).toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5B5FDC),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Checkout Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CheckoutScreen(
                      onPaymentComplete: () {
                        // This will be called when payment is complete
                        if (mounted) {
                          setState(() {}); // Refresh the cart screen
                        }
                      },
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B5FDC),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "PROCEED TO CHECKOUT",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Continue Shopping Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: _navigateToHomeTab,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(
                  color: Color(0xFF5B5FDC),
                  width: 1.5,
                ),
              ),
              child: const Text(
                "Continue Shopping",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF5B5FDC),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _parsePrice(String priceString) {
    try {
      final cleanString = priceString.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.parse(cleanString);
    } catch (e) {
      return 0.0;
    }
  }

  void _navigateToHomeTab() {
    if (widget.onContinueShopping != null) {
      widget.onContinueShopping!();
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
