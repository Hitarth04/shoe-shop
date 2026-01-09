import 'package:flutter/material.dart';
import '../models/address_model.dart';
import '../services/address_service.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';

class AddressForm extends StatefulWidget {
  final Address? address;
  final Function(Address) onSave;

  const AddressForm({
    super.key,
    this.address,
    required this.onSave,
  });

  @override
  State<AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<AddressForm> {
  final _formKey = GlobalKey<FormState>();
  final AddressService addressService = AddressService();

  String _tag = 'Home';
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _tag = widget.address!.tag;
      _fullNameController.text = widget.address!.fullName;
      _phoneController.text = widget.address!.phone;
      _streetController.text = widget.address!.street;
      _cityController.text = widget.address!.city;
      _stateController.text = widget.address!.state;
      _pincodeController.text = widget.address!.pincode;
      _isDefault = widget.address!.isDefault;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      final address = Address(
        id: widget.address?.id ?? addressService.generateId(),
        tag: _tag,
        fullName: _fullNameController.text,
        phone: _phoneController.text,
        street: _streetController.text,
        city: _cityController.text,
        state: _stateController.text,
        pincode: _pincodeController.text,
        isDefault: _isDefault,
      );
      widget.onSave(address);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.address == null ? "Add New Address" : "Edit Address",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _tag,
                decoration: const InputDecoration(
                  labelText: "Address Tag",
                  border: OutlineInputBorder(),
                ),
                items: AppConstants.addressTags.map((tag) {
                  return DropdownMenuItem(
                    value: tag,
                    child: Text(tag),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _tag = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) => Validators.validateName(value),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => Validators.validatePhone(value),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _streetController,
                decoration: const InputDecoration(
                  labelText: "Street Address",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
                validator: (value) =>
                    Validators.validateRequired(value, "Street address"),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: "City",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          Validators.validateRequired(value, "City"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _stateController,
                      decoration: const InputDecoration(
                        labelText: "State",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          Validators.validateRequired(value, "State"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pincodeController,
                decoration: const InputDecoration(
                  labelText: "Pincode",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => Validators.validatePincode(value),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _isDefault,
                    onChanged: (value) {
                      setState(() {
                        _isDefault = value!;
                      });
                    },
                  ),
                  const Text("Set as default address"),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveAddress,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        "Save Address",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
