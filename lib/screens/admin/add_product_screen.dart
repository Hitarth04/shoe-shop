import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descController = TextEditingController();
  final imageController = TextEditingController();

  bool _isLoading = false;

  Future<void> _uploadProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Create a unique ID for the product
      final docRef = FirebaseFirestore.instance.collection('products').doc();

      await docRef.set({
        'id': docRef.id, // Save the ID inside the document too
        'name': nameController.text.trim(),
        'price': "₹${priceController.text.trim()}", // Auto-add currency symbol
        'description': descController.text.trim(),
        'image': imageController.text.trim(), // Expecting a URL here
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Product Added Successfully!')),
      );
      Navigator.pop(context); // Go back after success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Secret Admin Console"),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Add New Kicks",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                  controller: nameController,
                  label: "Shoe Name",
                  icon: Icons.shopping_bag_outlined),
              const SizedBox(height: 15),
              _buildTextField(
                  controller: priceController,
                  label: "Price (e.g. 4999)",
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 15),
              _buildTextField(
                  controller: imageController,
                  label: "Image URL",
                  hint: "Paste a link from Google Images",
                  icon: Icons.image_outlined),
              const SizedBox(height: 15),
              _buildTextField(
                  controller: descController,
                  label: "Description",
                  icon: Icons.description_outlined,
                  maxLines: 3),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _uploadProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("UPLOAD TO DATABASE"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (val) => val!.isEmpty ? "Required" : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
