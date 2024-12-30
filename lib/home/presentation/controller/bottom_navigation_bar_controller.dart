import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sleep/shared/app_contans.dart';

part 'bottom_navigation_bar_controller.g.dart';

@riverpod
class BottomNavigationBarController extends _$BottomNavigationBarController {
  @override
  BottomNavigationEnumType build() {
    return BottomNavigationEnumType.home;
  }

  void changeTab(BottomNavigationEnumType tab) {
    state = tab;
  }
}
