import 'package:sleep/core/domain/failures.dart';
import 'package:sleep/core/domain/value_object.dart';
import 'package:sleep/core/domain/value_validity.dart';

class RatingValue extends ValueObject<double> {
  factory RatingValue(double? input) => RatingValue._(value: validate(input));

  const RatingValue._({required super.value});

  static ValueValidity<double> validate(double? input) {
    if (input == null) {
      return InvalidValue(
        failure: ValueFailure.empty(failedValue: input),
      );
    }
    if (input > 5) {
      return InvalidValue(
        failure: ValueFailure.numberTooLarge(failedValue: input, max: 5),
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
