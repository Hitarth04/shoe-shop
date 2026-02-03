import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Orders")),
      // Fetch orders from ALL users using collectionGroup
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collectionGroup('orders')
            .orderBy('orderDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            // This prints the full error (including links) to your VS Code Debug Console
            print("🔥 FIREBASE ERROR: ${snapshot.error}");

            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text("No orders found"));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final String status = data['status'] ?? 'Processing';
              final String orderId = data['orderId'] ?? '???';
              final double total = (data['totalAmount'] ?? 0).toDouble();
              final date =
                  DateTime.tryParse(data['orderDate'] ?? '') ?? DateTime.now();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title:
                      Text("Order #${orderId.substring(0, 8).toUpperCase()}"),
                  subtitle: Text("${date.toString().split(' ')[0]} • ₹$total"),
                  trailing: Chip(
                    label: Text(status),
                    backgroundColor: _getStatusColor(status).withOpacity(0.2),
                  ),
                  onTap: () => _showStatusUpdateDialog(context, docs[index]),
                ),
              );
            },
          );
        },
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

  void _showStatusUpdateDialog(BuildContext context, DocumentSnapshot doc) {
    final List<String> statuses = [
      'Processing',
      'Shipped',
      'Delivered',
      'Cancelled'
    ];

    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text("Update Status"),
        children: statuses
            .map((status) => SimpleDialogOption(
                  padding: const EdgeInsets.all(15),
                  child: Text(status, style: const TextStyle(fontSize: 16)),
                  onPressed: () async {
                    // Update the specific order document directly using its reference
                    await doc.reference.update({'status': status});
                    if (context.mounted) Navigator.pop(ctx);
                  },
                ))
            .toList(),
      ),
    );
  }
}
