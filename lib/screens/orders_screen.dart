import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import '../widgets/order_details_sheet.dart';
import '../utils/extensions.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final OrderService orderService = OrderService();

  // --- FIX 1: Rename 'orders' to '_allOrders' ---
  List<Order> _allOrders = [];

  // --- FIX 2: Add the filter state variable ---
  String _filterStatus = 'All';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final loadedOrders = await orderService.getOrders();
    // Sort by date descending
    loadedOrders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
    setState(() {
      _allOrders = loadedOrders; // Update the renamed variable
    });
  }

  // --- FIX 3: Add the getter for filtering ---
  List<Order> get _filteredOrders {
    if (_filterStatus == 'All') return _allOrders;
    return _allOrders
        .where((o) => o.status.toLowerCase() == _filterStatus.toLowerCase())
        .toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'shipped':
        return Colors.blue;
      case 'processing':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders"),
        actions: [
          // --- FIX 4: Add Filter Button ---
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filterStatus = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'All', child: Text("All Orders")),
              const PopupMenuItem(
                  value: 'Processing', child: Text("Processing")),
              const PopupMenuItem(value: 'Shipped', child: Text("Shipped")),
              const PopupMenuItem(value: 'Delivered', child: Text("Delivered")),
              const PopupMenuItem(value: 'Cancelled', child: Text("Cancelled")),
            ],
          ),
        ],
      ),
      // --- FIX 5: Use '_filteredOrders' instead of 'orders' ---
      body: _filteredOrders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _filterStatus == 'All'
                        ? "No orders yet"
                        : "No $_filterStatus orders",
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  if (_filterStatus == 'All')
                    const Text(
                      "Your orders will appear here",
                      style: TextStyle(color: Colors.grey),
                    ),
                  const SizedBox(height: 30),
                  if (_filterStatus == 'All')
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Continue Shopping"),
                    ),
                ],
              ),
            )
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey.shade50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${_filteredOrders.length} orders", // Update count
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredOrders.length, // Use filtered count
                    itemBuilder: (context, index) {
                      final order = _filteredOrders[index]; // Use filtered item
                      return _buildOrderCard(order);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildOrderCard(Order order) {
    // FIX 6: Ensure short ID logic handles strings safely
    String shortId = order.orderId;
    if (order.orderId.length > 8) {
      shortId = order.orderId.substring(0, 8).toUpperCase();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Order #$shortId",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.orderDate.toFormattedDate(),
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor(order.status),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    order.status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(order.status),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (order.items.isNotEmpty) ...[
              for (var i = 0;
                  i < (order.items.length > 2 ? 2 : order.items.length);
                  i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 6, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order.items[i].product.name,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        " x${order.items[i].quantity}",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              if (order.items.length > 2)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 14),
                  child: Text(
                    "+ ${order.items.length - 2} more items",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 16),
            const Divider(height: 1),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  _viewOrderDetails(order);
                },
                child: const Text("View Details"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _viewOrderDetails(Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => OrderDetailsSheet(order: order),
    );
  }
}
