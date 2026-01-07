import 'package:flutter/material.dart';
import 'cart_model.dart';
import 'order_model.dart';
import 'address_selection_sheet.dart';

class CheckoutScreen extends StatefulWidget {
  final VoidCallback? onPaymentComplete;
  final Address? selectedAddress;
  final List<Address> addresses;
  final Function(Address) onAddressChanged;

  const CheckoutScreen(
      {super.key,
      this.onPaymentComplete,
      this.selectedAddress,
      required this.addresses,
      required this.onAddressChanged});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _couponController = TextEditingController();
  double _discountAmount = 0.0;
  String? _appliedCoupon;
  String _selectedPaymentMethod = 'credit_card';

  // Available coupons
  final Map<String, double> _availableCoupons = {
    'SAVE10': 0.10, // 10% discount
    'SAVE20': 0.20, // 20% discount
    'WELCOME50': 50.0, // ₹50 flat discount
    'FREESHIP': 30.0, // Free shipping (₹30)
  };

  @override
  void initState() {
    super.initState();
    // Initialize discount to 0
    _discountAmount = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = Cart.totalPrice;
    final shipping = subtotal > 0 ? 30.0 : 0.0;
    final discount = _discountAmount;
    final total = subtotal + shipping - discount;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Checkout"),
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
            // Address Section - ADD THIS FIRST
            if (widget.selectedAddress != null) _buildAddressSection(),

            const SizedBox(height: 20),

            // Order Summary Section
            _buildOrderSummary(subtotal, shipping, discount, total),

            const SizedBox(height: 30),

            // Coupon Section
            _buildCouponSection(),

            const SizedBox(height: 30),

            // Payment Method Section
            _buildPaymentMethodSection(),

            const SizedBox(height: 40),

            // Proceed to Payment Button
            _buildProceedButton(total),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(
      double subtotal, double shipping, double discount, double total) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Order Summary",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Subtotal
            _buildSummaryRow("Subtotal", "₹${subtotal.toStringAsFixed(2)}"),

            // Shipping
            _buildSummaryRow("Shipping", "₹${shipping.toStringAsFixed(2)}"),

            // Discount
            if (discount > 0)
              _buildSummaryRow(
                "Discount",
                "-₹${discount.toStringAsFixed(2)}",
                isDiscount: true,
              ),

            const Divider(height: 30),

            // Total
            _buildSummaryRow(
              "Total",
              "₹${total.toStringAsFixed(2)}",
              isTotal: true,
            ),
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
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? Colors.green : Colors.black,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 20 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isDiscount
                  ? Colors.green
                  : isTotal
                      ? const Color(0xFF5B5FDC)
                      : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Apply Coupon",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),

            // Applied coupon display
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
                          Text(
                            "Coupon Applied: $_appliedCoupon",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            "You saved ₹${_discountAmount.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: _removeCoupon,
                    ),
                  ],
                ),
              ),

            if (_appliedCoupon == null) ...[
              // Coupon input field
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _couponController,
                      decoration: InputDecoration(
                        hintText: "Enter coupon code",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _applyCoupon,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B5FDC),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Apply",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Available coupons
              const Text(
                "Available coupons:",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 5),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableCoupons.entries.map((entry) {
                  return Chip(
                    label: Text(entry.key),
                    backgroundColor: Colors.grey.shade100,
                    onDeleted: () {
                      _couponController.text = entry.key;
                    },
                    deleteIcon: const Icon(Icons.content_copy, size: 16),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // In the build method, add address selection section
  Widget _buildAddressSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Shipping Address",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                TextButton(
                  onPressed: _changeAddress,
                  child: const Text("Change"),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (widget.selectedAddress != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5B5FDC).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.selectedAddress!.tag,
                          style: const TextStyle(
                            color: Color(0xFF5B5FDC),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (widget.selectedAddress!.isDefault)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "Default",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(widget.selectedAddress!.fullName),
                  Text(widget.selectedAddress!.phone),
                  const SizedBox(height: 4),
                  Text(
                    widget.selectedAddress!.fullAddress,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _changeAddress() {
    showModalBottomSheet(
      context: context,
      builder: (context) => AddressSelectionSheet(
        addresses: widget.addresses,
        selectedAddress: widget.selectedAddress,
        onAddressSelected: (address) {
          widget.onAddressChanged(address);
          Navigator.pop(context);
          setState(() {});
        },
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Payment Method",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),

            // Credit/Debit Card
            _buildPaymentOption(
              value: 'credit_card',
              icon: Icons.credit_card,
              title: "Credit/Debit Card",
              subtitle: "Pay with your card",
            ),

            const SizedBox(height: 10),

            // UPI
            _buildPaymentOption(
              value: 'upi',
              icon: Icons.phone_android,
              title: "UPI",
              subtitle: "Google Pay, PhonePe, Paytm",
            ),

            const SizedBox(height: 10),

            // Cash on Delivery
            _buildPaymentOption(
              value: 'cod',
              icon: Icons.money,
              title: "Cash on Delivery",
              subtitle: "Pay when you receive",
            ),

            const SizedBox(height: 10),

            // Net Banking
            _buildPaymentOption(
              value: 'net_banking',
              icon: Icons.account_balance,
              title: "Net Banking",
              subtitle: "All major banks",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String value,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _selectedPaymentMethod == value
              ? const Color(0xFF5B5FDC).withOpacity(0.1)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _selectedPaymentMethod == value
                ? const Color(0xFF5B5FDC)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _selectedPaymentMethod == value
                    ? const Color(0xFF5B5FDC)
                    : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: _selectedPaymentMethod == value
                    ? Colors.white
                    : Colors.grey.shade700,
                size: 20,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Radio(
              value: value,
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
              activeColor: const Color(0xFF5B5FDC),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProceedButton(double total) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          _processPayment(total);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5B5FDC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Proceed to Payment",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              "₹${total.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyCoupon() {
    final couponCode = _couponController.text.trim().toUpperCase();

    if (couponCode.isEmpty) {
      _showError("Please enter a coupon code");
      return;
    }

    if (!_availableCoupons.containsKey(couponCode)) {
      _showError("Invalid coupon code");
      return;
    }

    final discount = _availableCoupons[couponCode]!;
    double discountAmount = 0.0;

    if (discount <= 1.0) {
      // Percentage discount
      discountAmount = Cart.totalPrice * discount;
    } else {
      // Fixed amount discount
      discountAmount = discount;
    }

    // Apply maximum discount of 90% of order total
    final maxDiscount = Cart.totalPrice * 0.9;
    if (discountAmount > maxDiscount) {
      discountAmount = maxDiscount;
    }

    setState(() {
      _appliedCoupon = couponCode;
      _discountAmount = discountAmount;
      _couponController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text("Coupon applied! Saved ₹${discountAmount.toStringAsFixed(2)}"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _removeCoupon() {
    setState(() {
      _appliedCoupon = null;
      _discountAmount = 0.0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Coupon removed"),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _processPayment(double total) async {
    if (Cart.items.isEmpty) {
      _showError("Your cart is empty");
      return;
    }

    // Store cart items count before clearing (for success message)
    final itemCount = Cart.items.length;

    // Show processing dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text("Processing payment..."),
            const SizedBox(height: 8),
            Text(
              "₹${total.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    // Close dialog
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    // CLEAR CART
    Cart.items.clear();
    Cart.discountAmount = 0.0;
    Cart.appliedCoupon = null;

    // Call the callback if it still exists
    if (widget.onPaymentComplete != null) {
      widget.onPaymentComplete!();
    }

    // Show success with option to continue
    final shouldContinue = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Payment Successful! 🎉"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 60),
                const SizedBox(height: 20),
                Text(
                  "Order Total: ₹${total.toStringAsFixed(2)}\n"
                  "Items: $itemCount",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Your order has been confirmed!",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B5FDC),
                  minimumSize: const Size(120, 45),
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        true;

    if (shouldContinue && mounted) {
      Cart.items.clear();
      // Pop back to CartScreen
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }
}
