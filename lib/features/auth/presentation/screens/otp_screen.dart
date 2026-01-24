import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:pinput/pinput.dart';
import '../../data/services/auth_service.dart';
import '../../../../routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_snackbar.dart';
// import '../../../../core/widgets/custom_text_field.dart'; // No longer needed here

class OtpScreen extends StatefulWidget {
  final String? email; // Passed from ForgotPasswordScreen

  const OtpScreen({super.key, this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  Timer? _timer;
  int _start = 60;
  bool _isResendEnabled = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void startTimer() {
    setState(() {
      _isResendEnabled = false;
      _start = 60;
    });
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
          _isResendEnabled = true;
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  String get _email {
    final emailArg = ModalRoute.of(context)?.settings.arguments as String?;
    return widget.email ?? emailArg ?? '';
  }

  void _handleVerifyOtp() async {
    // Form validation might not work directly with Pinput if wrapped in Form in duplicate way,
    // but Pinput has its own validator. For now, we check manually or use form.

    final email = _email;
    if (email.isEmpty) {
      CustomSnackbar.showError(context, "Email not found. Please try again.");
      return;
    }

    if (_otpController.text.length != 6) {
      CustomSnackbar.showWarning(context, "Please enter a valid 6-digit OTP");
      return;
    }

    setState(() => _isLoading = true);

    try {
      bool success = await _authService.verifyOtp(
        email,
        _otpController.text.trim(),
      );

      if (success) {
        if (mounted) {
          CustomSnackbar.showSuccess(context, "OTP Verified!");
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.dashboard, // Or appropriate next screen
            (route) => false,
          );
        }
      }
    } catch (e) {
      CustomSnackbar.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleResendOtp() async {
    final email = _email;
    if (email.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await _authService.sendOtp(email);
      if (mounted) {
        CustomSnackbar.showInfo(context, "OTP resent successfully");
        startTimer();
      }
    } catch (e) {
      CustomSnackbar.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 50.w,
      height: 60.h,
      textStyle: TextStyle(
        fontSize: 22.sp,
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryLight, // Light red/pink background
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.transparent),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppColors.primary),
    );

    final submittedPinTheme = defaultPinTheme.copyDecorationWith(
      color: AppColors.primaryMedium,
    );

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.0.w),
        child: Column(
          // Removed Form widget wrapper as Pinput handles its own state mostly, simplified for now
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20.h),
            SizedBox(
              width: 200.r,
              height: 200.r,
              child: Lottie.asset('assets/animations/otp_animation.json'),
            ),
            SizedBox(height: 24.h),
            Text(
              "Verification Code",
              style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              "We have sent the code verification to\n${_email.isNotEmpty ? _email : 'your email'}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.getTextSecondary(context),
              ),
            ),
            SizedBox(height: 48.h),

            // Pinput Field
            Pinput(
              length: 6,
              controller: _otpController,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedPinTheme,
              submittedPinTheme: submittedPinTheme,
              validator: (s) {
                return s?.length == 6 ? null : 'Pin is incorrect';
              },
              pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
              showCursor: true,
              onCompleted: (pin) => print(pin),
            ),

            SizedBox(height: 24.h),

            // Timer and Resend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isResendEnabled)
                  Text(
                    "Resend code in 00:${_start.toString().padLeft(2, '0')}",
                    style: TextStyle(
                      color: AppColors.getTextSecondary(context),
                      fontSize: 14.sp,
                    ),
                  ),
                if (_isResendEnabled)
                  TextButton(
                    onPressed: _handleResendOtp,
                    child: Text(
                      "Resend Code",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // Verify Button
            CustomButton(
              text: "Verify",
              isLoading: _isLoading,
              onPressed: _handleVerifyOtp,
            ),
          ],
        ),
      ),
    );
  }
}
