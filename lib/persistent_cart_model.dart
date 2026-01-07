import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'product_model.dart';
import 'cart_model.dart';

class PersistentCart {
  static const String _cartKey = 'shopping_cart';

  static Future<void> saveCart(List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = items.map((item) {
      return {
        'product_name': item.product.name,
        'quantity': item.quantity,
        'product_price': item.product.price,
        'product_image': item.product.image,
        'product_description': item.product.description,
      };
    }).toList();

    await prefs.setString(_cartKey, json.encode(cartData));
  }

  static Future<List<CartItem>> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString(_cartKey);

    if (cartJson == null) return [];

    try {
      final List<dynamic> cartData = json.decode(cartJson);
      return cartData.map((item) {
        return CartItem(
          product: Product(
            name: item['product_name'],
            price: item['product_price'],
            image: item['product_image'],
            description: item['product_description'],
          ),
          quantity: item['quantity'],
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }
}
