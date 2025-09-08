import 'package:dinq/core/network/network_info.dart';
import 'package:dinq/features/dinq/restaurant_management/data/datasources/menu/menu_remote_data_source.dart';
import 'package:dinq/features/dinq/restaurant_management/data/datasources/restaurant/restaurant_remote_data_source_restaurant.dart';
import 'package:dinq/features/dinq/restaurant_management/data/datasources/review/review_remote_data_source.dart';
import 'package:dinq/features/dinq/restaurant_management/domain/repositories/menu_repository.dart';
import 'package:dinq/features/dinq/restaurant_management/domain/repositories/restaurant_repository.dart';
import 'package:dinq/features/dinq/restaurant_management/domain/repositories/review_repository.dart';
import 'package:dio/dio.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([
  MenuRepository,
  RestaurantRepository,
  ReviewRepository,
  MenuRemoteDataSource,
  RestaurantRemoteDataSource,
  ReviewRemoteDataSource,
  NetworkInfo,
  Dio,
])
void main() {}
