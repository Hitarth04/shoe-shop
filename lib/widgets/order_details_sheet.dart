import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/order_model.dart';
import '../utils/constants.dart';

class OrderDetailsSheet extends StatelessWidget {
  final Order order;

  const OrderDetailsSheet({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // 1. Determine current step for the Timeline
    int currentStep = 0;
    if (order.status == 'Processing') currentStep = 1;
    if (order.status == 'Shipped') currentStep = 2;
    if (order.status == 'Delivered') currentStep = 3;
    if (order.status == 'Cancelled') currentStep = -1;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        // Wrap in ClipRRect to ensure clean rounded corners
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                // --- HANDLE BAR ---
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // --- SCROLLABLE CONTENT ---
                Expanded(
                  child: ListView(
                    controller: controller,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Order Details",
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                  "ID: #${order.orderId.substring(0, 8).toUpperCase()}",
                                  style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor(order.status)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: _getStatusColor(order.status)),
                            ),
                            child: Text(
                              order.status.toUpperCase(),
                              style: TextStyle(
                                color: _getStatusColor(order.status),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // --- 1. VISUAL TIMELINE ---
                      if (currentStep != -1) _buildTimeline(currentStep),

                      if (currentStep == -1)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.error_outline, color: Colors.red),
                              SizedBox(width: 12),
                              Text("This order has been cancelled.",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),

                      const SizedBox(height: 30),

                      // --- 2. LIVE TRACKING MAP (Only when SHIPPED) ---
                      // FIX: Removed 'Delivered' from this condition
                      if (order.status == 'Shipped') ...[
                        const Text("Live Tracking",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        _buildTrackingMap(),
                        const SizedBox(height: 30),
                      ],

                      // --- ITEMS LIST ---
                      const Text("Items",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      ...order.items.map((item) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    item.product.image,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.broken_image),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(item.product.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600)),
                                      Text(item.product.price,
                                          style: TextStyle(
                                              color:
                                                  AppConstants.primaryColor)),
                                    ],
                                  ),
                                ),
                                Text("x${item.quantity}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                              ],
                            ),
                          )),

                      const Divider(height: 40),

                      // --- BILL SUMMARY ---
                      _buildDetailRow("Subtotal", "₹${order.subtotalAmount}"),
                      _buildDetailRow("Shipping", "₹${order.shippingAmount}"),
                      _buildDetailRow("Tax (18%)", "₹${order.taxAmount}"),
                      if (order.discountAmount > 0)
                        _buildDetailRow("Discount", "-₹${order.discountAmount}",
                            isGreen: true),
                      const Divider(),
                      _buildDetailRow("Total Amount", "₹${order.totalAmount}",
                          isBold: true),

                      const SizedBox(height: 10),
                      Text(
                        "Shipping Address",
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${order.shippingAddress.fullName}\n${order.shippingAddress.street}, ${order.shippingAddress.city}\n${order.shippingAddress.state} - ${order.shippingAddress.pincode}\nPhone: ${order.shippingAddress.phone}",
                        style: const TextStyle(fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- WIDGET: TIMELINE STEPPER ---
  Widget _buildTimeline(int currentStep) {
    return Row(
      children: [
        _buildStep("Ordered", 0, currentStep, isFirst: true),
        _buildConnector(0, currentStep),
        _buildStep("Processing", 1, currentStep),
        _buildConnector(1, currentStep),
        _buildStep("Shipped", 2, currentStep),
        _buildConnector(2, currentStep),
        _buildStep("Delivered", 3, currentStep, isLast: true),
      ],
    );
  }

  Widget _buildStep(String label, int index, int currentStep,
      {bool isFirst = false, bool isLast = false}) {
    bool isCompleted = index <= currentStep;
    bool isCurrent = index == currentStep;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: isCompleted ? AppConstants.primaryColor : Colors.grey[200],
              shape: BoxShape.circle,
              border: isCurrent
                  ? Border.all(
                      color: AppConstants.primaryColor.withOpacity(0.3),
                      width: 4)
                  : null,
            ),
            child: Icon(
              isCompleted ? Icons.check : Icons.circle,
              size: 16,
              color: isCompleted ? Colors.white : Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: isCompleted ? AppConstants.primaryColor : Colors.grey,
              fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnector(int index, int currentStep) {
    bool isColored = index < currentStep;
    return Expanded(
      child: Container(
        height: 2,
        color: isColored ? AppConstants.primaryColor : Colors.grey[200],
        margin: const EdgeInsets.only(bottom: 20),
      ),
    );
  }

  // --- WIDGET: DUMMY TRACKING MAP ---
  Widget _buildTrackingMap() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(28.6139, 77.2090),
                initialZoom: 13.0,
                interactionOptions:
                    InteractionOptions(flags: InteractiveFlag.none),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.shoe_shop',
                ),
                MarkerLayer(
                  markers: [
                    const Marker(
                      point: LatLng(28.6139, 77.2090),
                      width: 40,
                      height: 40,
                      child: Icon(Icons.local_shipping,
                          color: AppConstants.primaryColor, size: 30),
                    ),
                    Marker(
                      point: const LatLng(28.6200, 77.2150),
                      width: 40,
                      height: 40,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.home,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [
                        const LatLng(28.6139, 77.2090),
                        const LatLng(28.6160, 77.2120),
                        const LatLng(28.6200, 77.2150),
                      ],
                      color: AppConstants.primaryColor,
                      strokeWidth: 4.0,
                      pattern: const StrokePattern
                          .dotted(), // Using the correct parameter
                    ),
                  ],
                ),
              ],
            ),
            Positioned.fill(child: Container(color: Colors.transparent)),
            Positioned(
              bottom: 10,
              left: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.green),
                    SizedBox(width: 6),
                    Text("Arriving today by 9 PM",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isBold = false, bool isGreen = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                color: isBold ? Colors.black : Colors.grey,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: isBold ? 16 : 14,
              )),
          Text(value,
              style: TextStyle(
                color: isGreen ? Colors.green : Colors.black,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                fontSize: isBold ? 16 : 14,
              )),
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
}
