import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart'; // Ensure you have latlong2 for coordinates
import '../models/address_model.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import 'mini_map_picker.dart';

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

  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pincodeController;

  String _selectedTag = 'Home';
  bool _isMapVisible = false;

  @override
  void initState() {
    super.initState();
    _fullNameController =
        TextEditingController(text: widget.address?.fullName ?? '');
    _phoneController = TextEditingController(text: widget.address?.phone ?? '');
    _streetController =
        TextEditingController(text: widget.address?.street ?? '');
    _cityController = TextEditingController(text: widget.address?.city ?? '');
    _stateController = TextEditingController(text: widget.address?.state ?? '');
    _pincodeController =
        TextEditingController(text: widget.address?.pincode ?? '');

    if (widget.address != null) {
      _selectedTag = widget.address!.tag;
    }
  }

  Future<void> _fillAddressFromCoordinates(LatLng pos) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(pos.latitude, pos.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        setState(() {
          _cityController.text = place.locality ?? '';
          _stateController.text = place.administrativeArea ?? '';
          _pincodeController.text = place.postalCode ?? '';

          if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) {
            _streetController.text =
                "${place.thoroughfare}, ${place.subLocality}";
          }
        });
      }
    } catch (e) {
      debugPrint("Geocoding error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding + 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.address == null ? "Add New Address" : "Edit Address",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              if (widget.address == null)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isMapVisible = !_isMapVisible;
                      });
                    },
                    icon: Icon(_isMapVisible ? Icons.close : Icons.map),
                    label: Text(_isMapVisible
                        ? "Hide Map"
                        : "Locate on Map (Auto-fill)"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppConstants.primaryColor,
                    ),
                  ),
                ),

              if (_isMapVisible) ...[
                const SizedBox(height: 10),
                const Text("Drag map to select location:",
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 5),
                MiniMapPicker(
                  onLocationChanged: (LatLng pos) {
                    _fillAddressFromCoordinates(pos);
                  },
                ),
                const SizedBox(height: 20),
              ],

              SizedBox(
                height: 10.0,
              ),

              // Validators.validateName takes 1 arg (String?) -> OK
              _buildTextField(
                  "Full Name", _fullNameController, Validators.validateName),
              const SizedBox(height: 10),
              // Validators.validatePhone takes 1 arg (String?) -> OK
              _buildTextField(
                  "Phone Number", _phoneController, Validators.validatePhone,
                  isPhone: true),
              const SizedBox(height: 10),

              Row(
                children: [
                  // Validators.validatePincode takes 1 arg (String?) -> OK
                  Expanded(
                      child: _buildTextField("Pincode", _pincodeController,
                          Validators.validatePincode,
                          isNumber: true)),
                  const SizedBox(width: 10),

                  // FIX 1: Wrap validateRequired to pass the field name "City"
                  Expanded(
                      child: _buildTextField("City", _cityController,
                          (val) => Validators.validateRequired(val, "City"))),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  // FIX 2: Wrap validateRequired to pass the field name "State"
                  Expanded(
                      child: _buildTextField("State", _stateController,
                          (val) => Validators.validateRequired(val, "State"))),
                ],
              ),
              const SizedBox(height: 10),
              // FIX 3: Wrap validateRequired to pass "Street Address"
              _buildTextField("Street Address / Area", _streetController,
                  (val) => Validators.validateRequired(val, "Street Address"),
                  maxLines: 2),

              const SizedBox(height: 20),
              const Text("Address Type",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Row(
                children: ['Home', 'Work', 'Other'].map((tag) {
                  final isSelected = _selectedTag == tag;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(tag),
                      selected: isSelected,
                      selectedColor:
                          Colors.cyanAccent.shade100.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppConstants.primaryColor
                            : Colors.black,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedTag = tag);
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Save Address",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      String? Function(String?) validator,
      {bool isPhone = false, bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: isPhone
          ? TextInputType.phone
          : (isNumber ? TextInputType.number : TextInputType.text),
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      final newAddress = Address(
        id: widget.address?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        street: _streetController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        pincode: _pincodeController.text.trim(),
        tag: _selectedTag,
        isDefault: widget.address?.isDefault ?? false,
      );
      widget.onSave(newAddress);
    }
  }
}
