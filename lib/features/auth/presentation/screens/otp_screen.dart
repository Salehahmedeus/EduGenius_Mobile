import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lottie/lottie.dart';
import 'package:pinput/pinput.dart';
import '../../data/services/auth_service.dart';
import '../../../../routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class OtpScreen extends StatefulWidget {
  final String? email;

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
    final email = _email;
    if (email.isEmpty) {
      CustomSnackbar.showError(context, "email_not_found".tr());
      return;
    }

    if (_otpController.text.length != 6) {
      CustomSnackbar.showWarning(context, "enter_valid_otp".tr());
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
          CustomSnackbar.showSuccess(context, "otp_verified".tr());
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.dashboard,
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) CustomSnackbar.showError(context, e.toString());
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
        CustomSnackbar.showInfo(context, "otp_resent".tr());
        startTimer();
      }
    } catch (e) {
      if (mounted) CustomSnackbar.showError(context, e.toString());
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
        color: AppColors.primaryLight,
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
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.0.w),
          child: Column(
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
                "verification_code".tr(),
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                "${'verification_msg'.tr()}\n${_email.isNotEmpty ? _email : 'email'.tr()}",
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
                  return s?.length == 6 ? null : 'pin_incorrect'.tr();
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
                      "${'resend_in'.tr()} 00:${_start.toString().padLeft(2, '0')}",
                      style: TextStyle(
                        color: AppColors.getTextSecondary(context),
                        fontSize: 14.sp,
                      ),
                    ),
                  if (_isResendEnabled)
                    TextButton(
                      onPressed: _handleResendOtp,
                      child: Text(
                        "resend_code".tr(),
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
                text: "verify".tr(),
                isLoading: _isLoading,
                onPressed: _handleVerifyOtp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
