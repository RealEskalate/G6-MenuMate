import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/util/theme.dart';

import '../../../restaurant_management/data/model/category_model.dart';
import '../../../restaurant_management/domain/entities/restaurant.dart';
import '../../../search/presentation/bloc/Menu_bloc/menu_bloc.dart';
import '../../../search/presentation/bloc/Menu_bloc/menu_event.dart';
import '../../../search/presentation/bloc/Menu_bloc/menu_state.dart';
import '../../../search/presentation/pages/item_details_page.dart';
import '../../../search/presentation/widgets/bottom_navbar.dart';

import 'menu_model.dart';
import 'category_model.dart';

class RestaurantPage extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantPage({
    super.key,
    required this.restaurant,
  });

  @override
  State<RestaurantPage> createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage>
    with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    // Load menus from Bloc
    context.read<MenuBloc>().add(LoadListOfMenus(widget.restaurant.slug));
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MenuBloc, MenuState>(
      builder: (context, state) {
        if (state.status == MenuStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status == MenuStatus.error) {
          return Scaffold(
            body: Center(
              child: Text(
                state.errorMessage ?? 'Something went wrong',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        if (state.status == MenuStatus.success) {
          final menus = state.menus;

          // Convert menus into categories (each menu becomes a category)
          final categories = menus
              .map<CategoryModel>((menu) => CategoryModel.fromMenu(menu))
              .toList();

          _tabController ??= TabController(length: categories.length, vsync: this);

          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  _buildBanner(),
                  _buildInfoCard(),
                  _buildTabBar(categories),
                  Expanded(child: _buildTabContent(categories)),
                ],
              ),
            ),
            bottomNavigationBar: BottomNavBar(
              selectedTab: BottomNavTab.explore,
              onTabSelected: (_) {},
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBanner() {
    return SizedBox(
      height: 220,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            widget.restaurant.coverImage ?? '',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black54, Colors.transparent],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _circleIcon(Icons.arrow_back, () => Navigator.pop(context)),
                  _circleIcon(Icons.share, () {}),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: Text(
              widget.restaurant.restaurantName,
              style: const TextStyle(
                  color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text('Bole Atlas, Addis Ababa'),
                SizedBox(height: 4),
                Text('Open: 11:00 AM - 10:00 PM'),
              ]),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.orange),
                  const SizedBox(width: 4),
                  const Text('4.8'),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(List<CategoryModel> categories) {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.black,
      indicator: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(25),
      ),
      tabs: categories
          .map<Widget>((cat) => Tab(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(cat.name),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildTabContent(List<CategoryModel> categories) {
    return TabBarView(
      controller: _tabController,
      children: categories.map<Widget>((cat) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: cat.items.length,
          itemBuilder: (context, idx) {
            final item = cat.items[idx];
            return ItemDetailsPage(item: item);
          },
        );
      }).toList(),
    );
  }

  Widget _circleIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.black87),
      ),
    );
  }
}
