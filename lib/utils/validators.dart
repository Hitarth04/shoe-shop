class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email is required";
    }

    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (!emailRegex.hasMatch(value.trim())) {
      return "Please enter a valid email";
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Password is required";
    }

    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }

    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.trim().isEmpty) {
      return "Please confirm your password";
    }

    if (value != password) {
      return "Passwords do not match";
    }

    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Full name is required";
    }

    if (value.trim().split(' ').length < 2) {
      return "Please enter your full name";
    }

    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Phone number is required";
    }

    final phoneRegex = RegExp(r'^[0-9]{10}$');
    final cleanPhone = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (!phoneRegex.hasMatch(cleanPhone)) {
      return "Please enter a valid 10-digit phone number";
    }

    return null;
  }

  static String? validatePincode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Pincode is required";
    }

    final pincodeRegex = RegExp(r'^[0-9]{6}$');
    if (!pincodeRegex.hasMatch(value.trim())) {
      return "Please enter a valid 6-digit pincode";
    }

    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return "$fieldName is required";
    }

    return null;
  }

  static String? validateCoupon(
      String? value, Map<String, double> availableCoupons) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter a coupon code";
    }

    final couponCode = value.trim().toUpperCase();
    if (!availableCoupons.containsKey(couponCode)) {
      return "Invalid coupon code";
    }

    return null;
  }
}
