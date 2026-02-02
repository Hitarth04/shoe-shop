import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';
import '../models/cart_model.dart';
import '../utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  CartData _cartData = CartData();

  List<CartItem> get items => _cartData.items;
  double get discountAmount => _cartData.discountAmount;
  String? get appliedCoupon => _cartData.appliedCoupon;

  Future<void> initialize() async {
    await _loadCart();
  }

  // --- UPDATED METHOD ---
  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString(AppConstants.cartKey);

    if (cartJson != null) {
      try {
        final List<dynamic> cartData = json.decode(cartJson);
        List<CartItem> loadedItems = [];

        // Loop through saved IDs and fetch latest data from Firestore
        for (var item in cartData) {
          try {
            final doc = await FirebaseFirestore.instance
                .collection('products')
                .doc(item['product_id'])
                .get();

            if (doc.exists) {
              loadedItems.add(CartItem(
                product: Product.fromFirestore(doc),
                quantity: item['quantity'],
              ));
            }
          } catch (e) {
            print("Error loading cart item: $e");
          }
        }
        _cartData.items = loadedItems;
      } catch (e) {
        _cartData.items = [];
      }
    }
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = _cartData.items.map((item) {
      return {
        'product_id': item.product.id,
        'quantity': item.quantity,
      };
    }).toList();

    await prefs.setString(AppConstants.cartKey, json.encode(cartData));
  }

  Future<void> addToCart(Product product, {int quantity = 1}) async {
    final existingIndex =
        _cartData.items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      _cartData.items[existingIndex].quantity += quantity;
    } else {
      _cartData.items.add(CartItem(product: product, quantity: quantity));
    }

    await _saveCart();
  }

  Future<void> updateQuantity(Product product, int quantity) async {
    final index =
        _cartData.items.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      if (quantity <= 0) {
        _cartData.items.removeAt(index);
      } else {
        _cartData.items[index].quantity = quantity;
      }
      await _saveCart();
    }
  }

  Future<void> removeItem(Product product) async {
    _cartData.items.removeWhere((item) => item.product.id == product.id);
    await _saveCart();
  }

  Future<void> increaseQuantity(Product product) async {
    await updateQuantity(
        product,
        _cartData.items
                .firstWhere((item) => item.product.id == product.id)
                .quantity +
            1);
  }

  Future<void> decreaseQuantity(Product product) async {
    final item =
        _cartData.items.firstWhere((item) => item.product.id == product.id);
    if (item.quantity > 1) {
      await updateQuantity(product, item.quantity - 1);
    } else {
      await removeItem(product);
    }
  }

  Future<void> clearCart() async {
    _cartData.items.clear();
    _cartData.discountAmount = 0.0;
    _cartData.appliedCoupon = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.cartKey);
  }

  void applyDiscount(double amount, String coupon) {
    _cartData.discountAmount = amount;
    _cartData.appliedCoupon = coupon;
  }

  void removeDiscount() {
    _cartData.discountAmount = 0.0;
    _cartData.appliedCoupon = null;
  }

  // Calculations
  double get totalPrice {
    return _cartData.items.fold(0.0, (sum, item) => sum + item.itemTotal);
  }

  double get shippingAmount {
    return totalPrice > 0 ? AppConstants.defaultShippingFee : 0.0;
  }

  double get taxAmount {
    return totalPrice * AppConstants.taxRate;
  }

  double get finalTotal {
    return totalPrice + shippingAmount + taxAmount - _cartData.discountAmount;
  }

  int get itemCount {
    return _cartData.items.fold(0, (sum, item) => sum + item.quantity);
  }
}
