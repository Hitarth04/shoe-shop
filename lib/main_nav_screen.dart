import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'cart_screen.dart';

class MainNavScreen extends StatefulWidget {
  final String userName;

  const MainNavScreen({super.key, required this.userName});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int currentIndex = 0;
  DateTime? currentBackPressTime;

  // Method to switch tabs
  void _switchToHomeTab() {
    setState(() {
      currentIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(userName: widget.userName),
      CartScreen(onContinueShopping: _switchToHomeTab),
    ];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: screens[currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => setState(() => currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: "Cart",
            ),
          ],
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
