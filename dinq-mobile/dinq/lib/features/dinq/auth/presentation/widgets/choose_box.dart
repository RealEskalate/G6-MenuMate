import 'package:flutter/material.dart';
import '../../../../../core/util/theme.dart';

class ChooseBox extends StatelessWidget {
  final String category;
  final String explanation;
  final IconData icon; // Keeping this parameter if you need it for other purposes

  const ChooseBox({
    super.key,
    required this.category,
    required this.explanation,
    required this.icon

  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // ontap
      child: Container(
        width: 370,
        height:150,
        decoration: BoxDecoration(
          color: Colors.white, // Changed to white background
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon with background for better visibility
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryColor,
                  )
                ),
                child: Icon(
                  icon, // Changed to human icon
                  size: 40,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      category,
                      style: const TextStyle(
                        color: AppColors.secondaryColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      explanation,
                      style: TextStyle(
                        color: AppColors.secondaryColor.withOpacity(0.8),
                        fontSize: 14,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
      ),
    );
  }
}