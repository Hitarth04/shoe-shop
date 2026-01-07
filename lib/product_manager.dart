import 'product_model.dart';

class ProductManager {
  static final List<Product> _products = [
    Product(
        name: "Nike Air Max",
        image: "assets/images/shoes.png",
        price: "₹8,999",
        description:
            'Dynamic Air unit system: Features dual-pressure tubes with varied pressure in the heel and midfoot for a reactive and smooth stepping sensation.'),
    Product(
        name: "Adidas Ultraboost",
        image: "assets/images/shoes2.png",
        price: "₹11,499",
        description:
            'Balanced cushioning and flexibility: These shoes offer a perfect equilibrium between cushioning for soft landings and flexibility for a natural running motion.'),
    Product(
        name: "Puma RS-X",
        image: "assets/images/shoes3.png",
        price: "₹7,999",
        description:
            "RS-X is back. This future-retro silhouette made waves when it dropped in 2018, celebrated for its disruptive design, fresh material mixes, and bold colours. Today, RS-X returns for a new generation of consumers who live to express their individuality. It's here to start a revolution of self-expression. This version features a mesh upper, synthetic overlays, and reflective details."),
    Product(
        name: "New Balance 574",
        image: "assets/images/shoes4.png",
        price: "₹9,299",
        description:
            "The most New Balance shoe ever’ says it all, right? No, actually. The 574 might be our unlikeliest icon. The 574 was built to be a reliable shoe that could do a lot of different things well rather than as a platform for revolutionary technology, or as a premium materials showcase. This unassuming, unpretentious versatility is exactly what launched the 574 into the ranks of all-time greats."),
    Product(
        name: "Nike Air Max",
        image: "assets/images/shoes.png",
        price: "₹8,999",
        description:
            'Dynamic Air unit system: Features dual-pressure tubes with varied pressure in the heel and midfoot for a reactive and smooth stepping sensation.'),
    Product(
        name: "Adidas Ultraboost",
        image: "assets/images/shoes2.png",
        price: "₹11,499",
        description:
            'Balanced cushioning and flexibility: These shoes offer a perfect equilibrium between cushioning for soft landings and flexibility for a natural running motion.'),
    Product(
        name: "Puma RS-X",
        image: "assets/images/shoes3.png",
        price: "₹7,999",
        description:
            "RS-X is back. This future-retro silhouette made waves when it dropped in 2018, celebrated for its disruptive design, fresh material mixes, and bold colours. Today, RS-X returns for a new generation of consumers who live to express their individuality. It's here to start a revolution of self-expression. This version features a mesh upper, synthetic overlays, and reflective details."),
    Product(
        name: "New Balance 574",
        image: "assets/images/shoes4.png",
        price: "₹9,299",
        description:
            "The most New Balance shoe ever’ says it all, right? No, actually. The 574 might be our unlikeliest icon. The 574 was built to be a reliable shoe that could do a lot of different things well rather than as a platform for revolutionary technology, or as a premium materials showcase. This unassuming, unpretentious versatility is exactly what launched the 574 into the ranks of all-time greats."),
  ];

  static List<Product> get products => _products;

  static Product getProductByName(String name) {
    return _products.firstWhere((product) => product.name == name);
  }

  static void updateProductWishlistStatus(String name, bool isWishlisted) {
    final product = _products.firstWhere((p) => p.name == name);
    product.isWishlisted = isWishlisted;
  }
}
