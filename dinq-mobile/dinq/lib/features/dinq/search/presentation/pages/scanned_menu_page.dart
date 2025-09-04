import '../widgets/scanned_menu.dart';
import 'package:flutter/material.dart';
import '../../../../../core/util/theme.dart';
import '../widgets/bottom_navbar.dart';

class ScannedMenuPage extends StatelessWidget {
  const ScannedMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Menu Preview',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Restaurant Info
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
                child: const Icon(Icons.restaurant_menu, color: AppColors.primaryColor, size: 32),
              ),
              const SizedBox(width: 14),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bella Vista',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Italian Restaurant',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEAEAEA)),
          const SizedBox(height: 18),

          // Appetizers Section
          const _SectionHeader(
            icon: Icons.emoji_food_beverage,
            label: 'Appetizers',
          ),
          const SizedBox(height: 10),
          const MenuItemCard(
            imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80',
            name: 'Bruschetta Classica',
            price: '350br',
            description: 'Fresh tomatoes, basil, garlic on toasted bread',
          ),
          const MenuItemCard(
            imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80',
            name: 'Antipasto Misto',
            price: '300br',
            description: 'Selection of cured meats, cheese, and olives',
          ),
          const SizedBox(height: 18),

          // Main Courses Section
          const _SectionHeader(
            icon: Icons.local_pizza,
            label: 'Main Courses',
          ),
          const SizedBox(height: 10),
          const MenuItemCard(
            imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80',
            name: 'Spaghetti Carbonara',
            price: '560br',
            description: 'Traditional Roman pasta with eggs, pancetta, and pecorino',
          ),
          const MenuItemCard(
            imageUrl: 'https://images.unsplash.com/photo-1542281286-9e0a16bb7366?auto=format&fit=crop&w=400&q=80',
            name: 'Pizza Margherita',
            price: '670br',
            description: 'San Marzano tomatoes, fresh mozzarella, basil',
          ),
          const MenuItemCard(
            imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80',
            name: 'Grilled Salmon',
            price: '\$22.00',
            description: 'Atlantic salmon with seasonal vegetables and lemon',
          ),
          const SizedBox(height: 18),

          // Desserts Section
          const _SectionHeader(
            icon: Icons.icecream,
            label: 'Desserts',
          ),
          const SizedBox(height: 10),
          const MenuItemCard(
            imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80',
            name: 'Tiramisu',
            price: '\$7.50',
            description: 'Classic Italian dessert with mascarpone and coffee',
          ),
          const MenuItemCard(
            imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80',
            name: 'Panna Cotta',
            price: '\$6.50',
            description: 'Vanilla cream dessert with mixed berry coulis',
          ),
          const SizedBox(height: 24),
          // Save & Share Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.share, color: Colors.white),
              label: const Text(
                'Save & Share Digital Menu',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              onPressed: () {
                // TODO: Implement share functionality
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedTab: BottomNavTab.explore,
        onTabSelected: (tab) {
          // Implement navigation if needed
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryColor, size: 22),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

