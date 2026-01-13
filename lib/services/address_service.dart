import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/address_model.dart';
import '../utils/constants.dart';

class AddressService {
  static final AddressService _instance = AddressService._internal();
  factory AddressService() => _instance;
  AddressService._internal();

  final Uuid uuid = const Uuid();

  Future<List<Address>> getAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final addressesJson = prefs.getString(AppConstants.addressesKey);

    if (addressesJson == null) return [];

    try {
      final List<dynamic> addressesData = json.decode(addressesJson);
      return addressesData.map((addrJson) {
        return Address(
          id: addrJson['id'],
          tag: addrJson['tag'],
          fullName: addrJson['fullName'],
          phone: addrJson['phone'],
          street: addrJson['street'],
          city: addrJson['city'],
          state: addrJson['state'],
          pincode: addrJson['pincode'],
          isDefault: addrJson['isDefault'] ?? false,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveAddress(Address address) async {
    final prefs = await SharedPreferences.getInstance();
    final addressesJson = prefs.getString(AppConstants.addressesKey) ?? '[]';
    final List<dynamic> addresses = json.decode(addressesJson);

    // If setting as default, remove default from others
    if (address.isDefault) {
      for (var addr in addresses) {
        addr['isDefault'] = false;
      }
    }

    addresses.add({
      'id': address.id,
      'tag': address.tag,
      'fullName': address.fullName,
      'phone': address.phone,
      'street': address.street,
      'city': address.city,
      'state': address.state,
      'pincode': address.pincode,
      'isDefault': address.isDefault,
    });

    await prefs.setString(AppConstants.addressesKey, json.encode(addresses));
  }

  Future<void> deleteAddress(String addressId) async {
    final prefs = await SharedPreferences.getInstance();
    final addressesJson = prefs.getString(AppConstants.addressesKey) ?? '[]';
    final List<dynamic> addresses = json.decode(addressesJson);

    addresses.removeWhere((addr) => addr['id'] == addressId);
    await prefs.setString(AppConstants.addressesKey, json.encode(addresses));
  }

  Future<void> setDefaultAddress(String addressId) async {
    final prefs = await SharedPreferences.getInstance();
    final addressesJson = prefs.getString(AppConstants.addressesKey) ?? '[]';
    final List<dynamic> addresses = json.decode(addressesJson);

    for (var addr in addresses) {
      addr['isDefault'] = addr['id'] == addressId;
    }

    await prefs.setString(AppConstants.addressesKey, json.encode(addresses));
  }

  String generateId() {
    return uuid.v4();
  }
}
