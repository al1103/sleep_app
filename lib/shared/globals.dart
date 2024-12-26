import 'dart:io';

import 'package:flutter/material.dart';

final kTestMode = Platform.environment.containsKey('FLUTTER_TEST');
// ignore: constant_identifier_names
const String USER_LOCAL_STORAGE_KEY = 'user';
// ignore: constant_identifier_names
const String ACCESS_TOKEN_LOCAL_STORAGE_KEY = 'access_token';
// ignore: constant_identifier_names
const String REFRESH_TOKEN_LOCAL_STORAGE_KEY = 'refresh_token';
// ignore: constant_identifier_names
const String APP_THEME_STORAGE_KEY = 'AppTheme';
// ignore: constant_identifier_names
const String CACHED_VEHICLE_KEY = 'vehicles';

class GlobalKeys {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}
