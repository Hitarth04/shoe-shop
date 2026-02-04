import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main_nav_screen.dart';
import 'signup_screen.dart';
import 'package:shoe_shop/services/auth_service.dart';
import '../../utils/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailResetController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  void _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      emailController.text = prefs.getString('saved_email') ?? '';
      _rememberMe = emailController.text.isNotEmpty;
    });
  }

  // --- NEW: Handle Google Login ---
  void _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    String? result = await AuthService().signInWithGoogle();

    if (!mounted) return;

    if (result == "Success") {
      // Fetch user name (Optional, for UI polish)
      String displayName = "User";
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        displayName = currentUser.displayName?.split(' ').first ?? "User";
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainNavScreen(userName: displayName),
        ),
      );
    } else {
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
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- Image Animation ---
                    TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0.0, 20 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Image.asset(
                        'assets/images/login_page.png',
                        height: 200,
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    // --- Title ---
                    const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 40.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // --- Email Field ---
                    _buildInputField(
                      label: "Email",
                      icon: Icons.email_outlined,
                      controller: emailController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Email is required";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // --- Password Field ---
                    _buildInputField(
                      label: "Password",
                      icon: Icons.lock_outline,
                      isPassword: true,
                      obscureText: _obscurePassword,
                      controller: passwordController,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Password is required";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // --- Forgot Password & Remember Me ---
                    Align(
                      alignment: Alignment.topLeft,
                      child: TextButton(
                        onPressed: () => _showForgotPasswordDialog(context),
                        child: const Text(
                          "Forgot password?",
                          style: TextStyle(color: AppConstants.primaryColor),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          activeColor: AppConstants.primaryColor,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value!;
                            });
                          },
                        ),
                        const Text("Remember Me"),
                      ],
                    ),

                    // --- Login Button ---
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 130,
                        height: 45,
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: AppConstants.primaryColor,
                                ),
                              )
                            : ElevatedButton(
                                onPressed: _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppConstants.secondaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: const Text(
                                  "Login",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- Sign Up Link ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignupScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              color: AppConstants.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // --- NEW: Social Login Divider ---
                    const SizedBox(height: 0),
                    const Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child:
                              Text("OR", style: TextStyle(color: Colors.grey)),
                        ),
                        Expanded(child: Divider(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // --- NEW: Google Login Button ---
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: _handleGoogleLogin, // Calls our new function
                        icon: Image.asset(
                          'assets/images/google.png',
                          height: 24,
                        ),
                        label: const Text(
                          "Sign in with Google",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side:
                              const BorderSide(color: AppConstants.accentColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets & Methods (Unchanged) ---
  Widget _buildInputField({
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    required TextEditingController controller,
    required String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      obscureText: isPassword && obscureText,
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppConstants.primaryColor),
        suffixIcon: suffixIcon,
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppConstants.primaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.accentColor),
        ),
      ),
    );
  }

  void _handleLogin() async {
    FocusScope.of(context).unfocus();

    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('saved_email', emailController.text.trim());
    } else {
      await prefs.remove('saved_email');
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      String displayName = "User";
      if (userDoc.exists && userDoc.data() != null) {
        final fullName = userDoc.get('username') as String;
        if (fullName.isNotEmpty) {
          final firstName = fullName.trim().split(' ').first;
          if (firstName.isNotEmpty) {
            displayName = firstName[0].toUpperCase() +
                firstName.substring(1).toLowerCase();
          }
        }
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainNavScreen(
            userName: displayName,
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? "Authentication failed"),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("An unexpected error occurred"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showForgotPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Enter your email to receive a password reset link:"),
            const SizedBox(height: 15),
            TextFormField(
              controller: emailResetController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailResetController.text.trim();
              if (email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter your email")),
                );
                return;
              }

              try {
                await FirebaseAuth.instance
                    .sendPasswordResetEmail(email: email);

                if (!mounted) return;
                Navigator.pop(context);
                emailResetController.clear();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Password reset link sent to your email"),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Error: ${e.toString()}"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
            ),
            child: const Text(
              "Send Link",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailResetController.dispose();
    super.dispose();
  }
}
