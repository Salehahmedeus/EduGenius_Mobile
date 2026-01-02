import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../data/services/auth_service.dart';
import '../../../../routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>(); // Added form key for validation
  bool _isLoading = false;
  bool _agreeToTerms = false;
  bool _isPasswordVisible = false;

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    // Check terms if strictly required by design, though usually for signup
    if (!_agreeToTerms) {
      Fluttertoast.showToast(msg: "Please agree to the terms and conditions");
      return;
    }

    setState(() => _isLoading = true);

    try {
      bool success = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success) {
        if (mounted) {
          Fluttertoast.showToast(msg: "Login Successful!");
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.dashboard,
            (route) => false,
          );
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD32F2F)),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.welcome,
            (route) => false,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Logo
              SizedBox(
                width: 120,
                height: 120,
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
              const SizedBox(height: 48),

              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: "Email",
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: const Icon(
                    Icons.email_outlined,
                    color: Colors.grey,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  hintText: "Password",
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Terms Checkbox
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text("Agree with ", style: TextStyle(fontSize: 14)),
                  GestureDetector(
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

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
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
                          "Login",
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
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, Routes.register);
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Color(0xFFD32F2F),
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
    );
  }
}
