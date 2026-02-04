import 'package:flutter/material.dart';

class AppConstants {
  // Colors
  // static const primaryColor = Color.fromARGB(255, 91, 95, 220);
  // static const backgroundColor = Colors.white;
  // static const primaryColor = Color(0xFFFF5722); // Vibrant Deep Orange
  // static const backgroundColor = Color(0xFFFAFAFA); // Crisp Off-White

  static const primaryColor = Color(0xFF2A2D43); // Deep Navy (AppBars, Headers)
  static const secondaryColor = Color(0xFFFF6B6B); // Coral (CTAs, Buy Buttons)
  static const accentColor = Color(0xFF4ECDC4); // Teal (Price, Success)

  static const backgroundColor = Color(0xFFF5F3FF); // Off-White Background
  static const surfaceColor = Color(0xFFF5F5F5); // Cards

  static const textPrimary = Color(0xFF2D3436); // Dark Gray Text
  static const textSecondary = Color(0xFF636E72); // Medium Gray Text

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
