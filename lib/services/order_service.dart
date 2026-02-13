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
      final orderMap = order.toMap();
      orderMap['userId'] = _userId;
      await _ordersRef!.doc(order.orderId).set(orderMap);
    } catch (e) {
      print("Error saving order: $e");
      rethrow;
    }
  }

  // --- NEW: REAL-TIME STREAM ---
  Stream<List<Order>> getOrdersStream() {
    if (_ordersRef == null) return Stream.value([]);

    return _ordersRef!
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            try {
              // Use our safe parser
              return Order.fromFirestore(doc);
            } catch (e) {
              print("Error parsing order ${doc.id}: $e");
              return null;
            }
          })
          .whereType<Order>()
          .toList();
    });
  }
}
