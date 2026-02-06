import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order_model.dart';

class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference? get _ordersRef {
    if (_userId == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('orders');
  }

  Future<void> saveOrder(Order order) async {
    if (_ordersRef == null) return;
    try {
      // FIX: Inject the REAL userId into the map before saving
      final orderMap = order.toMap();
      orderMap['userId'] = _userId; // <--- This ensures it is never empty

      await _ordersRef!.doc(order.orderId).set(orderMap);
    } catch (e) {
      print("Error saving order: $e");
      rethrow;
    }
  }

  Future<List<Order>> getOrders() async {
    if (_ordersRef == null) return [];
    try {
      final snapshot =
          await _ordersRef!.orderBy('orderDate', descending: true).get();
      return snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList();
    } catch (e) {
      print("CRITICAL ERROR fetching orders: $e");
      return [];
    }
  }
}
