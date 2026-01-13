import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order_model.dart';
import '../models/address_model.dart';
import '../models/product_model.dart';
import '../utils/constants.dart';
import '../models/cart_model.dart';

class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  Future<void> saveOrder(Order order) async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson = prefs.getString(AppConstants.ordersKey) ?? '[]';
    final List<dynamic> orders = json.decode(ordersJson);

    orders.add({
      'orderId': order.orderId,
      'orderDate': order.orderDate.toIso8601String(),
      'items': order.items.map((item) {
        return {
          'product_id': item.product.id,
          'quantity': item.quantity,
        };
      }).toList(),
      'subtotalAmount': order.subtotalAmount,
      'shippingAmount': order.shippingAmount,
      'taxAmount': order.taxAmount,
      'discountAmount': order.discountAmount,
      'totalAmount': order.totalAmount,
      'status': order.status,
      'shippingAddress': {
        'id': order.shippingAddress.id,
        'tag': order.shippingAddress.tag,
        'fullName': order.shippingAddress.fullName,
        'phone': order.shippingAddress.phone,
        'street': order.shippingAddress.street,
        'city': order.shippingAddress.city,
        'state': order.shippingAddress.state,
        'pincode': order.shippingAddress.pincode,
        'isDefault': order.shippingAddress.isDefault,
      },
      'appliedCoupon': order.appliedCoupon,
    });

    await prefs.setString(AppConstants.ordersKey, json.encode(orders));
  }

  Future<List<Order>> getOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson = prefs.getString(AppConstants.ordersKey);

    if (ordersJson == null) return [];

    try {
      final List<dynamic> ordersData = json.decode(ordersJson);
      return ordersData.map((orderJson) {
        return Order(
          orderId: orderJson['orderId'],
          orderDate: DateTime.parse(orderJson['orderDate']),
          items: (orderJson['items'] as List).map((item) {
            final product = ProductManager.products.firstWhere(
              (p) => p.id == item['product_id'],
              orElse: () => ProductManager.products[0],
            );
            return CartItem(
              product: product,
              quantity: item['quantity'],
            );
          }).toList(),
          subtotalAmount: (orderJson['subtotalAmount'] ?? 0).toDouble(),
          shippingAmount: (orderJson['shippingAmount'] ?? 0).toDouble(),
          taxAmount: (orderJson['taxAmount'] ?? 0).toDouble(),
          discountAmount: (orderJson['discountAmount'] ?? 0).toDouble(),
          totalAmount: orderJson['totalAmount'].toDouble(),
          status: orderJson['status'],
          shippingAddress: Address(
            id: orderJson['shippingAddress']['id'],
            tag: orderJson['shippingAddress']['tag'],
            fullName: orderJson['shippingAddress']['fullName'],
            phone: orderJson['shippingAddress']['phone'],
            street: orderJson['shippingAddress']['street'],
            city: orderJson['shippingAddress']['city'],
            state: orderJson['shippingAddress']['state'],
            pincode: orderJson['shippingAddress']['pincode'],
            isDefault: orderJson['shippingAddress']['isDefault'] ?? false,
          ),
          appliedCoupon: orderJson['appliedCoupon'],
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
