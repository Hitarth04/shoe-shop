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
      // Fetch all documents from the user's cart collection
      final snapshot = await _cartRef!.get();
      List<CartItem> loadedItems = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final String productId = doc.id; // Doc ID is the Product ID
        final int quantity = data['quantity'] ?? 1;

        // Fetch the LIVE product details (Name, Price, Image) from the 'products' collection
        final productDoc = await FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .get();

        if (productDoc.exists) {
          loadedItems.add(CartItem(
            product: Product.fromFirestore(productDoc),
            quantity: quantity,
          ));
        }
      }

      _cartData.items = loadedItems;
    } catch (e) {
      print("Error loading cart: $e");
      _cartData.items = [];
    }
  }

  // --- 2. ADD TO CART ---
  Future<void> addToCart(Product product, {int quantity = 1}) async {
    if (_cartRef == null) return;

    // Update Local State (Instant UI Feedback)
    final existingIndex =
        _cartData.items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      _cartData.items[existingIndex].quantity += quantity;
    } else {
      _cartData.items.add(CartItem(product: product, quantity: quantity));
    }

    // Update Firestore
    // We use merge: true so it creates the doc if it doesn't exist
    await _cartRef!.doc(product.id).set({
      'quantity': FieldValue.increment(quantity),
      'addedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // --- 3. UPDATE QUANTITY ---
  Future<void> updateQuantity(Product product, int quantity) async {
    if (_cartRef == null) return;

    final index =
        _cartData.items.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      if (quantity <= 0) {
        await removeItem(product); // Remove if 0
      } else {
        // Update Local
        _cartData.items[index].quantity = quantity;

        // Update Firestore
        await _cartRef!.doc(product.id).update({
          'quantity': quantity,
        });
      }
    }
  }

  // --- 4. REMOVE ITEM ---
  Future<void> removeItem(Product product) async {
    if (_cartRef == null) return;

    // Remove Local
    _cartData.items.removeWhere((item) => item.product.id == product.id);

    // Remove Firestore
    await _cartRef!.doc(product.id).delete();
  }

  Future<void> increaseQuantity(Product product) async {
    final item = _cartData.items.firstWhere(
      (item) => item.product.id == product.id,
      orElse: () => CartItem(product: product, quantity: 0),
    );

    if (item.quantity > 0) {
      await updateQuantity(product, item.quantity + 1);
    }
  }

  Future<void> decreaseQuantity(Product product) async {
    final item = _cartData.items.firstWhere(
      (item) => item.product.id == product.id,
      orElse: () => CartItem(product: product, quantity: 0),
    );

    if (item.quantity > 1) {
      await updateQuantity(product, item.quantity - 1);
    } else {
      await removeItem(product);
    }
  }

  // --- 5. CLEAR CART (After Checkout) ---
  Future<void> clearCart() async {
    if (_cartRef == null) return;

    // Clear Local
    _cartData.items.clear();
    _cartData.discountAmount = 0.0;
    _cartData.appliedCoupon = null;

    // Clear Firestore (Delete all docs in sub-collection)
    final snapshot = await _cartRef!.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // --- COUPON LOGIC (Kept Local for simplicity) ---
  void applyDiscount(double amount, String coupon) {
    _cartData.discountAmount = amount;
    _cartData.appliedCoupon = coupon;
  }

  void removeDiscount() {
    _cartData.discountAmount = 0.0;
    _cartData.appliedCoupon = null;
  }

  // --- CALCULATIONS ---
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
