import 'dart:math';

import 'package:sleep/core/domain/value_object.dart';
import 'package:sleep/core/domain/value_validity.dart';

class UniqueId extends ValueObject<String> {
  factory UniqueId() {
    return UniqueId._(value: ValidValue(data: getRandomString()));
  }

  /// Used with strings we trust are unique, such as database IDs.
  factory UniqueId.fromUniqueString(String uniqueIdStr) {
    return UniqueId._(value: ValidValue(data: uniqueIdStr));
  }

  const UniqueId._({required super.value});

  /// Temp method to get a random string
  static String getRandomString() {
    const chars =
        '''AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890''';
    const length = 10;
    final rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
      ),
    );
  }
}
