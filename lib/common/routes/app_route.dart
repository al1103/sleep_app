import 'package:alarm/model/alarm_settings.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:sleep/auth/presentation/pages/otp_verification.dart';
import 'package:sleep/auth/presentation/pages/sign_in_page.dart';
import 'package:sleep/auth/presentation/pages/sign_up_page.dart';
import 'package:sleep/common/routes/route_path.dart';
import 'package:sleep/home/presentation/pages/home.dart';
import 'package:sleep/home/presentation/pages/record/record.dart';
import 'package:sleep/home/presentation/pages/relax.dart';
import 'package:sleep/home/presentation/pages/ring.dart';
import 'package:sleep/home/presentation/pages/stats.dart';
import 'package:sleep/splash/presentation/pages/splash_page.dart';

part 'app_route.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        // Set splash as initial route
        AutoRoute(
          page: SplashRoute.page,
          path: RoutePath.splash,
          initial: true,
        ),
        AutoRoute(
          page: SignInRoute.page,
          path: RoutePath.signIn,
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
        AutoRoute(
          page: RecordRoute.page,
          path: RoutePath.record,
        ),
        AutoRoute(
          page: StatsRoute.page,
          path: RoutePath.stats,
        ),
        AutoRoute(
          page: StatsRoute.page,
          path: RoutePath.stats,
        ),
        AutoRoute(
          page: RelaxRoute.page,
          path: RoutePath.releax,
        ),
        AutoRoute(page: AlarmRingRoute.page, path: RoutePath.alarmRing),
      ];
}

class $AppRouter {}
