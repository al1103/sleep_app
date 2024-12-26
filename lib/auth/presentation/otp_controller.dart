import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtpController extends StateNotifier<OtpState> {
  OtpController() : super(OtpState.initial());

  void setOtp(String otp) {
    state = state.copyWith(otp: otp);
  }

  void setIsComplete(bool isComplete) {
    state = state.copyWith(isComplete: isComplete);
  }

  void resetTimer() {
    state = state.copyWith(timer: 60);
  }

  void decrementTimer() {
    if (state.timer > 0) {
      state = state.copyWith(timer: state.timer - 1);
    }
  }
}

class OtpState {

  OtpState({
    required this.otp,
    required this.isComplete,
    required this.timer,
  });

  factory OtpState.initial() {
    return OtpState(
      otp: '',
      isComplete: false,
      timer: 60,
    );
  }
  final String otp;
  final bool isComplete;
  final int timer;

  OtpState copyWith({
    String? otp,
    bool? isComplete,
    int? timer,
  }) {
    return OtpState(
      otp: otp ?? this.otp,
      isComplete: isComplete ?? this.isComplete,
      timer: timer ?? this.timer,
    );
  }
}

final otpControllerProvider =
    StateNotifierProvider<OtpController, OtpState>((ref) => OtpController());
