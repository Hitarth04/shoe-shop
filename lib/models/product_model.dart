class Product {
  final String id;
  final String name;
  final String image;
  final String price;
  final String description;
  bool isWishlisted;

  Product({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.description,
    this.isWishlisted = false,
  });
}

// Product Manager - Just holds product data
class ProductManager {
  static final List<Product> products = [
    Product(
      id: '1',
      name: "Nike Air Max",
      image: "assets/images/shoes.png",
      price: "₹4,999",
      description: "Dynamic Air unit system...",
    ),
    Product(
      id: '2',
      name: "Adidas Ultraboost",
      image: "assets/images/shoes2.png",
      price: "₹1,499",
      description: "Balanced cushioning and flexibility...",
    ),
    Product(
      id: '3',
      name: "Puma RS-X",
      image: "assets/images/shoes3.png",
      price: "₹7,999",
      description: "RS-X is back. This future-retro silhouette...",
    ),
    Product(
      id: '4',
      name: "New Balance 574",
      image: "assets/images/shoes4.png",
      price: "₹9,299",
      description: "The most New Balance shoe ever...",
    ),
    Product(
      id: '5',
      name: "Nike Air Max",
      image: "assets/images/shoes.png",
      price: "₹8,999",
      description: "Dynamic Air unit system...",
    ),
    Product(
      id: '6',
      name: "Adidas Ultraboost",
      image: "assets/images/shoes2.png",
      price: "₹11,499",
      description: "Balanced cushioning and flexibility...",
    ),
    Product(
      id: '7',
      name: "Puma RS-X",
      image: "assets/images/shoes3.png",
      price: "₹8,999",
      description: "RS-X is back. This future-retro silhouette...",
    ),
    Product(
      id: '8',
      name: "New Balance 574",
      image: "assets/images/shoes4.png",
      price: "₹999",
      description: "The most New Balance shoe ever...",
    ),
    Product(
      id: '9',
      name: "New Balance 550",
      image: "assets/images/shoes4.png",
      price: "₹1,999",
      description: "The most New Balance shoe ever...",
    ),
    Product(
      id: '10',
      name: "New Balance 590",
      image: "assets/images/shoes4.png",
      price: "₹2,999",
      description: "The most New Balance shoe ever...",
    ),
  ];

  static Product getProductByName(String name) {
    return products.firstWhere((product) => product.name == name);
  }
}
