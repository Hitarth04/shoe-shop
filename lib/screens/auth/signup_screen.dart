import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../main_nav_screen.dart';
import 'package:shoe_shop/services/auth_service.dart';
import '../../utils/constants.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
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
                  children: [
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
                        'assets/images/sign_up.png',
                        height: 170,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 600),
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.scale(
                            scale: 0.8 + 0.2 * value,
                            child: child,
                          ),
                        );
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildInputField(
                      label: "Full Name",
                      icon: Icons.person_outline,
                      controller: nameController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Full name is required";
                        }
                        if (value.trim().split(' ').length < 2) {
                          return "Please enter your full name";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    _buildInputField(
                      label: "Email",
                      icon: Icons.email_outlined,
                      controller: emailController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Email is required";
                        }
                        final emailRegex = RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                        if (!emailRegex.hasMatch(value.trim())) {
                          return "Please enter a valid email";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
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
                        if (value.length < 6) {
                          return "Password must be at least 6 characters";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    _buildInputField(
                      label: "Confirm Password",
                      icon: Icons.lock_outline,
                      isPassword: true,
                      obscureText: _obscureConfirmPassword,
                      controller: confirmPasswordController,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please confirm your password";
                        }
                        if (value != passwordController.text) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    _buildInputField(
                      label: "Phone Number",
                      icon: Icons.phone,
                      controller: phoneController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Phone number is required";
                        }
                        final phoneRegex = RegExp(r'^[0-9]{10}$');
                        if (!phoneRegex.hasMatch(value.trim())) {
                          return "Please enter a valid 10-digit phone number";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 140,
                        height: 45,
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: AppConstants.primaryColor,
                                ),
                              )
                            : ElevatedButton(
                                onPressed: _handleSignup,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppConstants.secondaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: const Text(
                                  "Sign Up",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              color: AppConstants.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

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

  void _handleSignup() async {
    FocusScope.of(context).unfocus();

    // 1. Basic Form Validation
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 2. Password Match Check (Already covered by validator, but safe to keep)
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // 3. Call the Firebase Logic
    String? result = await AuthService().signUpUser(
      username: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      phoneNumber: phoneController.text.trim(),
    );

    // Check if widget is still in the tree before updating state
    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    // 4. Handle the Outcome
    if (result == "Success") {
      // We use postFrameCallback to ensure the 'loading' state is fully rendered
      // before we jump to a new screen.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Account created successfully!"),
            backgroundColor: Colors.green,
          ),
        );

        final fullName = nameController.text.trim();
        final firstName = fullName.split(' ').first;
        final capitalizedFirstName =
            firstName[0].toUpperCase() + firstName.substring(1).toLowerCase();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainNavScreen(
              userName: capitalizedFirstName,
            ),
          ),
        );
      });
    } else {
      // 5. Show Error if result is not "Success"
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result ?? "An unknown error occurred"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
