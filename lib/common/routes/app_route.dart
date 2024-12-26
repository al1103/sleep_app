import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:sleep/auth/presentation/pages/otp_verification.dart';
import 'package:sleep/auth/presentation/pages/sign_in_page.dart';
import 'package:sleep/auth/presentation/pages/sign_up_page.dart';
import 'package:sleep/common/routes/route_path.dart';
import 'package:sleep/home/presentation/pages/home.dart';

part 'app_route.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: SignInRoute.page,
          path: RoutePath.splash,
          initial: true,
        ),
        AutoRoute(
          page: HomeRoute.page,
          path: RoutePath.home,
        ),
        AutoRoute(
          page: OtpVerificationRoute.page,
          path: RoutePath.otp,
        ),
        AutoRoute(
          page: SignUpRoute.page,
          path: RoutePath.signUp,
        ),
        RedirectRoute(
          path: '*',
          redirectTo: '/',
        ),
      ];
}

class $AppRouter {}
