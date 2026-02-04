import 'package:flutter/material.dart';
import '../models/address_model.dart';
import '../services/address_service.dart';
import '../widgets/address_form.dart';
import '../utils/extensions.dart';
import '../utils/constants.dart';

class AddressScreen extends StatefulWidget {
  final bool fromCheckout;

  const AddressScreen({super.key, this.fromCheckout = false});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final AddressService addressService = AddressService();
  List<Address> addresses = [];

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final loadedAddresses = await addressService.getAddresses();
    setState(() {
      addresses = loadedAddresses;
    });
  }

  void _addNewAddress() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddressForm(
        onSave: (newAddress) async {
          await addressService.saveAddress(newAddress);
          await _loadAddresses();

          Navigator.pop(context); // Close bottom sheet

          if (widget.fromCheckout) {
            // Return the address to the previous screen
            Navigator.pop(context, newAddress);
          }
        },
      ),
    );
  }

  void _editAddress(Address address) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddressForm(
        address: address,
        onSave: (updatedAddress) async {
          await addressService.deleteAddress(address.id);
          await addressService.saveAddress(updatedAddress);
          await _loadAddresses();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _deleteAddress(String addressId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Address"),
        content: const Text("Are you sure you want to delete this address?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await addressService.deleteAddress(addressId);
              await _loadAddresses();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Saved Addresses"),
        backgroundColor: Colors.white,
        leading: widget.fromCheckout
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewAddress,
          ),
        ],
      ),
      body: addresses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "No addresses saved",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _addNewAddress,
                    child: const Text("Add New Address"),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final address = addresses[index];
                return Card(
                  color: Colors.grey.shade100,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
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
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
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
                        const SizedBox(height: 8),
                        Text(address.fullName),
                        Text(address.phone),
                        const SizedBox(height: 4),
                        Text(
                          address.fullAddress,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text("Edit"),
                        ),
                        const PopupMenuItem(
                          value: 'set_default',
                          child: Text("Set as Default"),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text("Delete"),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editAddress(address);
                        } else if (value == 'set_default') {
                          addressService.setDefaultAddress(address.id);
                          _loadAddresses();
                        } else if (value == 'delete') {
                          _deleteAddress(address.id);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
