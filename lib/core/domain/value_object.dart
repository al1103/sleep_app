import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sleep/core/domain/failures.dart';
import 'package:sleep/core/domain/value_validity.dart';

mixin Validatable {
  bool isValid();
}

@immutable
abstract class ValueObject<T> implements Validatable {
  const ValueObject({required ValueValidity<T> value}) : _value = value;
  final ValueValidity<T> _value;

  /// The validity must be already checked when calling this method.
  T get value {
    return _value.maybeMap(
      valid: (value) => value.data,
      orElse: () => throw Exception('Object is not valid'),
    );
  }

  /// The validity must be already checked when calling this method.
  ValueFailure<T> get failure {
    return _value.maybeMap(
      invalid: (value) => value.failure,
      orElse: () => throw Exception('Object is valid'),
    );
  }

  @override
  bool isValid() {
    return _value is ValidValue;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ValueObject<T> && other._value == _value;
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() => 'Value($_value)';
}
