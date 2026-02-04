import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
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
      appBar: AppBar(title: const Text("Manage Orders")),
      body: Column(
        children: [
          // --- SEARCH BAR ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search Order ID or Status...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // --- ORDER LIST ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collectionGroup('orders')
                  .orderBy('orderDate', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                // FILTER LOGIC
                final filteredDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final status =
                      (data['status'] ?? '').toString().toLowerCase();
                  final orderId =
                      (data['orderId'] ?? '').toString().toLowerCase();

                  return status.contains(_searchQuery) ||
                      orderId.contains(_searchQuery);
                }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(child: Text("No orders found"));
                }

                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final String status = data['status'] ?? 'Processing';
                    final String orderId = data['orderId'] ?? '???';
                    final double total = (data['totalAmount'] ?? 0).toDouble();
                    final date = DateTime.tryParse(data['orderDate'] ?? '') ??
                        DateTime.now();

                    // Formatting Order ID safely
                    final shortId = orderId.length > 8
                        ? orderId.substring(0, 8).toUpperCase()
                        : orderId.toUpperCase();

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text("Order #$shortId"),
                        subtitle:
                            Text("${date.toString().split(' ')[0]} • ₹$total"),
                        trailing: Chip(
                          label: Text(status),
                          backgroundColor:
                              _getStatusColor(status).withOpacity(0.2),
                        ),
                        onTap: () => _showStatusUpdateDialog(context, doc),
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
                    await doc.reference.update({'status': status});
                    if (context.mounted) Navigator.pop(ctx);
                  },
                ))
            .toList(),
      ),
    );
  }
}
