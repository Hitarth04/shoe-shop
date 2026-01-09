import 'package:flutter/material.dart';
import '../models/address_model.dart';
import '../services/cart_service.dart';
import '../widgets/address_selection_sheet.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import 'address_screen.dart';
import '../services/address_service.dart';

class CheckoutScreen extends StatefulWidget {
  final VoidCallback? onPaymentComplete;
  final Address? selectedAddress;
  final List<Address> addresses;
  final Function(Address) onAddressChanged;

  const CheckoutScreen({
    super.key,
    this.onPaymentComplete,
    this.selectedAddress,
    required this.addresses,
    required this.onAddressChanged,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _couponController = TextEditingController();
  final CartService cartService = CartService();
  List<Address> _addresses = [];
  final AddressService _addressService = AddressService();

  String _selectedPaymentMethod = 'credit_card';
  String? _appliedCoupon;
  double _discountAmount = 0.0;

  @override
  void initState() {
    super.initState();
    cartService.initialize();
    _loadAddresses();
  }

  @override
  Widget build(BuildContext context) {
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
            if (widget.selectedAddress != null) _buildAddressSection(),
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
                          color: AppConstants.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.selectedAddress!.tag,
                          style: const TextStyle(
                            color: AppConstants.primaryColor,
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

  Widget _buildOrderSummary() {
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
            _buildSummaryRow(
                "Subtotal", "₹${cartService.totalPrice.toStringAsFixed(2)}"),
            _buildSummaryRow("Shipping",
                "₹${cartService.shippingAmount.toStringAsFixed(2)}"),
            _buildSummaryRow(
                "Tax (18%)", "₹${cartService.taxAmount.toStringAsFixed(2)}"),
            if (_discountAmount > 0)
              _buildSummaryRow(
                "Discount",
                "-₹${_discountAmount.toStringAsFixed(2)}",
                isDiscount: true,
              ),
            const Divider(height: 30),
            _buildSummaryRow(
              "Total",
              "₹${cartService.finalTotal.toStringAsFixed(2)}",
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
                      ? AppConstants.primaryColor
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
                      backgroundColor: AppConstants.primaryColor,
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
                children: AppConstants.availableCoupons.entries.map((entry) {
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
            _buildPaymentOption(
              value: 'credit_card',
              icon: Icons.credit_card,
              title: "Credit/Debit Card",
              subtitle: "Pay with your card",
            ),
            const SizedBox(height: 10),
            _buildPaymentOption(
              value: 'upi',
              icon: Icons.phone_android,
              title: "UPI",
              subtitle: "Google Pay, PhonePe, Paytm",
            ),
            const SizedBox(height: 10),
            _buildPaymentOption(
              value: 'cod',
              icon: Icons.money,
              title: "Cash on Delivery",
              subtitle: "Pay when you receive",
            ),
            const SizedBox(height: 10),
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
              ? AppConstants.primaryColor.withOpacity(0.1)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _selectedPaymentMethod == value
                ? AppConstants.primaryColor
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
                    ? AppConstants.primaryColor
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
              activeColor: AppConstants.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProceedButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
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
              "₹${cartService.finalTotal.toStringAsFixed(2)}",
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

  void _changeAddress() async {
    final result = await showModalBottomSheet<Address>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => AddressSelectionSheet(
        addresses: widget.addresses,
        selectedAddress: widget.selectedAddress,
        onAddressSelected: (address) {
          // This will be called when an address is selected
          widget.onAddressChanged(address);
        },
        onAddNewAddressPressed: () async {
          // Navigate to AddressScreen for adding new address
          final newAddress = await Navigator.push<Address>(
            context,
            MaterialPageRoute(
              builder: (context) => AddressScreen(fromCheckout: true),
            ),
          );

          if (newAddress != null) {
            // Update the address in parent widget
            widget.onAddressChanged(newAddress);
            // You might need to refresh addresses here
          }
        },
      ),
    );
  }

  Future<void> _loadAddresses() async {
    final loadedAddresses = await _addressService.getAddresses();
    setState(() {
      _addresses = loadedAddresses;
    });
  }

  void _applyCoupon() {
    final couponCode = _couponController.text.trim().toUpperCase();

    final error =
        Validators.validateCoupon(couponCode, AppConstants.availableCoupons);
    if (error != null) {
      _showError(error);
      return;
    }

    final discount = AppConstants.availableCoupons[couponCode]!;
    double discountAmount = 0.0;

    if (discount <= 1.0) {
      discountAmount = cartService.totalPrice * discount;
    } else {
      discountAmount = discount;
    }

    final maxDiscount = cartService.totalPrice * 0.9;
    if (discountAmount > maxDiscount) {
      discountAmount = maxDiscount;
    }

    setState(() {
      _appliedCoupon = couponCode;
      _discountAmount = discountAmount;
      _couponController.clear();
      cartService.applyDiscount(discountAmount, couponCode);
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
      cartService.removeDiscount();
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

  void _processPayment() async {
    if (cartService.items.isEmpty) {
      _showError("Your cart is empty");
      return;
    }

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
              "₹${cartService.finalTotal.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    if (widget.onPaymentComplete != null) {
      widget.onPaymentComplete!();
    }

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
                  "Order Total: ₹${cartService.finalTotal.toStringAsFixed(2)}\n"
                  "Items: ${cartService.itemCount}",
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
                  backgroundColor: AppConstants.primaryColor,
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
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }
}
