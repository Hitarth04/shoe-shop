import 'package:flutter/material.dart';
import 'add_product_screen.dart';
import 'manage_products_screen.dart';
import 'admin_orders_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildAdminCard(
            context,
            icon: Icons.add_circle_outline,
            title: "Add New Product",
            color: Colors.blue,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AddProductScreen())),
          ),
          _buildAdminCard(
            context,
            icon: Icons.edit_note,
            title: "Manage Products",
            subtitle: "Edit or Delete existing shoes",
            color: Colors.orange,
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ManageProductsScreen())),
          ),
          _buildAdminCard(
            context,
            icon: Icons.local_shipping_outlined,
            title: "Manage Orders",
            subtitle: "Update order status",
            color: Colors.green,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AdminOrdersScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
