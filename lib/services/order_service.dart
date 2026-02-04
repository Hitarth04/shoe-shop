import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order_model.dart';
import '../models/address_model.dart';
import '../models/product_model.dart';
import '../models/cart_model.dart';

class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  // Helper: Get Current User ID
  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  // Helper: Get Firestore Reference (users -> uid -> orders)
  CollectionReference? get _ordersRef {
    if (_userId == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('orders');
  }

  // --- 1. SAVE ORDER (Checkout) ---
  Future<void> saveOrder(Order order) async {
    if (_ordersRef == null) return;

    try {
      // We use .doc(order.orderId) so we can set our own custom ID (UUID)
      // instead of letting Firebase generate a random one.
      await _ordersRef!.doc(order.orderId).set({
        'orderId': order.orderId,
        'orderDate': order.orderDate.toIso8601String(),
        'status': order.status,
        'totalAmount': order.totalAmount,
        'subtotalAmount': order.subtotalAmount,
        'shippingAmount': order.shippingAmount,
        'taxAmount': order.taxAmount,
        'discountAmount': order.discountAmount,
        'appliedCoupon': order.appliedCoupon,

        // Save Address Snapshot
        'shippingAddress': {
          'id': order.shippingAddress.id,
          'fullName': order.shippingAddress.fullName,
          'phone': order.shippingAddress.phone,
          'street': order.shippingAddress.street,
          'city': order.shippingAddress.city,
          'state': order.shippingAddress.state,
          'pincode': order.shippingAddress.pincode,
          'tag': order.shippingAddress.tag,
        },

        // Save Items Snapshot (Crucial for history!)
        'items': order.items.map((item) {
          return {
            'productId': item.product.id,
            'name': item.product.name,
            'price': item.product.price, // Save price AT TIME OF PURCHASE
            'image': item.product.image,
            'quantity': item.quantity,
          };
        }).toList(),
      });
    } catch (e) {
      print("Error saving order: $e");
      rethrow; // Pass error to UI to show alert
    }
  }

  // --- 2. GET ORDER HISTORY ---
  Future<List<Order>> getOrders() async {
    if (_ordersRef == null) return [];

    try {
      // Get orders sorted by date (newest first)
      final snapshot =
          await _ordersRef!.orderBy('orderDate', descending: true).get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        return Order(
          orderId: data['orderId'],
          orderDate: DateTime.parse(data['orderDate']),
          status: data['status'] ?? 'Processing',
          totalAmount: (data['totalAmount'] ?? 0).toDouble(),
          subtotalAmount: (data['subtotalAmount'] ?? 0).toDouble(),
          shippingAmount: (data['shippingAmount'] ?? 0).toDouble(),
          taxAmount: (data['taxAmount'] ?? 0).toDouble(),
          discountAmount: (data['discountAmount'] ?? 0).toDouble(),
          appliedCoupon: data['appliedCoupon'],

          // Reconstruct Address
          shippingAddress: Address(
            id: data['shippingAddress']['id'] ?? 'unknown',
            fullName: data['shippingAddress']['fullName'] ?? '',
            phone: data['shippingAddress']['phone'] ?? '',
            street: data['shippingAddress']['street'] ?? '',
            city: data['shippingAddress']['city'] ?? '',
            state: data['shippingAddress']['state'] ?? '',
            pincode: data['shippingAddress']['pincode'] ?? '',
            tag: data['shippingAddress']['tag'] ?? 'Home',
          ),

          // Reconstruct Items
          items: (data['items'] as List).map((item) {
            return CartItem(
              product: Product(
                id: item['productId'],
                name: item['name'],
                price: item['price'],
                image: item['image'],
                description: '', // Not needed for history list
                category: item['category'],
              ),
              quantity: item['quantity'],
            );
          }).toList(),
        );
      }).toList();
    } catch (e) {
      print("Error fetching orders: $e");
      return [];
    }
  }
}
