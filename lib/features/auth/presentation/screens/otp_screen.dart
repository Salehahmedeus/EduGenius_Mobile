import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:pinput/pinput.dart';
import '../../data/services/auth_service.dart';
import '../../../../routes.dart';
import '../../../../core/widgets/custom_button.dart';
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
      Fluttertoast.showToast(
        msg: "Email not found. Please try again.",
        backgroundColor: Colors.red,
      );
      return;
    }

    if (_otpController.text.length != 6) {
      Fluttertoast.showToast(msg: "Please enter a valid 6-digit OTP");
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
          Fluttertoast.showToast(msg: "OTP Verified!");
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.dashboard, // Or appropriate next screen
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

  void _handleResendOtp() async {
    final email = _email;
    if (email.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await _authService.sendOtp(email);
      if (mounted) {
        Fluttertoast.showToast(msg: "OTP resent successfully");
        startTimer();
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Color(0xFFD32F2F),
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE), // Light red/pink background
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.transparent),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: const Color(0xFFD32F2F)),
    );

    final submittedPinTheme = defaultPinTheme.copyDecorationWith(
      color: const Color(0xFFFFCDD2),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD32F2F)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          // Removed Form widget wrapper as Pinput handles its own state mostly, simplified for now
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              height: 200,
              child: Lottie.asset('assets/animations/otp_animation.json'),
            ),
            const SizedBox(height: 24),
            const Text(
              "Verification Code",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD32F2F),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "We have sent the code verification to\n${_email.isNotEmpty ? _email : 'your email'}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 48),

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

            const SizedBox(height: 24),

            // Timer and Resend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isResendEnabled)
                  Text(
                    "Resend code in 00:${_start.toString().padLeft(2, '0')}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                if (_isResendEnabled)
                  TextButton(
                    onPressed: _handleResendOtp,
                    child: const Text(
                      "Resend Code",
                      style: TextStyle(
                        color: Color(0xFFD32F2F),
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
