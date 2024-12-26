import 'package:flutter/material.dart';
import 'package:sleep/auth/domain/auth_register.dart';
import 'package:sleep/auth/domain/auth_register_repository.dart';
import 'package:sleep/core/infrastructure/datasource/remote/api_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_register_repository_impl.g.dart';

class AuthRegisterRepositoryImpl implements AuthRegisterRepository {
  AuthRegisterRepositoryImpl(this.apiService);
  final ApiService apiService;
  @override
  Future<AuthRegister?> registerUser({
    required String username,
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiService.requestPost(
        '/auth/register',
        {
          'username': username,
          'email': email,
          'password': password,
          'fullName': fullName,
        },
        responseFactory: (json) {
          // Handle both success and error cases from backend
          return AuthRegister(
            status: json['status'] as int?,
            message: json['message'] as String?,
            token: json['token'] as String?,
          );
        },
      );

      if (response.token != null) {
        // Store token for OTP verification
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('temp_register_token', response.token!);
      }

      return response;
    } catch (e) {
      debugPrint('Register Error: $e');
      return null;
    }
  }
}

@Riverpod(keepAlive: true)
AuthRegisterRepository authRegisterRepository(AuthRegisterRepositoryRef ref) {
  return AuthRegisterRepositoryImpl(ref.watch(apiServiceProvider));
}
