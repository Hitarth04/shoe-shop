import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';

class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  List<CartItem> _items = [];
  List<CartItem> get items => _items;

  // --- NEW: Add this Getter ---
  int get itemCount => _items.length;
  // ----------------------------

  double get totalPrice {
    return _items.fold(0, (sum, item) {
      // 1. Remove everything that is NOT a number or a decimal point
      // Replaces '₹', '$', ',', ' ' with empty string
      String cleanPrice = item.product.price.replaceAll(RegExp(r'[^0-9.]'), '');

      // 2. Parse the clean string
      double price = double.tryParse(cleanPrice) ?? 0.0;

      return sum + (price * item.quantity);
    });
  }

  double get shippingAmount => totalPrice > 500 ? 0 : 40;
  double get taxAmount => totalPrice * 0.18;

  double _discountAmount = 0.0;
  String? _appliedCoupon;

  double get discountAmount => _discountAmount;
  String? get appliedCoupon => _appliedCoupon;
  double get finalTotal =>
      (totalPrice + shippingAmount + taxAmount) - _discountAmount;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference? get _cartRef {
    if (_userId == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('cart');
  }

  Future<void> initialize() async {
    if (_cartRef == null) return;
    try {
      final snapshot = await _cartRef!.get();
      _items = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return CartItem(
          product: Product(
            id: data['productId'],
            name: data['name'],
            price: (data['price'] ?? '0').toString(),
            image: data['image'],
            description: '',
            category: data['category'] ?? '',
            sizes: [],
          ),
          quantity: data['quantity'],
          size: data['size'] ?? 'N/A',
        );
      }).toList();
    } catch (e) {
      print("Error loading cart: $e");
    }
  }

  Future<void> addToCart(Product product, String size) async {
    if (_cartRef == null) return;

    final existingIndex = _items.indexWhere(
        (item) => item.product.id == product.id && item.size == size);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(product: product, quantity: 1, size: size));
    }

    final docId = "${product.id}_$size";
    await _cartRef!.doc(docId).set({
      'productId': product.id,
      'name': product.name,
      'price': product.price,
      'image': product.image,
      'quantity': existingIndex >= 0 ? _items[existingIndex].quantity : 1,
      'size': size,
      'category': product.category,
    });
  }

  Future<void> decreaseQuantity(CartItem item) async {
    if (item.quantity > 1) {
      item.quantity--;
      final docId = "${item.product.id}_${item.size}";
      await _cartRef!.doc(docId).update({'quantity': item.quantity});
    } else {
      await removeItem(item.product, item.size);
    }
  }

  Future<void> increaseQuantity(CartItem item) async {
    item.quantity++;
    final docId = "${item.product.id}_${item.size}";
    await _cartRef!.doc(docId).update({'quantity': item.quantity});
  }

  Future<void> removeItem(Product product, String size) async {
    _items.removeWhere(
        (item) => item.product.id == product.id && item.size == size);
    final docId = "${product.id}_$size";
    await _cartRef!.doc(docId).delete();
  }

  Future<void> clearCart() async {
    if (_cartRef == null) return;
    final snapshot = await _cartRef!.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
    _items.clear();
    _discountAmount = 0.0;
    _appliedCoupon = null;
  }

  void applyDiscount(double amount, String code) {
    _discountAmount = amount;
    _appliedCoupon = code;
  }

  void removeDiscount() {
    _discountAmount = 0.0;
    _appliedCoupon = null;
  }
}
