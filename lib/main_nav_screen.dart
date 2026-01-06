import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'home_screen.dart';
import 'cart_screen.dart';
import 'wishlist_screen.dart'; // Add this import
import 'cart_model.dart';
import 'wishlist_model.dart'; // Add this import

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
  int _wishlistCount = 0; // Add wishlist counter

  @override
  void initState() {
    super.initState();
    _updateCartCount();
    _updateWishlistCount(); // Initialize wishlist count
  }

  void _switchToHomeTab() {
    setState(() {
      currentIndex = 0;
    });
  }

  void _updateCartCount() {
    final newCount = Cart.items.fold(0, (sum, item) => sum + item.quantity);
    if (newCount != _cartItemCount) {
      setState(() {
        _cartItemCount = newCount;
      });
    }
  }

  void _updateWishlistCount() {
    final newCount = Wishlist.count;
    if (newCount != _wishlistCount) {
      setState(() {
        _wishlistCount = newCount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        userName: widget.userName,
        onCartUpdated: _updateCartCount,
        onWishlistUpdated: _updateWishlistCount, // Add this
      ),
      WishlistScreen(
        // Add wishlist screen
        onWishlistUpdated: _updateWishlistCount,
        onCartUpdated: _updateCartCount,
      ),
      CartScreen(
        onContinueShopping: _switchToHomeTab,
        onCartUpdated: _updateCartCount,
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            tabMargin: const EdgeInsets.symmetric(horizontal: 8),
            tabBorderRadius: 12,
            backgroundColor: Colors.white,
            rippleColor: const Color(0xFF5B5FDC).withOpacity(0.2),
            hoverColor: const Color(0xFF5B5FDC).withOpacity(0.1),
            gap: 8,
            activeColor: Colors.white,
            iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            duration: const Duration(milliseconds: 400),
            tabBackgroundColor: const Color(0xFF5B5FDC),
            color: Colors.grey[700],
            tabs: [
              const GButton(
                icon: Icons.home,
                text: 'Home',
                textStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFFFFFFF),
                ),
              ),
              GButton(
                icon: Icons.favorite,
                text: 'Wishlist',
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFFFFFFF),
                ),
                iconActiveColor: const Color(0xFFFFFFFF),
                leading: Stack(
                  children: [
                    const Icon(Icons.favorite_border),
                    if (_wishlistCount > 0)
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
                            _wishlistCount > 99
                                ? '99+'
                                : _wishlistCount.toString(),
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
              GButton(
                icon: Icons.shopping_cart,
                text: 'Cart',
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFFFFFFF),
                ),
                leading: Stack(
                  children: [
                    const Icon(Icons.shopping_cart_outlined),
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
                            _cartItemCount > 99
                                ? '99+'
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
                // Update counts when switching tabs
                if (index == 1) _updateWishlistCount();
                if (index == 2) _updateCartCount();
              });
            },
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() {
    if (currentIndex != 0) {
      setState(() {
        currentIndex = 0;
      });
      return Future.value(false);
    }

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
