import 'package:deep_pick/deep_pick.dart';
import 'package:sleep/common/constants/keys.dart';

class ApiException implements Exception {
  ApiException(this.statusCode, this.message);

  ApiException.fromJson(Map<String, dynamic>? json)
      : statusCode = pick(json, Keys.statusCode).asIntOrNull() ?? -1,
        message = pick(json, Keys.message).asStringOrNull() ?? '';

  final int statusCode;
  final String message;

  @override
  String toString() {
    return message.isEmpty ? 'Something went wrong' : message;
  }
}
