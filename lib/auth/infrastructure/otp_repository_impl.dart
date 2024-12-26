import 'package:flutter/material.dart';
import 'package:sleep/auth/domain/otp_repository.dart';
import 'package:sleep/core/infrastructure/datasource/remote/api_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'otp_repository_impl.g.dart';

class OtpRepositoryImpl implements OtpRepository {
  OtpRepositoryImpl(this.apiService);
  final ApiService apiService;

  @override
  Future<bool> verificationOtp(String otp) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('temp_register_token');

      if (token == null) {
        throw Exception('Registration token not found');
      }

      final response = await apiService.requestPost(
        '/auth/verify-registration',
        {
          'token': token,
          'code': otp,
        },
        responseFactory: (json) {
          if (json['status'] == 201) {
            // Clear temporary token after successful verification
            prefs.remove('temp_register_token');
            return true;
          }
          throw Exception(json['error'] ?? 'OTP verification failed');
        },
      );

      return response;
    } catch (e) {
      debugPrint('OTP Verification Error: $e');
      rethrow;
    }
  }
}

@Riverpod(keepAlive: true)
OtpRepository otpRepository(OtpRepositoryRef ref) {
  return OtpRepositoryImpl(ref.watch(apiServiceProvider));
}
