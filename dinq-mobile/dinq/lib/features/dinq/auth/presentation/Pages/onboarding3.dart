import 'package:flutter/material.dart';

import '../../../../../core/routing/app_route.dart';
import '../../../../../core/util/theme.dart';
import 'onboarding2_page.dart';
import 'onboarding_first.dart';
class OnboardingThirdPage extends StatelessWidget {
  const OnboardingThirdPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.04),

              // Image with cute decoration - responsive sizing
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/image1.png',
                    width: screenWidth * 0.8, // 80% of screen width
                    height: screenHeight * 0.35, // 35% of screen height
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.05),

              // Title with cute styling - responsive font size
              Text(
                'Bring your menu to life!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                  color: Colors.black,
                  fontSize: isSmallScreen ? 18 : 20,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: screenHeight * 0.025),

              // Description with cute styling - responsive padding
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: Text(
                  'Upload your menu, share your QR code, and make it easy for customers to explore what you serve.',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Inter',
                    color: AppColors.secondaryColor,
                    fontSize: isSmallScreen ? 14 : 16,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: screenHeight * 0.05),

              // Button with cute styling - responsive sizing
              GestureDetector(
                onTap: () {
                  // Add navigation logic here if needed
                  Navigator.pushNamed(
                    context,
                    AppRoute.mainShell,
                  );
                },
                child: Container(
                  width: screenWidth * 0.8, // 80% of screen width
                  height: isSmallScreen ? 45 : 50,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Continue ->',
                      style: TextStyle(
                        color: AppColors.whiteColor,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.04),

              // Cute decorative dots
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
                      width: isSmallScreen ? 10 : 12,
                      height: isSmallScreen ? 10 : 12,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryColor.withOpacity(0.3),
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
                        MaterialPageRoute(builder: (context) => const OnboardingSecondPage()),
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
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OnboardingThirdPage()),
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
                ],
              ),

              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
