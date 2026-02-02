import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'address_screen.dart';
import 'orders_screen.dart';
import '../utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser; // Get the live user
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      // 1. Try getting email from Firebase Auth (Real)
      // 2. Fallback to SharedPreferences (Legacy)
      // 3. Fallback to Placeholder
      _userEmail =
          user?.email ?? prefs.getString('user_email') ?? 'user@example.com';

      _userPhone = prefs.getString('user_phone') ?? '+91 9876543210';
    });
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
            _buildProfileHeader(),
            const SizedBox(height: 30),
            _buildSectionTitle("Account"),
            _buildMenuTile(
              icon: Icons.location_on,
              title: "Saved Addresses",
              subtitle: "Manage delivery addresses",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddressScreen(),
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
                    builder: (context) => const OrdersScreen(),
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
            color: AppConstants.primaryColor.withOpacity(0.1),
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
            color: AppConstants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppConstants.primaryColor),
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
              backgroundColor: AppConstants.primaryColor,
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
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Payment Methods",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text("Save Payment Information"),
              subtitle: const Text(
                  "Securely save your payment details for faster checkout"),
              value: true,
              onChanged: (value) {},
              activeColor: AppConstants.primaryColor,
            ),
            const Divider(),
            const SizedBox(height: 10),
            const Text(
              "Saved Payment Methods",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "No payment methods saved",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
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
                  backgroundColor: AppConstants.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  "Close",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Notification Settings",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                SwitchListTile(
                  title: const Text("Enable Notifications"),
                  subtitle: const Text("Turn off to disable all notifications"),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                  activeColor: AppConstants.primaryColor,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      "Save Settings",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showPrivacySettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Privacy & Security",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text("Biometric Authentication"),
              subtitle: const Text("Use fingerprint or face ID to log in"),
              value: false,
              onChanged: (value) {},
              activeColor: AppConstants.primaryColor,
            ),
            SwitchListTile(
              title: const Text("Two-Factor Authentication"),
              subtitle:
                  const Text("Add an extra layer of security to your account"),
              value: false,
              onChanged: (value) {},
              activeColor: AppConstants.primaryColor,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  "Save Settings",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
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
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
