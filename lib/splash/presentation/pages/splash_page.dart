import 'dart:async';
import 'dart:ui';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  // UI colors - matching the app's color palette
  final Color _primaryColor = const Color(0xFF6366F1); // Modern indigo
  final Color _darkBackgroundColor = const Color(0xFF0F1120); // Dark blue-black
  final Color _accentColor = const Color(0xFF22C55E); // Vibrant green
  final Color _tertiaryAccent = const Color(0xFFF59E0B); // Vibrant amber

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0, 0.5, curve: Curves.easeInOut),
    ),);

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0, 0.8, curve: Curves.easeOutCubic),
    ),);

    // Start animation and navigate after delay
    _animationController.forward();

    Timer(const Duration(milliseconds: 3000), () {
      // Navigate to the home screen
      context.router.replaceNamed('/home');
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBackgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background decorative elements
          Positioned(
            right: -50,
            top: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _primaryColor.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: 100,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accentColor.withOpacity(0.05),
              ),
            ),
          ),

          // Stars decoration
          Positioned(
            right: 80,
            top: 150,
            child: Icon(
              Icons.star,
              color: Colors.white.withOpacity(0.2),
              size: 14,
            ),
          ),
          Positioned(
            left: 120,
            top: 220,
            child: Icon(
              Icons.star,
              color: Colors.white.withOpacity(0.15),
              size: 10,
            ),
          ),
          Positioned(
            right: 150,
            bottom: 250,
            child: Icon(
              Icons.star,
              color: Colors.white.withOpacity(0.1),
              size: 16,
            ),
          ),

          // Main content
          Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: child,
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App icon/logo with gradient
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _primaryColor,
                          Color.lerp(_primaryColor, _tertiaryAccent, 0.6)!,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _primaryColor.withOpacity(0.3),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: const Center(
                          child: Icon(
                            Icons.nights_stay,
                            color: Colors.white,
                            size: 60,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // App name with animated shimmer
                  ShimmerText(
                    text: 'Sleep Tracker',
                    startColor: Colors.white,
                    endColor: Colors.white.withOpacity(0.5),
                    textStyle: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tagline
                  Text(
                    'Better sleep for a better you',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Loading indicator
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                      strokeWidth: 3,
                      backgroundColor: _primaryColor.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Version info at bottom
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Shimmer text effect for the app title
class ShimmerText extends StatefulWidget {

  const ShimmerText({
    required this.text,
    required this.startColor,
    required this.endColor,
    required this.textStyle,
    super.key,
  });
  final String text;
  final Color startColor;
  final Color endColor;
  final TextStyle textStyle;

  @override
  State<ShimmerText> createState() => _ShimmerTextState();
}

class _ShimmerTextState extends State<ShimmerText>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [widget.startColor, widget.endColor, widget.startColor],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: SlidingGradientTransform(
                slidePercent: _shimmerController.value,
              ),
            ).createShader(bounds);
          },
          child: Text(
            widget.text,
            style: widget.textStyle.copyWith(color: Colors.white),
          ),
        );
      },
    );
  }
}

// Helper class for shimmer animation
class SlidingGradientTransform extends GradientTransform {

  const SlidingGradientTransform({
    required this.slidePercent,
  });
  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
      bounds.width * (slidePercent - 0.5) * 2,
      0,
      0,
    );
  }
}
