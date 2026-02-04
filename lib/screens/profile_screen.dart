import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'address_screen.dart';
import 'orders_screen.dart';
import '../utils/constants.dart';

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

class _ProfileScreenState extends State<ProfileScreen>
    with WidgetsBindingObserver {
  String? _userEmail;
  String? _userPhone;
  bool _notificationsEnabled = false;
  bool _locationEnabled = false; // 1. Added State Variable

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserData();
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
    }
  }

  // 2. Updated to check BOTH permissions
  Future<void> _checkPermission() async {
    final notifStatus = await Permission.notification.status;
    final locStatus = await Permission.location.status;

    if (mounted) {
      setState(() {
        _notificationsEnabled = notifStatus.isGranted;
        _locationEnabled = locStatus.isGranted;
      });
    }
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    final prefs = await SharedPreferences.getInstance();

    setState(() {
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
        backgroundColor: Colors.white,
        title: const Text("My Profile"),
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
            // 3. Added Location Tile Here
            _buildMenuTile(
              icon: Icons.my_location,
              title: "Location Access",
              subtitle: "Manage location permissions",
              onTap: _showLocationSettings,
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
              widget.userName.isNotEmpty
                  ? widget.userName[0].toUpperCase()
                  : "U",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
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
          icon: const Icon(Icons.edit, color: AppConstants.primaryColor),
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
      color: Colors.grey.shade100,
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
          child: Icon(
            icon,
            color: AppConstants.primaryColor,
          ),
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

  void _showNotificationsSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(20),
            height: 250,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Notification Settings",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                SwitchListTile(
                  title: const Text("Enable Notifications"),
                  value: _notificationsEnabled,
                  activeColor: AppConstants.primaryColor,
                  onChanged: (value) async {
                    if (value) {
                      PermissionStatus status =
                          await Permission.notification.request();

                      if (status.isGranted) {
                        setState(() => _notificationsEnabled = true);
                        setModalState(() {});
                      } else {
                        if (mounted) {
                          Navigator.pop(context);
                          _showPermissionDeniedDialog("Notifications");
                        }
                      }
                    } else {
                      if (mounted) {
                        Navigator.pop(context);
                        await openAppSettings();
                      }
                    }
                  },
                ),
                const Spacer(),
                const Text(
                  "Note: To change settings, you may need to visit system settings.",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  // 4. Added Location Settings Bottom Sheet (Same Logic)
  void _showLocationSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(20),
            height: 250,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Location Settings",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                SwitchListTile(
                  title: const Text("Allow Location Access"),
                  value: _locationEnabled,
                  activeColor: AppConstants.primaryColor,
                  onChanged: (value) async {
                    if (value) {
                      PermissionStatus status =
                          await Permission.location.request();

                      if (status.isGranted) {
                        setState(() => _locationEnabled = true);
                        setModalState(() {});
                      } else {
                        if (mounted) {
                          Navigator.pop(context);
                          _showPermissionDeniedDialog("Location");
                        }
                      }
                    } else {
                      if (mounted) {
                        Navigator.pop(context);
                        await openAppSettings();
                      }
                    }
                  },
                ),
                const Spacer(),
                const Text(
                  "Note: Location is used to auto-fill your address on the map.",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  // 5. Updated Dialog to handle generic feature names
  void _showPermissionDeniedDialog(String feature) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Permission Required"),
        content: Text(
            "$feature access is disabled for this app. Please enable it in your phone's settings."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor),
            child: const Text("Open Settings",
                style: TextStyle(color: Colors.white)),
          ),
        ],
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
        backgroundColor: Colors.white,
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
            child: const Text(
              "Cancel",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
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
              backgroundColor: AppConstants.secondaryColor,
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
            const Text("Payment Methods",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Center(
                child: Text("No payment methods saved",
                    style: TextStyle(color: Colors.grey))),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor),
                child:
                    const Text("Close", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacySettings() {
    // ... (Your existing _showPrivacySettings logic remains identical)
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Privacy & Security",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text("Biometric Authentication"),
              value: false,
              onChanged: (val) {},
              activeColor: AppConstants.primaryColor,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor),
                child: const Text("Save Settings",
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTermsAndConditions() {
    // ... (Your existing logic)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Terms & Conditions"),
        content: const SingleChildScrollView(
          child: Text(
              "1. Acceptance of Terms\n\n2. User Account\n\n3. Orders and Payments..."),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close")),
        ],
      ),
    );
  }

  void _showHelpSupport() {
    // ... (Your existing logic)
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Help & Support",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
                leading: const Icon(Icons.email),
                title: const Text("Email Support")),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation() {
    // ... (Your existing logic)
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
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
