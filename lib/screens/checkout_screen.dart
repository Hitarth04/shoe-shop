import 'dart:math'; // Import Math for random ID
import 'package:flutter/material.dart';
import '../models/address_model.dart';
import '../models/order_model.dart';
import '../models/cart_model.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';
import '../services/address_service.dart';
import '../services/payment_service.dart';
import '../widgets/address_selection_sheet.dart';
import '../utils/constants.dart';

class CheckoutScreen extends StatefulWidget {
  final VoidCallback? onPaymentComplete;

  const CheckoutScreen({
    super.key,
    this.onPaymentComplete,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _couponController = TextEditingController();
  final CartService cartService = CartService();
  final AddressService _addressService = AddressService();
  final OrderService _orderService = OrderService();

  late PaymentService _paymentService;

  Address? _selectedAddress;
  String? _appliedCoupon;
  double _discountAmount = 0.0;
  bool _isPaymentProcessing = false;

  @override
  void initState() {
    super.initState();
    cartService.initialize();
    _loadDefaultAddress();

    _paymentService = PaymentService(
      onSuccess: _handlePaymentSuccess,
      onFailure: _handlePaymentFailure,
    );
    _paymentService.initialize();
  }

  @override
  void dispose() {
    _couponController.dispose();
    _paymentService.dispose();
    super.dispose();
  }

  // --- NEW HELPER: Generate Short Unique ID ---
  String _generateOrderId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    // Generates format: "XY12-AB34"
    String part1 = String.fromCharCodes(Iterable.generate(
        4, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
    String part2 = String.fromCharCodes(Iterable.generate(
        4, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
    return '$part1-$part2';
  }

  Future<void> _loadDefaultAddress() async {
    final loadedAddresses = await _addressService.getAddresses();
    if (loadedAddresses.isNotEmpty) {
      setState(() {
        _selectedAddress = loadedAddresses.firstWhere(
          (addr) => addr.isDefault,
          orElse: () => loadedAddresses.first,
        );
      });
    }
  }

  void _applyCoupon() {
    final couponCode = _couponController.text.trim().toUpperCase();
    if (couponCode.isEmpty) return;

    if (!AppConstants.availableCoupons.containsKey(couponCode)) {
      _showError("Invalid Coupon Code");
      return;
    }

    final double discountValue = AppConstants.availableCoupons[couponCode]!;
    double calculatedDiscount = 0.0;

    if (couponCode == 'FREESHIP') {
      calculatedDiscount = cartService.shippingAmount;
    } else if (discountValue < 1.0) {
      calculatedDiscount = cartService.totalPrice * discountValue;
    } else {
      calculatedDiscount = discountValue;
    }

    double maxPossibleDiscount =
        cartService.totalPrice + cartService.shippingAmount;
    if (calculatedDiscount > maxPossibleDiscount) {
      calculatedDiscount = maxPossibleDiscount;
    }

    setState(() {
      _appliedCoupon = couponCode;
      _discountAmount = calculatedDiscount;
      _couponController.text = couponCode;
      cartService.applyDiscount(calculatedDiscount, couponCode);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              "Coupon applied! Saved ₹${calculatedDiscount.toStringAsFixed(0)}"),
          backgroundColor: Colors.green),
    );
  }

  void _removeCoupon() {
    setState(() {
      _appliedCoupon = null;
      _discountAmount = 0.0;
      _couponController.clear();
      cartService.removeDiscount();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Coupon removed"), backgroundColor: Colors.orange),
    );
  }

  void _initiatePayment() {
    if (_isPaymentProcessing) return;

    if (cartService.items.isEmpty) {
      _showError("Your cart is empty");
      return;
    }

    if (_selectedAddress == null) {
      _showError("Please select a shipping address");
      return;
    }

    setState(() => _isPaymentProcessing = true);

    if (cartService.finalTotal <= 0) {
      _handlePaymentSuccess("FREE-${_generateOrderId()}");
      return;
    }

    try {
      _paymentService.openCheckout(
        amount: cartService.finalTotal,
        mobile: _selectedAddress!.phone,
        email: 'user@shoeapp.com',
      );
    } catch (e) {
      _handlePaymentFailure("Could not open payment: $e");
    }
  }

  void _handlePaymentSuccess(String paymentId) async {
    await _saveOrderToFirebase(paymentId);
  }

  void _handlePaymentFailure(String error) {
    setState(() => _isPaymentProcessing = false);
    _showError(error);
  }

  Future<void> _saveOrderToFirebase(String paymentId) async {
    try {
      final List<CartItem> itemsSnapshot =
          List<CartItem>.from(cartService.items);

      final newOrder = Order(
        id: '',
        // FIX: Use the new Random ID Generator
        orderId: _generateOrderId(),
        userId: '',
        items: itemsSnapshot,
        totalAmount: cartService.finalTotal,
        subtotalAmount: cartService.totalPrice,
        shippingAmount: cartService.shippingAmount,
        taxAmount: cartService.taxAmount,
        discountAmount: cartService.discountAmount,
        shippingAddress: _selectedAddress!,
        orderDate: DateTime.now(),
        status: "Processing",
        paymentMethod:
            cartService.finalTotal <= 0 ? "Free Order" : "Online (Razorpay)",
        paymentId: paymentId,
      );

      await _orderService.saveOrder(newOrder);
      await cartService.clearCart();

      if (mounted) {
        setState(() => _isPaymentProcessing = false);
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text("Order Placed! 🎉"),
            content: Text("Your Order ID is #${newOrder.orderId}"),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onPaymentComplete?.call();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.secondaryColor),
                child: const Text("Continue Shopping",
                    style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        );
      }
    } catch (e) {
      _handlePaymentFailure("Failed to save order: $e");
    }
  }

  void _changeAddress() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddressSelectionSheet(
        onAddressSelected: (address) async {
          setState(() => _selectedAddress = address);
          await _addressService.setDefaultAddress(address.id);
        },
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Checkout"),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAddressSection(),
            const SizedBox(height: 20),
            _buildOrderSummary(),
            const SizedBox(height: 30),
            _buildCouponSection(),
            const SizedBox(height: 30),
            _buildPaymentMethodSection(),
            const SizedBox(height: 40),
            _buildProceedButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSection() {
    return Card(
      color: Colors.grey.shade50,
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Shipping Address",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton(
                    onPressed: _changeAddress, child: const Text("Change")),
              ],
            ),
            const SizedBox(height: 8),
            if (_selectedAddress != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: AppConstants.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4)),
                      child: Text(_selectedAddress!.tag,
                          style: const TextStyle(
                              color: AppConstants.primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Text(_selectedAddress!.fullName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(_selectedAddress!.phone),
                  Text(_selectedAddress!.fullAddress,
                      style: const TextStyle(color: Colors.grey)),
                ],
              )
            else
              const Text("No address selected. Please add one."),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      color: Colors.grey.shade50,
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Order Summary",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildSummaryRow(
                "Subtotal", "₹${cartService.totalPrice.toStringAsFixed(2)}"),
            _buildSummaryRow("Shipping",
                "₹${cartService.shippingAmount.toStringAsFixed(2)}"),
            _buildSummaryRow(
                "Tax (18%)", "₹${cartService.taxAmount.toStringAsFixed(2)}"),
            if (_discountAmount > 0)
              _buildSummaryRow(
                  "Discount", "-₹${_discountAmount.toStringAsFixed(2)}",
                  isDiscount: true),
            const Divider(height: 30),
            _buildSummaryRow(
                "Total", "₹${cartService.finalTotal.toStringAsFixed(2)}",
                isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isDiscount = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: isTotal ? 18 : 16,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  color: isDiscount ? Colors.green : Colors.black)),
          Text(value,
              style: TextStyle(
                  fontSize: isTotal ? 20 : 16,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  color: isDiscount
                      ? Colors.green
                      : (isTotal ? AppConstants.primaryColor : Colors.black))),
        ],
      ),
    );
  }

  Widget _buildCouponSection() {
    return Card(
      color: Colors.grey.shade50,
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Apply Coupon",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            if (_appliedCoupon != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.discount, color: Colors.green),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Coupon: $_appliedCoupon",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green)),
                          Text("Saved ₹${_discountAmount.toStringAsFixed(2)}",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.green)),
                        ],
                      ),
                    ),
                    IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: _removeCoupon),
                  ],
                ),
              ),
            if (_appliedCoupon == null) ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _couponController,
                      decoration: InputDecoration(
                        hintText: "Enter code",
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _applyCoupon,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.secondaryColor),
                    child: const Text("Apply",
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              const Text("Available coupons:",
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.availableCoupons.entries.map((entry) {
                  return ActionChip(
                    label: Text(entry.key),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                        color: AppConstants.primaryColor.withOpacity(0.5)),
                    onPressed: () {
                      _couponController.text = entry.key;
                      _applyCoupon();
                    },
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Card(
      color: Colors.grey.shade50,
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Payment Method",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _buildPaymentOption(
                value: 'online',
                icon: Icons.credit_card,
                title: "Online Payment",
                subtitle: "Cards, UPI, NetBanking"),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
      {required String value,
      required IconData icon,
      required String title,
      required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppConstants.primaryColor, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppConstants.primaryColor),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text(subtitle,
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: AppConstants.primaryColor),
        ],
      ),
    );
  }

  Widget _buildProceedButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isPaymentProcessing ? null : _initiatePayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.secondaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isPaymentProcessing
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Pay & Order",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(width: 10),
                  Text("₹${cartService.finalTotal.toStringAsFixed(0)}",
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ],
              ),
      ),
    );
  }
}
