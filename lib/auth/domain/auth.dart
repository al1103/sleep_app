import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth.freezed.dart';
part 'auth.g.dart';

@freezed
class AuthLogin with _$AuthLogin {
  const factory AuthLogin({
    @JsonKey(name: 'message') String? message,
    @JsonKey(name: 'accessToken') String? accessToken,
    @JsonKey(name: 'refreshToken') String? refreshToken,
    @JsonKey(name: 'data') Data? data,
  }) = _AuthLogin;

  factory AuthLogin.fromJson(Map<String, dynamic> json) =>
      _$AuthLoginFromJson(json);
}

@freezed
class Data with _$Data {
  const factory Data({
    @JsonKey(name: 'userId') String? userId,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'username') String? username,
    @JsonKey(name: 'fullName') String? fullName,
    @JsonKey(name: 'avatar') dynamic avatar,
    @JsonKey(name: 'status') String? status,
  }) = _Data;

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);
}
