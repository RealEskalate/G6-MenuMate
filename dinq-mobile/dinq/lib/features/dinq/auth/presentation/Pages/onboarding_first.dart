import 'package:flutter/material.dart';

import '../../../../../core/util/theme.dart';
import 'onboarding2_page.dart';
import 'onboarding3.dart';

class OnboardingFirst extends StatelessWidget {
  const OnboardingFirst({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.08),
                // First logo with safe animation - responsive sizing
                _buildSafeAnimatedLogo(
                  'assets/images/logo.png',
                  screenWidth * 0.45, // 45% of screen width
                  screenWidth * 0.45, // 45% of screen width
                  0, // delay
                ),
                // Second logo with safe animation - responsive sizing
                _buildSafeSlideUpLogo(
                  'assets/images/logo2.png',
                  screenWidth * 0.5, // 50% of screen width
                  screenWidth * 0.25, // 25% of screen width
                  400, // delay
                ),
                SizedBox(height: screenHeight * 0.1),
                // Custom Get Started button - responsive sizing
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const OnboardingSecondPage()),
                    );
                  },
                  child: Container(
                    width: screenWidth * 0.8, // 80% of screen width
                    height: isSmallScreen ? 45 : 50,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'Get Started',
                        style: TextStyle(
                          color: AppColors.whiteColor,
                          fontWeight: FontWeight.normal,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.06),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const OnboardingFirst()),
                        );
                      },
                      child: Container(
                        width: isSmallScreen ? 10 : 12,
                        height: isSmallScreen ? 10 : 12,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.3),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryColor.withOpacity(0.4),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),

                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const OnboardingSecondPage()),
                        );
                      },
                      child: Container(
                        width: isSmallScreen ? 14 : 16,
                        height: isSmallScreen ? 14 : 16,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondaryColor.withOpacity(0.4),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const OnboardingThirdPage()),
                        );
                      },
                      child: Container(
                        width: isSmallScreen ? 10 : 12,
                        height: isSmallScreen ? 10 : 12,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryColor.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Safe fade animation with scaling for the first logo
  Widget _buildSafeAnimatedLogo(
    String asset,
    double width,
    double height,
    int delay,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 1000 + delay),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        // Clamp the value to ensure it stays within [0, 1]
        final clampedValue = value.clamp(0.0, 1.0);
        return Opacity(
          opacity: clampedValue,
          child: Transform.scale(
            scale: 0.8 + (clampedValue * 0.2),
            child: Transform.rotate(
              angle: (1 - clampedValue) * 0.1,
              child: child,
            ),
          ),
        );
      },
      child: Image.asset(
        asset,
        width: width,
        height: height,
        fit: BoxFit.contain,
      ),
    );
  }

  // Safe slide-up animation for the second logo
  Widget _buildSafeSlideUpLogo(
    String asset,
    double width,
    double height,
    int delay,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 800 + delay),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        // Clamp the value to ensure it stays within [0, 1]
        final clampedValue = value.clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(0, (1 - clampedValue) * 100),
          child: Opacity(
            opacity: clampedValue,
            child: Transform.scale(
              scale: 0.7 + (clampedValue * 0.3),
              child: child,
            ),
          ),
        );
      },
      child: Image.asset(
        asset,
        width: width,
        height: height,
        fit: BoxFit.contain,
      ),
    );
  }
}
