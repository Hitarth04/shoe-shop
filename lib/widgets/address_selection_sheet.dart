import 'package:flutter/material.dart';
import '../models/address_model.dart';
import '../utils/extensions.dart';
import '../utils/constants.dart';

class AddressSelectionSheet extends StatelessWidget {
  final List<Address> addresses;
  final Address? selectedAddress;
  final Function(Address) onAddressSelected;
  final VoidCallback onAddNewAddressPressed;

  const AddressSelectionSheet({
    super.key,
    required this.addresses,
    this.selectedAddress,
    required this.onAddressSelected,
    required this.onAddNewAddressPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select Address",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...addresses.map((address) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    onTap: () {
                      Navigator.pop(context, address);
                    },
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        address.tag.getAddressIcon(),
                        color: AppConstants.primaryColor,
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(
                          address.tag,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (address.isDefault)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              "Default",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.green,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(address.fullName),
                        Text(address.phone),
                        const SizedBox(height: 4),
                        Text(
                          address.fullAddress,
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: selectedAddress?.id == address.id
                        ? const Icon(Icons.check, color: Color(0xFF5B5FDC))
                        : null,
                  ),
                );
              }).toList(),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the bottom sheet first
                  onAddNewAddressPressed(); // Then trigger the callback
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  "Add New Address",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Cancel"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
