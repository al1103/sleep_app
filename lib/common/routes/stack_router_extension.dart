import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';

extension StackRouterX on StackRouter {
  @optionalTypeArgs
  Future<T?> replaceAllNamed<T extends Object?>(
    String path, {
    bool includePrefixMatches = false,
    OnNavigationFailure? onFailure,
  }) {
    popUntilRoot();
    return replaceNamed(
      path,
      includePrefixMatches: includePrefixMatches,
      onFailure: onFailure,
    );
  }
}
