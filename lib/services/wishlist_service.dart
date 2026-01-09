import '../models/product_model.dart';
import '../models/wishlist_model.dart';

class WishlistService {
  static final WishlistService _instance = WishlistService._internal();
  factory WishlistService() => _instance;
  WishlistService._internal();

  WishlistData _wishlistData = WishlistData();

  List<Product> get items => _wishlistData.items;

  void addToWishlist(Product product) {
    if (!_wishlistData.items.any((item) => item.id == product.id)) {
      _wishlistData.items.add(product);
      product.isWishlisted = true;
    }
  }

  void removeFromWishlist(Product product) {
    _wishlistData.items.removeWhere((item) => item.id == product.id);
    product.isWishlisted = false;
  }

  bool contains(Product product) {
    return _wishlistData.items.any((item) => item.id == product.id);
  }

  void toggleWishlist(Product product) {
    if (contains(product)) {
      removeFromWishlist(product);
    } else {
      addToWishlist(product);
    }
  }

  void clear() {
    for (var product in _wishlistData.items) {
      product.isWishlisted = false;
    }
    _wishlistData.items.clear();
  }

  int get count => _wishlistData.items.length;
}
