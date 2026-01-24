import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:iconsax/iconsax.dart';
import '../../data/services/auth_service.dart';
import '../../../../routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/custom_snackbar.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _handleSendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.sendOtp(_emailController.text.trim());

      if (mounted) {
        CustomSnackbar.showInfo(context, "OTP sent to your email");
        Navigator.pushNamed(
          context,
          Routes.otpVerify,
          arguments: _emailController.text.trim(),
        );
      }
    } catch (e) {
      CustomSnackbar.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
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
              // Logo or Image can go here if needed
              SizedBox(
                width: 200.r,
                height: 200.r,
                child: Image.asset(
                  'assets/images/forgot_password_illustration.png',
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                "Forgot Password?",
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                "Enter your email address to receive a verification code.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: AppColors.grey),
              ),
              SizedBox(height: 48.h),

              // Email Field
              CustomTextField(
                controller: _emailController,
                hintText: "Email",
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
              SizedBox(height: 32.h),

              // Send Button
              CustomButton(
                text: "Send OTP",
                isLoading: _isLoading,
                onPressed: _handleSendOtp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
