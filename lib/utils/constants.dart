import 'package:flutter/material.dart';

class AppConstants {
  // Colors
  static const primaryColor = Color(0xFF5B5FDC);
  static const backgroundColor = Colors.white;

  // SharedPreferences keys
  static const cartKey = 'shopping_cart';
  static const ordersKey = 'user_orders';
  static const addressesKey = 'user_addresses';

  // Default values
  static const defaultShippingFee = 30.0;
  static const taxRate = 0.18;

  // Address tags
  static const addressTags = ['Home', 'Work', 'Other'];

  // Available coupons
  static const availableCoupons = {
    'SAVE10': 0.10,
    'SAVE20': 0.20,
    'WELCOME50': 50.0,
    'FREESHIP': 30.0,
  };

  // Payment methods
  static const paymentMethods = {
    'credit_card': 'Credit/Debit Card',
    'upi': 'UPI',
    'cod': 'Cash on Delivery',
    'net_banking': 'Net Banking',
  };
}
