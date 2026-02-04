import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/address_model.dart';

class AddressService {
  static final AddressService _instance = AddressService._internal();
  factory AddressService() => _instance;
  AddressService._internal();

  // Get current User ID
  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  // Get Firestore Reference
  CollectionReference? get _addressRef {
    if (_userId == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('addresses');
  }

  Future<List<Address>> getAddresses() async {
    if (_addressRef == null) return [];

    try {
      final snapshot = await _addressRef!.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Address(
          id: doc.id,
          tag: data['tag'] ?? 'Home',
          fullName: data['fullName'] ?? '',
          phone: data['phone'] ?? '',
          street: data['street'] ?? '',
          city: data['city'] ?? '',
          state: data['state'] ?? '',
          pincode: data['pincode'] ?? '',
          isDefault: data['isDefault'] ?? false,
        );
      }).toList();
    } catch (e) {
      print("Error fetching addresses: $e");
      return [];
    }
  }

  Future<void> saveAddress(Address address) async {
    if (_addressRef == null) return;

    // If setting as default, uncheck others first
    if (address.isDefault) {
      final allDocs = await _addressRef!.get();
      for (var doc in allDocs.docs) {
        await doc.reference.update({'isDefault': false});
      }
    }

    await _addressRef!.doc(address.id).set({
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
  }

  Future<void> deleteAddress(String addressId) async {
    if (_addressRef == null) return;
    await _addressRef!.doc(addressId).delete();
  }

  Future<void> setDefaultAddress(String addressId) async {
    if (_addressRef == null) return;

    final allDocs = await _addressRef!.get();
    final batch = FirebaseFirestore.instance.batch();

    for (var doc in allDocs.docs) {
      batch.update(doc.reference, {'isDefault': doc.id == addressId});
    }

    await batch.commit();
  }
}
