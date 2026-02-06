import 'package:cloud_firestore/cloud_firestore.dart';
import 'address_model.dart';
import 'cart_model.dart';
import 'product_model.dart';

class Order {
  final String id;
  final String orderId;
  final String userId;
  final List<CartItem> items;
  final double totalAmount;
  final double subtotalAmount;
  final double shippingAmount;
  final double taxAmount;
  final double discountAmount;
  final Address shippingAddress;
  final String status;
  final DateTime orderDate;
  final String paymentMethod;
  final String paymentId;

  // NEW: Store the exact database path for Admin updates
  final String path;

  Order({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.subtotalAmount,
    required this.shippingAmount,
    required this.taxAmount,
    required this.discountAmount,
    required this.shippingAddress,
    required this.status,
    required this.orderDate,
    required this.paymentMethod,
    this.paymentId = '',
    this.path = '', // Default empty
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'totalAmount': totalAmount,
      'subtotalAmount': subtotalAmount,
      'shippingAmount': shippingAmount,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'status': status,
      'paymentMethod': paymentMethod,
      'paymentId': paymentId,
      'orderDate': Timestamp.fromDate(orderDate),
      'shippingAddress': {
        'fullName': shippingAddress.fullName,
        'phone': shippingAddress.phone,
        'street': shippingAddress.street,
        'city': shippingAddress.city,
        'state': shippingAddress.state,
        'pincode': shippingAddress.pincode,
        'tag': shippingAddress.tag,
      },
      'items': items
          .map((item) => {
                'productId': item.product.id,
                'name': item.product.name,
                'price': item.product.price,
                'image': item.product.image,
                'quantity': item.quantity,
                'size': item.size,
                'category': item.product.category,
              })
          .toList(),
    };
  }

  factory Order.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    double toDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.parse(val);
      return DateTime.now();
    }

    return Order(
      id: doc.id,
      // NEW: Save the document reference path!
      path: doc.reference.path,

      orderId: data['orderId'] ?? '',
      userId: data['userId'] ?? '',
      totalAmount: toDouble(data['totalAmount']),
      subtotalAmount: toDouble(data['subtotalAmount']),
      shippingAmount: toDouble(data['shippingAmount']),
      taxAmount: toDouble(data['taxAmount']),
      discountAmount: toDouble(data['discountAmount']),
      status: data['status'] ?? 'Processing',
      paymentMethod: data['paymentMethod'] ?? 'COD',
      paymentId: data['paymentId'] ?? '',
      orderDate: parseDate(data['orderDate']),
      shippingAddress: Address(
        id: '',
        tag: data['shippingAddress']['tag'] ?? 'Shipping',
        fullName: data['shippingAddress']['fullName'] ?? '',
        phone: data['shippingAddress']['phone'] ?? '',
        street: data['shippingAddress']['street'] ?? '',
        city: data['shippingAddress']['city'] ?? '',
        state: data['shippingAddress']['state'] ?? '',
        pincode: data['shippingAddress']['pincode'] ?? '',
        isDefault: false,
      ),
      items: (data['items'] as List<dynamic>).map((itemData) {
        return CartItem(
          product: Product(
            id: itemData['productId'] ?? '',
            name: itemData['name'] ?? 'Unknown',
            price: (itemData['price'] ?? '0').toString(),
            image: itemData['image'] ?? '',
            description: '',
            category: itemData['category'] ?? 'Other',
            sizes: [],
          ),
          quantity: itemData['quantity'] is int
              ? itemData['quantity']
              : int.tryParse(itemData['quantity'].toString()) ?? 1,
          size: itemData['size'] ?? 'N/A',
        );
      }).toList(),
    );
  }
}
