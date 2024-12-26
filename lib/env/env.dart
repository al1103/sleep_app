import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleep/app.dart';
import 'package:sleep/core/infrastructure/service/local_notify.dart';
import 'package:sleep/env/env_fields.dart';

abstract base class Env implements EnvFields {
  Env() {
    instance = this;
    _init();
  }

  static late Env instance;

  Future<void> _init() async {
    await runZonedGuarded(
      () async {
        WidgetsFlutterBinding.ensureInitialized();

        debugPrint('$appMode ready !!! ');

        if (!kIsWeb) {
          LocalNotificationService.initialize();

          await Firebase.initializeApp(options: firebaseOptions);

          debugPrint(await FirebaseMessaging.instance.getToken());

          FirebaseMessaging.onMessage
              .listen(LocalNotificationService.displayData);
        }

        runApp(ProviderScope(child: App()));
      },
      (error, stackTrace) => debugPrint(error.toString()),
    );
  }
}
