import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sleep/auth/infrastructure/otp_repository_impl.dart';

part 'verification_otp_controller.g.dart';

@riverpod
class VerificationOtpController extends _$VerificationOtpController {
  @override
  FutureOr<bool> build() {
    return false;
  }

  Future<bool> verificationOtp(String otp) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      final response =
          await ref.read(otpRepositoryProvider).verificationOtp(otp);
      return response;
    });
    state = result;
    return result.value ?? false;
  }
}
