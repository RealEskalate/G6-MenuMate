import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../../core/routing/app_route.dart';
import '../../../../../core/util/theme.dart';
import '../../../restaurant_management/data/datasources/restaurant/restaurant_remote_data_source_restaurant.dart';
import '../../../restaurant_management/domain/entities/restaurant.dart';
import '../../../restaurant_management/presentation/bloc/restaurant_bloc.dart';
import '../../../restaurant_management/presentation/bloc/restaurant_event.dart';
import '../../../restaurant_management/presentation/bloc/restaurant_state.dart';
import '../widgets/nearby_restaurant_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Restaurant> _searchResults = [];
  bool _isSearching = false;
  String _currentSearchQuery = '';
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<RestaurantBloc>()
          .add(const LoadRestaurants(page: 1, pageSize: 20));
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _currentSearchQuery = '';
      });
      return;
    }
    _debounceTimer = Timer(const Duration(milliseconds: 400), () async {
      setState(() {
        _isSearching = true;
      });
      try {
        final dataSource = GetIt.instance<RestaurantRemoteDataSource>();
        final results = await dataSource.searchRestaurants(
            name: query, page: 1, pageSize: 20);
        setState(() {
          _searchResults = results;
          _currentSearchQuery = query;
        });
      } catch (e) {
        // ignore for now
      } finally {
        setState(() {
          _isSearching = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // Header & Search
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: const InputDecoration(
                        hintText: 'Search restaurants',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Restaurants list driven by bloc
            Expanded(
              flex: 3,
              child: BlocBuilder<RestaurantBloc, RestaurantState>(
                builder: (context, state) {
                  if (state is RestaurantLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is RestaurantsLoaded) {
                    final list = state.restaurants;

                    // If user is actively searching, show search loader / results
                    if (_isSearching) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (_currentSearchQuery.isNotEmpty) {
                      if (_searchResults.isEmpty) {
                        return Center(
                            child: Text(
                                'No restaurants found for "$_currentSearchQuery"'));
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: _searchResults.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final r = _searchResults[index];
                          return NearbyRestaurantCard(restaurant: r);
                        },
                      );
                    }

                    // Default: show all restaurants from bloc
                    if (list.isEmpty)
                      return const Center(child: Text('No restaurants'));

                    return ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final r = list[index];
                        return NearbyRestaurantCard(restaurant: r);
                      },
                    );
                  } else if (state is RestaurantError) {
                    return Center(child: Text(state.message));
                  }
                  return const Center(child: Text('No data'));
                },
              ),
            ),
            // Popular Dishes placeholder
            const SizedBox(height: 12),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        onPressed: () => Navigator.pushNamed(context, AppRoute.qrcode),
        child: const Icon(Icons.qr_code_scanner, size: 32, color: Colors.white),
      ),
    );
  }
}
