import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';
import '../../../../routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController(); // Added phone controller
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _agreeToTerms = false;
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD32F2F)),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                // Logo
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Image.asset('assets/images/logo.png'),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Edu Genius",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD32F2F),
                  ),
                ),
                const SizedBox(height: 32),

                // Name Field
                _buildTextField(
                  controller: _nameController,
                  hintText: "Full Name",
                  icon: Icons.person_outline,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 16),

                // Phone Field
                _buildTextField(
                  controller: _phoneController,
                  hintText: "Phone Number",
                  icon: Icons.phone_android,
                  keyboardType: TextInputType.phone,
                  // Phone is visual only for now as AuthService doesn't support it yet
                ),
                const SizedBox(height: 16),

                // Email Field
                _buildTextField(
                  controller: _emailController,
                  hintText: "Email Address",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter your email' : null,
                ),
                const SizedBox(height: 16),

                // Password Field
                _buildTextField(
                  controller: _passwordController,
                  hintText: "Password",
                  icon: _isPasswordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  isObscure: !_isPasswordVisible,
                  onIconPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter password' : null,
                ),
                const SizedBox(height: 16),

                // Terms Checkbox
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text("Agree with ", style: TextStyle(fontSize: 14)),
                    GestureDetector(
                      onTap: () {
                        // TODO: Show terms
                      },
                      child: const Text(
                        "Terms & Conditions",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFD32F2F),
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFFD32F2F),
                        ),
                      ),
                    ),
                    Checkbox(
                      value: _agreeToTerms,
                      activeColor: const Color(0xFFD32F2F),
                      onChanged: (value) {
                        setState(() {
                          _agreeToTerms = value ?? false;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Register",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(
                          context,
                        ); // Go back to Login (assuming pushed from Login or has route)
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Color(0xFFD32F2F),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isObscure = false,
    TextInputType? keyboardType,
    VoidCallback? onIconPressed,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(icon, color: Colors.grey),
          onPressed:
              onIconPressed, // Null if not clickable (like non-password fields)
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }

  void _handleRegister() {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please agree to the Terms & Conditions")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Using AuthService to register
    AuthService()
        .register(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
        )
        .then((success) {
          if (success && mounted) {
            // Navigate to Dashboard or Login
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.dashboard,
              (route) => false,
            );
          }
        })
        .catchError((e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString()),
                backgroundColor: Colors.red,
              ),
            );
          }
        })
        .whenComplete(() {
          if (mounted) setState(() => _isLoading = false);
        });
  }
}
