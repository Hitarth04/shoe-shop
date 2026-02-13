import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/order_model.dart' as model; // Alias to avoid conflict
import '../../utils/constants.dart';
import '../../utils/extensions.dart'; // For date formatting

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  // STREAM: Listen to ALL orders from ALL users in real-time
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
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("No orders received yet",
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          // 1. Parse Data Safely
          final orders = snapshot.data!.docs
              .map((doc) {
                try {
                  return model.Order.fromFirestore(doc);
                } catch (e) {
                  // Skip corrupted documents
                  return null;
                }
              })
              .whereType<model.Order>()
              .toList();

          // 2. FORCE SORT: Newest First
          orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return _buildAdminOrderCard(orders[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildAdminOrderCard(model.Order order) {
    // Logic to show short ID if it's a long UUID, or full ID if it's our custom short one
    final displayId = order.orderId.length > 10
        ? order.orderId.substring(0, 8).toUpperCase()
        : order.orderId.toUpperCase();

    final isCancelled = order.status == 'Cancelled';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          "Order #$displayId",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(order.orderDate.toFormattedDate(),
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
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
          child: Text(
            order.status.toUpperCase(),
            style: TextStyle(
                color: _getStatusColor(order.status),
                fontSize: 10,
                fontWeight: FontWeight.bold),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer Details
                const Text("Customer Details:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(order.shippingAddress.fullName),
                Text(order.shippingAddress.phone),
                Text(order.shippingAddress.fullAddress,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),

                const Divider(height: 20),

                // Items List
                const Text("Items:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Text("${item.quantity}x ",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(child: Text(item.product.name)),
                          Text("Size: ${item.size}",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    )),

                const Divider(height: 20),

                // --- ADMIN ACTION BUTTONS ---
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
                    child: OutlinedButton.icon(
                      onPressed: () => _cancelOrder(order),
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      label: const Text("CANCEL ORDER",
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  )
                ] else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade100),
                    ),
                    child: const Center(
                      child: Text(
                        "🚫 Order Cancelled",
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
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
        child: Text(
          status,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
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

  // --- ACTIONS ---

  Future<void> _updateStatus(model.Order order, String newStatus) async {
    try {
      // FIX: Use order.path directly. No guessing userIds!
      await FirebaseFirestore.instance
          .doc(order.path)
          .update({'status': newStatus});
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Status updated to $newStatus")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Update Failed: $e"), backgroundColor: Colors.red));
    }
  }

  Future<void> _cancelOrder(model.Order order) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cancel Order?"),
        content: const Text(
            "Are you sure you want to cancel this order? This cannot be undone."),
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
