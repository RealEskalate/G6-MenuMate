import 'package:flutter/material.dart';
import 'package:dinq/core/util/theme.dart';
import 'package:dinq/features/DineQ_App/auth/presentation/Pages/login_page.dart';
import 'package:dinq/features/DineQ_App/auth/presentation/Pages/onboarding2_page.dart';
import 'package:dinq/features/DineQ_App/auth/presentation/Pages/onboarding_first.dart';
class OnboardingThirdPage extends StatelessWidget {
  const OnboardingThirdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 30),
              
              // Image with cute decoration
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    "assets/images/image1.png",
                    width: 300,
                    height: 280,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Title with cute styling
              Text(
                "Bring your menu to life!",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                  color: Colors.black,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 20),
              
              // Description with cute styling
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Upload your menu, share your QR code, and make it easy for customers to explore what you serve.",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Inter',
                    color: AppColors.secondaryColor,
                    fontSize: 16,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Button with cute styling
              GestureDetector(
                onTap: () {
                  // Add navigation logic here if needed
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: Container(
                  width: 300,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      "Continue ->",
                      style: TextStyle(
                        color: AppColors.whiteColor,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
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
                      width: 12,
                      height: 12,
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
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}