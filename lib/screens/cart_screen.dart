import 'package:flutter/material.dart';
import '../models/address_model.dart';
import '../models/order_model.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';
import '../services/address_service.dart';
import 'checkout_screen.dart';
import 'address_screen.dart';
import '../utils/extensions.dart';
import '../utils/constants.dart';
import '../models/cart_model.dart';

class CartScreen extends StatefulWidget {
  final VoidCallback? onContinueShopping;
  final VoidCallback? onCartUpdated;

  CartScreen({
    super.key,
    this.onContinueShopping,
    this.onCartUpdated,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService cartService = CartService();
  final OrderService orderService = OrderService();
  final AddressService addressService = AddressService();

  @override
  void initState() {
    super.initState();
    cartService.initialize();
  }

  void refreshCart() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Cart"),
        automaticallyImplyLeading: false,
      ),
      body:
          cartService.items.isEmpty ? _buildEmptyCart() : _buildCartWithItems(),
    );
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
            onPressed: widget.onContinueShopping ?? () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
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
            itemCount: cartService.items.length,
            itemBuilder: (context, index) {
              final item = cartService.items[index];
              return _buildCartItem(item);
            },
          ),
        ),

        // Checkout Section
        _buildCheckoutSection(),
      ],
    );
  }

  Widget _buildCartItem(CartItem item) {
    final price = item.product.price.toDouble();

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
                color: AppConstants.primaryColor,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove, size: 20),
              onPressed: () async {
                await cartService.decreaseQuantity(item.product);
                widget.onCartUpdated?.call();
                refreshCart();
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
              onPressed: () async {
                await cartService.increaseQuantity(item.product);
                widget.onCartUpdated?.call();
                refreshCart();
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () async {
                await cartService.removeItem(item.product);
                widget.onCartUpdated?.call();
                refreshCart();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutSection() {
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
                "₹${cartService.totalPrice.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _proceedToCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
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
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: widget.onContinueShopping ?? () {},
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(
                  color: AppConstants.primaryColor,
                  width: 1.5,
                ),
              ),
              child: const Text(
                "Continue Shopping",
                style: TextStyle(
                  fontSize: 16,
                  color: AppConstants.primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _proceedToCheckout() async {
    if (cartService.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Your cart is empty!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          onPaymentComplete: () async {
            final addresses = await addressService.getAddresses();

            if (addresses.isEmpty) {
              return;
            }

            final selectedAddress = addresses.firstWhere(
              (a) => a.isDefault,
              orElse: () => addresses.first,
            );

            await _createOrder(selectedAddress);
            await cartService.clearCart();
            widget.onCartUpdated?.call();

            if (mounted) {
              setState(() {});
            }

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Order placed successfully!"),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showAddAddressDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Add Address"),
        content: const Text(
            "You need to add a shipping address before placing an order. Would you like to add one now?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddressScreen(fromCheckout: true),
                ),
              );
              if (result != true) {
                _proceedToCheckout();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
            ),
            child: const Text(
              "Add Address",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createOrder(Address shippingAddress) async {
    final orderId = "ORD${DateTime.now().millisecondsSinceEpoch}";

    final order = Order(
      orderId: orderId,
      orderDate: DateTime.now(),
      items: List.from(cartService.items),
      subtotalAmount: cartService.totalPrice,
      shippingAmount: cartService.shippingAmount,
      taxAmount: cartService.taxAmount,
      discountAmount: cartService.discountAmount,
      totalAmount: cartService.finalTotal,
      status: 'Processing',
      shippingAddress: shippingAddress,
      appliedCoupon: cartService.appliedCoupon,
    );

    await orderService.saveOrder(order);
  }
}
