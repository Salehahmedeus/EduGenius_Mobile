import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:iconsax/iconsax.dart';
import '../../data/services/auth_service.dart';
import '../../../../routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/custom_app_bar.dart';

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
        CustomSnackbar.showInfo(context, "otp_sent_email".tr());
        Navigator.pushNamed(
          context,
          Routes.otpVerify,
          arguments: _emailController.text.trim(),
        );
      }
    } catch (e) {
      if (mounted) CustomSnackbar.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.0.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20.h),
                SizedBox(
                  width: 200.r,
                  height: 200.r,
                  child: Image.asset(
                    'assets/images/forgot_password_illustration.png',
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  "forgot_password_title".tr(),
                  style: TextStyle(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  "forgot_password_msg".tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.getTextSecondary(context),
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
                SizedBox(height: 32.h),

                // Send Button
                CustomButton(
                  text: "send_otp".tr(),
                  isLoading: _isLoading,
                  onPressed: _handleSendOtp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
