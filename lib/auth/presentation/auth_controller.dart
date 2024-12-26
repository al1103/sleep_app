import 'package:sleep/auth/domain/auth.dart';
import 'package:sleep/auth/infrastructure/auth_repository_impl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<AuthLogin?> build() {
    return null;
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response =
          await ref.read(authRepositoryProvider).signIn(email, password);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', response.accessToken ?? '');
      await prefs.setString('userId', response.data?.userId?.toString() ?? '');
      return response;
    });
  }
}
