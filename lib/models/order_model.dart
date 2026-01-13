import 'cart_model.dart';
import 'address_model.dart';

class Order {
  final String orderId;
  final DateTime orderDate;
  final List<CartItem> items;
  final double subtotalAmount;
  final double shippingAmount;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final String status;
  final Address shippingAddress;
  final String? appliedCoupon;

  Order({
    required this.orderId,
    required this.orderDate,
    required this.items,
    required this.subtotalAmount,
    required this.shippingAmount,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.status,
    required this.shippingAddress,
    this.appliedCoupon,
  });
}
