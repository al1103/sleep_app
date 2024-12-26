import 'package:sleep/core/domain/failures.dart';
import 'package:sleep/core/domain/value_object.dart';
import 'package:sleep/core/domain/value_validity.dart';

class Email extends ValueObject<String> {
  factory Email(String? input) => Email._(value: validate(input));

  const Email._({required super.value});

  static ValueValidity<String> validate(String? input) {
    if (input == null) {
      return InvalidValue(
        failure: ValueFailure.empty(failedValue: input),
      );
    }
    const emailRegex =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    if (!RegExp(emailRegex).hasMatch(input)) {
      return InvalidValue(
        failure: ValueFailure.invalidEmail(failedValue: input),
      );
    }

    return ValidValue(data: input);
  }
}

class Password extends ValueObject<String> {
  factory Password(String? input) => Password._(value: validate(input));

  const Password._({required super.value});

  static ValueValidity<String> validate(String? input) {
    if (input == null) {
      return InvalidValue(
        failure: ValueFailure.empty(failedValue: input),
      );
    }
    if (input.length < 7) {
      return InvalidValue(
        failure: ValueFailure.shortPassword(failedValue: input, min: 7),
      );
    }

    return ValidValue(data: input);
  }
}

class Username extends ValueObject<String> {
  factory Username(String? input) => Username._(value: validate(input));

  const Username._({required super.value});

  static ValueValidity<String> validate(String? input) {
    if (input == null) {
      return InvalidValue(
        failure: ValueFailure.empty(failedValue: input),
      );
    }

    return ValidValue(data: input);
  }
}
