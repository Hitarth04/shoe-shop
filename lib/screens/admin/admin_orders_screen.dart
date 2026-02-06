import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/order_model.dart' as model;
import '../../utils/constants.dart';
import '../../utils/extensions.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final Stream<QuerySnapshot> _ordersStream =
      FirebaseFirestore.instance.collectionGroup('orders').snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Manage Orders"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _ordersStream,
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(child: Text("Error: ${snapshot.error}"));
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return const Center(child: Text("No orders received yet"));

          final orders = snapshot.data!.docs
              .map((doc) {
                try {
                  return model.Order.fromFirestore(doc);
                } catch (e) {
                  return null;
                }
              })
              .whereType<model.Order>()
              .toList();

          // Sort: Newest First
          orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) =>
                _buildAdminOrderCard(orders[index]),
          );
        },
      ),
    );
  }

  Widget _buildAdminOrderCard(model.Order order) {
    // FIX: If order ID is short (like our new random ones), don't substring it
    final displayId = order.orderId.length > 8
        ? order.orderId.substring(0, 8).toUpperCase()
        : order.orderId.toUpperCase();

    final isCancelled = order.status == 'Cancelled';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text("Order #$displayId",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(order.orderDate.toFormattedDate(),
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text("Total: ₹${order.totalAmount.toStringAsFixed(2)}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor)),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _getStatusColor(order.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _getStatusColor(order.status)),
          ),
          child: Text(order.status.toUpperCase(),
              style: TextStyle(
                  color: _getStatusColor(order.status),
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Customer Details:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(order.shippingAddress.fullName),
                Text(order.shippingAddress.phone),
                Text(order.shippingAddress.fullAddress,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const Divider(height: 20),
                const Text("Items:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ...order.items.map((item) => Text(
                    "${item.quantity}x ${item.product.name} (${item.size})")),
                const Divider(height: 20),

                // ADMIN ACTIONS
                if (!isCancelled) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatusButton(order, "Processing", Colors.orange),
                      _buildStatusButton(order, "Shipped", Colors.blue),
                      _buildStatusButton(order, "Delivered", Colors.green),
                    ],
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _cancelOrder(order),
                      icon: const Icon(Icons.cancel, color: Colors.white),
                      label: const Text("CANCEL ORDER PERMANENTLY",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  )
                ] else
                  const Center(
                    child: Text(
                      "🚫 This order is Cancelled and cannot be modified.",
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatusButton(model.Order order, String status, Color color) {
    final isSelected = order.status == status;
    return InkWell(
      onTap: () => _updateStatus(order, status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color),
        ),
        child: Text(status,
            style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.bold,
                fontSize: 12)),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'shipped':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Future<void> _updateStatus(model.Order order, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .doc(order.path)
          .update({'status': newStatus});
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Order marked as $newStatus")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Update Failed: $e"), backgroundColor: Colors.red));
    }
  }

  // --- IRREVERSIBLE CANCEL ACTION ---
  Future<void> _cancelOrder(model.Order order) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cancel Order?"),
        content: const Text(
            "Are you sure you want to CANCEL this order? \n\n⚠️ This action CANNOT be undone."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("No")),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Yes, Cancel",
                  style: TextStyle(color: Colors.white))),
        ],
      ),
    );

    if (confirm == true) {
      _updateStatus(order, "Cancelled");
    }
  }
}
