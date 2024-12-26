import 'package:sleep/auth/domain/auth_register.dart';

abstract class AuthRegisterRepository {
  Future<AuthRegister?> registerUser({
    required String username,
    required String email,
    required String password,
    required String fullName,
  });
}
