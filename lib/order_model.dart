import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'product_model.dart';
import 'cart_model.dart';

class Order {
  final String orderId;
  final DateTime orderDate;
  final List<CartItem> items;
  final double totalAmount;
  final String status;
  final Address? shippingAddress;

  Order({
    required this.orderId,
    required this.orderDate,
    required this.items,
    required this.totalAmount,
    required this.status,
    this.shippingAddress,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'orderDate': orderDate.toIso8601String(),
      'items': items
          .map((item) => {
                'product_name': item.product.name,
                'quantity': item.quantity,
                'product_price': item.product.price,
                'product_image': item.product.image,
              })
          .toList(),
      'totalAmount': totalAmount,
      'status': status,
      'shippingAddress': shippingAddress?.toJson(),
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'],
      orderDate: DateTime.parse(json['orderDate']),
      items: (json['items'] as List).map((item) {
        return CartItem(
          product: Product(
            name: item['product_name'],
            price: item['product_price'],
            image: item['product_image'],
            description: '',
            isWishlisted: false,
          ),
          quantity: item['quantity'],
        );
      }).toList(),
      totalAmount: json['totalAmount'],
      status: json['status'],
      shippingAddress: json['shippingAddress'] != null
          ? Address.fromJson(json['shippingAddress'])
          : null,
    );
  }
}

class Address {
  final String id;
  final String tag;
  final String fullName;
  final String phone;
  final String street;
  final String city;
  final String state;
  final String pincode;
  final bool isDefault;

  Address({
    required this.id,
    required this.tag,
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    required this.state,
    required this.pincode,
    this.isDefault = false,
  });

  String get fullAddress {
    return '$street, $city, $state - $pincode';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tag': tag,
      'fullName': fullName,
      'phone': phone,
      'street': street,
      'city': city,
      'state': state,
      'pincode': pincode,
      'isDefault': isDefault,
    };
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      tag: json['tag'],
      fullName: json['fullName'],
      phone: json['phone'],
      street: json['street'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
      isDefault: json['isDefault'] ?? false,
    );
  }
}

class OrderManager {
  static const String _ordersKey = 'user_orders';
  static const String _addressesKey = 'user_addresses';

  // Orders management
  static Future<void> saveOrder(Order order) async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson = prefs.getString(_ordersKey) ?? '[]';
    final List<dynamic> orders = json.decode(ordersJson);

    orders.add(order.toJson());
    await prefs.setString(_ordersKey, json.encode(orders));
  }

  static Future<List<Order>> getOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson = prefs.getString(_ordersKey);

    if (ordersJson == null) return [];

    try {
      final List<dynamic> ordersData = json.decode(ordersJson);
      return ordersData.map((orderJson) => Order.fromJson(orderJson)).toList();
    } catch (e) {
      return [];
    }
  }

  // Addresses management
  static Future<void> saveAddress(Address address) async {
    final prefs = await SharedPreferences.getInstance();
    final addressesJson = prefs.getString(_addressesKey) ?? '[]';
    final List<dynamic> addresses = json.decode(addressesJson);

    // If setting as default, remove default from others
    if (address.isDefault) {
      for (var addr in addresses) {
        addr['isDefault'] = false;
      }
    }

    addresses.add(address.toJson());
    await prefs.setString(_addressesKey, json.encode(addresses));
  }

  static Future<List<Address>> getAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final addressesJson = prefs.getString(_addressesKey);

    if (addressesJson == null) return [];

    try {
      final List<dynamic> addressesData = json.decode(addressesJson);
      return addressesData
          .map((addrJson) => Address.fromJson(addrJson))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> deleteAddress(String addressId) async {
    final prefs = await SharedPreferences.getInstance();
    final addressesJson = prefs.getString(_addressesKey) ?? '[]';
    final List<dynamic> addresses = json.decode(addressesJson);

    addresses.removeWhere((addr) => addr['id'] == addressId);
    await prefs.setString(_addressesKey, json.encode(addresses));
  }

  static Future<void> setDefaultAddress(String addressId) async {
    final prefs = await SharedPreferences.getInstance();
    final addressesJson = prefs.getString(_addressesKey) ?? '[]';
    final List<dynamic> addresses = json.decode(addressesJson);

    for (var addr in addresses) {
      addr['isDefault'] = addr['id'] == addressId;
    }

    await prefs.setString(_addressesKey, json.encode(addresses));
  }
}
