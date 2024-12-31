import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleep/home/presentation/controller/bottom_navigation_bar_controller.dart';

// Generate Bottom Navigation Bar for easy handle
class BaseNavigationBar extends ConsumerWidget {
  const BaseNavigationBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigateState = ref.watch(bottomNavigationBarControllerProvider);
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color.fromARGB(255, 255, 255, 255),
            width: 0.5,
          ),
        ),
      ),
      child: BottomAppBar(
        color: Colors.transparent,
        height: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.home,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.ac_unit_sharp,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.person,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                      onPressed: () {
                        context.router.pushNamed('/record');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
