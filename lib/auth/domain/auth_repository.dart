import 'package:sleep/auth/domain/auth.dart';

mixin AuthRepository {
  Future<AuthLogin> signIn(String email, String password);
}
