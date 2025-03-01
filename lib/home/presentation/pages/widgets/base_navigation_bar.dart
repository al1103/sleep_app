import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleep/home/presentation/controller/bottom_navigation_bar_controller.dart';

class BaseNavigationBar extends ConsumerWidget {
  const BaseNavigationBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigateState = ref.watch(bottomNavigationBarControllerProvider);

    // Define app color scheme
    final Color primaryColor = const Color(0xFF6366F1);
    final Color darkBackgroundColor = const Color(0xFF0F1120);
    final Color activeIconColor = const Color(0xFF6366F1);
    final Color inactiveIconColor = Colors.white54;

    return Container(
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
                isActive: navigateState == 0,
                activeColor: activeIconColor,
                inactiveColor: inactiveIconColor,
                onTap: () {
                  // ref
                  //     .read(bottomNavigationBarControllerProvider.notifier)
                  //     .state = 0;
                  context.router.pushNamed('/home');
                },
              ),
              _buildNavItem(
                icon: Icons.insert_chart_rounded,
                label: 'Stats',
                isActive: navigateState == 1,
                activeColor: activeIconColor,
                inactiveColor: inactiveIconColor,
                onTap: () {
                  // ref
                  //     .read(bottomNavigationBarControllerProvider.notifier)
                  //     .state = 1;
                  context.router.pushNamed('/stats');
                },
              ),
              const SizedBox(width: 10),
              _buildCenterButton(
                context: context,
                color: primaryColor,
              ),
              const SizedBox(width: 10),
              _buildNavItem(
                icon: Icons.spa_rounded,
                label: 'Relax',
                isActive: navigateState == 2,
                activeColor: activeIconColor,
                inactiveColor: inactiveIconColor,
                onTap: () {
                  // ref
                  //     .read(bottomNavigationBarControllerProvider.notifier)
                  //     .state = 2;
                  context.router.pushNamed('/relax');
                },
              ),
              _buildNavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                isActive: navigateState == 3,
                activeColor: activeIconColor,
                inactiveColor: inactiveIconColor,
                onTap: () {
                  // ref
                  //     .read(bottomNavigationBarControllerProvider.notifier)
                  //     .state = 3;
                  context.router.pushNamed('/profile');
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
    );
  }

  Widget _buildCenterButton({
    required BuildContext context,
    required Color color,
  }) {
    return SizedBox(
      height: 60,
      width: 60,
      child: FloatingActionButton(
        onPressed: () {
          context.router.pushNamed('/record');
        },
        backgroundColor: color,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: const Icon(
          Icons.mic,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}
