import 'package:deep_pick/deep_pick.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleep/auth/domain/auth.dart';
import 'package:sleep/auth/domain/auth_repository.dart';
import 'package:sleep/core/infrastructure/datasource/remote/api_service.dart';

part 'auth_repository_impl.g.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this.apiService);

  final ApiService apiService;

  @override
  Future<AuthLogin> signIn(String email, String password) async {
    final response = await apiService.requestPost(
      '/auth/login',
      {'email': email, 'password': password},
      responseFactory: (json) {
        final data = pick(json).asMapOrEmpty<String, dynamic>();
        return AuthLogin.fromJson(data);
      },
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', response.data?.userId?.toString() ?? '');
    return response;
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
  }

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }
}

@Riverpod(keepAlive: true)
// ignore: deprecated_member_use_from_same_package
AuthRepository authRepository(AuthRepositoryRef ref) =>
    AuthRepositoryImpl(ref.read(apiServiceProvider));
