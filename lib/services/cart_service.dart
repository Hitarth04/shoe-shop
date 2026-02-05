import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_model.dart';
import '../models/cart_model.dart';
import '../utils/constants.dart';

class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final CartData _cartData = CartData();

  // Getters for UI
  List<CartItem> get items => _cartData.items;
  double get discountAmount => _cartData.discountAmount;
  String? get appliedCoupon => _cartData.appliedCoupon;

  // Helper: Get current User ID
  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  // Helper: Get Firestore Reference (users -> uid -> cart)
  CollectionReference? get _cartRef {
    if (_userId == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('cart');
  }

  // --- 1. INITIALIZE (Load from Firebase) ---
  Future<void> initialize() async {
    await _loadCart();
  }

  Future<void> _loadCart() async {
    if (_userId == null) {
      _cartData.items = [];
      return;
    }

    try {
      final snapshot = await _cartRef!.get();
      List<CartItem> loadedItems = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // COMPATIBILITY FIX:
        // New items have 'productId' field. Old items used doc.id as productId.
        final String productId = data['productId'] ?? doc.id;
        final String size = data['size'] ?? 'N/A'; // Default for old items
        final int quantity = data['quantity'] ?? 1;

        // Fetch product details
        final productDoc = await FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .get();

        if (productDoc.exists) {
          loadedItems.add(CartItem(
            product: Product.fromFirestore(productDoc),
            quantity: quantity,
            size: size, // <--- LOAD SIZE
          ));
        }
      }

      _cartData.items = loadedItems;
    } catch (e) {
      print("Error loading cart: $e");
      _cartData.items = [];
    }
  }

  // --- 2. ADD TO CART (Now requires Size) ---
  Future<void> addToCart(Product product, String size,
      {int quantity = 1}) async {
    if (_cartRef == null) return;

    // 1. Update Local State (Check ID AND Size)
    final existingIndex = _cartData.items.indexWhere(
        (item) => item.product.id == product.id && item.size == size);

    if (existingIndex >= 0) {
      _cartData.items[existingIndex].quantity += quantity;
    } else {
      _cartData.items
          .add(CartItem(product: product, quantity: quantity, size: size));
    }

    // 2. Update Firestore
    // Use Composite ID: 'productId_size' to allow duplicates of same shoe
    final String docId = '${product.id}_$size';

    await _cartRef!.doc(docId).set({
      'productId': product.id,
      'size': size,
      'quantity': FieldValue.increment(quantity),
      'addedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // --- 3. UPDATE QUANTITY ---
  Future<void> updateQuantity(
      Product product, String size, int quantity) async {
    if (_cartRef == null) return;

    final index = _cartData.items.indexWhere(
        (item) => item.product.id == product.id && item.size == size);

    if (index >= 0) {
      if (quantity <= 0) {
        await removeItem(product, size);
      } else {
        // Update Local
        _cartData.items[index].quantity = quantity;

        // Update Firestore (Using Composite ID)
        final String docId = '${product.id}_$size';
        await _cartRef!.doc(docId).update({
          'quantity': quantity,
        });
      }
    }
  }

  // --- 4. REMOVE ITEM ---
  Future<void> removeItem(Product product, String size) async {
    if (_cartRef == null) return;

    // Remove Local
    _cartData.items.removeWhere(
        (item) => item.product.id == product.id && item.size == size);

    // Remove Firestore
    final String docId = '${product.id}_$size';
    await _cartRef!.doc(docId).delete();
  }

  // --- HELPERS FOR UI (+ / - buttons) ---

  Future<void> increaseQuantity(CartItem item) async {
    await updateQuantity(item.product, item.size, item.quantity + 1);
  }

  Future<void> decreaseQuantity(CartItem item) async {
    if (item.quantity > 1) {
      await updateQuantity(item.product, item.size, item.quantity - 1);
    } else {
      await removeItem(item.product, item.size);
    }
  }

  // --- 5. CLEAR CART ---
  Future<void> clearCart() async {
    if (_cartRef == null) return;

    _cartData.items.clear();
    _cartData.discountAmount = 0.0;
    _cartData.appliedCoupon = null;

    final snapshot = await _cartRef!.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // --- COUPON & CALCULATIONS (Unchanged) ---
  void applyDiscount(double amount, String coupon) {
    _cartData.discountAmount = amount;
    _cartData.appliedCoupon = coupon;
  }

  void removeDiscount() {
    _cartData.discountAmount = 0.0;
    _cartData.appliedCoupon = null;
  }

  double get totalPrice {
    return _cartData.items.fold(0.0, (sum, item) => sum + item.itemTotal);
  }

  double get shippingAmount {
    return totalPrice > 0 ? AppConstants.defaultShippingFee : 0.0;
  }

  double get taxAmount {
    return totalPrice * AppConstants.taxRate;
  }

  double get finalTotal {
    return totalPrice + shippingAmount + taxAmount - _cartData.discountAmount;
  }

  int get itemCount {
    return _cartData.items.fold(0, (sum, item) => sum + item.quantity);
  }
}
