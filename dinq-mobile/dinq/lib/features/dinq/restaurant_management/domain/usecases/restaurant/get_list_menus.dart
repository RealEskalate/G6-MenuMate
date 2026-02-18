import 'package:fpdart/fpdart.dart';

import '../../../../../../core/error/failures.dart';
import '../../../../../../core/usecase/usecase.dart';
import '../../../data/model/menu_model.dart';
import '../../../data/model/restaurant_page_response.dart';
import '../../entities/menu.dart';
import '../../repositories/restaurant_repository.dart';

class GetListMenus implements UseCase<RestaurantPageResponse, GetListMenusParams> {
  final RestaurantRepository restaurantRepository;
  const GetListMenus(this.restaurantRepository);
  @override
  Future<Either<Failure, RestaurantPageResponse>> call(GetListMenusParams params) async {
    return await restaurantRepository.getListOfMenus(params.slug);
  }
}

class GetListMenusParams {
  final String slug;
  GetListMenusParams({required this.slug});
}
