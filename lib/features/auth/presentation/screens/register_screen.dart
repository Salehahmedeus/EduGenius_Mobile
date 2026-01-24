import 'package:easy_localization/easy_localization.dart';
import '../../../../core/widgets/custom_app_bar.dart';
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
      appBar: const CustomAppBar(),
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
                  hintText: "full_name".tr(),
                  prefixIcon: Iconsax.user,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'enter_name_error'.tr() : null,
                ),
                SizedBox(height: 16.h),

                // Phone Field
                CustomTextField(
                  controller: _phoneController,
                  hintText: "phone".tr(),
                  prefixIcon: Iconsax.mobile,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'enter_phone_error'.tr();
                    }
                    if (!value.startsWith('+218')) {
                      return 'phone_prefix_error'.tr();
                    }
                    if (value.length != 14) {
                      return 'phone_length_error'.tr();
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Email Field
                CustomTextField(
                  controller: _emailController,
                  hintText: "email".tr(),
                  prefixIcon: Iconsax.sms,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'enter_email_error'.tr();
                    }
                    final emailRegex = RegExp(
                      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
                    );
                    if (!emailRegex.hasMatch(value)) {
                      return 'valid_email_error'.tr();
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Password Field
                CustomTextField(
                  controller: _passwordController,
                  hintText: "password".tr(),
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
                      return 'enter_password_error'.tr();
                    }
                    if (value.length < 6) {
                      return 'password_length_error'.tr();
                    }
                    return null;
                  },
                ),

                SizedBox(height: 16.h),

                // Confirm Password Field
                CustomTextField(
                  controller: _confirmPasswordController,
                  hintText: "confirm_password".tr(),
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
                      return 'confirm_password_error'.tr();
                    }
                    final password = _passwordController.text;
                    if (value != password) {
                      return 'password_mismatch_error'.tr();
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
                      "agree_terms".tr() + " ",
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
                        "terms_conditions".tr(),
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
                  text: "register".tr(),
                  isLoading: _isLoading,
                  onPressed: _handleRegister,
                ),
                SizedBox(height: 24.h),

                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "already_have_account".tr() + " ",
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
                        "login".tr(),
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
      CustomSnackbar.showWarning(context, "agree_terms_error".tr());
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
                      "registration_success_otp".tr(),
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
