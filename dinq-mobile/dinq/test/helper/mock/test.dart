import 'package:dinq/core/network/network_info.dart';
import 'package:dinq/features/dinq/restaurant_management/data/datasources/restaurant_remote_data_source.dart';
import 'package:dinq/features/dinq/restaurant_management/domain/repositories/restaurant_repository.dart';
import 'package:dio/dio.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([RestaurantRepository, RestaurantRemoteDataSource, NetworkInfo, Dio])
void main() {}
