class Product {
  final String name;
  final String image;
  final String price;
  final String description;
  bool isWishlisted;

  Product({
    required this.name,
    required this.image,
    required this.price,
    required this.description,
    this.isWishlisted = false,
  });
}
