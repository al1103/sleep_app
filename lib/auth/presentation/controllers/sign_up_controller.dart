import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sleep/auth/domain/auth_register.dart';
import 'package:sleep/auth/infrastructure/auth_register_repository_impl.dart';

part 'sign_up_controller.g.dart';

@riverpod
class SignUpController extends _$SignUpController {
  @override
  FutureOr<AuthRegister?> build() {
    return null;
  }

  Future<AuthRegister?> signUp({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return ref.read(authRegisterRepositoryProvider).registerUser(
            username: username,
            email: email,
            password: password,
            fullName: fullName,
          );
    });
    return state.value;
  }
}
