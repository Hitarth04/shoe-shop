import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shoe_shop/services/auth_service.dart'; // Ensure this path is correct
import '../main_nav_screen.dart'; // Ensure this path is correct
import 'login_screen.dart';
import 'signup_screen.dart';
import '../../utils/constants.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isLoading = false;

  void _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    String? result = await AuthService().signInWithGoogle();

    if (!mounted) return;

    if (result == "Success") {
      // Fetch user name to pass to MainNav (Optional, but nice for UX)
      String displayName = "User";
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // Try to get name from Firestore or fallback to Auth Display Name
        displayName = currentUser.displayName?.split(' ').first ?? "User";
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainNavScreen(userName: displayName),
        ),
      );
    } else {
      // Only show error if result is not null (null means user cancelled)
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result), backgroundColor: Colors.red),
        );
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main Content
          SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Image.asset(
                      'assets/images/home_page.png',
                      height:
                          300, // Added a height constraint to prevent overflow
                    ),
                    const SizedBox(height: 30.0),
                    const Text(
                      'Hello!',
                      style: TextStyle(
                        fontSize: 40.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    const Text(
                      'Welcome to our app, where you shop for all the shoe fashion you need!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 40.0),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupScreen(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          side: const BorderSide(
                            color: AppConstants.primaryColor,
                          ),
                        ),
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 16,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    const Text(
                      'Sign in using',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Facebook Button (Placeholder for now)
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      "Facebook Login not implemented yet")),
                            );
                          },
                          child: Image.asset(
                            'assets/images/facebook.png',
                            height: 40.0,
                          ),
                        ),
                        const SizedBox(width: 20.0),

                        // Google Button (Now Functional!)
                        GestureDetector(
                          onTap: _handleGoogleLogin,
                          child: Image.asset(
                            'assets/images/google.png',
                            height: 40.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppConstants.primaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
