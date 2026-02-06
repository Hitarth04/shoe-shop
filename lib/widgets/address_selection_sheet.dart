import 'package:flutter/material.dart';
import '../models/address_model.dart';
import '../services/address_service.dart';
import '../screens/address_screen.dart';
import '../utils/constants.dart';

class AddressSelectionSheet extends StatefulWidget {
  final Function(Address) onAddressSelected;

  const AddressSelectionSheet({
    super.key,
    required this.onAddressSelected,
    // REMOVED: required this.addresses <-- This line is gone now!
  });

  @override
  State<AddressSelectionSheet> createState() => _AddressSelectionSheetState();
}

class _AddressSelectionSheetState extends State<AddressSelectionSheet> {
  final AddressService _addressService = AddressService(); // Internal Service

  void _navigateToAddAddress() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddressScreen()),
    );
    setState(() {}); // Refresh list after returning
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Select Delivery Address",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close)),
            ],
          ),
          const Divider(),
          Expanded(
            child: FutureBuilder<List<Address>>(
              future:
                  _addressService.getAddresses(), // <--- Fetches data itself
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text("No addresses found. Add one!"));
                }

                final addresses = snapshot.data!;

                return ListView.separated(
                  itemCount: addresses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final address = addresses[index];
                    return InkWell(
                      onTap: () {
                        widget.onAddressSelected(address);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                color: AppConstants.primaryColor),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(address.tag,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppConstants.secondaryColor)),
                                  const SizedBox(height: 4),
                                  Text(address.fullName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  Text("${address.street}, ${address.city}",
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 12)),
                                  Text("${address.state} - ${address.pincode}",
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                            if (address.isDefault)
                              const Icon(Icons.check_circle,
                                  color: Colors.green, size: 20),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: _navigateToAddAddress,
              icon: const Icon(Icons.add),
              label: const Text("Add New Address"),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppConstants.primaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
