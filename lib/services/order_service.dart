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
      // UPDATED: Save full product details so we don't need to look them up later
      'items': order.items.map((item) {
        return {
          'product_id': item.product.id,
          'product_name': item.product.name,
          'product_price': item.product.price,
          'product_image': item.product.image,
          'product_desc': item.product.description,
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
            // UPDATED: Reconstruct Product from saved history data
            // This prevents "Undefined ProductManager" errors
            final product = Product(
              id: item['product_id'] ?? 'unknown',
              name: item['product_name'] ?? 'Unknown Product',
              price: item['product_price'] ?? '₹0',
              image: item['product_image'] ?? 'assets/images/shoes.png',
              description: item['product_desc'] ?? '',
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
          totalAmount: (orderJson['totalAmount'] ?? 0).toDouble(),
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
      print("Error parsing orders: $e");
      return [];
    }
  }
}
