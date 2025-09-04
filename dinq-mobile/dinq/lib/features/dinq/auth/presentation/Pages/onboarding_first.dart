import 'package:flutter/material.dart';
import 'package:dinq/core/util/theme.dart';
import 'package:dinq/features/dinq/auth/presentation/Pages/onboarding2_page.dart';
import 'package:dinq/features/dinq/auth/presentation/Pages/onboarding3.dart';

class OnboardingFirst extends StatelessWidget {
  const OnboardingFirst({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 70),
              // First logo with safe animation
              _buildSafeAnimatedLogo(
                'assets/images/logo.png',
                174,
                174,
                0, // delay
              ),
              // Second logo with safe animation
              _buildSafeSlideUpLogo(
                'assets/images/logo2.png',
                200,
                98,
                400, // delay
              ),
              const SizedBox(height: 90),
              // Custom Get Started button
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OnboardingSecondPage()),
                  );
                },
                child: Container(
                  width: 300,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      "Get Started",
                      style: TextStyle(
                        color: AppColors.whiteColor,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
              ),
              const  SizedBox(height: 50,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OnboardingFirst()),
                      );
                    },
                    child: Container(
                      width: 12,
                      height: 12,
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
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OnboardingSecondPage()),
                      );
                    },
                    child: Container(
                      width: 16,
                      height: 16,
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
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OnboardingThirdPage()),
                      );
                    },
                    child: Container(
                      width: 12,
                      height: 12,
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