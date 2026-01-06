import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'main_nav_screen.dart';

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
      backgroundColor: const Color(0xFF5B5FDC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5B5FDC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Navigate back to WelcomeScreen
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
                    // Animated image
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

                    // Animated title
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

                    /// Name
                    _inputField(
                      label: "Full Name",
                      icon: Icons.person_outline,
                      keyboardType: TextInputType.name,
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

                    /// Email
                    _inputField(
                      label: "Email",
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
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

                    /// Password
                    _inputField(
                      label: "Password",
                      icon: Icons.lock_outline,
                      isPassword: true,
                      obscureText: _obscurePassword,
                      keyboardType: TextInputType.visiblePassword,
                      controller: passwordController,
                      onChanged: (value) {
                        // Trigger re-validation of confirm password when password changes
                        if (confirmPasswordController.text.isNotEmpty) {
                          _formKey.currentState?.validate();
                        }
                      },
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

                    /// Confirm Password
                    _inputField(
                      label: "Confirm Password",
                      icon: Icons.lock_outline,
                      isPassword: true,
                      obscureText: _obscureConfirmPassword,
                      keyboardType: TextInputType.visiblePassword,
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

                    // Password strength indicator (optional)
                    if (passwordController.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 12),
                        child: _buildPasswordStrength(),
                      ),

                    const SizedBox(height: 15),

                    /// Phone Number
                    _inputField(
                      label: "Phone Number",
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
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

                    /// Signup Button (bottom-right)
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 140,
                        height: 45,
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF5B5FDC),
                                ),
                              )
                            : ElevatedButton(
                                onPressed: _handleSignup,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF5B5FDC),
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

                    /// Already have account
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
                              color: Color(0xFF5B5FDC),
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

  /// Reusable Input Field with validator
  Widget _inputField({
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    required TextInputType keyboardType,
    TextEditingController? controller,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      obscureText: isPassword && obscureText,
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF5B5FDC)),
        suffixIcon: suffixIcon,
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF5B5FDC), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }

  void _handleSignup() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            const Text("Account created successfully!"),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );

    await Future.delayed(const Duration(seconds: 1));

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
  }

  /// Password strength indicator (optional feature)
  Widget _buildPasswordStrength() {
    final password = passwordController.text;
    int strength = 0;

    if (password.length >= 6) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    String strengthText;
    Color strengthColor;

    switch (strength) {
      case 0:
      case 1:
        strengthText = "Weak";
        strengthColor = Colors.red;
        break;
      case 2:
      case 3:
        strengthText = "Medium";
        strengthColor = Colors.orange;
        break;
      case 4:
      case 5:
        strengthText = "Strong";
        strengthColor = Colors.green;
        break;
      default:
        strengthText = "Weak";
        strengthColor = Colors.red;
    }

    return Row(
      children: [
        Text(
          "Strength: ",
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        Text(
          strengthText,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: strengthColor,
          ),
        ),
      ],
    );
  }
}
