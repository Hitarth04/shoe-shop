import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'home_screen.dart';
import 'cart_screen.dart';
import 'cart_model.dart';

class MainNavScreen extends StatefulWidget {
  final String userName;

  const MainNavScreen({super.key, required this.userName});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int currentIndex = 0;
  DateTime? currentBackPressTime;
  int _cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    _updateCartCount();
  }

  // Method to switch tabs
  void _switchToHomeTab() {
    setState(() {
      currentIndex = 0;
    });
  }

  // Method to update cart count
  void _updateCartCount() {
    final newCount = Cart.items.fold(0, (sum, item) => sum + item.quantity);
    if (newCount != _cartItemCount) {
      setState(() {
        _cartItemCount = newCount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        userName: widget.userName,
        onCartUpdated: _updateCartCount, // Pass callback to HomeScreen
      ),
      CartScreen(
        onContinueShopping: _switchToHomeTab,
        onCartUpdated: _updateCartCount, // Pass callback to CartScreen
      ),
    ];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: screens[currentIndex],
        bottomNavigationBar: _buildGoogleNavBar(),
      ),
    );
  }

  Widget _buildGoogleNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          child: GNav(
            // Center the tabs properly
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,

            // Visual properties
            backgroundColor: Colors.white,
            rippleColor: const Color(0xFF5B5FDC).withOpacity(0.1),
            hoverColor: const Color(0xFF5B5FDC).withOpacity(0.1),
            gap: 10,
            activeColor: Colors.white,
            iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            duration: const Duration(milliseconds: 400),
            tabBackgroundColor: const Color(0xFF5B5FDC),
            color: Colors.grey[600],

            // Tabs
            tabs: [
              const GButton(
                icon: Icons.home,
                text: 'Home',
                textStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              GButton(
                icon: Icons.shopping_cart,
                text: 'Cart',
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                // Use Stack for badge
                iconActiveColor: Colors.white,
                iconColor: Colors.grey[700],
                leading: Stack(
                  children: [
                    const Icon(Icons.shopping_cart_rounded),
                    if (_cartItemCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            _cartItemCount > 9
                                ? '9+'
                                : _cartItemCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            selectedIndex: currentIndex,
            onTabChange: (index) {
              setState(() {
                currentIndex = index;
                // Update cart count when switching to cart tab
                if (index == 1) {
                  _updateCartCount();
                }
              });
            },
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() {
    // If not on home tab, switch to home tab
    if (currentIndex != 0) {
      setState(() {
        currentIndex = 0;
      });
      return Future.value(false);
    }

    // If on home tab, implement double tap to exit
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFF5B5FDC),
        ),
      );
      return Future.value(false);
    }

    return Future.value(true);
  }
}
