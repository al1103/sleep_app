import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleep/auth/presentation/otp_controller.dart';
import 'package:sleep/auth/presentation/verification_otp_controller.dart';
import 'package:sleep/shared/constants/gaps.dart';
import 'package:sleep/shared/theme/text_styles.dart';

@RoutePage()
class OtpVerificationPage extends ConsumerStatefulWidget {
  const OtpVerificationPage({
    super.key,
    required this.email,
  });
  final String email;

  @override
  ConsumerState<OtpVerificationPage> createState() => _OtpVerificationState();
}

class _OtpVerificationState extends ConsumerState<OtpVerificationPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startTimer();
    });
  }

  void startTimer() {
    ref.read(otpControllerProvider.notifier).resetTimer();
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        final currentValue = ref.read(otpControllerProvider).timer;
        if (currentValue <= 0) {
          timer.cancel();
        } else {
          ref.read(otpControllerProvider.notifier).decrementTimer();
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isComplete = ref.watch(otpControllerProvider).isComplete;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ColoredBox(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 2),
                kGap44,
                _HeaderSection(email: widget.email, onResend: startTimer),
                kGap44,
                const _OTPInputSection(),
                const Spacer(flex: 2),
                _ContinueButton(isEnabled: isComplete, email: widget.email),
                kGap20,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends ConsumerStatefulWidget {
  const _HeaderSection({
    required this.email,
    required this.onResend,
  });
  final String email;
  final VoidCallback onResend;

  @override
  ConsumerState<_HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends ConsumerState<_HeaderSection> {
  @override
  Widget build(BuildContext context) {
    final remainingTime = ref.watch(otpControllerProvider).timer;

    return Column(
      children: [
        const Text(
          'Enter OTP code',
          style: AppTextStyles.title5,
        ),
        kGap12,
        Text(
          'Enter the 6-digit code sent to ${widget.email}',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMdRegular,
        ),
        kGap12,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Didn't receive code? ",
              style: AppTextStyles.bodyMdRegular,
            ),
            GestureDetector(
              onTap: remainingTime <= 0 ? widget.onResend : null,
              child: Text(
                'Request new code',
                style: AppTextStyles.bodyMdSm.copyWith(
                  // ignore: lines_longer_than_80_chars
                  color: remainingTime <= 0
                      ? const Color(0xFF007FFF)
                      : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OTPInputSection extends ConsumerStatefulWidget {
  const _OTPInputSection();

  @override
  ConsumerState<_OTPInputSection> createState() => _OTPInputSectionState();
}

class _OTPInputSectionState extends ConsumerState<_OTPInputSection> {
  late final List<FocusNode> focusNodes;
  late final List<TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    focusNodes = List.generate(6, (index) => FocusNode());
    controllers = List.generate(6, (index) => TextEditingController());
  }

  @override
  void dispose() {
    for (final node in focusNodes) {
      node.dispose();
    }
    for (final controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void checkComplete() {
    final otp = controllers.map((c) => c.text).join();
    ref.read(otpControllerProvider.notifier).setOtp(otp);
    ref.read(otpControllerProvider.notifier).setIsComplete(otp.length == 6);
  }

  @override
  Widget build(BuildContext context) {
    final remainingTime = ref.watch(otpControllerProvider).timer;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            6,
            (index) => CustomOTPTextField(
              controller: controllers[index],
              focusNode: focusNodes[index],
              onChanged: (value) {
                if (value.length == 1 && index < 5) {
                  focusNodes[index + 1].requestFocus();
                }
                if (value.isEmpty && index > 0) {
                  focusNodes[index - 1].requestFocus();
                }
                checkComplete();
              },
            ),
          ),
        ),
        kGap32,
        Text(
          '${remainingTime}s',
          style: AppTextStyles.bodyMdSm,
        ),
      ],
    );
  }
}

class _ContinueButton extends ConsumerWidget {
  const _ContinueButton({
    required this.isEnabled,
    required this.email,
  });

  final String email;
  final bool isEnabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: isEnabled
          ? () async {
              final result = await ref
                  .read(verificationOtpControllerProvider.notifier)
                  .verificationOtp(ref.read(otpControllerProvider).otp);

              if (result && context.mounted) {
                await showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Thành công'),
                    content: const Text('Xác thực OTP thành công'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              } else {
                await showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Thất bại'),
                    content: const Text('Xác thực OTP không thành công'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            }
          : null,
      child: Container(
        width: double.infinity,
        height: 40,
        decoration: ShapeDecoration(
          color: isEnabled ? const Color(0xFF007FFF) : Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Center(
          child: Text(
            'Continue',
            style: AppTextStyles.bodyLgSm.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class CustomOTPTextField extends StatelessWidget {
  const CustomOTPTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  // ignore: inference_failure_on_function_return_type
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        maxLength: 1,
        keyboardType: TextInputType.number,
        onChanged: onChanged,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF007FFF)),
          ),
        ),
        style: AppTextStyles.bodyLgMd,
      ),
    );
  }
}
