import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/product_model.dart';
import '../../utils/constants.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Products")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search by product name...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) =>
                  setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;
                final products = docs
                    .map((doc) => Product.fromFirestore(doc))
                    .where((product) {
                  return product.name.toLowerCase().contains(_searchQuery);
                }).toList();

                if (products.isEmpty)
                  return const Center(child: Text("No products found"));

                return ListView.separated(
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final product = products[index];

                    Widget imageWidget;
                    if (product.image.startsWith('http')) {
                      imageWidget = Image.network(product.image,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image));
                    } else {
                      imageWidget = Image.asset(product.image,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image_not_supported));
                    }

                    return ListTile(
                      leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: imageWidget),
                      title: Text(product.name),
                      subtitle: Text(
                          "${product.price} • ${product.category}"), // Showing Category
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () =>
                                _showEditDialog(context, docs[index]),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                _confirmDelete(context, product.id),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String productId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Product?"),
        content: const Text("This cannot be undone."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('products')
                  .doc(productId)
                  .delete();
              if (context.mounted) Navigator.pop(ctx);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // --- UPDATED EDIT DIALOG ---
  void _showEditDialog(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final nameController = TextEditingController(text: data['name']);
    final priceController = TextEditingController(
        text: data['price'].toString().replaceAll('₹', ''));

    String currentCategory = data['category'] ?? 'Sneakers';
    final List<String> categories = [
      'Sneakers',
      'Formal',
      'Sports',
      'Loafers',
      'Other'
    ];
    if (!categories.contains(currentCategory)) currentCategory = 'Other';

    // Load sizes
    final List<String> currentSizes =
        List<String>.from(data['sizes'] ?? ['7', '8', '9', '10']);
    final List<String> allPossibleSizes = [
      '6',
      '7',
      '8',
      '9',
      '10',
      '11',
      '12'
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Edit Product"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: "Name")),
                    TextField(
                        controller: priceController,
                        decoration: const InputDecoration(labelText: "Price")),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: currentCategory,
                      decoration: const InputDecoration(labelText: "Category"),
                      items: categories
                          .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) =>
                          setDialogState(() => currentCategory = val!),
                    ),
                    const SizedBox(height: 15),
                    const Text("Available Sizes:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: allPossibleSizes.map((size) {
                        final isSelected = currentSizes.contains(size);
                        return FilterChip(
                          label: Text(size),
                          selected: isSelected,
                          selectedColor:
                              AppConstants.primaryColor.withOpacity(0.2),
                          onSelected: (selected) {
                            setDialogState(() {
                              if (selected)
                                currentSizes.add(size);
                              else
                                currentSizes.remove(size);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Cancel")),
                ElevatedButton(
                  onPressed: () async {
                    await doc.reference.update({
                      'name': nameController.text,
                      'price': '₹${priceController.text}',
                      'category': currentCategory,
                      'sizes': currentSizes.isEmpty
                          ? ['8']
                          : currentSizes, // <--- UPDATE SIZES
                    });
                    if (context.mounted) Navigator.pop(ctx);
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
