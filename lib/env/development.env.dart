import 'package:envied/envied.dart';
import 'package:sleep/env/env.dart';
import 'package:sleep/firebase_options_dev.dart';

part 'development.env.g.dart';

@Envied(name: 'Env', path: '.env/.development.env')
final class DevelopmentEnv extends Env {
  @override
  @EnviedField(varName: 'APP_MODE')
  final appMode = _Env.appMode;

  @override
  @EnviedField(varName: 'API_KEY', obfuscate: true)
  final apiKey = _Env.apiKey;

  @override
  @EnviedField(varName: 'API_URL')
  final apiUrl = _Env.apiUrl;

  @override
  final firebaseOptions = DefaultFirebaseOptions.currentPlatform;
}
