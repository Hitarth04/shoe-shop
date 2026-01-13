import 'package:flutter/material.dart';

extension PriceParsing on String {
  double toDouble() {
    try {
      return double.parse(replaceAll(RegExp(r'[^0-9.]'), ''));
    } catch (e) {
      return 0.0;
    }
  }
}

extension DateFormatter on DateTime {
  String toFormattedDate() {
    return "$day/$month/$year";
  }
}

extension StringCapitalize on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

extension AddressIcon on String {
  IconData getAddressIcon() {
    switch (toLowerCase()) {
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.work;
      case 'other':
        return Icons.location_on;
      default:
        return Icons.place;
    }
  }
}
