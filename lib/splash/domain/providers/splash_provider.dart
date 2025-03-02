import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SplashState {
  initializing,
  authenticated,
  unauthenticated,
  error,
}

class SplashNotifier extends StateNotifier<SplashState> {
  SplashNotifier() : super(SplashState.initializing);

  Future<void> initializeApp() async {
    try {
      state = SplashState.initializing;

      // Simulate initialization delay for demo purposes
      await Future.delayed(const Duration(milliseconds: 2000));

      // Here you would typically:
      // 1. Check if the user is logged in
      // 2. Load any required app settings
      // 3. Initialize required services
      // 4. Check if it's first run and show onboarding if needed

      // For now we'll just simulate success
      state = SplashState.authenticated;

      // If you need to handle login flow:
      // state = isLoggedIn ? SplashState.authenticated : SplashState.unauthenticated;
    } catch (e) {
      state = SplashState.error;
    }
  }
}

final splashProvider =
    StateNotifierProvider<SplashNotifier, SplashState>((ref) {
  return SplashNotifier();
});

// Optional: Create a provider for tracking initialization progress
class InitProgress {

  InitProgress({this.progress = 0.0, this.message = 'Loading...'});
  final double progress;
  final String message;
}

final initProgressProvider = StateProvider<InitProgress>((ref) {
  return InitProgress();
});
