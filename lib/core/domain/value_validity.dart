import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sleep/core/domain/failures.dart';

part 'value_validity.freezed.dart';

@freezed
abstract class ValueValidity<T> with _$ValueValidity<T> {
  const factory ValueValidity.valid({required T data}) = ValidValue<T>;
  const factory ValueValidity.invalid({required ValueFailure<T> failure}) =
      InvalidValue<T>;
}
