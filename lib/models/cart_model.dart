import 'product_model.dart';

class CartItem {
  final Product product;
  int quantity;
  final String size;

  CartItem({
    required this.product,
    this.quantity = 1,
    required this.size,
  });

  double get itemTotal {
    final price =
        double.parse(product.price.replaceAll(RegExp(r'[^0-9.]'), ''));
    return price * quantity;
  }
}

// Cart Data Model only
class CartData {
  List<CartItem> items = [];
  double discountAmount = 0.0;
  String? appliedCoupon;
}
