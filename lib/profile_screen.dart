import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'address_screen.dart';
import 'orders_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userName;
  final VoidCallback onLogout;

  const ProfileScreen({
    super.key,
    required this.userName,
    required this.onLogout,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _userEmail;
  String? _userPhone;
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _promotionalEmails = false;
  bool _priceDropAlerts = true;
  bool _biometricAuth = false;
  bool _twoFactorAuth = false;
  bool _savePaymentInfo = true;
  List<Map<String, dynamic>> _paymentMethods = [];
  List<String> _recentDevices = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadSettings();
    _loadPaymentMethods();
    _loadRecentDevices();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userEmail = prefs.getString('user_email') ?? 'user@example.com';
      _userPhone = prefs.getString('user_phone') ?? '+91 9876543210';
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _emailNotifications = prefs.getBool('email_notifications') ?? true;
      _pushNotifications = prefs.getBool('push_notifications') ?? true;
      _promotionalEmails = prefs.getBool('promotional_emails') ?? false;
      _priceDropAlerts = prefs.getBool('price_drop_alerts') ?? true;
      _biometricAuth = prefs.getBool('biometric_auth') ?? false;
      _twoFactorAuth = prefs.getBool('two_factor_auth') ?? false;
      _savePaymentInfo = prefs.getBool('save_payment_info') ?? true;
    });
  }

  Future<void> _loadPaymentMethods() async {
    // Simulate loading payment methods
    setState(() {
      _paymentMethods = [
        {
          'type': 'credit_card',
          'name': 'Visa ending in 4242',
          'icon': Icons.credit_card,
          'isDefault': true,
          'lastFour': '4242',
          'expiry': '12/25'
        },
        {
          'type': 'upi',
          'name': 'Google Pay',
          'icon': Icons.phone_android,
          'isDefault': false,
          'upiId': 'user@okicici'
        },
        {
          'type': 'netbanking',
          'name': 'HDFC Bank',
          'icon': Icons.account_balance,
          'isDefault': false,
        },
      ];
    });
  }

  Future<void> _loadRecentDevices() async {
    // Simulate loading recent devices
    setState(() {
      _recentDevices = [
        'iPhone 14 (Current Device)',
        'Samsung Galaxy S23',
        'iPad Pro',
      ];
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('email_notifications', _emailNotifications);
    await prefs.setBool('push_notifications', _pushNotifications);
    await prefs.setBool('promotional_emails', _promotionalEmails);
    await prefs.setBool('price_drop_alerts', _priceDropAlerts);
    await prefs.setBool('biometric_auth', _biometricAuth);
    await prefs.setBool('two_factor_auth', _twoFactorAuth);
    await prefs.setBool('save_payment_info', _savePaymentInfo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Profile"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            _buildProfileHeader(),
            const SizedBox(height: 30),

            // Account Section
            _buildSectionTitle("Account"),
            _buildMenuTile(
              icon: Icons.location_on,
              title: "Saved Addresses",
              subtitle: "Manage delivery addresses",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddressScreen(),
                  ),
                );
              },
            ),
            _buildMenuTile(
              icon: Icons.shopping_bag,
              title: "My Orders",
              subtitle: "View your order history",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrdersScreen(),
                  ),
                );
              },
            ),
            _buildMenuTile(
              icon: Icons.payment,
              title: "Payment Methods",
              subtitle: "Manage your payment options",
              onTap: _showPaymentMethods,
            ),

            const SizedBox(height: 30),

            // App Section
            _buildSectionTitle("App"),
            _buildMenuTile(
              icon: Icons.notifications,
              title: "Notifications",
              subtitle: "Manage your notifications",
              onTap: _showNotificationsSettings,
            ),
            _buildMenuTile(
              icon: Icons.security,
              title: "Privacy & Security",
              subtitle: "Manage your privacy settings",
              onTap: _showPrivacySettings,
            ),
            _buildMenuTile(
              icon: Icons.description,
              title: "Terms & Conditions",
              subtitle: "Read our terms and conditions",
              onTap: _showTermsAndConditions,
            ),
            _buildMenuTile(
              icon: Icons.help,
              title: "Help & Support",
              subtitle: "Get help with the app",
              onTap: _showHelpSupport,
            ),

            const SizedBox(height: 30),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showLogoutConfirmation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Logout",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: const Color(0xFF5B5FDC).withOpacity(0.1),
            borderRadius: BorderRadius.circular(35),
          ),
          child: Center(
            child: Text(
              widget.userName[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5B5FDC),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.userName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              if (_userEmail != null)
                Text(
                  _userEmail!,
                  style: const TextStyle(color: Colors.grey),
                ),
              if (_userPhone != null)
                Text(
                  _userPhone!,
                  style: const TextStyle(color: Colors.grey),
                ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit, color: Color(0xFF5B5FDC)),
          onPressed: _showEditProfile,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF5B5FDC).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF5B5FDC)),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }

  void _showEditProfile() {
    final nameController = TextEditingController(text: widget.userName);
    final emailController = TextEditingController(text: _userEmail);
    final phoneController = TextEditingController(text: _userPhone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Profile"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              // Save profile changes
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('user_email', emailController.text);
              await prefs.setString('user_phone', phoneController.text);

              setState(() {
                _userEmail = emailController.text;
                _userPhone = phoneController.text;
              });

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Profile updated successfully!"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B5FDC),
            ),
            child: const Text(
              "Save",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentMethods() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.all(20),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Payment Methods",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Toggle for saving payment info
                  SwitchListTile(
                    title: const Text("Save Payment Information"),
                    subtitle: const Text(
                        "Securely save your payment details for faster checkout"),
                    value: _savePaymentInfo,
                    onChanged: (value) {
                      setState(() {
                        _savePaymentInfo = value;
                      });
                      _saveSettings();
                    },
                    activeColor: const Color(0xFF5B5FDC),
                  ),

                  const Divider(),
                  const SizedBox(height: 10),

                  // Payment methods list
                  const Text(
                    "Saved Payment Methods",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 10),

                  if (_paymentMethods.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          "No payment methods saved",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ..._paymentMethods.map((method) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF5B5FDC).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              method['icon'] as IconData,
                              color: const Color(0xFF5B5FDC),
                            ),
                          ),
                          title: Text(method['name'] as String),
                          subtitle: method['type'] == 'credit_card'
                              ? Text("Expires ${method['expiry']}")
                              : method['type'] == 'upi'
                                  ? Text("UPI ID: ${method['upiId']}")
                                  : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (method['isDefault'] as bool)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    "Default",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 10),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete_outline, size: 20),
                                color: Colors.red,
                                onPressed: () {
                                  _deletePaymentMethod(method);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),

                  const SizedBox(height: 20),

                  // Add new payment method button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _addPaymentMethod,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF5B5FDC)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: const Icon(Icons.add, color: Color(0xFF5B5FDC)),
                      label: const Text(
                        "Add Payment Method",
                        style: TextStyle(color: Color(0xFF5B5FDC)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B5FDC),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        "Close",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _addPaymentMethod() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Add Payment Method",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Payment method type selection
            const Text("Select Payment Method",
                style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildPaymentTypeChip("Credit/Debit Card", Icons.credit_card),
                _buildPaymentTypeChip("UPI", Icons.phone_android),
                _buildPaymentTypeChip("Net Banking", Icons.account_balance),
                _buildPaymentTypeChip("Wallet", Icons.account_balance_wallet),
              ],
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Add payment method logic
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Payment method added successfully!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B5FDC),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Add Payment Method"),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentTypeChip(String title, IconData icon) {
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
      selected: false,
      onSelected: (selected) {},
      selectedColor: const Color(0xFF5B5FDC),
      backgroundColor: Colors.grey.shade100,
    );
  }

  void _deletePaymentMethod(Map<String, dynamic> method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Payment Method"),
        content:
            const Text("Are you sure you want to delete this payment method?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _paymentMethods.remove(method);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Payment method deleted"),
                  backgroundColor: Colors.green,
                ),
              );
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

  void _showNotificationsSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.all(20),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Notification Settings",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Master toggle
                  SwitchListTile(
                    title: const Text("Enable Notifications"),
                    subtitle:
                        const Text("Turn off to disable all notifications"),
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                        if (!value) {
                          _emailNotifications = false;
                          _pushNotifications = false;
                          _promotionalEmails = false;
                          _priceDropAlerts = false;
                        }
                      });
                      _saveSettings();
                    },
                    activeColor: const Color(0xFF5B5FDC),
                  ),

                  const Divider(),
                  const SizedBox(height: 10),

                  // Notification types (only if master toggle is on)
                  if (_notificationsEnabled) ...[
                    const Text(
                      "Notification Types",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      title: const Text("Order Updates"),
                      subtitle:
                          const Text("Order confirmation, shipping, delivery"),
                      value: _emailNotifications,
                      onChanged: (value) {
                        setState(() {
                          _emailNotifications = value;
                        });
                        _saveSettings();
                      },
                      activeColor: const Color(0xFF5B5FDC),
                    ),
                    SwitchListTile(
                      title: const Text("Push Notifications"),
                      subtitle: const Text("App notifications on your device"),
                      value: _pushNotifications,
                      onChanged: (value) {
                        setState(() {
                          _pushNotifications = value;
                        });
                        _saveSettings();
                      },
                      activeColor: const Color(0xFF5B5FDC),
                    ),
                    SwitchListTile(
                      title: const Text("Promotional Emails"),
                      subtitle: const Text(
                          "Special offers, discounts, and new arrivals"),
                      value: _promotionalEmails,
                      onChanged: (value) {
                        setState(() {
                          _promotionalEmails = value;
                        });
                        _saveSettings();
                      },
                      activeColor: const Color(0xFF5B5FDC),
                    ),
                    SwitchListTile(
                      title: const Text("Price Drop Alerts"),
                      subtitle: const Text(
                          "Get notified when wishlist items go on sale"),
                      value: _priceDropAlerts,
                      onChanged: (value) {
                        setState(() {
                          _priceDropAlerts = value;
                        });
                        _saveSettings();
                      },
                      activeColor: const Color(0xFF5B5FDC),
                    ),
                  ] else
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          "Notifications are currently disabled",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B5FDC),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        "Save Settings",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPrivacySettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(20),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Privacy & Security",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Security settings
                  const Text(
                    "Security",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 10),

                  SwitchListTile(
                    title: const Text("Biometric Authentication"),
                    subtitle:
                        const Text("Use fingerprint or face ID to log in"),
                    value: _biometricAuth,
                    onChanged: (value) {
                      setModalState(() {
                        _biometricAuth = value;
                      });
                      _saveSettings();
                    },
                    activeColor: const Color(0xFF5B5FDC),
                  ),

                  SwitchListTile(
                    title: const Text("Two-Factor Authentication"),
                    subtitle: const Text(
                        "Add an extra layer of security to your account"),
                    value: _twoFactorAuth,
                    onChanged: (value) {
                      setModalState(() {
                        _twoFactorAuth = value;
                      });
                      _saveSettings();
                    },
                    activeColor: const Color(0xFF5B5FDC),
                  ),

                  const Divider(),
                  const SizedBox(height: 10),

                  // Privacy settings
                  const Text(
                    "Privacy",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 10),

                  ListTile(
                    title: const Text("Personal Information"),
                    subtitle: const Text("Manage what information is shared"),
                    trailing:
                        const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {
                      // DON'T close the Privacy & Security sheet
                      _showPersonalInfoSettings();
                    },
                  ),

                  ListTile(
                    title: const Text("Data & Analytics"),
                    subtitle: const Text("Control how your data is used"),
                    trailing:
                        const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {
                      // DON'T close the Privacy & Security sheet
                      _showDataAnalyticsSettings();
                    },
                  ),

                  ListTile(
                    title: const Text("Location Services"),
                    subtitle: const Text(
                        "Manage location access for better delivery estimates"),
                    trailing:
                        const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {
                      // DON'T close the Privacy & Security sheet
                      _showLocationSettings();
                    },
                  ),

                  const Divider(),
                  const SizedBox(height: 10),

                  // Recent devices
                  const Text(
                    "Recent Devices",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 10),

                  if (_recentDevices.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          "No recent devices found",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ..._recentDevices.map((device) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.devices,
                              color: Color(0xFF5B5FDC)),
                          title: Text(device),
                          subtitle: device.contains("Current")
                              ? const Text(
                                  "Currently logged in",
                                  style: TextStyle(color: Colors.green),
                                )
                              : const Text("Last seen 2 days ago"),
                          trailing: device.contains("Current")
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.logout, size: 20),
                                  color: Colors.red,
                                  onPressed: () {
                                    _logoutDevice(device, setModalState);
                                  },
                                ),
                        ),
                      );
                    }).toList(),

                  const SizedBox(height: 20),

                  // Privacy policy and delete account
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // Close Privacy & Security and open Terms
                            Navigator.pop(context); // Close Privacy & Security
                            _showTermsAndConditions();
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.grey),
                          ),
                          child: const Text("Privacy Policy"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context); // Close Privacy & Security
                            _showDeleteAccountDialog();
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                          ),
                          child: const Text(
                            "Delete Account",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B5FDC),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        "Save Settings",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPersonalInfoSettings() {
    bool shareWithPartners = true;
    bool showPurchaseHistory = true;
    bool publicProfile = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Personal Information"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Control what personal information is shared:",
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text("Share with trusted partners"),
                    subtitle:
                        const Text("Allow sharing for personalized offers"),
                    value: shareWithPartners,
                    onChanged: (value) {
                      setDialogState(() {
                        shareWithPartners = value;
                      });
                    },
                    activeColor: const Color(0xFF5B5FDC),
                  ),
                  SwitchListTile(
                    title: const Text("Show purchase history"),
                    subtitle:
                        const Text("Display your orders to customer service"),
                    value: showPurchaseHistory,
                    onChanged: (value) {
                      setDialogState(() {
                        showPurchaseHistory = value;
                      });
                    },
                    activeColor: const Color(0xFF5B5FDC),
                  ),
                  SwitchListTile(
                    title: const Text("Public profile"),
                    subtitle: const Text("Allow others to see your reviews"),
                    value: publicProfile,
                    onChanged: (value) {
                      setDialogState(() {
                        publicProfile = value;
                      });
                    },
                    activeColor: const Color(0xFF5B5FDC),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Personal information settings saved"),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B5FDC),
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDataAnalyticsSettings() {
    bool usageAnalytics = true;
    bool crashReports = true;
    bool personalizedRecommendations = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Data & Analytics"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Control how your data is used for analytics:",
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text("Usage analytics"),
                    subtitle: const Text(
                        "Help improve the app by sharing usage data"),
                    value: usageAnalytics,
                    onChanged: (value) {
                      setDialogState(() {
                        usageAnalytics = value;
                      });
                    },
                    activeColor: const Color(0xFF5B5FDC),
                  ),
                  SwitchListTile(
                    title: const Text("Crash reports"),
                    subtitle: const Text("Automatically send crash reports"),
                    value: crashReports,
                    onChanged: (value) {
                      setDialogState(() {
                        crashReports = value;
                      });
                    },
                    activeColor: const Color(0xFF5B5FDC),
                  ),
                  SwitchListTile(
                    title: const Text("Personalized recommendations"),
                    subtitle: const Text(
                        "Get product recommendations based on your activity"),
                    value: personalizedRecommendations,
                    onChanged: (value) {
                      setDialogState(() {
                        personalizedRecommendations = value;
                      });
                    },
                    activeColor: const Color(0xFF5B5FDC),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Data & analytics settings saved"),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B5FDC),
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showLocationSettings() {
    bool deliveryEstimates = true;
    bool storeFinder = false;
    bool localOffers = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Location Services"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Manage location access for:",
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text("Delivery estimates"),
                    subtitle: const Text("Get accurate delivery times"),
                    value: deliveryEstimates,
                    onChanged: (value) {
                      setDialogState(() {
                        deliveryEstimates = value;
                      });
                    },
                    activeColor: const Color(0xFF5B5FDC),
                  ),
                  SwitchListTile(
                    title: const Text("Store finder"),
                    subtitle: const Text("Find nearby physical stores"),
                    value: storeFinder,
                    onChanged: (value) {
                      setDialogState(() {
                        storeFinder = value;
                      });
                    },
                    activeColor: const Color(0xFF5B5FDC),
                  ),
                  SwitchListTile(
                    title: const Text("Local offers"),
                    subtitle: const Text("Get offers based on your location"),
                    value: localOffers,
                    onChanged: (value) {
                      setDialogState(() {
                        localOffers = value;
                      });
                    },
                    activeColor: const Color(0xFF5B5FDC),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Location settings saved"),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B5FDC),
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _logoutDevice(String deviceName, StateSetter setModalState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout Device"),
        content: Text("Are you sure you want to logout from $deviceName?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setModalState(() {
                _recentDevices.remove(deviceName);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Logged out from $deviceName"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text(
          "Are you sure you want to delete your account? "
          "This action cannot be undone. All your data will be permanently deleted.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Account deletion request submitted"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              "Delete Account",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Terms & Conditions"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                "1. Acceptance of Terms\n"
                "By accessing and using this app, you accept and agree to be bound by these terms.\n\n"
                "2. User Account\n"
                "You are responsible for maintaining the confidentiality of your account.\n\n"
                "3. Orders and Payments\n"
                "All orders are subject to availability and confirmation of the order price.\n\n"
                "4. Returns and Refunds\n"
                "Refer to our return policy for detailed information.\n\n"
                "5. Privacy Policy\n"
                "Your privacy is important to us. Please review our privacy policy.",
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showHelpSupport() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Help & Support",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.email, color: Color(0xFF5B5FDC)),
              title: const Text("Email Support"),
              subtitle: const Text("support@shoestore.com"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.phone, color: Color(0xFF5B5FDC)),
              title: const Text("Call Support"),
              subtitle: const Text("+1 800-123-4567"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Color(0xFF5B5FDC)),
              title: const Text("Live Chat"),
              subtitle: const Text("Available 24/7"),
              onTap: () {},
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Close"),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onLogout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              "Logout",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
