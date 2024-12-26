import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_register.freezed.dart';
part 'auth_register.g.dart';

@freezed
class AuthRegister with _$AuthRegister {
  const factory AuthRegister({
    int? status,
    String? message,
    String? token, // Add token field
  }) = _AuthRegister;

  factory AuthRegister.fromJson(Map<String, dynamic> json) =>
      _$AuthRegisterFromJson(json);
}
