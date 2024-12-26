import 'package:firebase_core/firebase_core.dart';

abstract class EnvFields {
  abstract final String appMode;
  abstract final String apiUrl;
  abstract final String apiKey;
  abstract final FirebaseOptions? firebaseOptions;
}
