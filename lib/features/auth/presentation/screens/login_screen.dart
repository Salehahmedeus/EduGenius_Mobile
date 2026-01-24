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
  bool _isPasswordVisible = false;

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      bool success = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success) {
        // Send OTP after successful login credentials check
        await _authService.sendOtp(_emailController.text.trim());

        if (mounted) {
          CustomSnackbar.showSuccess(context, "otp_sent".tr());
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.otpVerify,
            (route) => false,
            arguments: _emailController.text.trim(),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        onBackPress: () => Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.welcome,
          (route) => false,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.0.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20.h),
              // Logo
              SizedBox(
                width: 120.r,
                height: 120.r,
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
              SizedBox(height: 48.h),

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

              const SizedBox(height: 16),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, Routes.forgotPassword);
                  },
                  child: Text(
                    "forgot_password".tr(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Removed Terms Checkbox
              SizedBox(height: 24.h),

              // Login Button
              CustomButton(
                text: "login".tr(),
                isLoading: _isLoading,
                onPressed: _handleLogin,
              ),

              SizedBox(height: 24.h),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "dont_have_account".tr() + " ",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.getTextPrimary(context),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, Routes.register);
                    },
                    child: Text(
                      "sign_up".tr(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.primary,
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
