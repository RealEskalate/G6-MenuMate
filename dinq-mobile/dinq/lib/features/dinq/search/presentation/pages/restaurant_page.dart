import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/util/theme.dart';
import '../../../restaurant_management/domain/entities/item.dart' as itemmodels;
import '../../../restaurant_management/domain/entities/restaurant.dart';
import '../../../restaurant_management/presentation/bloc/restaurant_bloc.dart';
import '../../../restaurant_management/presentation/bloc/restaurant_event.dart';
import '../../../restaurant_management/presentation/bloc/restaurant_state.dart';
import 'item_details_page.dart';

class RestaurantPage extends StatefulWidget {
  final Restaurant restaurant;
  const RestaurantPage({super.key, required this.restaurant});

  @override
  State<RestaurantPage> createState() =>
      _RestaurantPageState(restaurant: restaurant);
}

class _RestaurantPageState extends State<RestaurantPage> {
  final Restaurant restaurant;

  _RestaurantPageState({required this.restaurant});

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    try {
      final menuResult = await _getMenuUseCase.execute(widget.restaurantId);
      menuResult.fold(
        (failure) {
          setState(() {
            _isLoading = false;
            // Handle failure
          });
        },
        (menuData) {
          setState(() {
            _menu = menuData;
            _isLoading = false;
            _tabController = TabController(length: menuData.tabs.length, vsync: this);
          });
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  List<models.Restaurant> get allRestaurants => [
    // When creating a Restaurant for UI display:
    models.Restaurant(
      id: widget.restaurantId,
      name: 'Bella Italia',
      bannerUrl:
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80',
      verificationStatus:
          models.VerificationStatus.verified, // required, pick any
      contact: models.Contact(
        phone: '',
        email: '',
        social: [],
      ), // required, dummy
      ownerId: '',
      branchIds: [],
      averageRating: 4.8,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  List<models.Item> get allDishes {
    if (_menu == null) return [];
    return _menu!.tabs
        .expand((tab) => tab.categories)
        .expand((cat) => cat.items)
        .toList();
  }

  @override
  void dispose() {
    if (_menu != null) {
      _tabController.dispose();
    }
    super.dispose();
=======
    // Ask the RestaurantBloc to load the menu for this restaurant
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final slug = widget.restaurant.slug;
      context.read<RestaurantBloc>().add(LoadMenu(restaurantSlug: slug));
    });
>>>>>>> origin/mite-test
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
<<<<<<< HEAD
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildRestaurantHeader(),
              _buildTabBar(),
              SizedBox(
                height: 600, // Fixed height for tab content
                child: TabBarView(
                  controller: _tabController,
                  children: _menu!.tabs
                      .map((menuTab) => _buildTabContent(menuTab))
                      .toList(),
                ),
=======
        child: Column(
          children: [
            _buildRestaurantHeader(restaurant),

            // Menu section
            Expanded(
              child: BlocBuilder<RestaurantBloc, RestaurantState>(
                builder: (context, state) {
                  if (state is RestaurantLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is RestaurantError) {
                    return Center(child: Text(state.message));
                  } else if (state is MenuLoaded) {
                    return ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: state.menu.items.length,
                      itemBuilder: (context, index) {
                        final item = state.menu.items[index];
                        return _buildMenuItem(item);
                      },
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
>>>>>>> origin/mite-test
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRestaurantHeader(Restaurant restaurant) {
    // Fallback cover image
    String bannerUrl = restaurant.coverImage ??
        'https://plus.unsplash.com/premium_photo-1661883237884-263e8de8869b?q=80&w=889&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banner
        SizedBox(
          height: 260,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                bannerUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: Colors.grey[300]),
              ),

              // Gradient overlay
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black54, Colors.transparent],
                  ),
                ),
              ),

              // Top actions
              SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _circleIcon(
                        icon: Icons.arrow_back,
                        onTap: () => Navigator.pop(context),
                      ),
                      _circleIcon(icon: Icons.share_outlined, onTap: () {}),
                    ],
                  ),
                ),
              ),

              // Restaurant name
              Positioned(
                left: 16,
                bottom: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
<<<<<<< HEAD
                      'Bella Italia',
                      style: TextStyle(
=======
                      restaurant.restaurantName,
                      style: const TextStyle(
>>>>>>> origin/mite-test
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
<<<<<<< HEAD
                    SizedBox(height: 4),
                    Text(
                      'Authentic Italian cuisine',
=======
                    const SizedBox(height: 4),
                    const Text(
                      'Traditional Ethiopian cuisine',
>>>>>>> origin/mite-test
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Info card
        Transform.translate(
          offset: const Offset(0, -20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildRestaurantInfoCard(),
          ),
        ),

        const SizedBox(height: 4),

        // Menu header row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Digital Menu',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                ),
                icon: const Icon(Icons.translate_rounded, color: Colors.white),
                onPressed: () {},
                label: const Text(
                  'Translate',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildRestaurantInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.location_on, color: Colors.orange, size: 16),
                SizedBox(width: 6),
                Expanded(child: Text('Bole Atlas, Addis Ababa')),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.access_time, color: Colors.orange, size: 16),
                SizedBox(width: 6),
                Expanded(child: Text('Open: 11:00 AM - 10:00 PM')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.orange, size: 16),
                const SizedBox(width: 4),
                const Text(
                  '4.8',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 6),
                const Text('(142 reviews)'),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: _toggleFavorite,
                  icon: const Icon(Icons.bookmark_border),
                  label: const Text('Save'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleIcon({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.black87),
      ),
    );
  }

  Widget _buildMenuItem(itemmodels.Item item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemDetailsPage(item: item),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.images != null && item.images!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: Image.network(
                  item.images![0],
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[300],
                      child:
                          const Icon(Icons.restaurant, color: Colors.grey),
                    );
                  },
                ),
              )
            else
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: const Icon(Icons.restaurant, color: Colors.grey),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '${item.price.toStringAsFixed(0)} ${item.currency}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    if (item.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.description!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleFavorite() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved to favorites!')),
    );
  }
}
