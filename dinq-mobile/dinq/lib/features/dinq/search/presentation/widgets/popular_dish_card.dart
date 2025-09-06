import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../restaurant_management/presentation/bloc/restaurant_bloc.dart';
import '../../../restaurant_management/presentation/bloc/restaurant_event.dart';
import '../../../restaurant_management/presentation/bloc/restaurant_state.dart';
import '../../../../../core/routing/app_route.dart';
import 'package:flutter/material.dart';
import '../../../../../core/util/theme.dart';
import '../../../restaurant_management/domain/entities/item.dart';

class PopularDishCard extends StatelessWidget {
  final Item item;

  const PopularDishCard({super.key, required this.item});
  @override
  Widget build(BuildContext context) {
    return BlocListener<RestaurantBloc, RestaurantState>(
      listener: (context, state) {
        if (state is ItemDetailsLoaded) {
          Navigator.pushNamed(
            context,
            AppRoute.itemDetail,
            arguments: {'item': state.itemDetails},
          );
        }
      },
      child: GestureDetector(
        onTap: () {
          context.read<RestaurantBloc>().add(LoadReviews(item.id));
        },
        child: Container(
          width: 140,
          height: 200,
          margin: const EdgeInsets.only(right: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
                child: Image.network(
                  item.images?.isNotEmpty == true
                      ? item.images!.first
                      : 'https://via.placeholder.com/140x100?text=No+Image',
                  height: 100,
                  width: 140,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Restaurant name is not available in Item, so skip or pass as needed
                    if (item.menuSlug.isNotEmpty)
                      Text(
                        item.menuSlug,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item.price.toStringAsFixed(0)} ${item.currency}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                            fontSize: 14,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.orange, size: 15),
                            const SizedBox(width: 2),
                            Text(
                              item.averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
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
