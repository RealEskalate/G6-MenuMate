import 'package:dinq/features/dinq/search/domain/entities/Restaurant.dart'
    as models;
import 'package:dinq/features/dinq/search/presentation/widgets/bottom_navbar.dart';
import 'package:flutter/material.dart';
import '../../../../../core/util/theme.dart';
import '../../../search/domain/entities/menu.dart' as models;
import '../../../search/domain/usecases/get_menu.dart';
import 'item_details_page.dart';

class _FavoritesStore {
  static final Set<String> restaurantIds = <String>{};
  static final Set<String> dishIds = <String>{};
}

class RestaurantPage extends StatefulWidget {
  final String restaurantId;

  const RestaurantPage({Key? key, required this.restaurantId})
    : super(key: key);

  @override
  State<RestaurantPage> createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final GetMenuUseCase _getMenuUseCase = GetMenuUseCase();
  models.Menu? _menu;
  bool _isLoading = true;
  static final Set<String> _favoriteRestaurantIds = {}; // For UI only

  void _toggleFavorite() {
    setState(() {
      if (_FavoritesStore.restaurantIds.contains(widget.restaurantId)) {
        _FavoritesStore.restaurantIds.remove(widget.restaurantId);
      } else {
        _FavoritesStore.restaurantIds.add(widget.restaurantId);
      }
    });
  }

  void _onTabSelected(BottomNavTab tab) {
    if (tab == BottomNavTab.explore) {
      Navigator.pushReplacementNamed(context, '/explore');
    } else if (tab == BottomNavTab.favorites) {
      Navigator.pushReplacementNamed(
        context,
        '/favorites',
        arguments: {'allRestaurants': allRestaurants, 'allDishes': allDishes},
      );
    } else if (tab == BottomNavTab.profile) {
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    try {
      final menu = await _getMenuUseCase.execute(widget.restaurantId);
      setState(() {
        _menu = menu;
        _isLoading = false;
        _tabController = TabController(length: menu.tabs.length, vsync: this);
      });
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
      name: "Addis Red Sea",
      bannerUrl:
          "https://plus.unsplash.com/premium_photo-1661883237884-263e8de8869b?q=80&w=889&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      verificationStatus:
          models.VerificationStatus.verified, // required, pick any
      contact: models.Contact(
        phone: '',
        email: '',
        social: [],
      ), // required, dummy
      ownerId: '',
      branchIds: [],
      averageRating: 4.5,
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
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        ),
      );
    }

    if (_menu == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Menu'),
          backgroundColor: AppColors.primaryColor,
        ),
        body: const Center(child: Text('Failed to load menu')),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildRestaurantHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _menu!.tabs
                    .map((menuTab) => _buildTabContent(menuTab))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedTab: BottomNavTab.explore,
        onTabSelected: _onTabSelected,
      ),
    );
  }

  Widget _buildRestaurantHeader() {
    // If you later add a real banner image to your model, use it here.
    const String bannerUrl =
        'https://plus.unsplash.com/premium_photo-1661883237884-263e8de8869b?q=80&w=889&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'; // fallback

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banner + overlays
        SizedBox(
          height: 260,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Banner image
              ClipRRect(
                child: Image.network(
                  bannerUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: Colors.grey[300]),
                ),
              ),

              // Bottom gradient for text readability
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black54, Colors.transparent],
                  ),
                ),
              ),

              // Top actions (back / share)
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 8.0,
                  ),
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

              // Name + subtitle (bottom-left)
              Positioned(
                left: 16,
                bottom: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Addis Red Sea',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Traditional Ethiopian cuisine',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        // Floating info card overlapping the banner bottom
        Transform.translate(
          offset: const Offset(0, -20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildRestaurantInfoCard(),
          ),
        ),

        const SizedBox(height: 4),

        // Digital Menu row (kept as-is, just placed after the card)
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
            Row(
              children: const [
                Icon(Icons.location_on, color: Colors.orange, size: 16),
                SizedBox(width: 6),
                Expanded(child: Text('Bole Atlas, Addis Ababa')),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
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
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: const [
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

  Widget _buildTabBar() {
    return Container(
      height: 50,
      decoration: const BoxDecoration(color: Colors.white),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.black,
        indicator: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(25),
        ),
        tabs: _menu!.tabs.map((menuTab) {
          return Tab(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(child: Text(menuTab.name)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent(models.Tab menuTab) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: menuTab.categories.length,
      itemBuilder: (context, index) {
        final category = menuTab.categories[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (category.name != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  category.name!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ...category.items.map((item) => _buildMenuItem(item)).toList(),
          ],
        );
      },
    );
  }

  Widget _buildMenuItem(models.Item item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ItemDetailsPage(item: item)),
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
                      child: const Icon(Icons.restaurant, color: Colors.grey),
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
}
