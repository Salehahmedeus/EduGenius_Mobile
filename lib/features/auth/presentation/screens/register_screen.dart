import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:iconsax/iconsax.dart';
import '../../data/services/auth_service.dart';
import '../../../../routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/custom_snackbar.dart';

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
  final _confirmPasswordController =
      TextEditingController(); // Added confirm password controller
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _agreeToTerms = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible =
      false; // Added confirm password visibility state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: AppColors.primary),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.0.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10.h),
                // Logo
                SizedBox(
                  width: 100.r,
                  height: 100.r,
                  child: Image.asset('assets/images/logo.png'),
                ),
                SizedBox(height: 16.h),
                Text(
                  "Edu Genius",
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 32.h),

                // Name Field
                CustomTextField(
                  controller: _nameController,
                  hintText: "Full Name",
                  prefixIcon: Iconsax.user,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter your name' : null,
                ),
                SizedBox(height: 16.h),

                // Phone Field
                CustomTextField(
                  controller: _phoneController,
                  hintText: "Phone Number",
                  prefixIcon: Iconsax.mobile,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (!value.startsWith('+218')) {
                      return 'Phone number must start with +218';
                    }
                    if (value.length != 14) {
                      return 'Phone number must be exactly 14 digits';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Email Field
                CustomTextField(
                  controller: _emailController,
                  hintText: "Email Address",
                  prefixIcon: Iconsax.sms,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    final emailRegex = RegExp(
                      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
                    );
                    if (!emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Password Field
                CustomTextField(
                  controller: _passwordController,
                  hintText: "Password",
                  isObscure: !_isPasswordVisible,
                  prefixIcon: Iconsax.lock,
                  suffixIcon: _isPasswordVisible
                      ? Iconsax.eye
                      : Iconsax.eye_slash,
                  onSuffixIconPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 16.h),

                // Confirm Password Field
                CustomTextField(
                  controller: _confirmPasswordController,
                  hintText: "Confirm Password",
                  isObscure: !_isConfirmPasswordVisible,
                  prefixIcon: Iconsax.lock,
                  suffixIcon: _isConfirmPasswordVisible
                      ? Iconsax.eye
                      : Iconsax.eye_slash,
                  onSuffixIconPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    final password = _passwordController.text;
                    if (value != password) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Terms Checkbox
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Agree with ",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.getTextPrimary(context),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // TODO: Show terms
                      },
                      child: Text(
                        "Terms & Conditions",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary,
                        ),
                      ),
                    ),
                    Checkbox(
                      value: _agreeToTerms,
                      activeColor: AppColors.primary,
                      side: BorderSide(
                        color: AppColors.getTextSecondary(context),
                        width: 1.5,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _agreeToTerms = value ?? false;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // Register Button
                CustomButton(
                  text: "Register",
                  isLoading: _isLoading,
                  onPressed: _handleRegister,
                ),
                SizedBox(height: 24.h),

                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.getTextPrimary(context),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(
                          context,
                        ); // Go back to Login (assuming pushed from Login or has route)
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleRegister() {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      CustomSnackbar.showWarning(
        context,
        "Please agree to the Terms & Conditions",
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
            // Send OTP and Navigate to OTP verify
            AuthService()
                .sendOtp(_emailController.text.trim())
                .then((_) {
                  if (mounted) {
                    CustomSnackbar.showSuccess(
                      context,
                      "Registration successful! OTP sent.",
                    );
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      Routes.otpVerify,
                      (route) => false,
                      arguments: _emailController.text.trim(),
                    );
                  }
                })
                .catchError((e) {
                  if (mounted) {
                    CustomSnackbar.showError(
                      context,
                      "Registration successful but failed to send OTP: $e",
                    );
                    // Optionally navigate to login or dashboard anyway if OTP isn't strict blocking,
                    // but user requested verification.
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      Routes.login,
                      (route) => false,
                    );
                  }
                });
          }
        })
        .catchError((e) {
          if (mounted) {
            CustomSnackbar.showError(context, e.toString());
          }
        })
        .whenComplete(() {
          if (mounted) setState(() => _isLoading = false);
        });
  }
}
