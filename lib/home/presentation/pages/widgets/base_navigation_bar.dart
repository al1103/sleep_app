import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleep/home/presentation/controller/bottom_navigation_bar_controller.dart';
import 'package:sleep/shared/app_contans.dart';

class BaseNavigationBar extends ConsumerWidget {
  const BaseNavigationBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigateState = ref.watch(bottomNavigationBarControllerProvider);

    // Define app color scheme
    const primaryColor = Color(0xFF6366F1);
    const darkBackgroundColor = Color(0xFF0F1120);
    const activeIconColor = Color(0xFF6366F1);
    const inactiveIconColor = Colors.white54;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: darkBackgroundColor.withOpacity(0.95),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomAppBar(
          color: Colors.transparent,
          elevation: 0,
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          notchMargin: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.nightlight_rounded,
                label: 'Sleep',
                isActive: navigateState == BottomNavigationEnumType.home,
                activeColor: activeIconColor,
                inactiveColor: inactiveIconColor,
                onTap: () {
                  // Only navigate if not already on this tab
                  if (navigateState != BottomNavigationEnumType.home) {
                    ref
                        .read(bottomNavigationBarControllerProvider.notifier)
                        .state = BottomNavigationEnumType.home;
                    context.router.pushNamed('/home');
                  }
                },
              ),
              _buildNavItem(
                icon: Icons.insert_chart_rounded,
                label: 'Stats',
                isActive: navigateState == BottomNavigationEnumType.stats,
                activeColor: activeIconColor,
                inactiveColor: inactiveIconColor,
                onTap: () {
                  // Only navigate if not already on this tab
                  if (navigateState != BottomNavigationEnumType.stats) {
                    ref
                        .read(bottomNavigationBarControllerProvider.notifier)
                        .state = BottomNavigationEnumType.stats;
                    context.router.pushNamed('/stats');
                  }
                },
              ),
              _buildNavItem(
                icon: Icons.spa_rounded,
                label: 'Relax',
                isActive: navigateState == BottomNavigationEnumType.relax,
                activeColor: activeIconColor,
                inactiveColor: inactiveIconColor,
                onTap: () {
                  // Only navigate if not already on this tab
                  if (navigateState != BottomNavigationEnumType.relax) {
                    ref
                        .read(bottomNavigationBarControllerProvider.notifier)
                        .state = BottomNavigationEnumType.relax;
                    context.router.pushNamed('/relax');
                  }
                },
              ),
              _buildNavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                isActive: navigateState == BottomNavigationEnumType.profile,
                activeColor: activeIconColor,
                inactiveColor: inactiveIconColor,
                onTap: () {
                  // Only navigate if not already on this tab
                  if (navigateState != BottomNavigationEnumType.profile) {
                    ref
                        .read(bottomNavigationBarControllerProvider.notifier)
                        .state = BottomNavigationEnumType.profile;
                    context.router.pushNamed('/profile');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required Color activeColor,
    required Color inactiveColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimationConfiguration(
        isActive: isActive,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: isActive ? activeColor.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? activeColor : inactiveColor,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? activeColor : inactiveColor,
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Optional animation helper class
class AnimationConfiguration extends StatelessWidget {

  const AnimationConfiguration({
    required this.isActive,
    required this.child,
    super.key,
  });
  final bool isActive;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
