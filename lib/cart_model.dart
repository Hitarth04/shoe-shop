import 'product_model.dart';
import 'persistent_cart_model.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  // Helper to get item total
  double get itemTotal {
    try {
      final price =
          double.parse(product.price.replaceAll(RegExp(r'[^0-9.]'), ''));
      return price * quantity;
    } catch (e) {
      return 0.0;
    }
  }
}

class Cart {
  static List<CartItem> _items = [];
  static double discountAmount = 0.0;
  static String? appliedCoupon;

  // Getter for items
  static List<CartItem> get items => _items;

  /// Initialize cart from persistent storage
  static Future<void> initialize() async {
    _items = await PersistentCart.loadCart();
  }

  /// Save cart to persistent storage
  static Future<void> _saveCart() async {
    await PersistentCart.saveCart(_items);
  }

  /// Add product
  static Future<void> addToCart(Product product) async {
    final index =
        _items.indexWhere((item) => item.product.name == product.name);

    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }

    await _saveCart();
  }

  /// 🔴 Delete item
  static Future<void> removeItem(Product product) async {
    _items.removeWhere((item) => item.product.name == product.name);
    await _saveCart();
  }

  /// ➕ Increase quantity
  static Future<void> increaseQty(Product product) async {
    final item = _items.firstWhere((item) => item.product.name == product.name);
    item.quantity++;
    await _saveCart();
  }

  /// ➖ Decrease quantity
  static Future<void> decreaseQty(Product product) async {
    final index =
        _items.indexWhere((item) => item.product.name == product.name);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index); // Remove when quantity reaches 0
      }
    }
    await _saveCart();
  }

  /// 💰 Get cart subtotal (before discount)
  static double get totalPrice {
    return _items.fold(0.0, (sum, item) => sum + item.itemTotal);
  }

  /// 🧾 Get tax amount (18%)
  static double get taxAmount {
    return totalPrice * 0.18;
  }

  /// 🚚 Get shipping amount
  static double get shippingAmount {
    return totalPrice > 0 ? 30.0 : 0.0;
  }

  /// 🎫 Get final total (after discount and tax)
  static double get finalTotal {
    final subtotal = totalPrice;
    final shipping = shippingAmount;
    final tax = taxAmount;
    return subtotal + shipping + tax - discountAmount;
  }

  /// 📦 Get item count
  static int get itemCount {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  /// 🗑️ Clear cart and reset discount
  static Future<void> clearCart() async {
    _items.clear();
    discountAmount = 0.0;
    appliedCoupon = null;
    await PersistentCart.clearCart();
  }

  /// 🎫 Apply discount
  static void applyDiscount(double amount, String coupon) {
    discountAmount = amount;
    appliedCoupon = coupon;
  }

  /// 🎫 Remove discount
  static void removeDiscount() {
    discountAmount = 0.0;
    appliedCoupon = null;
  }

  // New helper methods from the new implementation

  /// Alternative add method with quantity parameter
  static Future<void> addToCartWithQuantity(Product product,
      {int quantity = 1}) async {
    final existingIndex =
        _items.indexWhere((item) => item.product.name == product.name);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }

    await _saveCart();
  }

  /// Update quantity directly
  static Future<void> updateQuantity(Product product, int quantity) async {
    final index =
        _items.indexWhere((item) => item.product.name == product.name);

    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
    }

    await _saveCart();
  }

  // /// Get total amount (alternative calculation)
  // static double get totalAmount {
  //   return _items.fold(0.0, (total, item) {
  //     return total + item.itemTotal;
  //   });
  // }
}
