import 'product_model.dart';

class Wishlist {
  static final List<Product> _items = [];

  static List<Product> get items => _items;

  /// Add product to wishlist
  static void addToWishlist(Product product) {
    if (!_items.contains(product)) {
      // Create a copy with wishlisted flag
      final wishlistedProduct = Product(
        name: product.name,
        image: product.image,
        price: product.price,
        description: product.description,
        isWishlisted: true,
      );
      _items.add(wishlistedProduct);

      // Update the original product's wishlist status
      product.isWishlisted = true;
    }
  }

  /// Remove product from wishlist
  static void removeFromWishlist(Product product) {
    _items.removeWhere((item) => item.name == product.name);

    // Update the original product's wishlist status
    product.isWishlisted = false;
  }

  /// Check if product is in wishlist
  static bool contains(Product product) {
    return _items.any((item) => item.name == product.name);
  }

  /// Toggle wishlist status
  static void toggleWishlist(Product product) {
    if (contains(product)) {
      removeFromWishlist(product);
    } else {
      addToWishlist(product);
    }
  }

  /// Clear wishlist
  static void clear() {
    _items.clear();

    // Reset all products' wishlist status
    // You'll need to update this based on how you manage products
  }

  /// Get wishlist count
  static int get count => _items.length;
}
