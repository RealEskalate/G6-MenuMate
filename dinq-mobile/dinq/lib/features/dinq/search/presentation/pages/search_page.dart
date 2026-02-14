import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/util/theme.dart';

import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/restaurant_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // ensure search state is cleared when opening the search page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeBloc>().add(ClearSearch());
    });
  }

  @override
  void dispose() {
    // clear search state when leaving
    context.read<HomeBloc>().add(ClearSearch());
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _controller,
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search restaurants or dishes',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _controller.clear();
                            context.read<HomeBloc>().add(ClearSearch());
                            setState(() {});
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: AppColors.primaryColor.withOpacity(0.6),
                        width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.primaryColor, width: 2),
                  ),
                ),
                onChanged: (q) {
                  context.read<HomeBloc>().add(SearchQueryChanged(q));
                  setState(() {});
                },
                onSubmitted: (q) {
                  // run search immediately on submit
                  context.read<HomeBloc>().add(SearchQueryChanged(q));
                },
              ),
            ),

            // results
            Expanded(
              child: BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  if (state.status == HomeStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.status == HomeStatus.error) {
                    return Center(child: Text(state.errorMessage ?? 'Error'));
                  }

                  // show results only when a query exists — otherwise show a prompt
                  if (state.query.isEmpty) {
                    return Center(
                      child: Text(
                        'Type to search',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    );
                  }

                  final items = state.restaurants;
                  if (state.status == HomeStatus.empty || items.isEmpty) {
                    return const Center(child: Text('No results'));
                  }

                  return ListView.separated(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final r = items[i];
                      return RestaurantCard(
                        imageUrl: (r.logoImage ?? r.coverImage) ?? '',
                        name: r.restaurantName,
                        cuisine: (r.tags != null && r.tags!.isNotEmpty)
                            ? r.tags!.first
                            : '',
                        distance: '',
                        rating: (r.averageRating).toDouble(),
                        reviews: 0,
                        onViewMenu: () {},
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
