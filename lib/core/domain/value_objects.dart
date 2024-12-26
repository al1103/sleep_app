import 'package:sleep/core/domain/failures.dart';
import 'package:sleep/core/domain/value_object.dart';
import 'package:sleep/core/domain/value_validity.dart';

class SingleLineText extends ValueObject<String> {
  factory SingleLineText(String? input) =>
      SingleLineText._(value: validate(input));

  const SingleLineText._({required super.value});

  static ValueValidity<String> validate(String? input) {
    if (input == null) {
      return InvalidValue(
        failure: ValueFailure.empty(failedValue: input),
      );
    }
    if (input.contains('\n')) {
      return InvalidValue(
        failure: ValueFailure.multiline(failedValue: input),
      );
    }
    return ValidValue(data: input);
  }
}

class PercentageValue extends ValueObject<double> {
  factory PercentageValue(double? input) =>
      PercentageValue._(value: validate(input));

  const PercentageValue._({required super.value});

  static ValueValidity<double> validate(double? input) {
    if (input == null) {
      return InvalidValue(
        failure: ValueFailure.empty(failedValue: input),
      );
    }
    if (input > 100) {
      return InvalidValue(
        failure: ValueFailure.numberTooLarge(failedValue: input, max: 100),
      );
    }
    if (input < 0) {
      return InvalidValue(
        failure: ValueFailure.numberTooSmall(failedValue: input, min: 0),
      );
    }
    return ValidValue(data: input);
  }
}

class UnsignedIntValue extends ValueObject<int> {
  factory UnsignedIntValue(int? input) =>
      UnsignedIntValue._(value: validate(input));

  const UnsignedIntValue._({required super.value});

  static ValueValidity<int> validate(int? input) {
    if (input == null) {
      return InvalidValue(
        failure: ValueFailure.empty(failedValue: input),
      );
    }
    if (input < 0) {
      return InvalidValue(
        failure: ValueFailure.numberTooSmall(failedValue: input, min: 0),
      );
    }
    return ValidValue(data: input);
  }
}

class UrlString extends ValueObject<String> {
  factory UrlString(String? input) => UrlString._(value: validate(input));

  const UrlString._({required super.value});

  static ValueValidity<String> validate(String? input) {
    if (input == null) {
      return InvalidValue(
        failure: ValueFailure.empty(failedValue: input),
      );
    }
    if (!input.startsWith('http://') && !input.startsWith('https://')) {
      return InvalidValue(
        failure: ValueFailure.invalidUrl(failedValue: input),
      );
    }
    return ValidValue(data: input);
  }
}
