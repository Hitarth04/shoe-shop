import 'product_model.dart';

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
  static final List<CartItem> items = [];
  static double discountAmount = 0.0;
  static String? appliedCoupon;

  /// Add product
  static void addToCart(Product product) {
    final index = items.indexWhere((item) => item.product.name == product.name);

    if (index >= 0) {
      items[index].quantity++;
    } else {
      items.add(CartItem(product: product));
    }
  }

  /// 🔴 Delete item
  static void removeItem(Product product) {
    items.removeWhere((item) => item.product.name == product.name);
  }

  /// ➕ Increase quantity
  static void increaseQty(Product product) {
    final item = items.firstWhere((item) => item.product.name == product.name);
    item.quantity++;
  }

  /// ➖ Decrease quantity
  static void decreaseQty(Product product) {
    final index = items.indexWhere((item) => item.product.name == product.name);
    if (index >= 0) {
      if (items[index].quantity > 1) {
        items[index].quantity--;
      } else {
        items.removeAt(index); // Remove when quantity reaches 0
      }
    }
  }

  /// 💰 Get cart subtotal (before discount)
  static double get totalPrice {
    return items.fold(0.0, (sum, item) => sum + item.itemTotal);
  }

  /// 🎫 Get final total (after discount)
  static double get finalTotal {
    final subtotal = totalPrice;
    final shipping = subtotal > 0 ? 30.0 : 0.0;
    return subtotal + shipping - discountAmount;
  }

  /// 📦 Get item count
  static int get itemCount {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  /// 🗑️ Clear cart and reset discount
  static void clearCart() {
    items.clear();
    discountAmount = 0.0;
    appliedCoupon = null;
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
}
